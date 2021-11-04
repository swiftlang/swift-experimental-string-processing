/// The source to a lexer. This can be bytes in memory, a file on disk,
/// something streamed over a network connection, etc.
///
/// Currently, we model this as just a Substring (i.e. String + position)
struct Source {
  var state: Substring
  init(_ str: String) { state = str[...] }

  func peek() -> Character? { state.first }
  mutating func eat() -> Character { state.eat() }

  var isEmpty: Bool { state.isEmpty }

  typealias Location = String.Index
  var currentLoc: Location { state.startIndex }
}

/// Tokens are produced by the lexer and carry rich syntactic information
///
struct Token {
  /// The underlying syntactic info
  let kind: Kind

  /// The source location span of the token itself
  let loc: Range<Source.Location>

  // TODO: diagnostics
}

// MARK: - Token kinds

extension Token {
  static var escape: Character { #"\"# }

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
  }

  /// The underlying syntactic info carried by a token
  enum Kind {
    case meta(MetaCharacter)
    case setOperator(SetOperator)
    case character(Character, isEscaped: Bool)
    case unicodeScalar(UnicodeScalar)
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
extension Token.Kind {
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
extension Token.Kind: CustomStringConvertible {
  var description: String {
    switch self {
    case .meta(let meta): return meta.description
    case .setOperator(let op): return op.description
    case .character(let c, _): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return "U\(u.halfWidthCornerQuoted)"
    }
  }
}

extension Token.Kind: Equatable {}
