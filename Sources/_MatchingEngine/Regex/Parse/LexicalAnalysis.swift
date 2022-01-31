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

Lexical analysis aids parsing by handling local ("lexical")
concerns upon request.

API convention:

- lexFoo will try to consume a foo and return it if successful, throws errors
- expectFoo will consume a foo, throwing errors, and throw an error if it can't
- eat() and tryEat() is still used by the parser as a character-by-character interface
*/

extension Source {
  // MARK: - recordLoc

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  fileprivate mutating func recordLoc<T>(
    _ f: (inout Self) throws -> T
  ) rethrows -> Located<T> {
    let start = currentPosition
    do {
      let result = try f(&self)
      return Located(result, Location(start..<currentPosition))
    } catch let e as LocatedError<ParseError> {
      throw e
    } catch let e as ParseError {
      throw LocatedError(e, Location(start..<currentPosition))
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  fileprivate mutating func recordLoc<T>(
    _ f: (inout Self) throws -> T?
  ) rethrows -> Located<T>? {
    let start = currentPosition
    do {
      guard let result = try f(&self) else { return nil }
      return Located(result, start..<currentPosition)
    } catch let e as Source.LocatedError<ParseError> {
      throw e
    } catch let e as ParseError {
      throw LocatedError(e, start..<currentPosition)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  @discardableResult
  fileprivate mutating func recordLoc(
    _ f: (inout Self) throws -> ()
  ) rethrows -> SourceLocation {
    let start = currentPosition
    do {
      try f(&self)
      return SourceLocation(start..<currentPosition)
    } catch let e as Source.LocatedError<ParseError> {
      throw e
    } catch let e as ParseError {
      throw LocatedError(e, start..<currentPosition)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }
}

// MARK: - Consumption routines
extension Source {
  typealias Quant = AST.Quantification

  /// Throws an expected character error if not matched
  @discardableResult
  mutating func expect(_ c: Character) throws -> SourceLocation {
    try recordLoc { src in
      guard src.tryEat(c) else {
        throw ParseError.expected(String(c))
      }
    }
  }

  /// Throws an expected character error if not matched
  mutating func expect<C: Collection>(
    sequence c: C
  ) throws where C.Element == Character {
    _ = try recordLoc { src in
      guard src.tryEat(sequence: c) else {
        throw ParseError.expected(String(c))
      }
    }
  }

  /// Throws an unexpected end of input error if not matched
  ///
  /// Note: much of the time, but not always, we can vend a more specific error.
  mutating func expectNonEmpty(
    _ error: ParseError = .unexpectedEndOfInput
  ) throws {
    _ = try recordLoc { src in
      if src.isEmpty { throw error }
    }
  }

  mutating func tryEatNonEmpty<C: Collection>(sequence c: C) throws -> Bool
    where C.Element == Char
  {
    try expectNonEmpty(.expected(String(c)))
    return tryEat(sequence: c)
  }

  mutating func tryEatNonEmpty(_ c: Char) throws -> Bool {
    try tryEatNonEmpty(sequence: String(c))
  }

  /// Attempt to make a series of lexing steps in `body`, returning `nil` if
  /// unsuccesful, which will revert the source back to its previous state. If
  /// an error is thrown, the source will not be reverted.
  mutating func tryEating<T>(
    _ body: (inout Source) throws -> T?
  ) rethrows -> T? {
    // We don't revert the source if an error is thrown, as it's useful to
    // maintain the source location in that case.
    let current = self
    guard let result = try body(&self) else {
      self = current
      return nil
    }
    return result
  }

  /// Attempt to eat the given character, returning its source location if
  /// successful, `nil` otherwise.
  mutating func tryEatWithLoc(_ c: Character) -> SourceLocation? {
    let start = currentPosition
    guard tryEat(c) else { return nil }
    return .init(start ..< currentPosition)
  }

  /// Throws an expected ASCII character error if not matched
  mutating func expectASCII() throws -> Located<Character> {
    try recordLoc { src in
      guard let c = src.peek() else {
        throw ParseError.unexpectedEndOfInput
      }
      guard c.isASCII else {
        throw ParseError.expectedASCII(c)
      }
      src.eat(asserting: c)
      return c
    }
  }
}

enum RadixKind {
  case octal, decimal, hex

  var characterFilter: (Character) -> Bool {
    switch self {
    case .octal:   return \.isOctalDigit
    case .decimal: return \.isNumber
    case .hex:     return \.isHexDigit
    }
  }
  var radix: Int {
    switch self {
    case .octal:   return 8
    case .decimal: return 10
    case .hex:     return 16
    }
  }
}

enum IdentifierKind {
  case groupName
  case onigurumaCalloutName
  case onigurumaCalloutTag
}

extension Source {
  /// Validate a string of digits as a particular radix, and return the number,
  /// or throw an error if the string is malformed or would overflow the number
  /// type.
  private static func validateNumber<Num: FixedWidthInteger>(
    _ str: String, _: Num.Type, _ kind: RadixKind
  ) throws -> Num {
    guard !str.isEmpty && str.all(kind.characterFilter) else {
      throw ParseError.expectedNumber(str, kind: kind)
    }
    guard let i = Num(str, radix: kind.radix) else {
      throw ParseError.numberOverflow(str)
    }
    return i
  }

  /// Validate a string of digits as a unicode scalar of a particular radix, and
  /// return the scalar value, or throw an error if the string is malformed or
  /// would overflow the scalar.
  private static func validateUnicodeScalar(
    _ str: String, _ kind: RadixKind
  ) throws -> Unicode.Scalar {
    let num = try validateNumber(str, UInt32.self, kind)
    guard let scalar = Unicode.Scalar(num) else {
      throw ParseError.misc("Invalid scalar value U+\(num.hexStr)")
    }
    return scalar
  }

  /// Try to eat a number of a particular type and radix off the front.
  ///
  /// Returns: `nil` if there's no number, otherwise the number
  ///
  /// Throws on overflow
  ///
  private mutating func lexNumber<Num: FixedWidthInteger>(
    _ ty: Num.Type, _ kind: RadixKind
  ) throws -> Located<Num>? {
    try recordLoc { src in
      guard let str = src.tryEatPrefix(kind.characterFilter)?.string else {
        return nil
      }
      guard let i = Num(str, radix: kind.radix) else {
        throw ParseError.numberOverflow(str)
      }
      return i
    }
  }

  /// Try to eat a number off the front.
  ///
  /// Returns: `nil` if there's no number, otherwise the number
  ///
  /// Throws on overflow
  ///
  mutating func lexNumber() throws -> Located<Int>? {
    try lexNumber(Int.self, .decimal)
  }

  mutating func expectNumber() throws -> Located<Int> {
    guard let num = try lexNumber() else {
      throw ParseError.expectedNumber("", kind: .decimal)
    }
    return num
  }

  /// Eat a scalar value from hexadecimal notation off the front
  private mutating func expectUnicodeScalar(
    numDigits: Int
  ) throws -> Located<Unicode.Scalar> {
    try recordLoc { src in
      let str = src.eat(upToCount: numDigits).string
      guard str.count == numDigits else {
        throw ParseError.expectedNumDigits(str, numDigits)
      }
      return try Source.validateUnicodeScalar(str, .hex)
    }
  }

  /// Eat a scalar off the front, starting from after the
  /// backslash and base character (e.g. `\u` or `\x`).
  ///
  ///     UniScalar -> 'u{' HexDigit{1...} '}'
  ///                | 'u'  HexDigit{4}
  ///                | 'x{' HexDigit{1...} '}'
  ///                | 'x'  HexDigit{0...2}
  ///                | 'U'  HexDigit{8}
  ///                | 'o{' OctalDigit{1...} '}'
  ///                | OctalDigit{1...3}
  ///
  mutating func expectUnicodeScalar(
    escapedCharacter base: Character
  ) throws -> Located<Unicode.Scalar> {
    try recordLoc { src in
      // TODO: PCRE offers a different behavior if PCRE2_ALT_BSUX is set.
      switch base {
      // Hex numbers.
      case "u" where src.tryEat("{"), "x" where src.tryEat("{"):
        let str = try src.lexUntil(eating: "}").value
        return try Source.validateUnicodeScalar(str, .hex)

      case "x":
        // \x expects *up to* 2 digits.
        guard let digits = src.tryEatPrefix(maxLength: 2, \.isHexDigit) else {
          // In PCRE, \x without any valid hex digits is \u{0}.
          // TODO: This doesn't appear to be followed by ICU or Oniguruma, so
          // could be changed to throw an error if we had a parsing mode for
          // them.
          return Unicode.Scalar(0)
        }
        return try Source.validateUnicodeScalar(digits.string, .hex)

      case "u":
        return try src.expectUnicodeScalar(numDigits: 4).value
      case "U":
        return try src.expectUnicodeScalar(numDigits: 8).value

      // Octal numbers.
      case "o" where src.tryEat("{"):
        let str = try src.lexUntil(eating: "}").value
        return try Source.validateUnicodeScalar(str, .octal)

      case let c where c.isOctalDigit:
        // We can read *up to* 2 more octal digits per PCRE.
        // FIXME: ICU can read up to 3 octal digits if the leading digit is 0,
        // we should have a parser mode to switch.
        let nextDigits = src.tryEatPrefix(maxLength: 2, \.isOctalDigit)
        let str = String(c) + (nextDigits?.string ?? "")
        return try Source.validateUnicodeScalar(str, .octal)

      default:
        fatalError("Unexpected scalar start")
      }
    }
  }

  /// Try to consume a quantifier
  ///
  ///     Quantifier -> ('*' | '+' | '?' | '{' Range '}') QuantKind?
  ///     QuantKind  -> '?' | '+'
  ///
  mutating func lexQuantifier(context: ParsingContext) throws -> (
    Located<Quant.Amount>, Located<Quant.Kind>
  )? {
    let amt: Located<Quant.Amount>? = try recordLoc { src in
      if src.tryEat("*") { return .zeroOrMore }
      if src.tryEat("+") { return .oneOrMore }
      if src.tryEat("?") { return .zeroOrOne }

      return try src.tryEating { src in
        guard src.tryEat("{"),
              let range = try src.lexRange(context: context),
              src.tryEat("}")
        else { return nil }
        return range.value
      }
    }
    guard let amt = amt else { return nil }

    let kind: Located<Quant.Kind> = recordLoc { src in
      if src.tryEat("?") { return .reluctant  }
      if src.tryEat("+") { return .possessive }
      return .eager
    }

    return (amt, kind)
  }

  /// Try to consume a range, returning `nil` if unsuccessful.
  ///
  ///     Range       -> ',' <Int> | <Int> ',' <Int>? | <Int>
  ///                  | ExpRange
  ///     ExpRange    -> '..<' <Int> | '...' <Int>
  ///                  | <Int> '..<' <Int> | <Int> '...' <Int>?
  mutating func lexRange(context: ParsingContext) throws -> Located<Quant.Amount>? {
    try recordLoc { src in
      try src.tryEating { src in
        let lowerOpt = try src.lexNumber()

        // ',' or '...' or '..<' or nothing
        // TODO: We ought to try and consume whitespace here and emit a
        // diagnostic for the user warning them that it would cause the range to
        // be treated as literal.
        let closedRange: Bool?
        if src.tryEat(",") {
          closedRange = true
        } else if context.experimentalRanges && src.tryEat(".") {
          try src.expect(".")
          if src.tryEat(".") {
            closedRange = true
          } else {
            try src.expect("<")
            closedRange = false
          }
        } else {
          closedRange = nil
        }

        let upperOpt = try src.lexNumber()?.map { upper in
          // If we have an open range, the upper bound should be adjusted down.
          closedRange == true ? upper : upper - 1
        }

        switch (lowerOpt, closedRange, upperOpt) {
        case let (l?, nil, nil):
          return .exactly(l)
        case let (l?, true, nil):
          return .nOrMore(l)
        case let (nil, _?, u?):
          return .upToN(u)
        case let (l?, _?, u?):
          return .range(l, u)

        case (nil, nil, _?):
          fatalError("Didn't lex lower bound, but lexed upper bound?")
        default:
          return nil
        }
      }
    }
  }

  private mutating func lexUntil(
    _ predicate: (inout Source) throws -> Bool
  ) rethrows -> Located<String> {
    try recordLoc { src in
      var result = ""
      while try !predicate(&src) {
        result.append(src.eat())
      }
      return result
    }
  }

  private mutating func lexUntil(eating end: String) throws -> Located<String> {
    try lexUntil { try $0.tryEatNonEmpty(sequence: end) }
  }

  private mutating func lexUntil(
    eating end: Character
  ) throws -> Located<String> {
    try lexUntil(eating: String(end))
  }

  /// Expect a linear run of non-nested non-empty content ending with a given
  /// delimiter. If `ignoreEscaped` is true, escaped characters will not be
  /// considered for the ending delimiter.
  private mutating func expectQuoted(
    endingWith endSingle: String, count: Int = 1, ignoreEscaped: Bool = false,
    eatEnding: Bool = true
  ) throws -> Located<String> {
    let end = String(repeating: endSingle, count: count)
    let result = try recordLoc { src -> String in
      try src.lexUntil { src in
        if src.starts(with: end) {
          return true
        }
        try src.expectNonEmpty(.expected(endSingle))

        // Ignore escapes if we're allowed to. lexUntil will consume the next
        // character.
        if ignoreEscaped, src.tryEat("\\") {
          try src.expectNonEmpty(.expectedEscape)
        }
        return false
      }.value
    }
    guard !result.value.isEmpty else {
      throw ParseError.expectedNonEmptyContents
    }
    if eatEnding {
      try expect(sequence: end)
    }
    return result
  }

  /// Try to consume quoted content
  ///
  ///     Quote -> '\Q' (!'\E' .)* '\E'
  ///
  /// With `SyntaxOptions.experimentalQuotes`, also accepts
  ///
  ///     ExpQuote -> '"' ('\"' | [^"])* '"'
  ///
  /// Future: Experimental quotes are full fledged Swift string literals
  ///
  /// TODO: Need to support some escapes
  ///
  mutating func lexQuote(context: ParsingContext) throws -> AST.Quote? {
    let str = try recordLoc { src -> String? in
      if src.tryEat(sequence: #"\Q"#) {
        return try src.expectQuoted(endingWith: #"\E"#).value
      }
      if context.experimentalQuotes, src.tryEat("\"") {
        return try src.expectQuoted(endingWith: "\"", ignoreEscaped: true).value
      }
      return nil
    }
    guard let str = str else { return nil }
    return AST.Quote(str.value, str.location)
  }

  /// Try to consume a comment
  ///
  ///     Comment -> '(?#' [^')']* ')'
  ///
  /// With `SyntaxOptions.experimentalComments`
  ///
  ///     ExpComment -> '/*' (!'*/' .)* '*/'
  ///
  /// TODO: Swift-style nested comments, line-ending comments, etc
  ///
  mutating func lexComment(context: ParsingContext) throws -> AST.Trivia? {
    let trivia: Located<String>? = try recordLoc { src in
      if src.tryEat(sequence: "(?#") {
        return try src.expectQuoted(endingWith: ")").value
      }
      if context.experimentalComments, src.tryEat(sequence: "/*") {
        return try src.expectQuoted(endingWith: "*/").value
      }
      return nil
    }
    guard let trivia = trivia else { return nil }
    return AST.Trivia(trivia)
  }

  /// Try to consume non-semantic whitespace as trivia
  ///
  ///     Whitespace -> ' '+
  ///
  /// Does nothing unless `SyntaxOptions.nonSemanticWhitespace` is set
  mutating func lexNonSemanticWhitespace(
    context: ParsingContext
  ) throws -> AST.Trivia? {
    guard context.ignoreWhitespace else { return nil }
    let trivia: Located<String>? = recordLoc { src in
      src.tryEatPrefix { $0 == " " }?.string
    }
    guard let trivia = trivia else { return nil }
    return AST.Trivia(trivia)
  }

  /// Try to consume trivia.
  ///
  ///     Trivia -> Comment | Whitespace
  ///
  mutating func lexTrivia(context: ParsingContext) throws -> AST.Trivia? {
    if let comment = try lexComment(context: context) {
      return comment
    }
    if let whitespace = try lexNonSemanticWhitespace(context: context) {
      return whitespace
    }
    return nil
  }

  /// Try to lex a matching option.
  ///
  ///     MatchingOption -> 'i' | 'J' | 'm' | 'n' | 's' | 'U' | 'x' | 'xx' | 'w'
  ///                     | 'D' | 'P' | 'S' | 'W' | 'y{' ('g' | 'w') '}'
  ///
  mutating func lexMatchingOption() throws -> AST.MatchingOption? {
    typealias OptKind = AST.MatchingOption.Kind

    let locOpt = try recordLoc { src -> OptKind? in
      func advanceAndReturn(_ o: OptKind) -> OptKind {
        src.advance()
        return o
      }
      guard let c = src.peek() else { return nil }
      switch c {
      // PCRE options.
      case "i": return advanceAndReturn(.caseInsensitive)
      case "J": return advanceAndReturn(.allowDuplicateGroupNames)
      case "m": return advanceAndReturn(.multiline)
      case "n": return advanceAndReturn(.noAutoCapture)
      case "s": return advanceAndReturn(.singleLine)
      case "U": return advanceAndReturn(.reluctantByDefault)
      case "x":
        src.advance()
        return src.tryEat("x") ? .extraExtended : .extended

      // ICU options.
      case "w": return advanceAndReturn(.unicodeWordBoundaries)

      // Oniguruma options.
      case "D": return advanceAndReturn(.asciiOnlyDigit)
      case "P": return advanceAndReturn(.asciiOnlyPOSIXProps)
      case "S": return advanceAndReturn(.asciiOnlySpace)
      case "W": return advanceAndReturn(.asciiOnlyWord)
      case "y":
        src.advance()
        try src.expect("{")
        let opt: OptKind
        if src.tryEat("w") {
          opt = .textSegmentWordMode
        } else {
          try src.expect("g")
          opt = .textSegmentGraphemeMode
        }
        try src.expect("}")
        return opt

      // Swift semantic level options
      case "X": return advanceAndReturn(.graphemeClusterSemantics)
      case "u": return advanceAndReturn(.unicodeScalarSemantics)
      case "b": return advanceAndReturn(.byteSemantics)
        
      default:
        return nil
      }
    }
    guard let locOpt = locOpt else { return nil }
    return .init(locOpt.value, location: locOpt.location)
  }

  /// Try to lex a sequence of matching options.
  ///
  ///     MatchingOptionSeq -> '^' MatchingOption* | MatchingOption+
  ///                        | MatchingOption* '-' MatchingOption*
  ///
  mutating func lexMatchingOptionSequence(
  ) throws -> AST.MatchingOptionSequence? {
    let ateCaret = recordLoc { $0.tryEat("^") }

    // TODO: Warn on duplicate options, and options appearing in both adding
    // and removing lists?
    var adding: [AST.MatchingOption] = []
    while let opt = try lexMatchingOption() {
      adding.append(opt)
    }

    // If the sequence begun with a caret '^', options can only be added, so
    // we're done.
    if ateCaret.value {
      if peek() == "-" {
        throw ParseError.cannotRemoveMatchingOptionsAfterCaret
      }
      return .init(caretLoc: ateCaret.location, adding: adding, minusLoc: nil,
                   removing: [])
    }

    // Try to lex options to remove.
    let ateMinus = recordLoc { $0.tryEat("-") }
    if ateMinus.value {
      var removing: [AST.MatchingOption] = []
      while let opt = try lexMatchingOption() {
        // Text segment options can only be added, they cannot be removed
        // with (?-), they should instead be set to a different mode.
        if opt.isTextSegmentMode {
          throw ParseError.cannotRemoveTextSegmentOptions
        }
        // Matching semantics options can only be added, not removed.
        if opt.isSemanticMatchingLevel {
          throw ParseError.cannotRemoveSemanticsOptions
        }
        removing.append(opt)
      }
      return .init(caretLoc: nil, adding: adding, minusLoc: ateMinus.location,
                   removing: removing)
    }
    guard !adding.isEmpty else { return nil }
    return .init(caretLoc: nil, adding: adding, minusLoc: nil, removing: [])
  }

  /// Try to consume explicitly spelled-out PCRE2 group syntax.
  mutating func lexExplicitPCRE2GroupStart() -> AST.Group.Kind? {
    tryEating { src in
      guard src.tryEat(sequence: "(*") else { return nil }

      if src.tryEat(sequence: "atomic:") {
        return .atomicNonCapturing
      }
      if src.tryEat(sequence: "pla:") ||
          src.tryEat(sequence: "positive_lookahead:") {
        return .lookahead
      }
      if src.tryEat(sequence: "nla:") ||
          src.tryEat(sequence: "negative_lookahead:") {
        return .negativeLookahead
      }
      if src.tryEat(sequence: "plb:") ||
          src.tryEat(sequence: "positive_lookbehind:") {
        return .lookbehind
      }
      if src.tryEat(sequence: "nlb:") ||
          src.tryEat(sequence: "negative_lookbehind:") {
        return .negativeLookbehind
      }
      if src.tryEat(sequence: "napla:") ||
          src.tryEat(sequence: "non_atomic_positive_lookahead:") {
        return .nonAtomicLookahead
      }
      if src.tryEat(sequence: "naplb:") ||
          src.tryEat(sequence: "non_atomic_positive_lookbehind:") {
        return .nonAtomicLookbehind
      }
      if src.tryEat(sequence: "sr:") || src.tryEat(sequence: "script_run:") {
        return .scriptRun
      }
      if src.tryEat(sequence: "asr:") ||
          src.tryEat(sequence: "atomic_script_run:") {
        return .atomicScriptRun
      }
      return nil
    }
  }

  /// Consume an identifier.
  ///
  ///     Identifier -> [\w--\d] \w*
  ///
  private mutating func expectIdentifier(
    _ kind: IdentifierKind, endingWith ending: String, eatEnding: Bool = true
  ) throws -> Located<String> {
    let str = try recordLoc { src -> String in
      if src.isEmpty || src.tryEat(sequence: ending) {
        throw ParseError.expectedIdentifier(kind)
      }
      if src.peek()!.isNumber {
        throw ParseError.identifierCannotStartWithNumber(kind)
      }
      guard let str = src.tryEatPrefix(\.isWordCharacter)?.string else {
        throw ParseError.identifierMustBeAlphaNumeric(kind)
      }
      return str
    }
    if eatEnding {
      try expect(sequence: ending)
    }
    return str
  }

  /// Try to consume an identifier, returning `nil` if unsuccessful.
  private mutating func lexIdentifier(
    _ kind: IdentifierKind, endingWith end: String, eatEnding: Bool = true
  ) -> Located<String>? {
    tryEating { src in
      try? src.expectIdentifier(kind, endingWith: end, eatEnding: eatEnding)
    }
  }

  /// Consume a named group field, producing either a named capture or balanced
  /// capture.
  ///
  ///     NamedGroup    -> 'P<' GroupNameBody '>'
  ///                    | '<' GroupNameBody '>'
  ///                    | "'" GroupNameBody "'"
  ///     GroupNameBody -> Identifier | Identifier? '-' Identifier
  ///
  private mutating func expectNamedGroup(
    endingWith ending: String
  ) throws -> AST.Group.Kind {
    func lexBalanced(_ lhs: Located<String>? = nil) throws -> AST.Group.Kind? {
      // If we have a '-', this is a .NET-style 'balanced group'.
      guard let dash = tryEatWithLoc("-") else { return nil }
      let rhs = try expectIdentifier(.groupName, endingWith: ending)
      return .balancedCapture(.init(name: lhs, dash: dash, priorName: rhs))
    }

    // Lex a group name, trying to lex a '-rhs' for a balanced capture group
    // both before and after.
    if let b = try lexBalanced() { return b }
    let name = try expectIdentifier(
      .groupName, endingWith: ending, eatEnding: false
    )
    if let b = try lexBalanced(name) { return b }

    try expect(sequence: ending)
    return .namedCapture(name)
  }

  /// Try to consume the start of a group
  ///
  ///     GroupStart -> '(?' GroupKind | '('
  ///     GroupKind  -> ':' | '|' | '>' | '=' | '!' | '*' | '<=' | '<!' | '<*'
  ///                 | NamedGroup | MatchingOptionSeq (':' | ')')
  ///
  /// If `SyntaxOptions.experimentalGroups` is enabled, also accepts:
  ///
  ///     ExpGroupStart -> '(_:'
  ///
  /// Future: Named groups of the form `(name: ...)`
  ///
  /// Note: we exclude comments from being `Group`s, since
  /// they do not nest: they parse like quotes. They actually
  /// need to be parsed earlier than the group check, as
  /// comments, like quotes, cannot be quantified.
  ///
  mutating func lexGroupStart(
    context: ParsingContext
  ) throws -> Located<AST.Group.Kind>? {
    try recordLoc { src in
      try src.tryEating { src in
        // Explicitly spelled out PRCE2 syntax for some groups. This needs to be
        // done before group-like atoms, as it uses the '(*' syntax, which is
        // otherwise a group-like atom.
        if let g = src.lexExplicitPCRE2GroupStart() { return g }

        // There are some atoms that syntactically look like groups, bail here
        // if we see any. Care needs to be taken here as e.g a group starting
        // with '(?-' is a subpattern if the next character is a digit,
        // otherwise a matching option specifier. Conversely, '(?P' can be the
        // start of a matching option sequence, or a reference if it is followed
        // by '=' or '<'.
        guard !src.shouldLexGroupLikeAtom() else { return nil }

        guard src.tryEat("(") else { return nil }
        if src.tryEat("?") {
          if src.tryEat(":") { return .nonCapture }
          if src.tryEat("|") { return .nonCaptureReset }
          if src.tryEat(">") { return .atomicNonCapturing }
          if src.tryEat("=") { return .lookahead }
          if src.tryEat("!") { return .negativeLookahead }
          if src.tryEat("*") { return .nonAtomicLookahead }

          if src.tryEat(sequence: "<=") { return .lookbehind }
          if src.tryEat(sequence: "<!") { return .negativeLookbehind }
          if src.tryEat(sequence: "<*") { return .nonAtomicLookbehind }

          // Named
          if src.tryEat("<") || src.tryEat(sequence: "P<") {
            return try src.expectNamedGroup(endingWith: ">")
          }
          if src.tryEat("'") {
            return try src.expectNamedGroup(endingWith: "'")
          }

          // Matching option changing group (?iJmnsUxxxDPSWy{..}-iJmnsUxxxDPSW:).
          if let seq = try src.lexMatchingOptionSequence() {
            if src.tryEat(":") {
              return .changeMatchingOptions(seq, isIsolated: false)
            }
            // If this isn't start of an explicit group, we should have an
            // implicit group that covers the remaining elements of the current
            // group.
            // TODO: This implicit scoping behavior matches Oniguruma, but PCRE
            // also does it across alternations, which will require additional
            // handling.
            guard src.tryEat(")") else {
              if let next = src.peek() {
                throw ParseError.invalidMatchingOption(next)
              }
              throw ParseError.expected(")")
            }
            return .changeMatchingOptions(seq, isIsolated: true)
          }

          guard let next = src.peek() else {
            throw ParseError.expectedGroupSpecifier
          }
          throw ParseError.unknownGroupKind("?\(next)")
        }

        // (_:)
        if context.experimentalCaptures && src.tryEat(sequence: "_:") {
          return .nonCapture
        }
        // TODO: (name:)

        return .capture
      }
    }
  }

  /// Consume a PCRE version number.
  ///
  ///     PCREVersionNumber -> <Int>.<Int>
  ///
  private mutating func expectPCREVersionNumber(
  ) throws -> AST.Conditional.Condition.PCREVersionNumber {
    let nums = try recordLoc { src -> (major: Int, minor: Int) in
      let major = try src.expectNumber().value
      try src.expect(".")
      let minor = try src.expectNumber().value
      return (major, minor)
    }
    return .init(major: nums.value.major, minor: nums.value.minor,
                 nums.location)
  }

  /// Consume a PCRE version check suffix.
  ///
  ///     PCREVersionCheck -> '>'? '=' PCREVersionNumber
  ///
  private mutating func expectPCREVersionCheck(
  ) throws -> AST.Conditional.Condition.Kind {
    typealias Kind = AST.Conditional.Condition.PCREVersionCheck.Kind
    let kind = try recordLoc { src -> Kind in
      let greaterThan = src.tryEat(">")
      try src.expect("=")
      return greaterThan ? .greaterThanOrEqual : .equal
    }
    return .pcreVersionCheck(.init(kind, try expectPCREVersionNumber()))
  }

  /// Try to lex a known condition (excluding group conditions).
  ///
  ///     KnownCondition -> 'R'
  ///                     | 'R' NumberRef
  ///                     | 'R&' <String> !')'
  ///                     | '<' NameRef '>'
  ///                     | "'" NameRef "'"
  ///                     | 'DEFINE'
  ///                     | 'VERSION' VersionCheck
  ///                     | NumberRef
  ///                     | NameRef
  ///
  private mutating func lexKnownCondition(
    context: ParsingContext
  ) throws -> AST.Conditional.Condition? {
    typealias ConditionKind = AST.Conditional.Condition.Kind

    let kind = try recordLoc { src -> ConditionKind? in
      try src.tryEating { src in

        // PCRE recursion check.
        if src.tryEat("R") {
          if src.tryEat("&") {
            return .groupRecursionCheck(
              try src.expectNamedReference(endingWith: ")", eatEnding: false))
          }
          if let num = try src.lexNumber() {
            return .groupRecursionCheck(
              .init(.absolute(num.value), innerLoc: num.location))
          }
          return .recursionCheck
        }

        if let open = src.tryEat(anyOf: "<", "'") {
          // In PCRE, this can only be a named reference. In Oniguruma, it can
          // also be a numbered reference.
          let closing = String(Source.getClosingDelimiter(for: open))
          return .groupMatched(
            try src.expectNamedOrNumberedReference(endingWith: closing))
        }

        // PCRE group definition and version check.
        if src.tryEat(sequence: "DEFINE") {
          return .defineGroup
        }
        if src.tryEat(sequence: "VERSION") {
          return try src.expectPCREVersionCheck()
        }

        // If we have a numbered reference, this is a check to see if a group
        // matched. Oniguruma also permits a recursion level here.
        if let num = try src.lexNumberedReference(allowRecursionLevel: true) {
          return .groupMatched(num)
        }

        // PCRE and .NET also allow a named reference to be parsed here. PCRE
        // always treats it as a named reference, whereas .NET only treats it
        // as such if a group exists with that name. For now, just check if a
        // prior group exists with that name.
        // FIXME: This should apply to future groups too.
        // TODO: We should probably advise users to use the more explicit
        // syntax.
        let nameRef = src.lexNamedReference(
          endingWith: ")", eatEnding: false, allowRecursionLevel: true)
        if let nameRef = nameRef, context.isPriorGroupRef(nameRef.kind) {
          return .groupMatched(nameRef)
        }
        return nil
      }
    }
    guard let kind = kind else { return nil }
    return .init(kind.value, kind.location)
  }

  /// Attempt to lex a known conditional start (excluding group conditions).
  ///
  ///     KnownConditionalStart -> '(?(' KnownCondition ')'
  ///
  mutating func lexKnownConditionalStart(
    context: ParsingContext
  ) throws -> AST.Conditional.Condition? {
    try tryEating { src in
      guard src.tryEat(sequence: "(?("),
            let cond = try src.lexKnownCondition(context: context)
      else { return nil }
      try src.expect(")")
      return cond
    }
  }

  /// Attempt to lex the start of a group conditional.
  ///
  ///     GroupConditionalStart -> '(?' GroupStart
  ///
  mutating func lexGroupConditionalStart(
    context: ParsingContext
  ) throws -> Located<AST.Group.Kind>? {
    try tryEating { src in
      guard src.tryEat(sequence: "(?"),
            let group = try src.lexGroupStart(context: context)
      else { return nil }

      // Implicitly scoped groups are not supported here.
      guard !group.value.hasImplicitScope else {
        throw LocatedError(
          ParseError.unsupportedCondition("implicitly scoped group"),
          group.location
        )
      }
      return group
    }
  }

  /// Try to consume the start of an absent function.
  ///
  ///     AbsentFunctionStart -> '(?~' '|'?
  ///
  mutating func lexAbsentFunctionStart(
  ) -> Located<AST.AbsentFunction.Start>? {
    recordLoc { src in
      if src.tryEat(sequence: "(?~|") { return .withPipe }
      if src.tryEat(sequence: "(?~") { return .withoutPipe }
      return nil
    }
  }

  mutating func lexCustomCCStart(
  ) throws -> Located<CustomCC.Start>? {
    recordLoc { src in
      // POSIX named sets are atoms.
      guard !src.starts(with: "[:") else { return nil }

      if src.tryEat("[") {
        return src.tryEat("^") ? .inverted : .normal
      }
      return nil
    }
  }

  /// Try to consume a binary operator from within a custom character class
  ///
  ///     CustomCCBinOp -> '--' | '~~' | '&&'
  ///
  mutating func lexCustomCCBinOp() throws -> Located<CustomCC.SetOp>? {
    recordLoc { src in
      // TODO: Perhaps a syntax options check (!PCRE)
      // TODO: Better AST types here
      guard let binOp = src.peekCCBinOp() else { return nil }
      try! src.expect(sequence: binOp.rawValue)
      return binOp
    }
  }

  // Check to see if we can lex a binary operator.
  func peekCCBinOp() -> CustomCC.SetOp? {
    if starts(with: "--") { return .subtraction }
    if starts(with: "~~") { return .symmetricDifference }
    if starts(with: "&&") { return .intersection }
    return nil
  }

  private mutating func lexPOSIXCharacterProperty(
  ) throws -> Located<AST.Atom.CharacterProperty>? {
    try recordLoc { src in
      guard src.tryEat(sequence: "[:") else { return nil }
      let inverted = src.tryEat("^")
      let prop = try src.lexCharacterPropertyContents(end: ":]").value
      return .init(prop, isInverted: inverted, isPOSIX: true)
    }
  }

  /// Try to consume a named character.
  ///
  ///     NamedCharacter -> '\N{' CharName '}'
  ///     CharName -> 'U+' HexDigit{1...8} | [\s\w-]+
  ///
  private mutating func lexNamedCharacter() throws -> Located<AST.Atom.Kind>? {
    try recordLoc { src in
      guard src.tryEat(sequence: "N{") else { return nil }

      // We should either have a unicode scalar.
      if src.tryEat(sequence: "U+") {
        let str = try src.lexUntil(eating: "}").value
        return .scalar(try Source.validateUnicodeScalar(str, .hex))
      }

      // Or we should have a character name.
      // TODO: Validate the types of characters that can appear in the name?
      return .namedCharacter(try src.lexUntil(eating: "}").value)
    }
  }

  private mutating func lexCharacterPropertyContents(
    end: String
  ) throws -> Located<AST.Atom.CharacterProperty.Kind> {
    try recordLoc { src in
      // We should either have:
      // - 'x=y' where 'x' is a property key, and 'y' is a value.
      // - 'y' where 'y' is a value (or a bool key with an inferred value
      //   of true), and its key is inferred.
      // TODO: We could have better recovery here if we only ate the characters
      // that property keys and values can use.
      let lhs = src.lexUntil {
        $0.isEmpty || $0.peek() == "=" || $0.starts(with: end)
      }.value
      if src.tryEat("=") {
        let rhs = try src.lexUntil(eating: end).value
        return try Source.classifyCharacterProperty(key: lhs, value: rhs)
      }
      try src.expect(sequence: end)
      return try Source.classifyCharacterPropertyValueOnly(lhs)
    }
  }

  /// Try to consume a character property.
  ///
  ///     Property -> ('p{' | 'P{') Prop ('=' Prop)? '}'
  ///     Prop -> [\s\w-]+
  ///
  private mutating func lexCharacterProperty(
  ) throws -> Located<AST.Atom.CharacterProperty>? {
    try recordLoc { src in
      // '\P{...}' is the inverted version of '\p{...}'
      guard src.starts(with: "p{") || src.starts(with: "P{") else { return nil }
      let isInverted = src.peek() == "P"
      src.advance(2)

      let prop = try src.lexCharacterPropertyContents(end: "}").value
      return .init(prop, isInverted: isInverted, isPOSIX: false)
    }
  }

  /// Try to lex an absolute or relative numbered reference.
  ///
  ///     NumberRef -> ('+' | '-')? <Decimal Number> RecursionLevel?
  ///
  private mutating func lexNumberedReference(
    allowWholePatternRef: Bool = false, allowRecursionLevel: Bool = false
  ) throws -> AST.Reference? {
    let kind = try recordLoc { src -> AST.Reference.Kind? in
      // Note this logic should match canLexNumberedReference.
      if src.tryEat("+") {
        return .relative(try src.expectNumber().value)
      }
      if src.tryEat("-") {
        return .relative(try -src.expectNumber().value)
      }
      if let num = try src.lexNumber() {
        return .absolute(num.value)
      }
      return nil
    }
    guard let kind = kind else { return nil }
    guard allowWholePatternRef || kind.value != .recurseWholePattern else {
      throw ParseError.cannotReferToWholePattern
    }
    let recLevel = allowRecursionLevel ? try lexRecursionLevel() : nil
    let loc = recLevel?.location.union(with: kind.location) ?? kind.location
    return .init(kind.value, recursionLevel: recLevel, innerLoc: loc)
  }

  /// Try to consume a recursion level for a group reference.
  ///
  ///     RecursionLevel -> '+' <Int> | '-' <Int>
  ///
  private mutating func lexRecursionLevel(
  ) throws -> Located<Int>? {
    try recordLoc { src in
      if src.tryEat("+") { return try src.expectNumber().value }
      if src.tryEat("-") { return try -src.expectNumber().value }
      return nil
    }
  }

  /// Checks whether a numbered reference can be lexed.
  private func canLexNumberedReference() -> Bool {
    var src = self
    _ = src.tryEat(anyOf: "+", "-")
    guard let next = src.peek() else { return false }
    return RadixKind.decimal.characterFilter(next)
  }

  /// Eat a named reference up to a given closing delimiter.
  private mutating func expectNamedReference(
    endingWith end: String, eatEnding: Bool = true,
    allowRecursionLevel: Bool = false
  ) throws -> AST.Reference {
    // Note we don't want to eat the ending as we may also want to parse a
    // recursion level.
    let str = try expectIdentifier(
      .groupName, endingWith: end, eatEnding: false)

    // If we're allowed to, try parse a recursion level.
    let recLevel = allowRecursionLevel ? try lexRecursionLevel() : nil
    let loc = recLevel?.location.union(with: str.location) ?? str.location

    if eatEnding {
      try expect(sequence: end)
    }
    return .init(.named(str.value), recursionLevel: recLevel, innerLoc: loc)
  }

  /// Try to consume a named reference up to a closing delimiter, returning
  /// `nil` if the characters aren't valid for a named reference.
  private mutating func lexNamedReference(
    endingWith end: String, eatEnding: Bool = true,
    allowRecursionLevel: Bool = false
  ) -> AST.Reference? {
    tryEating { src in
      try? src.expectNamedReference(
        endingWith: end, eatEnding: eatEnding,
        allowRecursionLevel: allowRecursionLevel
      )
    }
  }

  /// Try to lex a numbered reference, or otherwise a named reference.
  ///
  ///     NameOrNumberRef -> NumberRef | <String>
  ///
  private mutating func expectNamedOrNumberedReference(
    endingWith ending: String, eatEnding: Bool = true,
    allowWholePatternRef: Bool = false, allowRecursionLevel: Bool = false
  ) throws -> AST.Reference {
    let num = try lexNumberedReference(
      allowWholePatternRef: allowWholePatternRef,
      allowRecursionLevel: allowRecursionLevel
    )
    if let num = num {
      if eatEnding {
        try expect(sequence: ending)
      }
      return num
    }
    return try expectNamedReference(
      endingWith: ending, eatEnding: eatEnding,
      allowRecursionLevel: allowRecursionLevel
    )
  }

  private static func getClosingDelimiter(
    for openChar: Character
  ) -> Character {
    switch openChar {
      // Identically-balanced delimiters.
      case "'", "\"", "`", "^", "%", "#", "$": return openChar
      case "<": return ">"
      case "{": return "}"
      default: fatalError("Not implemented")
    }
  }

  /// Lex an escaped reference for a backreference or subpattern.
  ///
  ///     EscapedReference -> 'g{' NameOrNumberRef '}'
  ///                       | 'g<' NameOrNumberRef '>'
  ///                       | "g'" NameOrNumberRef "'"
  ///                       | 'g' NumberRef
  ///                       | 'k<' <String> '>'
  ///                       | "k'" <String> "'"
  ///                       | 'k{' <String> '}'
  ///                       | [1-9] [0-9]+
  ///
  private mutating func lexEscapedReference(
    context: ParsingContext
  ) throws -> Located<AST.Atom.Kind>? {
    try recordLoc { src in
      try src.tryEating { src in
        guard let firstChar = src.peek() else { return nil }

        // TODO: Oniguruma can parse an additional recursion level for
        // backreferences.
        if src.tryEat("g") {
          // PCRE-style backreferences.
          if src.tryEat("{") {
            let ref = try src.expectNamedOrNumberedReference(endingWith: "}")
            return .backreference(ref)
          }

          // Oniguruma-style subpatterns.
          if let openChar = src.tryEat(anyOf: "<", "'") {
            let closing = String(Source.getClosingDelimiter(for: openChar))
            return .subpattern(try src.expectNamedOrNumberedReference(
              endingWith: closing, allowWholePatternRef: true))
          }

          // PCRE allows \g followed by a bare numeric reference.
          if let ref = try src.lexNumberedReference() {
            return .backreference(ref)
          }
          return nil
        }

        if src.tryEat("k") {
          // Perl/.NET/Oniguruma-style backreferences.
          if let openChar = src.tryEat(anyOf: "<", "'") {
            let closing = String(Source.getClosingDelimiter(for: openChar))

            // Perl only accept named references here, but Oniguruma and .NET
            // also accepts numbered references. This shouldn't be an ambiguity
            // as named references may not begin with a digit, '-', or '+'.
            // Oniguruma also allows a recursion level to be specified.
            return .backreference(try src.expectNamedOrNumberedReference(
              endingWith: closing, allowRecursionLevel: true))
          }
          // Perl/.NET also allow a named references with the '{' delimiter.
          if src.tryEat("{") {
            return .backreference(
              try src.expectNamedReference(endingWith: "}"))
          }
          return nil
        }

        // Lexing \n is tricky, as it's ambiguous with octal sequences. In PCRE
        // it is treated as a backreference if its first digit is not 0 (as that
        // is always octal) and one of the following holds:
        //
        // - It's 0 < n < 10 (as octal would be pointless here)
        // - Its first digit is 8 or 9 (as not valid octal)
        // - There have been as many prior groups as the reference.
        //
        // Oniguruma follows the same rules except the second one. e.g \81 and
        // \91 are instead treated as literal 81 and 91 respectively.
        // TODO: If we want a strict Oniguruma mode, we'll need to add a check
        // here.
        if firstChar != "0", let numAndLoc = try src.lexNumber() {
          let num = numAndLoc.value
          let ref = AST.Reference(.absolute(num), innerLoc: numAndLoc.location)
          if num < 10 || firstChar == "8" || firstChar == "9" ||
              context.isPriorGroupRef(ref.kind) {
            return .backreference(ref)
          }
          return nil
        }
        return nil
      }
    }
  }

  /// Try to lex a reference that syntactically looks like a group.
  ///
  ///     GroupLikeReference -> '(?' GroupLikeReferenceBody ')'
  ///     GroupLikeReferenceBody -> 'P=' <String>
  ///                             | 'P>' <String>
  ///                             | '&' <String>
  ///                             | 'R'
  ///                             | NumberRef
  ///
  private mutating func lexGroupLikeReference(
  ) throws -> Located<AST.Atom.Kind>? {
    try recordLoc { src in
      try src.tryEating { src in
        guard src.tryEat(sequence: "(?") else { return nil }

        // Note the below should be covered by canLexGroupLikeReference.

        // Python-style references.
        if src.tryEat(sequence: "P=") {
          return .backreference(try src.expectNamedReference(endingWith: ")"))
        }
        if src.tryEat(sequence: "P>") {
          return .subpattern(try src.expectNamedReference(endingWith: ")"))
        }

        // Perl-style subpatterns.
        if src.tryEat("&") {
          return .subpattern(try src.expectNamedReference(endingWith: ")"))
        }

        // Whole-pattern recursion, which is equivalent to (?0).
        if let loc = src.tryEatWithLoc("R") {
          try src.expect(")")
          return .subpattern(.init(.recurseWholePattern, innerLoc: loc))
        }

        // Numbered subpattern reference.
        if let ref = try src.lexNumberedReference(allowWholePatternRef: true) {
          try src.expect(")")
          return .subpattern(ref)
        }
        return nil
      }
    }
  }

  /// Whether we can lex a group-like reference after the specifier '(?'.
  private func canLexGroupLikeReference() -> Bool {
    var src = self
    if src.tryEat("P") {
      return src.tryEat(anyOf: "=", ">") != nil
    }
    if src.tryEat(anyOf: "&", "R") != nil {
      return true
    }
    return src.canLexNumberedReference()
  }

  /// Whether a group specifier should be lexed as an atom instead of a group.
  private func shouldLexGroupLikeAtom() -> Bool {
    var src = self
    guard src.tryEat("(") else { return false }

    if src.tryEat("?") {
      // The start of a reference '(?P=', '(?R', ...
      if src.canLexGroupLikeReference() { return true }

      // The start of a PCRE callout.
      if src.tryEat("C") { return true }

      // The start of an Oniguruma 'of-contents' callout.
      if src.tryEat("{") { return true }

      return false
    }
    // The start of a backreference directive or Oniguruma named callout.
    if src.tryEat("*") { return true }

    return false
  }

  /// Consume an escaped atom, starting from after the backslash
  ///
  ///     Escaped          -> KeyboardModified | Builtin
  ///                       | UniScalar | Property | NamedCharacter
  ///                       | EscapedReference
  ///
  mutating func expectEscaped(
    context: ParsingContext
  ) throws -> Located<AST.Atom.Kind> {
    try recordLoc { src in
      let ccc = context.isInCustomCharacterClass

      // Keyboard control/meta
      if src.tryEat("c") || src.tryEat(sequence: "C-") {
        return .keyboardControl(try src.expectASCII().value)
      }
      if src.tryEat(sequence: "M-\\C-") {
        return .keyboardMetaControl(try src.expectASCII().value)
      }
      if src.tryEat(sequence: "M-") {
        return .keyboardMeta(try src.expectASCII().value)
      }

      // Named character '\N{...}'.
      if let char = try src.lexNamedCharacter() {
        return char.value
      }

      // Character property \p{...} \P{...}.
      if let prop = try src.lexCharacterProperty() {
        return .property(prop.value)
      }

      // References using escape syntax, e.g \1, \g{1}, \k<...>, ...
      // These are not valid inside custom character classes.
      if !ccc, let ref = try src.lexEscapedReference(context: context)?.value {
        return ref
      }

      let char = src.eat()

      // Single-character builtins.
      if let builtin = AST.Atom.EscapedBuiltin(
        char, inCustomCharacterClass: ccc
      ) {
        return .escaped(builtin)
      }

      switch char {
      // Hexadecimal and octal unicode scalars. This must be done after
      // backreference lexing due to the ambiguity with \nnn.
      case let c where c.isOctalDigit: fallthrough
      case "u", "x", "U", "o":
        return try .scalar(
          src.expectUnicodeScalar(escapedCharacter: char).value)
      default:
        return .char(char)
      }
    }
  }

  /// Try to consume a PCRE callout.
  ///
  ///     PCRECallout     -> '(?C' CalloutBody ')'
  ///     PCRECalloutBody -> '' | <Number>
  ///                      | '`' <String> '`'
  ///                      | "'" <String> "'"
  ///                      | '"' <String> '"'
  ///                      | '^' <String> '^'
  ///                      | '%' <String> '%'
  ///                      | '#' <String> '#'
  ///                      | '$' <String> '$'
  ///                      | '{' <String> '}'
  ///
  mutating func lexPCRECallout() throws -> AST.Atom.Callout? {
    guard tryEat(sequence: "(?C") else { return nil }
    let arg = try recordLoc { src -> AST.Atom.Callout.PCRE.Argument in
      // Parse '(?C' followed by a number.
      if let num = try src.lexNumber() {
        return .number(num.value)
      }
      // '(?C)' is implicitly '(?C0)'.
      if src.peek() == ")" {
        return .number(0)
      }
      // Parse '(C?' followed by a set of balanced delimiters as defined by
      // http://pcre.org/current/doc/html/pcre2pattern.html#SEC28
      if let open = src.tryEat(anyOf: "`", "'", "\"", "^", "%", "#", "$", "{") {
        let closing = String(Source.getClosingDelimiter(for: open))
        return .string(try src.expectQuoted(endingWith: closing).value)
      }
      // If we don't know what this syntax is, consume up to the ending ')' and
      // emit an error.
      let remaining = src.lexUntil { $0.isEmpty || $0.tryEat(")") }.value
      if remaining.isEmpty {
        throw ParseError.expected(")")
      }
      throw ParseError.unknownCalloutKind("(?C\(remaining))")
    }
    try expect(")")
    return .pcre(.init(arg))
  }

  /// Consume a list of arguments for an Oniguruma callout.
  ///
  ///     OnigurumaCalloutArgList -> OnigurumaCalloutArg (',' OnigurumaCalloutArgList)*
  ///     OnigurumaCalloutArg -> [^,}]+
  ///
  mutating func expectOnigurumaCalloutArgList(
    leftBrace: SourceLocation
  ) throws -> AST.Atom.Callout.OnigurumaNamed.ArgList {
    var args: [Located<String>] = []
    while true {
      let arg = try recordLoc { src -> String in
        // TODO: Warn about whitespace being included?
        guard let arg = src.tryEatPrefix({ $0 != "," && $0 != "}" }) else {
          throw ParseError.expectedCalloutArgument
        }
        return arg.string
      }
      args.append(arg)

      if peek() == "}" { break }
      try expect(",")
    }
    let rightBrace = try expect("}")
    return .init(leftBrace, args,  rightBrace)
  }

  /// Try to consume an Oniguruma callout tag.
  ///
  ///     OnigurumaTag -> '[' Identifier ']'
  ///
  mutating func lexOnigurumaCalloutTag(
  ) throws -> AST.Atom.Callout.OnigurumaTag? {
    guard let leftBracket = tryEatWithLoc("[") else { return nil }
    let name = try expectIdentifier(
      .onigurumaCalloutTag, endingWith: "]", eatEnding: false
    )
    let rightBracket = try expect("]")
    return .init(leftBracket, name, rightBracket)
  }

  /// Try to consume a named Oniguruma callout.
  ///
  ///     OnigurumaNamedCallout -> '(*' Identifier OnigurumaTag? Args? ')'
  ///     Args                  -> '{' OnigurumaCalloutArgList '}'
  ///
  mutating func lexOnigurumaNamedCallout() throws -> AST.Atom.Callout? {
    try tryEating { src in
      guard src.tryEat(sequence: "(*") else { return nil }
      guard let name = src.lexIdentifier(
        .onigurumaCalloutName, endingWith: ")", eatEnding: false)
      else { return nil }

      let tag = try src.lexOnigurumaCalloutTag()

      let args = try src.tryEatWithLoc("{").map {
        try src.expectOnigurumaCalloutArgList(leftBrace: $0)
      }
      try src.expect(")")
      return .onigurumaNamed(.init(name, tag: tag, args: args))
    }
  }

  /// Try to consume an Oniguruma callout 'of contents'.
  ///
  ///     OnigurumaCalloutOfContents -> '(?' '{'+ Contents '}'+ OnigurumaTag? Direction? ')'
  ///     Contents                   -> <String>
  ///     Direction                  -> 'X' | '<' | '>'
  ///
  mutating func lexOnigurumaCalloutOfContents() throws -> AST.Atom.Callout? {
    try tryEating { src in
      guard src.tryEat(sequence: "(?"),
            let openBraces = src.tryEatPrefix({ $0 == "{" })
      else { return nil }

      let contents = try src.expectQuoted(
        endingWith: "}", count: openBraces.count)
      let closeBraces = SourceLocation(
        contents.location.end ..< src.currentPosition)

      let tag = try src.lexOnigurumaCalloutTag()

      typealias Direction = AST.Atom.Callout.OnigurumaOfContents.Direction
      let direction = src.recordLoc { src -> Direction in
        if src.tryEat(">") { return .inProgress }
        if src.tryEat("<") { return .inRetraction }
        if src.tryEat("X") { return .both }
        // The default is in-progress.
        return .inProgress
      }
      try src.expect(")")

      let openBracesLoc = SourceLocation(from: openBraces)
      return .onigurumaOfContents(.init(
        openBracesLoc, contents, closeBraces, tag: tag, direction: direction))
    }
  }

  /// Try to consume a backtracking directive.
  ///
  ///     BacktrackingDirective     -> '(*' BacktrackingDirectiveKind (':' <String>)? ')'
  ///     BacktrackingDirectiveKind -> 'ACCEPT' | 'FAIL' | 'F' | 'MARK' | ''
  ///                                | 'COMMIT' | 'PRUNE' | 'SKIP' | 'THEN'
  ///
  mutating func lexBacktrackingDirective(
  ) throws -> AST.Atom.BacktrackingDirective? {
    try tryEating { src in
      guard src.tryEat(sequence: "(*") else { return nil }
      let kind = src.recordLoc { src -> AST.Atom.BacktrackingDirective.Kind? in
        if src.tryEat(sequence: "ACCEPT") { return .accept }
        if src.tryEat(sequence: "FAIL") || src.tryEat("F") { return .fail }
        if src.tryEat(sequence: "MARK") || src.peek() == ":" { return .mark }
        if src.tryEat(sequence: "COMMIT") { return .commit }
        if src.tryEat(sequence: "PRUNE") { return .prune }
        if src.tryEat(sequence: "SKIP") { return .skip }
        if src.tryEat(sequence: "THEN") { return .then }
        return nil
      }
      guard let kind = kind else { return nil }
      var name: Located<String>?
      if src.tryEat(":") {
        // TODO: PCRE allows escaped delimiters or '\Q...\E' sequences in the
        // name under PCRE2_ALT_VERBNAMES.
        name = try src.expectQuoted(endingWith: ")", eatEnding: false)
      }
      try src.expect(")")

      // MARK directives must be named.
      if name == nil && kind.value == .mark {
        throw ParseError.backtrackingDirectiveMustHaveName(
          String(src[kind.location.range]))
      }
      return .init(kind, name: name)
    }
  }

  /// Consume a group-like atom, throwing an error if an atom could not be
  /// produced.
  ///
  ///     GroupLikeAtom -> GroupLikeReference | Callout | BacktrackingDirective
  ///
  mutating func expectGroupLikeAtom() throws -> AST.Atom.Kind {
    try recordLoc { src in
      // References that look like groups, e.g (?R), (?1), ...
      if let ref = try src.lexGroupLikeReference() {
        return ref.value
      }

      // (*ACCEPT), (*FAIL), (*MARK), ...
      if let b = try src.lexBacktrackingDirective() {
        return .backtrackingDirective(b)
      }

      // Global matching options can only appear at the very start.
      if let opt = try src.lexGlobalMatchingOption() {
        throw ParseError.globalMatchingOptionNotAtStart(
          String(src[opt.location.range]))
      }

      // (?C)
      if let callout = try src.lexPCRECallout() {
        return .callout(callout)
      }

      // Try to consume an Oniguruma named callout '(*name)', which should be
      // done after backtracking directives and global options.
      if let callout = try src.lexOnigurumaNamedCallout() {
        return .callout(callout)
      }

      // (?{...})
      if let callout = try src.lexOnigurumaCalloutOfContents() {
        return .callout(callout)
      }

      // If we didn't produce an atom, consume up until a reasonable end-point
      // and throw an error.
      try src.expect("(")
      let remaining = src.lexUntil {
        $0.isEmpty || $0.tryEat(anyOf: ":", ")") != nil
      }.value
      if remaining.isEmpty {
        throw ParseError.expected(")")
      }
      throw ParseError.unknownGroupKind(remaining)
    }.value
  }


  /// Try to consume an Atom.
  ///
  ///     Atom             -> SpecialCharacter | POSIXSet
  ///                       | '\' Escaped | [^')' '|']
  ///     SpecialCharacter -> '.' | '^' | '$'
  ///     POSIXSet         -> '[:' name ':]'
  ///
  /// If `SyntaxOptions.experimentalGroups` is enabled, also accepts:
  ///
  ///     ExpGroupStart -> '(_:'
  ///
  mutating func lexAtom(context: ParsingContext) throws -> AST.Atom? {
    let customCC = context.isInCustomCharacterClass
    let kind: Located<AST.Atom.Kind>? = try recordLoc { src in
      // Check for not-an-atom, e.g. parser recursion termination
      if src.isEmpty { return nil }
      if !customCC && (src.peek() == ")" || src.peek() == "|") { return nil }
      // TODO: Store customCC in the atom, if that's useful

      // POSIX character property. This is only allowed in a custom character
      // class.
      // TODO: Can we try and recover and diagnose these outside character
      // classes?
      if customCC, let prop = try src.lexPOSIXCharacterProperty()?.value {
        return .property(prop)
      }

      // If we have group syntax that was skipped over in lexGroupStart, we
      // need to handle it as an atom, or throw an error.
      if !customCC && src.shouldLexGroupLikeAtom() {
        return try src.expectGroupLikeAtom()
      }

      let char = src.eat()
      switch char {
      case ")", "|":
        if customCC {
          return .char(char)
        }
        fatalError("unreachable")

      // (sometimes) special metacharacters
      case ".": return customCC ? .char(".") : .any
      case "^": return customCC ? .char("^") : .startOfLine
      case "$": return customCC ? .char("$") : .endOfLine

      // Escaped
      case "\\": return try src.expectEscaped(context: context).value

      case "]":
        assert(!customCC, "parser should have prevented this")
        fallthrough

      default: return .char(char)
      }
    }
    guard let kind = kind else { return nil }
    return AST.Atom(kind.value, kind.location)
  }

  /// Try to lex the end of a range in a custom character class, which consists
  /// of a '-' character followed by an atom.
  mutating func lexCustomCharClassRangeEnd(
    context: ParsingContext
  ) throws -> (dashLoc: SourceLocation, AST.Atom)? {
    // Make sure we don't have a binary operator e.g '--', and the '-' is not
    // ending the custom character class (in which case it is literal).
    guard peekCCBinOp() == nil, !starts(with: "-]"),
          let dash = tryEatWithLoc("-"),
          let end = try lexAtom(context: context)
    else {
      return nil
    }
    return (dash, end)
  }

  /// Try to consume a newline sequence matching option kind.
  ///
  ///     NewlineSequenceKind -> 'BSR_ANYCRLF' | 'BSR_UNICODE'
  ///
  private mutating func lexNewlineSequenceMatchingOption(
  ) throws -> AST.GlobalMatchingOption.NewlineSequenceMatching? {
    if tryEat(sequence: "BSR_ANYCRLF") { return .anyCarriageReturnOrLinefeed }
    if tryEat(sequence: "BSR_UNICODE") { return .anyUnicode }
    return nil
  }

  /// Try to consume a newline matching option kind.
  ///
  ///     NewlineKind -> 'CRLF' | 'CR' | 'ANYCRLF' | 'ANY' | 'LF' | 'NUL'
  ///
  private mutating func lexNewlineMatchingOption(
  ) throws -> AST.GlobalMatchingOption.NewlineMatching? {
    // The ordering here is important: CRLF needs to precede CR, and ANYCRLF
    // needs to precede ANY to ensure we don't short circuit on the wrong one.
    if tryEat(sequence: "CRLF") { return .carriageAndLinefeedOnly }
    if tryEat(sequence: "CR") { return .carriageReturnOnly }
    if tryEat(sequence: "ANYCRLF") { return .anyCarriageReturnOrLinefeed }
    if tryEat(sequence: "ANY") { return .anyUnicode }

    if tryEat(sequence: "LF") { return .linefeedOnly }
    if tryEat(sequence: "NUL") { return .nulCharacter }
    return nil
  }

  /// Try to consume a global matching option kind, returning `nil` if
  /// unsuccessful.
  ///
  ///     GlobalMatchingOptionKind -> LimitOptionKind '=' <Int>
  ///                               | NewlineKind | NewlineSequenceKind
  ///                               | 'NOTEMPTY_ATSTART' | 'NOTEMPTY'
  ///                               | 'NO_AUTO_POSSESS' | 'NO_DOTSTAR_ANCHOR'
  ///                               | 'NO_JIT' | 'NO_START_OPT' | 'UTF' | 'UCP'
  ///
  ///     LimitOptionKind          -> 'LIMIT_DEPTH' | 'LIMIT_HEAP'
  ///                               | 'LIMIT_MATCH'
  ///
  private mutating func lexGlobalMatchingOptionKind(
  ) throws -> Located<AST.GlobalMatchingOption.Kind>? {
    try recordLoc { src in
      if let opt = try src.lexNewlineSequenceMatchingOption() {
        return .newlineSequenceMatching(opt)
      }
      if let opt = try src.lexNewlineMatchingOption() {
        return .newlineMatching(opt)
      }
      if src.tryEat(sequence: "LIMIT_DEPTH") {
        try src.expect("=")
        return .limitDepth(try src.expectNumber())
      }
      if src.tryEat(sequence: "LIMIT_HEAP") {
        try src.expect("=")
        return .limitHeap(try src.expectNumber())
      }
      if src.tryEat(sequence: "LIMIT_MATCH") {
        try src.expect("=")
        return .limitMatch(try src.expectNumber())
      }

      // The ordering here is important: NOTEMPTY_ATSTART needs to precede
      // NOTEMPTY to ensure we don't short circuit on the wrong one.
      if src.tryEat(sequence: "NOTEMPTY_ATSTART") { return .notEmptyAtStart }
      if src.tryEat(sequence: "NOTEMPTY") { return .notEmpty }

      if src.tryEat(sequence: "NO_AUTO_POSSESS") { return .noAutoPossess }
      if src.tryEat(sequence: "NO_DOTSTAR_ANCHOR") { return .noDotStarAnchor }
      if src.tryEat(sequence: "NO_JIT") { return .noJIT }
      if src.tryEat(sequence: "NO_START_OPT") { return .noStartOpt }
      if src.tryEat(sequence: "UTF") { return .utfMode }
      if src.tryEat(sequence: "UCP") { return .unicodeProperties }
      return nil
    }
  }

  /// Try to consume a global matching option, returning `nil` if unsuccessful.
  ///
  ///     GlobalMatchingOption -> '(*' GlobalMatchingOptionKind ')'
  ///
  mutating func lexGlobalMatchingOption(
  ) throws -> AST.GlobalMatchingOption? {
    let kind = try recordLoc { src -> AST.GlobalMatchingOption.Kind? in
      try src.tryEating { src in
        guard src.tryEat(sequence: "(*"),
              let kind = try src.lexGlobalMatchingOptionKind()?.value
        else { return nil }
        try src.expect(")")
        return kind
      }
    }
    guard let kind = kind else { return nil }
    return .init(kind.value, kind.location)
  }

  /// Try to consume a sequence of global matching options.
  ///
  ///     GlobalMatchingOptionSequence -> GlobalMatchingOption+
  ///
  mutating func lexGlobalMatchingOptionSequence(
  ) throws -> AST.GlobalMatchingOptionSequence? {
    var opts: [AST.GlobalMatchingOption] = []
    while let opt = try lexGlobalMatchingOption() {
      opts.append(opt)
    }
    return .init(opts)
  }
}

