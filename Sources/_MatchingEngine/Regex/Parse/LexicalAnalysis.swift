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
  fileprivate mutating func recordLoc(
    _ f: (inout Self) throws -> ()
  ) rethrows {
    let start = currentPosition
    do {
      try f(&self)
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
  mutating func expect(_ c: Character) throws {
    _ = try recordLoc { src in
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
  mutating func expectNonEmpty() throws {
    _ = try recordLoc { src in
      if src.isEmpty { throw ParseError.unexpectedEndOfInput }
    }
  }

  mutating func tryEatNonEmpty(_ c: Char) throws -> Bool {
    guard !isEmpty else { throw ParseError.expected(String(c)) }
    return tryEat(c)
  }

  mutating func tryEatNonEmpty<C: Collection>(sequence c: C) throws -> Bool
    where C.Element == Char
  {
    guard !isEmpty else { throw ParseError.expected(String(c)) }
    return tryEat(sequence: c)
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
  ///                | 'x'  HexDigit{2}
  ///                | 'U'  HexDigit{8}
  ///                | 'o{' OctalDigit{1...} '}'
  ///                | OctalDigit{1...3}
  ///
  mutating func expectUnicodeScalar(
    escapedCharacter base: Character
  ) throws -> Located<Unicode.Scalar> {
    try recordLoc { src in
      switch base {
      // Hex numbers.
      case "u", "x":
        if src.tryEat("{") {
          let str = try src.lexUntil(eating: "}").value
          return try Source.validateUnicodeScalar(str, .hex)
        }
        let numDigits = base == "u" ? 4 : 2
        return try src.expectUnicodeScalar(numDigits: numDigits).value
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
        throw ParseError.misc("TODO: Or is this an assert?")
      }
    }
  }

  /// Try to consume a quantifier
  ///
  ///     Quantifier -> ('*' | '+' | '?' | '{' Range '}') QuantKind?
  ///     QuantKind  -> '?' | '+'
  ///
  mutating func lexQuantifier() throws -> (
    Located<Quant.Amount>, Located<Quant.Kind>
  )? {
    let amt: Located<Quant.Amount>? = try recordLoc { src in
      if src.tryEat("*") { return .zeroOrMore }
      if src.tryEat("+") { return .oneOrMore }
      if src.tryEat("?") { return .zeroOrOne }

      // FIXME: Actually, PCRE treats empty as literal `{}`...
      // But Java 8 errors out?
      if src.tryEat("{") {
        // FIXME: Erm, PCRE parses as literal if no lowerbound...
        let amt = try src.expectRange()
        try src.expect("}")
        return amt.value // FIXME: track actual range...
      }

      return nil
    }
    guard let amt = amt else { return nil }

    let kind: Located<Quant.Kind> = recordLoc { src in
      if src.tryEat("?") { return .reluctant  }
      if src.tryEat("+") { return .possessive }
      return .eager
    }

    return (amt, kind)
  }

  /// Consume a range
  ///
  ///     Range       -> ',' <Int> | <Int> ',' <Int>? | <Int>
  ///                  | ExpRange
  ///     ExpRange    -> '..<' <Int> | '...' <Int>
  ///                  | <Int> '..<' <Int> | <Int> '...' <Int>?
  mutating func expectRange() throws -> Located<Quant.Amount> {
    try recordLoc { src in
      // TODO: lex positive numbers, more specifically...

      let lowerOpt = try src.lexNumber()

      // ',' or '...' or '..<' or nothing
      let closedRange: Bool?
      if src.tryEat(",") {
        closedRange = true
      } else if src.experimentalRanges && src.tryEat(".") {
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
      // FIXME: wait, why `try!` ?
      let upperOpt: Located<Int>?
      if let u = try! src.lexNumber() {
        upperOpt = (closedRange == true) ? u : Located(u.value-1, u.location)
      } else {
        upperOpt = nil
      }

      switch (lowerOpt, closedRange, upperOpt) {
      case let (l?, nil, nil):
        return .exactly(l)
      case let (l?, true, nil):
        return .nOrMore(l)
      case let (nil, _, u?):
        return .upToN(u)
      case let (l?, _, u?):
        // FIXME: source location tracking
        return .range(l, u)

      case let (nil, nil, u) where u != nil:
        fatalError("Not possible")
      default:
        throw ParseError.misc("Invalid range")
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

  /// Expect a linear run of non-nested non-empty content
  private mutating func expectQuoted(
    endingWith end: String
  ) throws -> Located<String> {
    try recordLoc { src in
      let result = try src.lexUntil(eating: end).value
      guard !result.isEmpty else {
        throw ParseError.misc("Expected non-empty contents")
      }
      return result
    }
  }

  /// Try to consume quoted content
  ///
  ///     Quote -> '\Q' (!'\E' .)* '\E'
  ///
  /// With `SyntaxOptions.experimentalQuotes`, also accepts
  ///
  ///     ExpQuote -> '"' [^"]* '"'
  ///
  /// Future: Experimental quotes are full fledged Swift string literals
  ///
  /// TODO: Need to support some escapes
  ///
  mutating func lexQuote() throws -> Located<String>? {
    try recordLoc { src in
      if src.tryEat(sequence: #"\Q"#) {
        return try src.expectQuoted(endingWith: #"\E"#).value
      }
      if src.experimentalQuotes, src.tryEat("\"") {
        // TODO: escaped `"`, etc...
        return try src.expectQuoted(endingWith: "\"").value
      }
      return nil
    }
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
  mutating func lexComment() throws -> AST.Trivia? {
    let trivia: Located<String>? = try recordLoc { src in
      if src.tryEat(sequence: "(?#") {
        return try src.expectQuoted(endingWith: ")").value
      }
      if src.experimentalComments, src.tryEat(sequence: "/*") {
        return try src.expectQuoted(endingWith: "*/").value
      }
      return nil
    }
    guard let trivia = trivia else { return nil }
    return AST.Trivia(trivia)
  }

  /// Try to consume non-semantic whitespace as trivia
  ///
  /// Does nothing unless `SyntaxOptions.nonSemanticWhitespace` is set
  mutating func lexNonSemanticWhitespace() throws -> AST.Trivia? {
    guard syntax.ignoreWhitespace else { return nil }
    let trivia: Located<String>? = recordLoc { src in
      src.tryEatPrefix { $0 == " " }?.string
    }
    guard let trivia = trivia else { return nil }
    return AST.Trivia(trivia)
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
  ///                        | MatchingOption* '-' MatchingOption+
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

    // If the sequence begun with a caret '^', options can be added, so we're
    // done.
    if ateCaret.value {
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
        removing.append(opt)
      }
      return .init(caretLoc: nil, adding: adding, minusLoc: ateMinus.location,
                   removing: removing)
    }
    guard !adding.isEmpty else { return nil }
    return .init(caretLoc: nil, adding: adding, minusLoc: nil, removing: [])
  }

  /// Try to consume the start of a group
  ///
  ///     GroupStart -> '(?' GroupKind | '('
  ///     GroupKind  -> Named | ':' | '|' | '>' | '=' | '!' | '*' | '<=' | '<!'
  ///                 | '<*' | MatchingOptionSeq (':' | ')')
  ///     Named      -> '<' [^'>']+ '>' | 'P<' [^'>']+ '>'
  ///                 | '\'' [^'\'']+ '\''
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
  ) throws -> Located<AST.Group.Kind>? {
    try recordLoc { src in
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
          let name = try src.expectQuoted(endingWith: ">")
          return .namedCapture(name)
        }
        if src.tryEat("'") {
          let name = try src.expectQuoted(endingWith: "'")
          return .namedCapture(name)
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
          try src.expect(")")
          return .changeMatchingOptions(seq, isIsolated: true)
        }

        guard let next = src.peek() else {
          throw ParseError.expectedGroupSpecifier
        }
        throw ParseError.misc("Unknown group kind '(?\(next)'")
      }

      // Explicitly spelled out PRCE2 syntax for some groups.
      if src.tryEat("*") {
        if src.tryEat(sequence: "atomic:") { return .atomicNonCapturing }

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

        throw ParseError.misc("Quantifier '*' must follow operand")
      }

      // (_:)
      if src.experimentalCaptures && src.tryEat(sequence: "_:") {
        return .nonCapture
      }
      // TODO: (name:)

      return .capture
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
  ///     NumberRef -> ('+' | '-')? <Decimal Number>
  ///
  private mutating func lexNumberedReference(
  ) throws -> Located<Reference>? {
    try recordLoc { src in
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
  }

  /// Try to lex a numbered reference, or otherwise a named reference.
  ///
  ///     NameOrNumberRef -> NumberRef | <String>
  ///
  private mutating func expectNamedOrNumberedReference(
    endingWith ending: String
  ) throws -> Located<Reference> {
    try recordLoc { src in
      if let numbered = try src.lexNumberedReference() {
        try src.expect(sequence: ending)
        return numbered.value
      }
      return .named(try src.lexUntil(eating: ending).value)
    }
  }

  private static func getClosingDelimiter(
    for openChar: Character
  ) -> Character {
    switch openChar {
      case "<": return ">"
      case "'": return "'"
      case "{": return "}"
      default:
        fatalError("Not implemented")
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
    priorGroupCount: Int
  ) throws -> Located<AST.Atom.Kind>? {
    try recordLoc { src in
      if src.tryEat("g") {
        // PCRE-style backreferences.
        if src.tryEat("{") {
          let ref = try src.expectNamedOrNumberedReference(
            endingWith: "}").value
          return .backreference(ref)
        }

        // Oniguruma-style subpatterns.
        if let openChar = src.tryEat(anyOf: "<", "'") {
          let ref = try src.expectNamedOrNumberedReference(
            endingWith: String(Source.getClosingDelimiter(for: openChar))).value
          return .subpattern(ref)
        }

        // PCRE allows \g followed by a bare numeric reference.
        if let ref = try src.lexNumberedReference() {
          return .backreference(ref.value)
        }

        // Fallback to a literal character. We need to return here as we've
        // already eaten the 'g'.
        return .char("g")
      }

      if src.tryEat("k") {
        // Perl/.NET-style backreferences.
        if let openChar = src.tryEat(anyOf: "<", "'", "{") {
          let closingChar = Source.getClosingDelimiter(for: openChar)
          return .backreference(.named(
            try src.lexUntil(eating: closingChar).value))
        }
        // Fallback to a literal character. We need to return here as we've
        // already eaten the 'k'.
        return .char("k")
      }

      // Lexing \n is tricky, as it's ambiguous with octal sequences. In PCRE it
      // is treated as a backreference if its first digit is not 0 (as that is
      // always octal) and one of the following holds:
      //
      // - It's 0 < n < 10 (as octal would be pointless here)
      // - Its first digit is 8 or 9 (as not valid octal)
      // - There have been as many prior groups as the reference.
      //
      // Oniguruma follows the same rules except the second one. e.g \81 and \91
      // are instead treated as literal 81 and 91 respectively.
      // TODO: If we want a strict Oniguruma mode, we'll need to add a check
      // here.
      if src.peek() != "0", let digits = src.peekPrefix(\.isNumber) {
        // First lex out the decimal digits and see if we can treat this as a
        // backreference.
        let num = try Source.validateNumber(digits.string, Int.self, .decimal)
        if num < 10 || digits.first == "8" || digits.first == "9" ||
            num <= priorGroupCount {
          src.advance(digits.count)
          return .backreference(.absolute(num))
        }
      }
      return nil
    }
  }

  /// Consume an escaped atom, starting from after the backslash
  ///
  ///     Escaped          -> KeyboardModified | Builtin
  ///                       | UniScalar | Property | NamedCharacter
  ///                       | EscapedReference
  ///
  mutating func expectEscaped(
    isInCustomCharacterClass ccc: Bool, priorGroupCount: Int
  ) throws -> Located<AST.Atom.Kind> {
    try recordLoc { src in
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
      if !ccc, let ref = try src.lexEscapedReference(
        priorGroupCount: priorGroupCount
      )?.value {
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
  mutating func lexAtom(
    isInCustomCharacterClass customCC: Bool, priorGroupCount: Int
  ) throws -> AST.Atom? {
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

      // TODO: Python-style backreferences (?P=...), which look like groups.

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
      case "\\": return try src.expectEscaped(
        isInCustomCharacterClass: customCC,
        priorGroupCount: priorGroupCount).value

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
    priorGroupCount: Int
  ) throws -> AST.Atom? {
    // Make sure we don't have a binary operator e.g '--', and the '-' is not
    // ending the custom character class (in which case it is literal).
    guard peekCCBinOp() == nil && !starts(with: "-]") && tryEat("-") else {
      return nil
    }
    return try lexAtom(isInCustomCharacterClass: true,
                       priorGroupCount: priorGroupCount)
  }
}

