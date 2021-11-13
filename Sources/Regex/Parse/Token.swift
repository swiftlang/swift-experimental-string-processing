/// Tokens are produced by the lexer and carry rich syntactic information
struct TokenStorage {
  /// The underlying syntactic info
  let kind: Token

  /// The source location span of the token itself
  let loc: Range<Source.Loc>

  let fromCustomCharacterClass: Bool

  var token: Token {
    kind
  }
}

/// The underlying syntactic info carried by a token
enum Token: Hashable {
  case meta(MetaCharacter)
  case setOperator(SetOperator)
  case character(Character, isEscaped: Bool)
  case unicodeScalar(UnicodeScalar)
}

// MARK: - Token kinds

extension Token {
  enum MetaCharacter: Character, Hashable {
    case star = "*"
    case plus = "+"
    case question = "?"
    case pipe = "|"
    case lparen = "("
    case rparen = ")"
    case dot = "."
    case colon = ":"
    case lsquare = "["
    case rsquare = "]"
    case minus = "-"
    case caret = "^"
    case dollar = "$"
  }


  enum SetOperator: String, Hashable {
    case doubleAmpersand = "&&"
    case doubleDash = "--"
    case doubleTilda = "~~"
  }

  // Note: We do each character individually, as post-fix modifiers bind
  // tighter than concatenation. "abc*" is "a" -> "b" -> "c*"
}

// TODO: Consider a flat kind representation and leave structure
// as an API concern
extension Token {
  // Convenience accessors
  static var pipe: Self { .meta(.pipe) }
  static var question: Self { .meta(.question) }
  static var leftParen: Self { .meta(.lparen) }
  static var rightParen: Self { .meta(.rparen) }
  static var star: Self { .meta(.star) }
  static var plus: Self { .meta(.plus) }
  static var dot: Self { .meta(.dot) }
  static var colon: Self { .meta(.colon) }
  static var leftSquareBracket: Self { .meta(.lsquare) }
  static var rightSquareBracket: Self { .meta(.rsquare) }
  static var minus: Self { .meta(.minus) }
  static var caret: Self { .meta(.caret) }
}

extension Token.MetaCharacter: CustomStringConvertible {
  var description: String { String(self.rawValue) }
}
extension Token.SetOperator: CustomStringConvertible {
  var description: String { rawValue }
}
extension Token: CustomStringConvertible {
  var description: String {
    switch self {
    case .meta(let meta): return meta.description
    case .setOperator(let op): return op.description
    case .character(let c, _): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return "U\(u.halfWidthCornerQuoted)"
    }
  }
}

extension Character {
  var isEscape: Bool { return self == "\\" }
}

extension Token {
  /// Classify a given terminal character
  static func classifyTerminal(
    _ t: Character, fromEscape escaped: Bool
  ) -> Self {
    assert(!t.isEscape || escaped)
    if !escaped, let mc = Token.MetaCharacter(rawValue: t) {
      return .meta(mc)
    }
    return .character(t, isEscaped: escaped)
  }
}
