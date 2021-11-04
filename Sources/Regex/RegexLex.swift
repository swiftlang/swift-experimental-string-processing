public struct Lexer {
  var source: Source
  var nextToken: Token? = nil

  /// The number of parent custom character classes we're lexing within.
  private var customCharacterClassDepth = 0

  public init(_ source: Source) { self.source = source }

  /// Whether the lexer is currently lexing within a custom character class.
  private var isInCustomCharacterClass: Bool { customCharacterClassDepth > 0 }

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

  private mutating func consumeEscapedCharacter() -> Token {
    assert(!source.isEmpty, "Escape at end of input string")
    let nextCharacter = source.eat()

    switch nextCharacter {
    // Escaped metacharacters are just regular characters
    case let x where Token.MetaCharacter(rawValue: x) != nil:
      fallthrough
    case Token.escape:
      return .character(nextCharacter, isEscaped: false)

    // Explicit Unicode scalar values have one of these forms:
    // - \u{h...}   (1+ hex digits)
    // - \uhhhh     (exactly 4 hex digits)
    // - \x{h...}   (1+ hex digits)
    // - \xhh       (exactly 2 hex digits)
    // - \Uhhhhhhhh (exactly 8 hex digits)
    case "u":
      let firstDigit = source.eat()
      if firstDigit == "{" {
        return .unicodeScalar(consumeUnicodeScalar())
      } else {
        return .unicodeScalar(consumeUnicodeScalar(
          firstDigit: firstDigit, digits: 4))
      }
    case "x":
      let firstDigit = source.eat()
      if firstDigit == "{" {
        return .unicodeScalar(consumeUnicodeScalar())
      } else {
        return .unicodeScalar(consumeUnicodeScalar(
          firstDigit: firstDigit, digits: 2))
      }
    case "U":
      return .unicodeScalar(consumeUnicodeScalar(digits: 8))

    default:
      return .character(nextCharacter, isEscaped: true)
    }
  }

  private mutating func consumeIfSetOperator(_ ch: Character) -> Token? {
    // Can only occur in a custom character class. Otherwise, the operator
    // characters are treated literally.
    guard isInCustomCharacterClass else { return nil }
    switch ch {
    case "-" where source.peek() == "-":
      _ = source.eat()
      return .setOperator(.doubleDash)
    case "~" where source.peek() == "~":
      _ = source.eat()
      return .setOperator(.doubleTilda)
    case "&" where source.peek() == "&":
      _ = source.eat()
      return .setOperator(.doubleAmpersand)
    default:
      return nil
    }
  }

  private mutating func consumeIfMetaCharacter(_ ch: Character) -> Token? {
    guard let meta = Token.MetaCharacter(rawValue: ch) else { return nil }
    // Track the custom character class depth. We can increment it every time
    // we see a `[`, and decrement every time we see a `]`, though we don't
    // decrement if we see `]` outside of a custom character class, as that
    // should be treated as a literal character.
    if meta == .lsquare {
      customCharacterClassDepth += 1
    }
    if meta == .rsquare && isInCustomCharacterClass {
      customCharacterClassDepth -= 1
    }
    return .meta(meta)
  }

  private mutating func consumeNextToken() -> Token? {
    guard !source.isEmpty else { return nil }
    let current = source.eat()
    if let op = consumeIfSetOperator(current) {
      return op
    }
    if let meta = consumeIfMetaCharacter(current) {
      return meta
    }
    if current == Token.escape {
      return consumeEscapedCharacter()
    }
    return .character(current, isEscaped: false)
  }
  
  private mutating func advance() {
    nextToken = consumeNextToken()
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

  // Eat a token if there is one. Returns whether anything
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

