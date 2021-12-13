/*

Lexical analysis aids parsing by handling local ("lexical")
concerns upon request.

API convention:

- lexFoo will try to consume a foo and return it if successful, throws errors
- expectFoo will consume a foo, throwing errors, and throw an error if it can't
- eat() and tryEat() is still used by the parser as a character-by-character interface


*/

// MARK: - Consumption routines
extension Source {
  typealias Quant = AST.Quantification

  private mutating func consumeNumber<
    Num: FixedWidthInteger
  >(
    _ isNumber: (Char) -> Bool,
    validate: (Input.SubSequence) throws -> (),
    radix: Int
  ) throws -> Num? {
    guard let num = tryEatPrefix(isNumber) else {
      return nil
    }
    try validate(num)
    guard let i = Num(num, radix: radix) else {
      throw ParseError.numberOverflow(String(num))
    }
    return i
  }
  private mutating func consumeHexNumber<Num: FixedWidthInteger>(
    validate: (Input.SubSequence) throws -> ()
  ) throws -> Num? {
    try consumeNumber(\.isHexDigit, validate: validate, radix: 16)
  }

  private mutating func consumeHexNumber<Num: FixedWidthInteger>(
    numDigits: Int
  ) throws -> Num {
    guard let str = tryEat(count: numDigits) else {
      throw ParseError.misc("Expected more digits")
    }
    guard let i = Num(str, radix: 16) else {
      // TODO: Or, it might have failed because of overflow,
      // Can we tell easily?
      throw ParseError.expectedHexNumber(String(str))
    }
    return i
  }

  private mutating func consumeHexNumber<Num: FixedWidthInteger>(
    digitRange: ClosedRange<Int>
  ) throws -> Num {
    guard let str = self.tryEatPrefix(
      maxLength: digitRange.upperBound, \.isHexDigit
    ) else {
      throw ParseError.expectedDigits("", expecting: digitRange)
    }
    guard digitRange.contains(str.count) else {
      throw ParseError.expectedDigits(
        String(str), expecting: digitRange)
    }
    guard let i = Num(str, radix: 16) else {
      // TODO: Or, it might have failed because of overflow,
      // Can we tell easily?
      throw ParseError.expectedHexNumber(String(str))
    }
    return i
  }


  /// Try to eat a number off the front.
  ///
  /// Returns: `nil` if there's no number, otherwise the number
  ///
  /// Throws on overflow
  ///
  mutating func lexNumber() throws -> Loc<Int>? {
    try recordLoc {
      try $0.consumeNumber(
        \.isNumber, validate: { _ in }, radix: 10)
    }
  }

  /// Eat a scalar value from hexadecimal notation off the front
  private mutating func expectUnicodeScalar(
    numDigits: Int
  ) throws -> Loc<Unicode.Scalar> {
    try recordLoc { src in
      let num: UInt32 = try src.consumeHexNumber(
        numDigits: numDigits)
      guard let scalar = Unicode.Scalar(num) else {
        throw ParseError.misc(
          "Invalid scalar value U+\(num.hexStr)")
      }
      return scalar
    }
  }

  /// Eat a scalar value from hexadecimal notation off the front
  private mutating func expectUnicodeScalar(
    digitRange: ClosedRange<Int>
  ) throws -> Loc<Unicode.Scalar> {
    try recordLoc { src in
      let uOpt: UInt32? = try src.consumeHexNumber { s in
        guard digitRange.contains(s.count) else {
          throw ParseError.expectedDigits(
            String(s), expecting: digitRange)
        }
      }
      guard let u = uOpt else {
        throw ParseError.misc("Expected scalar value")
      }
      guard let scalar = Unicode.Scalar(u) else {
        throw ParseError.misc(
          "Invalid scalar value U+\(u.hexStr)")
      }
      return scalar
    }
  }

  /// Eat a scalar off the front, starting from after the
  /// backslash and base character (e.g. `\u` or `\x`).
  ///
  ///     UniScalar -> 'u{' HexDigit{1...8}
  ///                | 'u'  HexDigit{4}
  ///                | 'x{' HexDigit{1...8}
  ///                | 'x'  HexDigit{2}
  ///                | 'U'  HexDigit{8}
  ///
  mutating func expectUnicodeScalar(
    escapedCharacter base: Character
  ) throws -> Loc<Unicode.Scalar> {
    try recordLoc { src in
      switch base {
      case "u", "x":
        if src.tryEat("{") {
          let s = try src.expectUnicodeScalar(digitRange: 1...8)
          try src.expect("}")
          return s.value
        }
        let numDigits = base == "u" ? 4 : 2
        return try src.expectUnicodeScalar(
          numDigits: numDigits).value
      case "U":
        return try src.expectUnicodeScalar(numDigits: 8).value

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
    Loc<Quant.Amount>, Loc<Quant.Kind>
  )? {
    let amt: Loc<Quant.Amount>? = try recordLoc { src in
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

    let kind: Loc<Quant.Kind> = try recordLoc { src in
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
  mutating func expectRange() throws -> Loc<Quant.Amount> {
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
      let upperOpt: Loc<Int>?
      if let u = try! src.lexNumber() {
        upperOpt = (closedRange == true) ? u : Loc(u.value-1, u.location)
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
        return .range(l ... u)

      case let (nil, nil, u) where u != nil:
        fatalError("Not possible")
      default:
        throw ParseError.misc("Invalid range")
      }
    }
  }

  private mutating func lexUntil(
    _ predicate: (inout Source) -> Bool,
    validate: (String) throws -> Void = { _ in }
  ) throws -> Loc<String> {
    try recordLoc { src in
      var result = ""
      while !predicate(&src) {
        // TODO(diagnostic): expected `end`, instead of end-of-input

        result.append(src.eat())
      }
      try validate(result)
      return result
    }
  }

  private mutating func lexUntil(
    eating end: String, validate: (String) throws -> Void = { _ in }
  ) throws -> Loc<String> {
    try lexUntil({ src in src.tryEat(sequence: end) }, validate: validate)
  }

  /// Expect a linear run of non-nested non-empty content
  private mutating func expectQuoted(
    endingWith end: String
  ) throws -> Loc<String> {
    try lexUntil(eating: end, validate: { result in
      guard !result.isEmpty else {
        throw ParseError.misc("Expected non-empty contents")
      }
    })
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
  mutating func lexQuote() throws -> Loc<String>? {
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
  ///     Comment -> '(?#.' [^')']* ')'
  ///
  /// With `SyntaxOptions.modernComments`
  ///
  ///     ModernComment -> '/*' (!'*/' .)* '*/'
  ///
  /// TODO: Swift-style nested comments, line-ending comments, etc
  ///
  mutating func lexComment() throws -> AST.Trivia? {
    let trivia: Loc<String>? = try recordLoc { src in
      if src.tryEat(sequence: "(?#.") {
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
    let trivia: Loc<String>? = try recordLoc { src in
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
  ) throws -> Loc<AST.Group.Kind>? {
    try recordLoc { src in
      guard src.tryEat("(") else { return nil }

      if src.tryEat("?") {
        if src.tryEat(":") { return .nonCapture }
        if src.tryEat("|") { return .nonCaptureReset }
        if src.tryEat(">") { return .atomicNonCapturing }
        if src.tryEat("=") { return .lookahead }
        if src.tryEat("!") { return .negativeLookahead }

        if src.tryEat(sequence: "<=") { return .lookbehind }
        if src.tryEat(sequence: "<!") { return .negativeLookbehind }

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

      // (_:)
      if src.modernCaptures && src.tryEat(sequence: "_:") {
        return .nonCapture
      }
      // TODO: (name:)

      return .capture
    }
  }

  mutating func lexCustomCCStart(
  ) throws -> Loc<CustomCC.Start>? {
    try recordLoc { src in
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
  mutating func lexCustomCCBinOp() throws -> Loc<CustomCC.SetOp>? {
    try recordLoc { src in
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

  private mutating func lexPOSIXNamedSet() throws -> Loc<Atom.POSIXSet>? {
    try recordLoc { src in
      guard src.tryEat(sequence: "[:") else { return nil }
      let inverted = src.tryEat("^")
      let name = try src.lexUntil(eating: ":]").value
      guard let set = Unicode.POSIXCharacterSet(rawValue: name) else {
        throw ParseError.invalidPOSIXSetName(name)
      }
      return Atom.POSIXSet(inverted: inverted, set)
    }
  }

  /// Try to consume a character property.
  ///
  ///     Property -> ('p{' | 'P{') Prop ('=' Prop)? '}'
  ///     Prop -> [\s\w-]+
  ///
  private mutating func lexCharacterProperty(
  ) throws -> Loc<Atom.CharacterProperty>? {
    try recordLoc { src in
      // '\P{...}' is the inverted version of '\p{...}'
      guard src.starts(with: "p{") || src.starts(with: "P{") else { return nil }
      let isInverted = src.peek() == "P"
      src.advance(2)

      // We should either have:
      // - '\p{x=y}' where 'x' is a property key, and 'y' is a value.
      // - '\p{y}' where 'y' is a value (or a bool key with an inferred value
      //   of true), and its key is inferred.
      // TODO: We could have better recovery here if we only ate the characters
      // that property keys and values can use.
      let lhs = try src.lexUntil({ $0.peek() == "}" || $0.peek() == "=" }).value
      if src.tryEat("}") {
        let prop = try Source.classifyCharacterPropertyValueOnly(lhs)
        return .init(prop, isInverted: isInverted)
      }
      src.eat(asserting: "=")

      let rhs = try src.lexUntil(eating: "}").value
      let prop = try Source.classifyCharacterProperty(key: lhs, value: rhs)
      return .init(prop, isInverted: isInverted)
    }
  }

  /// Consume an escaped atom, starting from after the backslash
  ///
  ///     Escaped          -> KeyboardModified | Builtin
  ///                       | UniScalar | Property
  ///
  /// TODO: references
  mutating func expectEscaped(
    isInCustomCharacterClass ccc: Bool
  ) throws -> Loc<Atom> {
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

      // Named character \N{...}
      if src.tryEat(sequence: "N{") {
        return .namedCharacter(try src.lexUntil(eating: "}").value)
      }

      // Character property \p{...} \P{...}.
      if let prop = try src.lexCharacterProperty() {
        return .property(prop.value)
      }

      let char = src.eat()

      // Single-character builtins
      if let builtin = Atom.EscapedBuiltin(
        char, inCustomCharacterClass: ccc
      ) {
        return .escaped(builtin)
      }

      switch char {
      // Scalars
      case "u", "x", "U":
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
  ) throws -> Loc<Atom>? {
    try recordLoc { src in
      // Check for not-an-atom, e.g. parser recursion termination
      if src.isEmpty { return nil }
      if !customCC && (src.peek() == ")" || src.peek() == "|") { return nil }
      // TODO: Store customCC in the atom, if that's useful

      // POSIX named set. This is only allowed in a custom character class.
      // TODO: Can we try and recover and diagnose for named sets outside
      // character classes?
      if customCC, let set = try src.lexPOSIXNamedSet()?.value {
        return .namedSet(set)
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
  }

  /// Try to lex the end of a range in a custom character class, which consists
  /// of a '-' character followed by an atom.
  mutating func lexCustomCharClassRangeEnd() throws -> Loc<Atom>? {
    // Make sure we don't have a binary operator e.g '--', and the '-' is not
    // ending the custom character class (in which case it is literal).
    guard peekCCBinOp() == nil && !starts(with: "-]") && tryEat("-") else {
      return nil
    }
    return try lexAtom(isInCustomCharacterClass: true)
  }
}

