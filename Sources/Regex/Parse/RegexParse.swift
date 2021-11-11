/*

Syntactic structure of a regular expression

 Regex          -> '' | Alternation
 Alternation    -> Concatenation ('|' Concatenation)*
 Concatenation  -> Quantification Quantification*
 Quantification -> (Group | Atom) <token: qualifier>?
 Atom           -> <token: .character> | <any> | ... character classes ...
 CaptureGroup   -> '(' RE ')'
 Group          -> '(' '?' ':' RE ')'

*/

private struct Parser {
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
    var result = Array<AST>(singleElement: try parseConcatenation())
    while lexer.tryEat2(.alternation) {
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
    if let q = lexer.tryEatQuantification() {
      return .quantification(q, operand)
    }
    return operand
  }

  //     QuantifierOperand -> (Group | <token: Character>)
  mutating func parseQuantifierOperand() throws -> AST? {
    switch lexer.peek()?.kind {
    case .leftParen?:
      lexer.eat()
      var isCapturing = true
      if lexer.tryEat(.question) {
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
      }

      // TODO: anything else here?
      return .character(c)

    case .minus?, .colon?, .rightSquareBracket?:
      // Outside of custom character classes, these are not considered to be
      // metacharacters.

      // TODO: we want a much cleaner separation here, perhaps
      // lexer can present as normal characters
      guard case .meta(let meta) = lexer.eat()?.kind else {
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
    switch lexer.eat()?.kind {
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
    if lexer.peek()?.kind == .leftSquareBracket {
      return .characterClass(try parseCustomCharacterClass())
    }
    // Escaped character class.
    if case .character(let c, isEscaped: true) = lexer.peek()?.kind,
       let cc = CharacterClass(c) {
      lexer.eat()
      return .characterClass(cc)
    }
    // A character that can optionally form a range with another character.
    let c1 = try parseCharacterSetComponentCharacter()
    if lexer.tryEat(.minus) {
      let c2 = try parseCharacterSetComponentCharacter()
      return .range(c1...c2)
    }
    return .character(c1)
  }

  /// Attempt to parse a set operator, returning nil if the next token is not
  /// for a set operator.
  mutating func tryParseSetOperator() -> CharacterClass.SetOperator? {
    guard case .setOperator(let opTok) = lexer.peek()?.kind else { return nil }
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
    let isInverted = lexer.tryEat(.caret)
    var components: [CharacterSetComponent] = []
    while !lexer.tryEat(.rightSquareBracket) {
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

extension String: Error {}
