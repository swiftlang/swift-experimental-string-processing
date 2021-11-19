extension Lexer {
  private static func classifyAsMetaChar(
    _ t: Character, inCustomCharClass: Bool
  ) -> Token.MetaCharacter? {
    guard let mc = Token.MetaCharacter(rawValue: t) else { return nil }

    // Inside a custom character class, the only metacharacters are
    // '[', ']', '^', '-', ':'.
    switch mc {
    case .lsquare:
      // Metacharacters both inside and outside custom character classes.
      break
    case .rsquare, .minus, .colon, .caret:
      // Only metacharacters inside a custom character class. Though colon is
      // only needed for POSIX char classes, and caret for inverted char
      // classes, they could be dropped if we produced a single token for a
      // char class start.
      if !inCustomCharClass { return nil }
    default:
      // By default, no other metacharacters exist in custom character
      // classes.
      if inCustomCharClass { return nil }
    }
    return mc
  }

  /// Classify a given terminal character
  static func classifyTerminal(
    _ t: Character,
    fromEscape escaped: Bool,
    inCustomCharClass: Bool,
    syntax: SyntaxOptions
  ) -> Token {
    assert(!t.isEscape || escaped)
    if !escaped {
      // TODO: figure out best way to organize options logic...
      if syntax.ignoreWhitespace, t == " " {
        return .trivia
      }
      // A metacharacter such as '(', ']', '?'.
      if let mc = classifyAsMetaChar(t, inCustomCharClass: inCustomCharClass) {
        return .meta(mc)
      }
    }
    return .character(t, isEscaped: escaped)
  }
}
