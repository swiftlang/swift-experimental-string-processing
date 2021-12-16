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
  ///                | '0'  OctalDigit{0...2}
  ///
  mutating func expectUnicodeScalar(
    escapedCharacter base: Character
  ) throws -> Located<Unicode.Scalar> {
    try recordLoc { src in
      switch base {
      // Hex numbers.
      case "u", "x":
        if src.tryEat("{") {
          let str = src.lexUntil(eating: "}").value
          return try Source.validateUnicodeScalar(str, .hex)
        }
        let numDigits = base == "u" ? 4 : 2
        return try src.expectUnicodeScalar(numDigits: numDigits).value
      case "U":
        return try src.expectUnicodeScalar(numDigits: 8).value

      // Octal numbers.
      case "o" where src.tryEat("{"):
        let str = src.lexUntil(eating: "}").value
        return try Source.validateUnicodeScalar(str, .octal)

      case "0":
        // We can read *up to* 2 more octal digits per PCRE.
        // FIXME: ICU can read up to 3 octal digits, we should have a parser
        // mode to switch.
        guard let str = src.tryEatPrefix(maxLength: 2, \.isOctalDigit)?.string
        else { return Unicode.Scalar(0) }
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
      return .greedy
    }

    return (amt, kind)
  }

  /// Consume a range
  ///
  ///     Range       -> ',' <Int> | <Int> ',' <Int>? | <Int>
  ///                  | ModernRange
  ///     ModernRange -> '..<' <Int> | '...' <Int>
  ///                  | <Int> '..<' <Int> | <Int> '...' <Int>?
  mutating func expectRange() throws -> Located<Quant.Amount> {
    try recordLoc { src in
      // TODO: lex positive numbers, more specifically...

      let lowerOpt = try src.lexNumber()

      // ',' or '...' or '..<' or nothing
      let closedRange: Bool?
      if src.tryEat(",") {
        closedRange = true
      } else if src.modernRanges && src.tryEat(".") {
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
    _ predicate: (inout Source) -> Bool
  ) -> Located<String> {
    recordLoc { src in
      var result = ""
      while !predicate(&src) {
        result.append(src.eat())
      }
      return result
    }
  }

  private mutating func lexUntil(eating end: String) -> Located<String> {
    lexUntil { $0.tryEat(sequence: end) }
  }

  /// Expect a linear run of non-nested non-empty content
  private mutating func expectQuoted(
    endingWith end: String
  ) throws -> Located<String> {
    try recordLoc { src in
      let result = src.lexUntil(eating: end).value
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
  /// With `SyntaxOptions.modernQuotes`, also accepts
  ///
  ///     ModernQuote -> '"' [^"]* '"'
  ///
  /// Future: Modern quotes are full fledged Swift string literals
  ///
  /// TODO: Need to support some escapes
  ///
  mutating func lexQuote() throws -> Located<String>? {
    try recordLoc { src in
      if src.tryEat(sequence: #"\Q"#) {
        return try src.expectQuoted(endingWith: #"\E"#).value
      }
      if src.modernQuotes, src.tryEat("\"") {
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
  /// With `SyntaxOptions.modernComments`
  ///
  ///     ModernComment -> '/*' (!'*/' .)* '*/'
  ///
  /// TODO: Swift-style nested comments, line-ending comments, etc
  ///
  mutating func lexComment() throws -> AST.Trivia? {
    let trivia: Located<String>? = try recordLoc { src in
      if src.tryEat(sequence: "(?#") {
        return try src.expectQuoted(endingWith: ")").value
      }
      if src.modernComments, src.tryEat(sequence: "/*") {
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


  /// Try to consume the start of a group
  ///
  ///     GroupStart -> '(?' GroupKind | '('
  ///     GroupKind  -> Named | ':' | '|' | '>' | '=' | '!' | '<=' | '<!'
  ///     Named      -> '<' [^'>']+ '>' | 'P<' [^'>']+ '>'
  ///                 | '\'' [^'\'']+ '\''
  ///
  /// If `SyntaxOptions.modernGroups` is enabled, also accepts:
  ///
  ///     ModernGroupStart -> '(_:'
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

        throw ParseError.misc(
          "Unknown group kind '(?\(src.peek()!)'")
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
      }

      // (_:)
      if src.modernCaptures && src.tryEat(sequence: "_:") {
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
      let prop = try src.lexCharacterPropertyContents(
        end: ":]", isPOSIX: true).value
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
        let str = src.lexUntil(eating: "}").value
        return .scalar(try Source.validateUnicodeScalar(str, .hex))
      }

      // Or we should have a character name.
      // TODO: Validate the types of characters that can appear in the name?
      return .namedCharacter(src.lexUntil(eating: "}").value)
    }
  }

  private mutating func lexCharacterPropertyContents(
    end: String, isPOSIX: Bool
  ) throws -> Located<AST.Atom.CharacterProperty.Kind> {
    try recordLoc { src in
      // We should either have:
      // - 'x=y' where 'x' is a property key, and 'y' is a value.
      // - 'y' where 'y' is a value (or a bool key with an inferred value
      //   of true), and its key is inferred.
      // TODO: We could have better recovery here if we only ate the characters
      // that property keys and values can use.
      let lhs = src.lexUntil { $0.peek() == "=" || $0.starts(with: end) }.value
      if src.tryEat(sequence: end) {
        return try Source.classifyCharacterPropertyValueOnly(
          lhs, isPOSIX: isPOSIX)
      }
      src.eat(asserting: "=")

      let rhs = src.lexUntil(eating: end).value
      return try Source.classifyCharacterProperty(key: lhs, value: rhs)
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

      let prop = try src.lexCharacterPropertyContents(
        end: "}", isPOSIX: false).value
      return .init(prop, isInverted: isInverted, isPOSIX: false)
    }
  }

  /// Consume an escaped atom, starting from after the backslash
  ///
  ///     Escaped          -> KeyboardModified | Builtin
  ///                       | UniScalar | Property | NamedCharacter
  ///
  /// TODO: references
  mutating func expectEscaped(
    isInCustomCharacterClass ccc: Bool
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

      let char = src.eat()

      // Single-character builtins
      if let builtin = AST.Atom.EscapedBuiltin(
        char, inCustomCharacterClass: ccc
      ) {
        return .escaped(builtin)
      }

      switch char {
      // Scalars
      case "u", "x", "U", "o", "0":
        return try .scalar(
          src.expectUnicodeScalar(escapedCharacter: char).value)

      // Unicode property checks
      case "p", "P":
        fatalError("TODO: properties")

      case "1"..."9", "g", "k":
        fatalError("TODO: References")

      default: return .char(char)
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
  /// If `SyntaxOptions.nonSemanticWhitespace` is enabled, also accepts:
  ///
  ///     ModernGroupStart -> '(_:'
  ///
  mutating func lexAtom(
    isInCustomCharacterClass customCC: Bool
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
          isInCustomCharacterClass: customCC).value

      // TODO: backreferences et al here?

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
  mutating func lexCustomCharClassRangeEnd() throws -> AST.Atom? {
    // Make sure we don't have a binary operator e.g '--', and the '-' is not
    // ending the custom character class (in which case it is literal).
    guard peekCCBinOp() == nil && !starts(with: "-]") && tryEat("-") else {
      return nil
    }
    return try lexAtom(isInCustomCharacterClass: true)
  }
}

