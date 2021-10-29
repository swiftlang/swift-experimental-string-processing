private let regexLanguageDescription = """
Brief:
    Just a simple, vanilla regular expression languague.
    Supports *, +, ?, |, and non-capturing grouping
    TBD: character classes, ...
"""

extension String: Error {}

/// A parser reads off a lexer and produces an AST
///
/// Syntactic structure of a regular expression:
///
///     RE -> '' | Alternation
///     Alternation -> Concatenation ('|' Concatenation)*
///     Concatenation -> Quantification Quantification*
///     Quantification -> (Group | Atom) <token: qualifier>?
///     Atom -> <token: .character> | <any> | ... character classes ...
///     CaptureGroup -> '(' RE ')'
///     Group -> '(' '?' ':' RE ')'
///
public enum AST: Hashable {
  indirect case alternation([AST]) // alternation(AST, AST?)
  indirect case concatenation([AST])
  indirect case group(AST)
  indirect case capturingGroup(AST, transform: CaptureTransform? = nil)

  // Post-fix modifiers
  indirect case many(AST)
  indirect case zeroOrOne(AST)
  indirect case oneOrMore(AST)

  // Lazy versions of quantifiers
  indirect case lazyMany(AST)
  indirect case lazyZeroOrOne(AST)
  indirect case lazyOneOrMore(AST)

  case character(Character)
  case unicodeScalar(UnicodeScalar)
  case characterClass(CharacterClass)
  case any
  case empty
}

extension AST: CustomStringConvertible {
  public var description: String {
    switch self {
    case .alternation(let rest): return ".alt(\(rest))"
    case .concatenation(let rest): return ".concat(\(rest))"
    case .group(let rest): return ".group(\(rest))"
    case .capturingGroup(let rest, let transform):
      return """
          .capturingGroup(\(rest), transform: \(transform.map(String.init(describing:)) ?? "nil")
          """
    case .many(let rest): return ".many(\(rest))"
    case .zeroOrOne(let rest): return ".zeroOrOne(\(rest))"
    case .oneOrMore(let rest): return ".oneOrMore(\(rest))"
    case .lazyMany(let rest): return ".lazyMany(\(rest))"
    case .lazyZeroOrOne(let rest): return ".lazyZeroOrOne(\(rest))"
    case .lazyOneOrMore(let rest): return ".lazyOneOrMore(\(rest))"
    case .character(let c): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return u.halfWidthCornerQuoted
    case .characterClass(let cc): return ".characterClass(\(cc))"
    case .any: return ".any"
    case .empty: return "".halfWidthCornerQuoted
    }
  }
}

fileprivate struct Parser {
  var lexer: Lexer
  init(_ lexer: Lexer) {
    self.lexer = lexer
  }
}

// Diagnostics
extension Parser {
  mutating func report(
    _ str: String, _ function: String = #function, _ line: Int = #line
  ) throws -> Never {
    throw """
        ERROR: \(str)
        (error in user string evaluating \(
            String(describing: lexer.peek())) prior to: "\(lexer.source)")
        (error detected in parser at \(function):\(line))
        """
  }
}

extension Parser {
  //     RE -> '' | Alternation
  mutating func parse() throws -> AST {
    if lexer.isEmpty { return .empty }
    return try parseAlternation()
  }
  
  //     Alternation -> Concatenation ('|' Concatenation)*
  mutating func parseAlternation() throws -> AST {
    assert(!lexer.isEmpty)
    var result = Array<AST>(try parseConcatenation())
    while lexer.eat(.pipe) {
      result.append(try parseConcatenation())
    }
    return result.count == 1 ? result[0] : .alternation(result)
  }
  
  //     Concatenation -> Quantification Quantification*
  mutating func parseConcatenation() throws -> AST {
    var result = Array<AST>()
    while let operand = try parseQuantifierOperand() {
      result.append(try parseQuantification(of: operand))
    }
    guard !result.isEmpty else {
      // Happens in `abc|`
      try report("empty concatenation")
    }
    return result.count == 1 ? result[0] : .concatenation(result)
  }
  
  //     Quantification -> QuantifierOperand <token: Quantifier>?
  mutating func parseQuantification(of operand: AST) throws -> AST {
    switch lexer.peek() {
    case .star?:
      lexer.eat()
      return lexer.eat(.question)
        ? .lazyMany(operand)
        : .many(operand)
    case .plus?:
      lexer.eat()
      return lexer.eat(.question)
        ? .lazyOneOrMore(operand)
        : .oneOrMore(operand)
    case .question?:
      lexer.eat()
      return lexer.eat(.question)
        ? .lazyZeroOrOne(operand)
        : .zeroOrOne(operand)
    default:
      return operand
    }
  }

  //     QuantifierOperand -> (Group | <token: Character>)
  mutating func parseQuantifierOperand() throws -> AST? {
    switch lexer.peek() {
    case .leftParen?:
      lexer.eat()
      var isCapturing = true
      if lexer.eat(.question) {
        try lexer.eat(expecting: .colon)
        isCapturing = false
      }
      let child = try parse()
      try lexer.eat(expecting: .rightParen)
      return isCapturing ? .capturingGroup(child) : .group(child)

    case .character(let c, isEscaped: false):
      lexer.eat()
      return .character(c)

    case .unicodeScalar(let u):
      lexer.eat()
      return .unicodeScalar(u)

    case .character(let c, isEscaped: true):
      lexer.eat()
      if let cc = CharacterClass(c) {
        // Other characters either match a character class...
        return .characterClass(cc)

      } else {
        // ...or are invalid
        try report("unexpected escape sequence \\\(c)")
      }

    case .minus?, .colon?, .rightSquareBracket?:
      // Outside of custom character classes, these are not considered to be
      // metacharacters.
      guard case .meta(let meta) = lexer.eat() else {
        fatalError("Not a metachar?")
      }
      return .character(meta.rawValue)

    case .leftSquareBracket?:
      return .characterClass(try parseCustomCharacterClass())

    case .dot?:
      lexer.eat()
      return .characterClass(.any)

    // Correct terminations
    case .rightParen?: fallthrough
    case .pipe?: fallthrough
    case nil:
      return nil

    default:
      try report("expected a character or group")
    }
  }

  typealias CharacterSetComponent = CharacterClass.CharacterSetComponent

  /// Parse a literal character in a custom character class.
  mutating func parseCharacterSetComponentCharacter() throws -> Character {
    // Most metacharacters can be interpreted as literal characters in a
    // custom character class. This even includes the '-' character if it
    // appears in a position where it cannot be treated as a range
    // (per PCRE#SEC9). We may want to warn on this and require the user to
    // escape it though.
    switch lexer.eat() {
    case .meta(.rsquare):
      try report("unexpected end of character class")
    case .meta(let meta):
      return meta.rawValue
    case .character(let c, isEscaped: _):
      return c
    default:
      try report("expected a character or a ']'")
    }
  }

  mutating func parseCharacterSetComponent() throws -> CharacterSetComponent {
    // Nested custom character class.
    if lexer.peek() == .leftSquareBracket {
      return .characterClass(try parseCustomCharacterClass())
    }
    // Escaped character class.
    if case .character(let c, isEscaped: true) = lexer.peek(),
       let cc = CharacterClass(c) {
      lexer.eat()
      return .characterClass(cc)
    }
    // A character that can optionally form a range with another character.
    let c1 = try parseCharacterSetComponentCharacter()
    if lexer.eat(.minus) {
      let c2 = try parseCharacterSetComponentCharacter()
      return .range(c1...c2)
    }
    return .character(c1)
  }

  /// Attempt to parse a set operator, returning nil if the next token is not
  /// for a set operator.
  mutating func tryParseSetOperator() -> CharacterClass.SetOperator? {
    guard case .setOperator(let opTok) = lexer.peek() else { return nil }
    lexer.eat()
    switch opTok {
    case .doubleAmpersand:
      return .intersection
    case .doubleDash:
      return .subtraction
    case .doubleTilda:
      return .symmetricDifference
    }
  }

  ///     CharacterClass -> '[' CharacterSetComponent+ ']'
  ///
  ///     CharacterSetComponent -> CharacterSetComponent SetOp CharacterSetComponent
  ///     CharacterSetComponent -> CharacterClass
  ///     CharacterSetComponent -> <token: Character>
  ///     CharacterSetComponent -> <token: Character> '-' <token: Character>
  ///
  mutating func parseCustomCharacterClass() throws -> CharacterClass {
    try lexer.eat(expecting: .leftSquareBracket)
    let isInverted = lexer.eat(Token.caret)
    var components: [CharacterSetComponent] = []
    while !lexer.eat(.rightSquareBracket) {
      // If we have a binary set operator, parse it and the next component. Note
      // that this means we left associate for a chain of operators.
      // TODO: We may want to diagnose and require users to disambiguate,
      // at least for chains of separate operators.
      if let op = tryParseSetOperator() {
        guard let lhs = components.popLast() else {
          try report("Binary set operator requires operand")
        }
        let rhs = try parseCharacterSetComponent()
        components.append(.setOperation(lhs: lhs, op: op, rhs: rhs))
        continue
      }
      components.append(try parseCharacterSetComponent())
    }
    return .custom(components).withInversion(isInverted)
  }
}

public func parse(_ regex: String) throws -> AST {
  let lexer = Lexer(Source(regex))
  var parser = Parser(lexer)
  return try parser.parse()
}
