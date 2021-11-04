
/// The source to a lexer. This can be bytes in memory, a file on disk, something streamed over a
/// network connection, ect. For our purposes, we model this as just a Substring (i.e. String + position)
public struct Source {
  var state: Substring
  public init(_ str: String) { state = str[...] }

  public func peek() -> Character? { state.first }
  public mutating func eat() -> Character { state.eat() }

  public var isEmpty: Bool { state.isEmpty }
}

/// A lexer consumes its input (in this case a String) and produces Tokens.
///
/// Lexical structure of a regular expression:
///
///     RE            -> MetaCharacter RE | Character RE | ''
///     MetaCharacter -> '*' | '+' | '?' | '|' | '(' | ')' | '.'
///     Character     -> '\\'? <builtin: Character>
///
public enum Token {
  static let escape: Character = "\\"

  public enum MetaCharacter: Character, Hashable {
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

  public enum SetOperator: String, Hashable {
    case doubleAmpersand = "&&"
    case doubleDash = "--"
    case doubleTilda = "~~"
  }

  case meta(MetaCharacter)
  case setOperator(SetOperator)
  case character(Character, isEscaped: Bool)
  case unicodeScalar(UnicodeScalar)

  // Convenience accessors
  public static var pipe: Token { .meta(.pipe) }
  public static var question: Token { .meta(.question) }
  public static var leftParen: Token { .meta(.lparen) }
  public static var rightParen: Token { .meta(.rparen) }
  public static var star: Token { .meta(.star) }
  public static var plus: Token { .meta(.plus) }
  public static var dot: Token { .meta(.dot) }
  public static var colon: Token { .meta(.colon) }
  public static var leftSquareBracket: Token { .meta(.lsquare) }
  public static var rightSquareBracket: Token { .meta(.rsquare) }
  public static var minus: Token { .meta(.minus) }
  public static var caret: Token { .meta(.caret) }

  // Note: We do each character individually, as post-fix modifiers bind
  // tighter than concatenation. "abc*" is "a" -> "b" -> "c*"
}

extension Token.MetaCharacter: CustomStringConvertible {
  public var description: String { String(self.rawValue) }
}
extension Token.SetOperator: CustomStringConvertible {
  public var description: String { rawValue }
}
extension Token: CustomStringConvertible {
  public var description: String {
    switch self {
    case .meta(let meta): return meta.description
    case .setOperator(let op): return op.description
    case .character(let c, _): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return "U\(u.halfWidthCornerQuoted)"
    }
  }
}

extension Token: Equatable {}
