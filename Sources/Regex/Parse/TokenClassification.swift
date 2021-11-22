extension Lexer {
  /// Classify a 'special character escape'.
  ///
  /// If in a custom character class:
  /// SpecialCharEscape -> '\t' | '\r' | '\b' | '\f' | '\a' | '\e' | '\n'
  ///
  /// Otherwise:
  /// SpecialCharEscape -> '\t' | '\r' | '\f' | '\a' | '\e' | '\n'
  private static func classifyAsSpecialCharEscape(
    _ t: Character, inCustomCharClass: Bool
  ) -> Token.SpecialCharacterEscape? {
    switch t {
    case "t":
      return .tab
    case "r":
      return .carriageReturn
    case "b":
      // \b only means backspace in a custom character class.
      return inCustomCharClass ? .backspace : nil
    case "f":
      return .formFeed
    case "a":
      return .bell
    case "e":
      return .escape
    case "n":
      return .newline
    default:
      return nil
    }
  }

  /// Classify an anchor character.
  ///
  /// If in a custom character class:
  /// Anchor -> <none>
  ///
  /// Otherwise:
  /// Anchor -> '^' | '$' | '\b' | '\B' | '\A' | '\Z' | '\z' | '\G' | '\K' |
  ///           '\y' | '\Y'
  private static func classifyAsAnchor(
    _ t: Character, fromEscape escaped: Bool, inCustomCharClass: Bool
  ) -> Anchor? {
    // Anchors aren't valid in custom char classes.
    guard !inCustomCharClass else { return nil }
    if !escaped {
      switch t {
      case "^":
        return .lineStart
      case "$":
        return .lineEnd
      default:
        return nil
      }
    }
    switch t {
    case "b":
      return .wordBoundary
    case "B":
      return .nonWordBoundary
    case "A":
      return .stringStart
    case "Z":
      return .stringEndOrBeforeNewline
    case "z":
      return .stringEnd
    case "G":
      return .startOfPreviousMatch
    case "K":
      return .resetMatch
    case "y":
      return .textSegmentBoundary
    case "Y":
      return .textSegmentNonBoundary
    default:
      return nil
    }
  }

  /// Classify a meta-character.
  ///
  /// In a custom character class:
  /// MetaChar -> '[' | ']' | '-' | '^'
  ///
  /// Otherwise:
  /// MetaChar -> '[' | '*' | '?' | '|' | '(' | ')' | '.' | ':'
  ///
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

  /// Classify a given terminal character.
  ///
  /// Terminal -> Anchor | MetaChar | SpecialCharEscape | Character
  ///
  /// If .ignoreWhitespace:
  /// ' ' -> Trivia
  ///
  static func classifyTerminal(
    _ t: Character,
    fromEscape escaped: Bool,
    inCustomCharClass: Bool,
    syntax: SyntaxOptions
  ) -> Token {
    assert(!t.isEscape || escaped)
    if escaped {
      // A special character such as '\t' or '\n'.
      if let special =
          classifyAsSpecialCharEscape(t, inCustomCharClass: inCustomCharClass) {
        return .specialCharEscape(special)
      }
    } else {
      // TODO: figure out best way to organize options logic...
      if syntax.ignoreWhitespace, t == " " {
        return .trivia
      }
      // A metacharacter such as '(', ']', '?'.
      if let mc = classifyAsMetaChar(t, inCustomCharClass: inCustomCharClass) {
        return .meta(mc)
      }
    }
    // An anchor such as '^', '\A'.
    if let anchor = classifyAsAnchor(t, fromEscape: escaped,
                                     inCustomCharClass: inCustomCharClass) {
      return .anchor(anchor)
    }
    return .character(t, isEscaped: escaped)
  }
}
