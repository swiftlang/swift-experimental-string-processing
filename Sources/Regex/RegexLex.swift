
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
    case colon = ":"
  }

  case meta(MetaCharacter)
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
    case .unicodeScalar(let u): return "U\(u.halfWidthCornerQuoted)"
    }
  }
}

extension Token: Equatable {}

public struct Lexer {
  var source: Source
  var nextToken: Token? = nil
  public init(_ source: Source) { self.source = source }

  private mutating func consumeUnicodeScalar(
    firstDigit: Character? = nil,
    digits digitCount: Int
  ) -> UnicodeScalar {
    var digits = firstDigit.map(String.init) ?? ""
    for _ in digits.count ..< digitCount {
      assert(!source.isEmpty, "Exactly \(digitCount) hex digits required")
      digits.append(source.eat())
    }

    guard let value = UInt32(digits, radix: 16),
          let scalar = UnicodeScalar(value)
    else { fatalError("Invalid unicode sequence") }
    
    return scalar
  }
  
  private mutating func consumeUnicodeScalar() -> UnicodeScalar {
    var digits = ""
    // Eat a maximum of 9 characters, the last of which must be the terminator
    for _ in 0..<9 {
      assert(!source.isEmpty, "Unterminated unicode value")
      let next = source.eat()
      if next == "}" { break }
      digits.append(next)
      assert(digits.count <= 8, "Maximum 8 hex values required")
    }
    
    guard let value = UInt32(digits, radix: 16),
          let scalar = UnicodeScalar(value)
    else { fatalError("Invalid unicode sequence") }
    
    return scalar
  }
  
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
      assert(!source.isEmpty, "Escape at end of input string")
      let nextCharacter = source.eat()
      
      switch nextCharacter {
      // Escaped metacharacters are just regular characters
      case let x where Token.MetaCharacter(rawValue: x) != nil:
        fallthrough
      case Token.escape:
        nextToken = .character(nextCharacter, isEscaped: false)
        
      // Explicit Unicode scalar values have one of these forms:
      // - \u{h...}   (1+ hex digits)
      // - \uhhhh     (exactly 4 hex digits)
      // - \x{h...}   (1+ hex digits)
      // - \xhh       (exactly 2 hex digits)
      // - \Uhhhhhhhh (exactly 8 hex digits)
      case "u":
        let firstDigit = source.eat()
        if firstDigit == "{" {
          nextToken = .unicodeScalar(consumeUnicodeScalar())
        } else {
          nextToken = .unicodeScalar(consumeUnicodeScalar(
            firstDigit: firstDigit, digits: 4))
        }
      case "x":
        let firstDigit = source.eat()
        if firstDigit == "{" {
          nextToken = .unicodeScalar(consumeUnicodeScalar())
        } else {
          nextToken = .unicodeScalar(consumeUnicodeScalar(
            firstDigit: firstDigit, digits: 2))
        }
      case "U":
        nextToken = .unicodeScalar(consumeUnicodeScalar(digits: 8))
        
      default:
        nextToken = .character(nextCharacter, isEscaped: true)
      }
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

