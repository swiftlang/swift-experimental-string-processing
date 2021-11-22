/*

Syntactic structure of a regular expression

 Regex           -> Alternation
 Alternation     -> Concatenation ('|' Concatenation)*
 Concatenation   -> (!'|' !')' ConcatComponent)*
 ConcatComponent -> Trivia | Quote | Quantification
 Quantification  -> QuantOperand Quantifier?
 QuantOperand    -> Group | CustomCharClass | Atom
 Group           -> GroupStart Regex ')'

Custom character classes are a mini-language to their own. We
support UTS#18 set operators and nested character classes. The
meaning of some atoms, such as `\b` changes inside a custom
chararacter class. Below, we have a grammar "scope", that is we say
"SetOp" to mean "CustomCharactetClass.SetOp", so we don't have to
abbreviate/obfuscate/disambiguate with ugly names like "CCCSetOp".

TODO: Hamish, can you look this over?
Also, PCRE lets you end in `&&`, but not Oniguruma as it's a set
operator. We probably want a rule similar to how you can end in `-`
and that's just the character. Perhaps we also have syntax options
in case we need a compatibilty mode (it's easy to add here and now)

 CustomCharClass -> Start Set (SetOp Set)* ']'
 Set             -> Member+
 Member          -> CustomCharClass | !']' !SetOp (Range | Atom)
 Range           -> Atom `-` Atom

Lexical analysis provides the following:

 Atom       -> `lexAtom`
 Trivia     -> `lexComment` | `lexNonSemanticWhitespace`
 Quote      -> `lexQuote`
 Quantifier -> `lexQuantifier`
 GroupStart -> `lexGroupStart`

 CustomCharacterClass.Start -> `lexCustomCCStart`
 CustomCharacterClass.SetOp -> `lexCustomCCBinOp`

*/

private struct Parser {
  var source: Source

  fileprivate var customCharacterClassDepth = 0

  init(_ source: Source) {
    self.source = source
  }
}

// Diagnostics
extension Parser {
  private var isInCustomCharacterClass: Bool {
    customCharacterClassDepth > 0
  }

  mutating func report(
    _ str: String, _ function: String = #function, _ line: Int = #line
  ) throws -> Never {
    throw """
        ERROR: \(str)
        (error detected in parser at \(function):\(line))
        """
  }
}

extension Parser {
  /// Parse a regular expression
  ///
  ///     Regex        -> Alternation
  ///     Alternation  -> Concatenation ('|' Concatenation)*
  ///
  mutating func parse() throws -> AST {
    var result = Array<AST>(singleElement: try parseConcatenation())
    while source.tryEat("|") {
      result.append(try parseConcatenation())
    }
    return result.count == 1 ? result[0] : .alternation(result)
  }

  /// Parse a term, potentially separated from others by `|`
  ///
  ///     Concatenation   -> (!'|' !')' ConcatComponent)*
  ///     ConcatComponent -> Trivia | Quote | Quantification
  ///     Quantification  -> QuantOperand Quantifier?
  ///
  mutating func parseConcatenation() throws -> AST {
    var result = Array<AST>()
    while true {
      // Check for termination, e.g. of recursion or bin ops
      if source.isEmpty { break }
      if source.peek() == "|" || source.peek() == ")" { break }

      //     Trivia -> `lexComment` | `lexNonSemanticWhitespace`
      if let _ = try source.lexComment() {
        // TODO: remember comments
        result.append(.trivia)
        continue
      }
      if let _ = try source.lexNonSemanticWhitespace() {
        // TODO: Remember source range
        result.append(.trivia)
        continue
      }

      //     Quote      -> `lexQuote`
      if let quote = try source.lexQuote() {
        result.append(.quote(quote.value))
        continue
      }
      //     Quantification  -> QuantOperand Quantifier?
      if let operand = try parseQuantifierOperand() {
        if let q = try source.lexQuantifier()?.value {
          result.append(.quantification(q, operand))
        } else {
          result.append(operand)
        }
        continue
      }

      fatalError("unreachable?")
    }
    guard !result.isEmpty else {
      // Happens in `abc|`
      throw LexicalError.unexpectedEndOfInput
    }
    return result.count == 1 ? result[0] : .concatenation(result)
  }

  /// Parse a (potentially quantified) component
  ///
  ///     QuantOperand -> Group | CustomCharClass | Atom
  ///     Group        -> GroupStart Regex ')'
  mutating func parseQuantifierOperand() throws -> AST? {
    assert(!source.isEmpty)

    if let groupStart = try source.lexGroupStart()?.value {
      let ast = AST.group(Group(groupStart, nil), try parse())
      try source.expect(")")
      return ast
    }
    if let cccStart = try source.lexCustomCCStart()?.value {
      return .customCharacterClass(
        cccStart, try parseCustomCharacterClass(cccStart))
    }

    if let atom = try source.lexAtom(
      isInCustomCharacterClass: isInCustomCharacterClass
    )?.value {
      return .atom(atom)
    }

    // TODO: Is this reachable?
    return nil
  }
}

// MARK: - Custom character classes

extension Parser {
  private typealias CharacterSetComponent = CharacterClass.CharacterSetComponent

  /*
  mutating func parseCharacterSetComponent() throws -> CharacterSetComponent {
    // Nested custom character class.
    if let cccStart = try source.lexCustomCCStart()?.value {
      return .characterClass(
        try parseCustomCharacterClass(cccStart))
    }
    // Builtin character class.
    if case .builtinCharClass(let cc) = lexer.peek() {
      lexer.eat()
      return .characterClass(cc)
    }
    // A character that can optionally form a range with another character.
    let c1 = try parseCharacterSetComponentCharacter()
    if source.tryEat("-") {
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
*/

  /// Parse a custom character class
  ///
  ///     CustomCharClass -> Start Set (SetOp Set)* ']'
  ///     Set             -> Member+
  ///     Member          -> CustomCharClass | !']' !SetOp (Range | Atom)
  ///     Range           -> Atom `-` Atom
  ///
  mutating func parseCustomCharacterClass(
    _ start: CustomCharacterClass.Start
  ) throws -> CustomCharacterClass {
    typealias Member = CustomCharacterClass.Member
    var members: Array<Member> = []

    // TODO: Is this a correct/sane associativity? Precedence?
    while true {
      try source.expectNonEmpty()
      try parseCCCMembers(into: &members)

      // Slurp up the set operation and continue with it
      if let binOp = try source.lexCustomCCBinOp()?.value {
        var rhs: Array<Member> = []
        try parseCCCMembers(into: &rhs)

        // If we're done, bail early
        let ccc = CustomCharacterClass.setOperation(
          members, binOp, rhs)
        if source.tryEat("]") {
          return ccc
        }

        // Otherwise it's just another member to accumulate
        members = [.custom(ccc)]
        continue
      }

      // TODO: Pretty sure we're done here
      try source.expect("]")
      return .set(members)
    }
  }

  mutating func parseCCCMembers(
    into array: inout Array<CustomCharacterClass.Member>
  ) throws {
    fatalError("TODO")
  }

  /*
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
 */

}

public func parse<S: StringProtocol>(
  _ regex: S, _ syntax: SyntaxOptions
) throws -> AST where S.SubSequence == Substring
{
  let source = Source(regex, syntax)
  var parser = Parser(source)
  return try parser.parse()
}

extension String: Error {}
