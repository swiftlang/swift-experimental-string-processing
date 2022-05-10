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

extension Error {
  func addingLocation(_ loc: Range<Source.Position>) -> Error {
    // If we're already a LocatedError, don't change the location.
    if self is LocatedErrorProtocol {
      return self
    }
    return Source.LocatedError<Self>(self, loc)
  }
}

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
    } catch let e {
      throw e.addingLocation(start..<currentPosition)
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

  /// Attempt to eat a given prefix that satisfies a given predicate, with the
  /// source location recorded.
  mutating func tryEatLocatedPrefix(
    maxLength: Int? = nil,
    _ f: (Char) -> Bool
  ) -> Located<String>? {
    let result = recordLoc { src in
      src.tryEatPrefix(maxLength: maxLength, f)
    }
    guard let result = result else { return nil }
    return result.map(\.string)
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
    _ str: Source.Located<String>, _ kind: RadixKind
  ) throws -> AST.Atom.Scalar {
    let num = try validateNumber(str.value, UInt32.self, kind)
    guard let scalar = Unicode.Scalar(num) else {
      throw ParseError.misc("Invalid scalar value U+\(num.hexStr)")
    }
    return .init(scalar, str.location)
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
  ) throws -> AST.Atom.Scalar {
    let str = try recordLoc { src -> String in
      let str = src.eat(upToCount: numDigits).string
      guard str.count == numDigits else {
        throw ParseError.expectedNumDigits(str, numDigits)
      }
      return str
    }
    return try Source.validateUnicodeScalar(str, .hex)
  }

  /// Try to lex a seqence of hex digit unicode scalars.
  ///
  ///     UniScalarSequence   -> Whitespace? UniScalarSequencElt+
  ///     UniScalarSequencElt -> HexDigit{1...} Whitespace?
  ///
  mutating func expectUnicodeScalarSequence(
    eating ending: Character
  ) throws -> AST.Atom.Kind {
    try recordLoc { src in
      var scalars = [AST.Atom.Scalar]()
      var trivia = [AST.Trivia]()

      // Eat up any leading whitespace.
      if let t = src.lexWhitespace() { trivia.append(t) }

      while true {
        let str = src.lexUntil { src in
          // Hit the ending, stop lexing.
          if src.isEmpty || src.peek() == ending {
            return true
          }
          // Eat up trailing whitespace, and stop lexing to record the scalar.
          if let t = src.lexWhitespace() {
            trivia.append(t)
            return true
          }
          // Not the ending or trivia, must be a digit of the scalar.
          return false
        }
        guard !str.value.isEmpty else { break }
        scalars.append(try Source.validateUnicodeScalar(str, .hex))
      }
      guard !scalars.isEmpty else {
        throw ParseError.expectedNumber("", kind: .hex)
      }
      try src.expect(ending)

      if scalars.count == 1 {
        return .scalar(scalars[0])
      }
      return .scalarSequence(.init(scalars, trivia: trivia))
    }.value
  }

  /// Eat a scalar off the front, starting from after the
  /// backslash and base character (e.g. `\u` or `\x`).
  ///
  ///     UniScalar -> 'u{' UniScalarSequence '}'
  ///                | 'u'  HexDigit{4}
  ///                | 'x{' HexDigit{1...} '}'
  ///                | 'x'  HexDigit{0...2}
  ///                | 'U'  HexDigit{8}
  ///                | 'o{' OctalDigit{1...} '}'
  ///                | '0' OctalDigit{0...3}
  ///
  mutating func expectUnicodeScalar(
    escapedCharacter base: Character
  ) throws -> AST.Atom.Kind {
    try recordLoc { src in

      func nullScalar() -> AST.Atom.Kind {
        let pos = src.currentPosition
        return .scalar(.init(UnicodeScalar(0), SourceLocation(pos ..< pos)))
      }

      // TODO: PCRE offers a different behavior if PCRE2_ALT_BSUX is set.
      switch base {
      // Hex numbers.
      case "u" where src.tryEat("{"):
        return try src.expectUnicodeScalarSequence(eating: "}")

      case "x" where src.tryEat("{"):
        let str = try src.lexUntil(eating: "}")
        return .scalar(try Source.validateUnicodeScalar(str, .hex))

      case "x":
        // \x expects *up to* 2 digits.
        guard let digits = src.tryEatLocatedPrefix(maxLength: 2, \.isHexDigit)
        else {
          // In PCRE, \x without any valid hex digits is \u{0}.
          // TODO: This doesn't appear to be followed by ICU or Oniguruma, so
          // could be changed to throw an error if we had a parsing mode for
          // them.
          return nullScalar()
        }
        return .scalar(try Source.validateUnicodeScalar(digits, .hex))

      case "u":
        return .scalar(try src.expectUnicodeScalar(numDigits: 4))
      case "U":
        return .scalar(try src.expectUnicodeScalar(numDigits: 8))

      // Octal numbers.
      case "o" where src.tryEat("{"):
        let str = try src.lexUntil(eating: "}")
        return .scalar(try Source.validateUnicodeScalar(str, .octal))

      case "0":
        // We can read *up to* 3 more octal digits.
        // FIXME: PCRE can only read up to 2 octal digits, if we get a strict
        // PCRE mode, we should limit it here.
        guard let digits = src.tryEatLocatedPrefix(maxLength: 3, \.isOctalDigit)
        else {
          return nullScalar()
        }
        return .scalar(try Source.validateUnicodeScalar(digits, .octal))

      default:
        fatalError("Unexpected scalar start")
      }
    }.value
  }

  /// Try to consume a quantifier
  ///
  ///     Quantifier -> ('*' | '+' | '?' | '{' Range '}') QuantKind?
  ///     QuantKind  -> '?' | '+'
  ///
  mutating func lexQuantifier(
    context: ParsingContext
  ) throws -> (Located<Quant.Amount>, Located<Quant.Kind>, [AST.Trivia])? {
    var trivia: [AST.Trivia] = []

    if let t = try lexNonSemanticWhitespace(context: context) {
      trivia.append(t)
    }

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

    // PCRE allows non-semantic whitespace here in extended syntax mode.
    if let t = try lexNonSemanticWhitespace(context: context) {
      trivia.append(t)
    }

    let kind: Located<Quant.Kind> = recordLoc { src in
      if src.tryEat("?") { return .reluctant  }
      if src.tryEat("+") { return .possessive }
      return .eager
    }

    return (amt, kind, trivia)
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
    // We track locations outside of recordLoc, as the predicate may advance the
    // input when we hit the end, and we don't want that to affect the location
    // of what was lexed in the `result`. We still want the recordLoc call to
    // attach locations to any thrown errors though.
    // TODO: We should find a better way of doing this, `lexUntil` seems full
    // of footguns.
    let start = currentPosition
    var end = currentPosition
    var result = ""
    try recordLoc { src in
      while try !predicate(&src) {
        result.append(src.eat())
        end = src.currentPosition
      }
    }
    return .init(result, start ..< end)
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
  /// With `SyntaxOptions.endOfLineComments`
  ///
  ///     EndOfLineComment -> '#' .*
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
      if context.endOfLineComments, src.tryEat("#") {
        // Try eat until we either exhaust the input, or hit a newline. Note
        // that the definition of newline can be altered depending on the global
        // matching options. By default we consider a newline to be `\n` or
        // `\r`.
        return src.lexUntil { src in
          if src.isEmpty { return true }
          switch context.newlineMode {
          case .carriageReturnOnly:
            return src.tryEat("\r")
          case .linefeedOnly:
            return src.tryEat("\n")
          case .carriageAndLinefeedOnly:
            return src.tryEat("\r\n")
          case .anyCarriageReturnOrLinefeed:
            return src.tryEat(anyOf: "\r", "\n", "\r\n") != nil
          case .anyUnicode:
            return src.tryEat(where: \.isNewline)
          case .nulCharacter:
            return src.tryEat("\0")
          }
        }.value
      }
      return nil
    }
    guard let trivia = trivia else { return nil }
    return AST.Trivia(trivia)
  }

  /// Try to consume non-semantic whitespace as trivia
  ///
  ///     Whitespace -> WhitespaceChar+
  ///
  /// Does nothing unless `SyntaxOptions.nonSemanticWhitespace` is set
  mutating func lexNonSemanticWhitespace(
    context: ParsingContext
  ) throws -> AST.Trivia? {
    guard context.ignoreWhitespace else { return nil }

    // FIXME: PCRE only treats space and tab characters as whitespace when
    // inside a custom character class (and only treats whitespace as
    // non-semantic there for the extra-extended `(?xx)` mode). If we get a
    // strict-PCRE mode, we'll need to add a case for that.
    return lexWhitespace()
  }

  /// Try to consume whitespace as trivia
  ///
  ///     Whitespace -> WhitespaceChar+
  ///
  /// Unlike `lexNonSemanticWhitespace`, this will always attempt to lex
  /// whitespace.
  mutating func lexWhitespace() -> AST.Trivia? {
    let trivia: Located<String>? = recordLoc { src in
      src.tryEatPrefix(\.isPatternWhitespace)?.string
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
      case "n": return advanceAndReturn(.namedCapturesOnly)
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
    context: ParsingContext
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
        // Extended syntax may not be removed if in multi-line mode.
        if context.syntax.contains(.multilineExtendedSyntax) &&
            opt.isAnyExtended {
          throw ParseError.cannotRemoveExtendedSyntaxInMultilineMode
        }
        removing.append(opt)
      }
      return .init(caretLoc: nil, adding: adding, minusLoc: ateMinus.location,
                   removing: removing)
    }
    guard !adding.isEmpty else { return nil }
    return .init(caretLoc: nil, adding: adding, minusLoc: nil, removing: [])
  }

  /// A matching option changing atom.
  ///
  ///     '(?' MatchingOptionSeq ')'
  ///
  mutating func lexChangeMatchingOptionAtom(
    context: ParsingContext
  ) throws -> AST.MatchingOptionSequence? {
    try tryEating { src in
      guard src.tryEat(sequence: "(?"),
            let seq = try src.lexMatchingOptionSequence(context: context)
      else { return nil }
      try src.expect(")")
      return seq
    }
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
        guard !src.shouldLexGroupLikeAtom(context: context) else { return nil }

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
          if let seq = try src.lexMatchingOptionSequence(context: context) {
            guard src.tryEat(":") else {
              if let next = src.peek() {
                throw ParseError.invalidMatchingOption(next)
              }
              throw ParseError.expected(")")
            }
            return .changeMatchingOptions(seq)
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

        // If (?n) is set, a bare (...) group is non-capturing.
        if context.syntax.contains(.namedCapturesOnly) {
          return .nonCapture
        }
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
  ///     GroupCondStart -> '(?' GroupStart
  ///
  mutating func lexGroupConditionalStart(
    context: ParsingContext
  ) throws -> Located<AST.Group.Kind>? {
    try tryEating { src in
      guard src.tryEat(sequence: "(?") else { return nil }
      return try src.lexGroupStart(context: context)
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
      // Make sure we don't have a POSIX character property. This may require
      // walking to its ending to make sure we have a closing ':]', as otherwise
      // we have a custom character class.
      // TODO: This behavior seems subtle, could we warn?
      guard !src.canLexPOSIXCharacterProperty() else {
        return nil
      }
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
      try src.tryEating { src in
        guard src.tryEat(sequence: "[:") else { return nil }
        let inverted = src.tryEat("^")

        // Note we lex the contents and ending *before* classifying, because we
        // want to bail with nil if we don't have the right ending. This allows
        // the lexing of a custom character class if we don't have a ':]'
        // ending.
        let (key, value) = src.lexCharacterPropertyKeyValue()
        guard src.tryEat(sequence: ":]") else { return nil }

        let prop = try Source.classifyCharacterPropertyContents(key: key,
                                                                value: value)
        return .init(prop, isInverted: inverted, isPOSIX: true)
      }
    }
  }

  private func canLexPOSIXCharacterProperty() -> Bool {
    do {
      var src = self
      return try src.lexPOSIXCharacterProperty() != nil
    } catch {
      // We want to tend on the side of lexing a POSIX character property, so
      // even if it is invalid in some way (e.g invalid property names), still
      // try and lex it.
      return true
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
        let str = try src.lexUntil(eating: "}")
        return .scalar(try Source.validateUnicodeScalar(str, .hex))
      }

      // Or we should have a character name.
      // TODO: Validate the types of characters that can appear in the name?
      return .namedCharacter(try src.lexUntil(eating: "}").value)
    }
  }

  private mutating func lexCharacterPropertyKeyValue(
  ) -> (key: String?, value: String) {
    func atPossibleEnding(_ src: inout Source) -> Bool {
      guard let next = src.peek() else { return true }
      switch next {
      case "=":
        // End of a key.
        return true
      case ":", "[", "]":
        // POSIX character property endings to cover ':]', ']', and '[' as the
        // start of a nested character class.
        return true
      case "}":
        // Ending of '\p{'. We cover this for POSIX too as it's not a valid
        // character property name anyway, and it's nice not to have diverging
        // logic for these cases.
        return true
      case "\\":
        // An escape sequence, which may include e.g '\Q :] \E'. ICU bails here
        // for all its known escape sequences (e.g '\a', '\e' '\f', ...). It
        // seems character class escapes e.g '\d' are excluded, however it's not
        // clear that is intentional. Let's apply the rule for any escape, as a
        // backslash would never be a valid character property name, and we can
        // diagnose any invalid escapes when parsing as a character class.
        return true
      default:
        // We may want to handle other metacharacters here, e.g '{', '(', ')',
        // as they're not valid character property names. However for now
        // let's tend on the side of forming an unknown property name in case
        // these characters are ever used in future character property names
        // (though it's very unlikely). Users can always escape e.g the ':'
        // in '[:' if they definitely want a custom character class.
        return false
      }
    }
    // We should either have:
    // - 'x=y' where 'x' is a property key, and 'y' is a value.
    // - 'y' where 'y' is a value (or a bool key with an inferred value of true)
    //   and its key is inferred.
    let lhs = lexUntil(atPossibleEnding).value
    if tryEat("=") {
      let rhs = lexUntil(atPossibleEnding).value
      return (lhs, rhs)
    }
    return (nil, lhs)
  }

  private static func classifyCharacterPropertyContents(
    key: String?, value: String
  ) throws -> AST.Atom.CharacterProperty.Kind {
    if let key = key {
      return try classifyCharacterProperty(key: key, value: value)
    }
    return try classifyCharacterPropertyValueOnly(value)
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

      let (key, value) = src.lexCharacterPropertyKeyValue()
      let prop = try Source.classifyCharacterPropertyContents(key: key,
                                                              value: value)
      try src.expect("}")
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
      try src.tryEating { src in
        // Note this logic should match canLexNumberedReference.
        if src.tryEat("+"), let num = try src.lexNumber() {
          return .relative(num.value)
        }
        if src.tryEat("-"), let num = try src.lexNumber() {
          return .relative(-num.value)
        }
        if let num = try src.lexNumber() {
          return .absolute(num.value)
        }
        return nil
      }
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

        // Backslash followed by a non-0 digit character is a backreference.
        if firstChar != "0", let numAndLoc = try src.lexNumber() {
          return .backreference(.init(
            .absolute(numAndLoc.value), innerLoc: numAndLoc.location))
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

  private func canLexMatchingOptionsAsAtom(context: ParsingContext) -> Bool {
    var src = self

    // See if we can lex a matching option sequence that terminates in ')'. Such
    // a sequence is an atom. If an error is thrown, there are invalid elements
    // of the matching option sequence. In such a case, we can lex as a group
    // and diagnose the invalid group kind.
    guard (try? src.lexMatchingOptionSequence(context: context)) != nil else {
      return false
    }
    return src.tryEat(")")
  }

  /// Whether a group specifier should be lexed as an atom instead of a group.
  private func shouldLexGroupLikeAtom(context: ParsingContext) -> Bool {
    var src = self
    guard src.tryEat("(") else { return false }

    if src.tryEat("?") {
      // The start of a reference '(?P=', '(?R', ...
      if src.canLexGroupLikeReference() { return true }

      // The start of a PCRE callout.
      if src.tryEat("C") { return true }

      // The start of an Oniguruma 'of-contents' callout.
      if src.tryEat("{") { return true }

      // A matching option atom (?x), (?i), ...
      if src.canLexMatchingOptionsAsAtom(context: context) { return true }

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

      guard let char = src.tryEat() else {
        throw ParseError.expectedEscape
      }

      // Single-character builtins.
      if let builtin = AST.Atom.EscapedBuiltin(
        char, inCustomCharacterClass: ccc
      ) {
        return .escaped(builtin)
      }

      switch char {
      // Hexadecimal and octal unicode scalars.
      case "u", "x", "U", "o", "0":
        return try src.expectUnicodeScalar(escapedCharacter: char)
      default:
        break
      }

      // We only allow unknown escape sequences for non-letter non-number ASCII,
      // and non-ASCII whitespace.
      // TODO: Once we have fix-its, suggest a `0` prefix for octal `[\7]`.
      guard (char.isASCII && !char.isLetter && !char.isNumber) ||
              (!char.isASCII && char.isWhitespace)
      else {
        throw ParseError.invalidEscape(char)
      }
      return .char(char)
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
        // name under PCRE2_ALT_VERBNAMES. It also allows whitespace under (?x).
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
  mutating func expectGroupLikeAtom(
    context: ParsingContext
  ) throws -> AST.Atom.Kind {
    try recordLoc { src in
      // References that look like groups, e.g (?R), (?1), ...
      if let ref = try src.lexGroupLikeReference() {
        return ref.value
      }

      // Change matching options atom (?i), (?x-i), ...
      if let seq = try src.lexChangeMatchingOptionAtom(context: context) {
        return .changeMatchingOptions(seq)
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

      // POSIX character property. Like \p{...} this is also allowed outside of
      // a custom character class.
      if let prop = try src.lexPOSIXCharacterProperty()?.value {
        return .property(prop)
      }

      // If we have group syntax that was skipped over in lexGroupStart, we
      // need to handle it as an atom, or throw an error.
      if !customCC && src.shouldLexGroupLikeAtom(context: context) {
        return try src.expectGroupLikeAtom(context: context)
      }

      // A quantifier here is invalid.
      if !customCC,
         let q = try src.recordLoc({ try $0.lexQuantifier(context: context) }) {
        throw ParseError.quantifierRequiresOperand(
          String(src[q.location.range]))
      }

      let char = src.eat()
      switch char {
      case ")", "|":
        if customCC {
          return .char(char)
        }
        throw Unreachable("TODO: reason")

      case "(" where !customCC:
        throw Unreachable("Should have lexed a group or group-like atom")

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

