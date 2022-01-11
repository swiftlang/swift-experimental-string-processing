//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/*

Syntactic structure of a regular expression

 Regex           -> '' | Alternation
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

  /// Tracks the number of parent custom character classes to allow us to
  /// determine whether or not to lex with custom character class syntax.
  fileprivate var customCharacterClassDepth = 0

  /// Tracks the number of group openings we've seen, to disambiguate the '\n'
  /// syntax as a backreference or an octal sequence.
  fileprivate var priorGroupCount = 0

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

  fileprivate func loc(
    _ start: Source.Position
  ) -> SourceLocation {
    SourceLocation(start ..< source.currentPosition)
  }
}

extension Parser {
  /// Parse a regular expression
  ///
  ///     Regex        -> '' | Alternation
  ///     Alternation  -> Concatenation ('|' Concatenation)*
  ///
  mutating func parse() throws -> AST {
    let _start = source.currentPosition

    if source.isEmpty { return .empty(.init(loc(_start))) }

    var result = [try parseConcatenation()]
    var pipes: [SourceLocation] = []
    while true {
      let pipeStart = source.currentPosition
      guard source.tryEat("|") else { break }
      pipes.append(loc(pipeStart))
      result.append(try parseConcatenation())
    }

    if result.count == 1 {
      return result[0]
    }

    return .alternation(.init(result, pipes: pipes))
  }

  /// Parse a term, potentially separated from others by `|`
  ///
  ///     Concatenation   -> (!'|' !')' ConcatComponent)*
  ///     ConcatComponent -> Trivia | Quote | Quantification
  ///     Quantification  -> QuantOperand Quantifier?
  ///
  mutating func parseConcatenation() throws -> AST {
    var result = Array<AST>()
    let _start = source.currentPosition

    while true {
      // Check for termination, e.g. of recursion or bin ops
      if source.isEmpty { break }
      if source.peek() == "|" || source.peek() == ")" { break }

      // TODO: refactor loop body into function
      let _start = source.currentPosition

      //     Trivia -> `lexComment` | `lexNonSemanticWhitespace`
      if let triv = try source.lexComment() {
        result.append(.trivia(triv))
        continue
      }
      if let triv = try source.lexNonSemanticWhitespace() {
        result.append(.trivia(triv))
        continue
      }

      //     Quote      -> `lexQuote`
      if let quote = try source.lexQuote() {
        result.append(.quote(.init(quote.value, loc(_start))))
        continue
      }
      //     Quantification  -> QuantOperand Quantifier?
      if let operand = try parseQuantifierOperand() {
        if let (amt, kind) = try source.lexQuantifier() {
           result.append(.quantification(.init(
            amt, kind, operand, loc(_start))))
        } else {
          result.append(operand)
        }
        continue
      }

      fatalError("unreachable?")
    }
    guard !result.isEmpty else {
      return .empty(.init(loc(_start)))
    }
    if result.count == 1 {
      return result[0]
    }

    return .concatenation(.init(result, loc(_start)))
  }

  /// Parse a (potentially quantified) component
  ///
  ///     QuantOperand -> Group | CustomCharClass | Atom
  ///     Group        -> GroupStart Regex ')'
  ///     
  mutating func parseQuantifierOperand() throws -> AST? {
    assert(!source.isEmpty)

    let _start = source.currentPosition

    if let kind = try source.lexGroupStart() {
      priorGroupCount += 1
      let child = try parse()
      // An implicit scoped group has already consumed its closing paren.
      if !kind.value.hasImplicitScope {
        try source.expect(")")
      }
      return .group(.init(kind, child, loc(_start)))
    }
    if let cccStart = try source.lexCustomCCStart() {
      return .customCharacterClass(
        try parseCustomCharacterClass(cccStart))
    }

    if let atom = try source.lexAtom(
      isInCustomCharacterClass: isInCustomCharacterClass,
      priorGroupCount: priorGroupCount
    ) {
      // TODO: track source locations
      return .atom(atom)
    }

    return nil
  }
}

// MARK: - Custom character classes

/// `AST.CustomCharacterClass.Start` is a mouthful
internal typealias CustomCC = AST.CustomCharacterClass

extension Parser {
  /// Parse a custom character class
  ///
  ///     CustomCharClass -> Start Set (SetOp Set)* ']'
  ///     Set             -> Member+
  ///     Member          -> CustomCharClass | !']' !SetOp (Range | Atom)
  ///     Range           -> Atom `-` Atom
  ///
  mutating func parseCustomCharacterClass(
    _ start: Source.Located<CustomCC.Start>
  ) throws -> CustomCC {
    typealias Member = CustomCC.Member
    try source.expectNonEmpty()

    var members: Array<Member> = []
    try parseCCCMembers(into: &members)

    // If we have a binary set operator, parse it and the next members. Note
    // that this means we left associate for a chain of operators.
    // TODO: We may want to diagnose and require users to disambiguate, at least
    // for chains of separate operators.
    // TODO: What about precedence?
    while let binOp = try source.lexCustomCCBinOp() {
      var rhs: Array<Member> = []
      try parseCCCMembers(into: &rhs)

      if members.isEmpty || rhs.isEmpty {
        throw ParseError.expectedCustomCharacterClassMembers
      }

      // If we're done, bail early
      let setOp = Member.setOperation(members, binOp, rhs)
      if source.tryEat("]") {
        return CustomCC(
          start, [setOp], loc(start.location.start))
      }

      // Otherwise it's just another member to accumulate
      members = [setOp]
    }
    if members.isEmpty {
      throw ParseError.expectedCustomCharacterClassMembers
    }
    try source.expect("]")
    return CustomCC(start, members, loc(start.location.start))
  }

  mutating func parseCCCMembers(
    into members: inout Array<CustomCC.Member>
  ) throws {
    // Parse members until we see the end of the custom char class or an
    // operator.
    while source.peek() != "]" && source.peekCCBinOp() == nil {

      // Nested custom character class.
      if let cccStart = try source.lexCustomCCStart() {
        members.append(.custom(try parseCustomCharacterClass(cccStart)))
        continue
      }

      guard let atom = try source.lexAtom(
        isInCustomCharacterClass: true, priorGroupCount: priorGroupCount)
      else { break }

      // Range between atoms.
      if let (dashLoc, rhs) = try source.lexCustomCharClassRangeEnd(
        priorGroupCount: priorGroupCount
      ) {
        guard atom.literalCharacterValue != nil &&
              rhs.literalCharacterValue != nil else {
          throw ParseError.invalidCharacterClassRangeOperand
        }
        members.append(.range(.init(atom, dashLoc, rhs)))
        continue
      }

      members.append(.atom(atom))
      continue
    }
  }
}

public func parse<S: StringProtocol>(
  _ regex: S, _ syntax: SyntaxOptions
) throws -> AST where S.SubSequence == Substring
{
  let source = Source(String(regex), syntax)
  var parser = Parser(source)
  return try parser.parse()
}

/// Parse a given regex string with delimiters, inferring the syntax options
/// from the delimiter used.
public func parseWithDelimiters<S: StringProtocol>(
  _ regex: S
) throws -> AST where S.SubSequence == Substring {
  let (contents, delim) = droppingRegexDelimiters(String(regex))
  return try parse(contents, delim.defaultSyntaxOptions)
}

extension String: Error {}
