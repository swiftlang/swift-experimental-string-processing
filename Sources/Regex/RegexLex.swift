
/// The source to a lexer. This can be bytes in memory, a file on disk, something streamed over a
/// network connection, ect. For our purposes, we model this as just a Substring (i.e. String + position)
public struct Source {
  var state: Substring
  public init(_ str: String) { state = str[...] }

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
  }

  case meta(MetaCharacter)
  case character(Character, isEscaped: Bool)

  // Convenience accessors
  public static var pipe: Token { .meta(.pipe) }
  public static var question: Token { .meta(.question) }
  public static var leftParen: Token { .meta(.lparen) }
  public static var rightParen: Token { .meta(.rparen) }
  public static var star: Token { .meta(.star) }
  public static var plus: Token { .meta(.plus) }
  public static var dot: Token { .meta(.dot) }

  // Note: We do each character individually, as post-fix modifiers bind
  // tighter than concatenation. "abc*" is "a" -> "b" -> "c*"
}

extension Token.MetaCharacter: CustomStringConvertible {
  public var description: String { String(self.rawValue) }
}
extension Token: CustomStringConvertible {
  public var description: String {
    switch self {
    case .meta(let meta): return meta.description
    case .character(let c, _): return c.halfWidthCornerQuoted
    }
  }
}

extension Token: Equatable {
  public static func ==(_ lhs: Token, _ rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.meta(let l), .meta(let r)): return l == r
    case (.character(let l, _), .character(let r, _)): return l == r
    default: return false
    }
  }
}

public struct Lexer {
  var source: Source
  var nextToken: Token? = nil
  public init(_ source: Source) { self.source = source }

  private mutating func advance() {
    guard !source.isEmpty else {
      nextToken = nil
      return
    }
    let current = source.eat()
    if let q = Token.MetaCharacter(rawValue: current) {
      nextToken = .meta(q)
      return
    }
    if current == Token.escape {
      nextToken = .character(source.eat(), isEscaped: true)
      return
    }
    nextToken = .character(current, isEscaped: false)
  }
}

// Main interface
extension Lexer {
  public var isEmpty: Bool { nextToken == nil && source.isEmpty }

  public mutating func peek() -> Token? {
    if let tok = nextToken { return tok }
    guard !source.isEmpty else { return nil }
    advance()
    return nextToken.unsafelyUnwrapped
  }

  // Eat a token is there is one. Returns whether anything
  // happened
  public mutating func eat(_ tok: Token) -> Bool {
    guard peek() == tok else { return false }
    advance()
    return true
  }

  // Eat a token, returning it (unless we're at the end)
  @discardableResult
  public mutating func eat() -> Token? {
    defer { advance() }
    return peek()
  }

  public mutating func eat(expecting tok: Token) throws {
    guard peek() == tok else { throw "Expected \(tok)" }
    advance()
  }
}

// Can also be viewed as just a sequence of tokens
extension Lexer: Sequence, IteratorProtocol {
  public typealias Element = Token

  public mutating func next() -> Element? {
    defer { advance() }
    return peek()
  }
}

