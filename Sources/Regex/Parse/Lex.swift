/*

 Lexically, regular expressions are two langauges, one for inside
 a custom character class and one for outside.

 Outside of a custom character class, regexes have the following
 lexical structure:

 TODO

 Inside a custom character class:

 TODO

 Our currently-matched lexical structure of a regular expression:

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

*/

/// The lexer produces a stream of `Token`s for the parser to consume
struct Lexer {
  var source: Source // TODO: fileprivate after diags

  /// The lexer manages a fixed-length buffer of tokens on behalf of the parser.
  /// Currently, the parser uses a lookahead of 1.
  ///
  /// We're choosing encapsulation here for our buffer-management strategy, as
  /// the lexer is at the end of the assembly line.
  fileprivate var nextTokenStorage: TokenStorage? = nil

  var nextToken: Token? {
    nextTokenStorage?.token
  }

  /// The number of parent custom character classes we're lexing within.
  ///
  /// Nested custom character classes are possible in some engines,
  /// and regex lexes differently inside and outside custom char classes.
  /// Tracking which language we're lexing is technically the job of the parser.
  /// But, we want the lexer to provide rich lexical information and let the parser
  /// just handle parsing. We could have a `setIsInCustomCC(_:Bool)` called by
  /// the parser, which would save/restore via the call stack, but it's
  /// far simpler to just have the lexer count the `[` and `]`s.
  fileprivate var customCharacterClassDepth = 0

  /// Whether we are quoted / inside a quote
  fileprivate var isQuoted = false


  init(_ source: Source) { self.source = source }
}

// MARK: - Intramodule Programming Interface (IPI?)

extension Lexer: _Peekable {
  typealias Output = Token

  /// Whether we're done
  var isEmpty: Bool { nextToken == nil && source.isEmpty }

  /// Grab the next token without consuming it, if there is one
  mutating func peek() -> Token? {
    if let tok = nextToken { return tok }
    guard !source.isEmpty else { return nil }
    advance()
    return nextToken.unsafelyUnwrapped
  }

  mutating func advance() {
    nextTokenStorage = lexToken()
  }
}

// MARK: - Richer lexical analysis IPI

extension Lexer {
  mutating func tryEatQuantification() -> Quantifier? {
    // TODO: just lex directly, for now we bootstrap
    switch peek() {
    case .star?:
      eat()
      return .zeroOrMore(tryEat(.question) ? .reluctant : .greedy)
    case .plus?:
      eat()
      return .oneOrMore(tryEat(.question) ? .reluctant : .greedy)
    case .question?:
      eat()
      return .zeroOrOne(tryEat(.question) ? .reluctant : .greedy)
    default:
      return nil
    }
  }

  mutating func tryEatGroupStart() -> Group? {
    // TODO: just lex directly, for now we bootstrap
    guard tryEat(.leftParen) else { return nil }

    if tryEat(.question) {
      guard tryEat(.colon) else {
        fatalError("TODO: diagnostic, or else other group kinds")
      }
      return .nonCapture()
    }
    return .capture()
  }

  /// Try to eat a token, throwing if we don't see what we're expecting.
  mutating func eat(expecting tok: Token) throws {
    guard tryEat(tok) else { throw "Expected \(tok)" }
  }

  /// Try to eat a token, asserting we saw what we expected
  mutating func eat(asserting tok: Token) {
    let expected = tryEat(tok)
    assert(expected)
  }

  /// TODO: Consider a variant that will produce the requested token, but also
  /// produce diagnostics/fixit if that's not what's really there.
}

// MARK: - Implementation

extension Lexer {
  var syntax: SyntaxOptions { source.syntax }

  private mutating func lexToken() -> TokenStorage? {
    guard !source.isEmpty else { return nil }

    let startLoc = source.currentLoc
    func tok(_ kind: Token) -> TokenStorage {
      TokenStorage(
        kind: kind,
        loc: startLoc..<source.currentLoc,
        fromCustomCharacterClass: isInCustomCharacterClass)
    }

    let current = source.eat()

    // If we're in a quoted expression, everything is raw
    // except \E
    if isQuoted {
      if (current == "\\" && source.tryEat("E"))
      || (current == "\"" && syntax.contains(.swiftyQuotes))
      {
        self.isQuoted = false
        return tok(.endQuote)
      }

      // FIXME: Well, not explicitly escaped...
      return tok(classifyTerminal(current, fromEscape: true))
    }

    // Lex:  Token -> '\' Escaped | _SetOperator | Terminal
    if current.isEscape {
      return tok(consumeEscaped())
    }

    if syntax.contains(.swiftyQuotes), current == "\"" {
      assert(!isQuoted)
      self.isQuoted = true
      return tok(.startQuote)
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

    return tok(classifyTerminal(current, fromEscape: false))
  }

  /// Whether the lexer is currently lexing within a custom character class.
  private var isInCustomCharacterClass: Bool {
    customCharacterClassDepth > 0
  }

  // TODO: plumb diagnostics
  private mutating func consumeEscaped() -> Token {
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

    // Quoting
    case "Q":
      self.isQuoted = true
      return .startQuote
    case "E":
      // TODO: diagnostics
      fatalError("Error: End-quote without open quote")

    case let c:
      return classifyTerminal(c, fromEscape: true)
    }
  }

  // TODO: plumb diagnostic info
  private mutating func consumeUniScalar(
    allowBracketVariant: Bool,
    unbracketedNumDigits: Int
  ) -> Token {
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

  private mutating func tryConsumeSetOperator(_ ch: Character) -> Token? {
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


extension Lexer {
  /// Classify a given terminal character
  func classifyTerminal(
    _ t: Character,
    fromEscape escaped: Bool
  ) -> Token {
    assert(!t.isEscape || escaped)
    if !escaped {
      // TODO: figure out best way to organize options logic...
      if !isQuoted, syntax.ignoreWhitespace, t == " " {
        return .trivia
      }

      if let mc = Token.MetaCharacter(rawValue: t) {
        return .meta(mc)
      }
    }

    return .character(t, isEscaped: escaped)
  }
}
