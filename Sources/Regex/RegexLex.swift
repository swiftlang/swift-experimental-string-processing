/*

 Our current lexical structure of a regular expression:

 Regex     -> Token*
 Token     -> '\' Escaped | _SetOperator_ | Terminal
 Escaped   -> UniScalar | Terminal
 Terminal  -> `MetaCharacter` | `Character`

 UniScalar -> 'u{' HexDigit{1, 8}
            | 'u' HexDigit{4}
            | 'x{' HexDigit{1, 8}
            | 'x' HexDigit{2}
            | 'U' HexDigit{8}
 HexDigit  -> 0-9A-Fa-f

 _SetOperator_ is valid if we're inside a custom character set,
 otherwise it's just characters.

 TODO: We'll need a more principled approach here.

*/

/// The lexer produces a stream of `Token`s for the parser to consume
struct Lexer {
  var source: Source // TODO: fileprivate after diags

  /// The lexer manages a fixed-length buffer of tokens on behalf of the parser.
  /// Currently, the parser uses a lookahead of 1.
  ///
  /// We're choosing encapsulation here for our buffer-management strategy, as
  /// the lexer is at the end of the assembly line.
  ///
  fileprivate var nextToken: Token? = nil

  /// The number of parent custom character classes we're lexing within.
  fileprivate var customCharacterClassDepth = 0

  init(_ source: Source) { self.source = source }
}

// MARK: - Intramodule Programming Interface (IPI?)

extension Lexer {
  /// Whether we're done
  var isEmpty: Bool {
    nextToken == nil && source.isEmpty
  }

  /// Grab the next token without consuming it, if there is one
  mutating func peek() -> Token? {
    if let tok = nextToken { return tok }
    guard !source.isEmpty else { return nil }
    advance()
    return nextToken.unsafelyUnwrapped
  }

  /// Eat a token, returning it (unless we're at the end)
  @discardableResult
  mutating func eat() -> Token? {
    defer { advance() }
    return peek()
  }

  /// Eat the specified token if there is one. Returns whether anything happened
  mutating func tryEat(_ tok: Token.Kind) -> Bool {
    guard peek()?.kind == tok else { return false }
    advance()
    return true
  }

  /// Try to eat a token, throwing if we don't see what we're expecting.
  mutating func eat(expecting tok: Token.Kind) throws {
    guard tryEat(tok) else { throw "Expected \(tok)" }
  }

  /// Try to eat a token, asserting we saw what we expected
  mutating func eat(asserting tok: Token.Kind) {
    let expected = tryEat(tok)
    assert(expected)
  }

  /// TODO: Consider a variant that will produce the requested token, but also
  /// produce diagnostics/fixit if that's not what's really there.
}

// MARK: - Implementation

extension Lexer {
  private mutating func advance() {
    nextToken = lexToken()
  }

  private mutating func lexToken() -> Token? {
    guard !source.isEmpty else { return nil }

    let startLoc = source.currentLoc
    func tok(_ kind: Token.Kind) -> Token {
      Token(kind: kind, loc: startLoc..<source.currentLoc)
    }

    // Lex:  Token -> '\' Escaped | _SetOperator | Terminal
    let current = source.eat()
    if current.isEscape {
      return tok(consumeEscaped())
    }
    if isInCustomCharacterClass,
       let op = tryConsumeSetOperator(current)
    {
      return tok(op)
    }

    // Track the custom character class depth. We can increment it every time
    // we see a `[`, and decrement every time we see a `]`, though we don't
    // decrement if we see `]` outside of a custom character class, as that
    // should be treated as a literal character.
    if current == "[" {
      customCharacterClassDepth += 1
    }
    if current == "]" && isInCustomCharacterClass {
      customCharacterClassDepth -= 1
    }

    return tok(.classifyTerminal(current, fromEscape: false))
  }

  /// Whether the lexer is currently lexing within a custom character class.
  private var isInCustomCharacterClass: Bool { customCharacterClassDepth > 0 }

  // TODO: plumb diagnostics
  private mutating func consumeEscaped() -> Token.Kind {
    assert(!source.isEmpty, "TODO: diagnostic for this")
    /*

    Escaped   -> UniScalar | Terminal
    UniScalar -> 'u{' HexDigit{1, 8}
               | 'u' HexDigit{4}
               | 'x{' HexDigit{1, 8}
               | 'x' HexDigit{2}
               | 'U' HexDigit{8}
    */
    switch source.eat() {
    case "u":
      return consumeUniScalar(
        allowBracketVariant: true, unbracketedNumDigits: 4)
    case "x":
      return consumeUniScalar(
        allowBracketVariant: true, unbracketedNumDigits: 2)
    case "U":
      return consumeUniScalar(
        allowBracketVariant: false, unbracketedNumDigits: 8)
    case let c:
      return .classifyTerminal(c, fromEscape: true)
    }
  }

  // TODO: plumb diagnostic info
  private mutating func consumeUniScalar(
    allowBracketVariant: Bool,
    unbracketedNumDigits: Int
  ) -> Token.Kind {
    if allowBracketVariant, source.tryEat("{") {
      return .unicodeScalar(consumeBracketedUnicodeScalar())
    }
    return .unicodeScalar(consumeUnicodeScalar(
      digits: unbracketedNumDigits))
  }

  private mutating func consumeUnicodeScalar(
    digits digitCount: Int
  ) -> UnicodeScalar {
    var digits = ""
    for _ in digits.count ..< digitCount {
      assert(!source.isEmpty, "Exactly \(digitCount) hex digits required")
      digits.append(source.eat())
    }

    guard let value = UInt32(digits, radix: 16),
          let scalar = UnicodeScalar(value)
    else { fatalError("Invalid unicode sequence") }

    return scalar
  }

  private mutating func consumeBracketedUnicodeScalar() -> UnicodeScalar {
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

  private mutating func tryConsumeSetOperator(_ ch: Character) -> Token.Kind? {
    // Can only occur in a custom character class. Otherwise, the operator
    // characters are treated literally.
    assert(isInCustomCharacterClass)
    switch ch {
    case "-" where source.tryEat("-"):
      return .setOperator(.doubleDash)
    case "~" where source.tryEat("~"):
      return .setOperator(.doubleTilda)
    case "&" where source.tryEat("&"):
      return .setOperator(.doubleAmpersand)
    default:
      return nil
    }
  }
}


// Can also be viewed as just a sequence of tokens. Useful for
// testing
extension Lexer: Sequence, IteratorProtocol {
  typealias Element = Token

  mutating func next() -> Element? {
    defer { advance() }
    return peek()
  }
}

