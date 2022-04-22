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

@testable import _RegexParser

import XCTest
@testable import _StringProcessing

extension AST.Node: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = _StringProcessing.atom(.char(value))
  }
}
extension AST.Atom: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = atom_a(.char(value))
  }
}
extension AST.CustomCharacterClass.Member: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = atom_m((.char(value)))
  }
}


class RegexTests: XCTestCase {}

func parseTest(
  _ input: String, _ expectedAST: AST.Node,
  syntax: SyntaxOptions = .traditional,
  captures expectedCaptures: CaptureStructure = .empty,
  file: StaticString = #file,
  line: UInt = #line
) {
  parseTest(
    input, .init(expectedAST, globalOptions: nil), syntax: syntax,
    captures: expectedCaptures, file: file, line: line
  )
}

func parseTest(
  _ input: String, _ expectedAST: AST,
  syntax: SyntaxOptions = .traditional,
  captures expectedCaptures: CaptureStructure = .empty,
  file: StaticString = #file,
  line: UInt = #line
) {
  let ast = try! parse(input, syntax)
  guard ast == expectedAST
          || ast._dump() == expectedAST._dump() // EQ workaround
  else {
    XCTFail("""

              Expected: \(expectedAST._dump())
              Found:    \(ast._dump())
              """,
            file: file, line: line)
    return
  }
  let captures = ast.captureStructure
  guard captures == expectedCaptures else {
    XCTFail("""

              Expected captures: \(expectedCaptures)
              Found:             \(captures)
              """,
            file: file, line: line)
    return
  }
  // Test capture structure round trip serialization.
  let serializedCapturesSize = CaptureStructure.serializationBufferSize(
    forInputUTF8CodeUnitCount: input.utf8.count)
  let serializedCaptures = UnsafeMutableRawBufferPointer.allocate(
    byteCount: serializedCapturesSize,
    alignment: MemoryLayout<Int8>.alignment)
  captures.encode(to: serializedCaptures)
  guard let decodedCaptures = CaptureStructure(
    decoding: UnsafeRawBufferPointer(serializedCaptures)
  ) else {
    XCTFail("""
      Malformed capture structure serialization
      Captures: \(captures)
      Serialization: \(Array(serializedCaptures))
      """)
    return
  }
  guard decodedCaptures == captures else {
    XCTFail("""

              Expected captures:  \(expectedCaptures)
              Decoded:            \(decodedCaptures)
              """,
            file: file, line: line)
    return
  }
  serializedCaptures.deallocate()
}

/// Test delimiter lexing. Takes an input string that starts with a regex
/// literal. If `ignoreTrailing` is true, there may be additional characters
/// that follow the literal that are not considered part of it.
@discardableResult
func delimiterLexingTest(
  _ input: String, ignoreTrailing: Bool = false,
  file: StaticString = #file, line: UInt = #line
) -> String {
  input.withCString(encodedAs: UTF8.self) { ptr in
    let endPtr = ptr + input.utf8.count
    let (contents, delim, end) = try! lexRegex(
      start: ptr, end: endPtr, delimiters: Delimiter.allDelimiters)
    if ignoreTrailing {
      XCTAssertNotEqual(end, endPtr, file: file, line: line)
    } else {
      XCTAssertEqual(end, endPtr, file: file, line: line)
    }

    let rawPtr = UnsafeRawPointer(ptr)
    let buffer = UnsafeRawBufferPointer(start: rawPtr, count: end - rawPtr)
    let literal = String(decoding: buffer, as: UTF8.self)

    let (parseContents, parseDelim) = droppingRegexDelimiters(literal)
    XCTAssertEqual(contents, parseContents, file: file, line: line)
    XCTAssertEqual(delim, parseDelim, file: file, line: line)
    return literal
  }
}

/// Test parsing an input string with regex delimiters. If `ignoreTrailing` is
/// true, there may be additional characters that follow the literal that are
/// not considered part of it.
func parseWithDelimitersTest(
  _ input: String, _ expecting: AST.Node, ignoreTrailing: Bool = false,
  file: StaticString = #file, line: UInt = #line
) {
  // First try lexing.
  let literal = delimiterLexingTest(
    input, ignoreTrailing: ignoreTrailing, file: file, line: line)

  let orig = try! parseWithDelimiters(literal)
  let ast = orig.root
  guard ast == expecting
          || ast._dump() == expecting._dump() // EQ workaround
  else {
    XCTFail("""
              Expected: \(expecting._dump())
              Found:    \(ast._dump())
              """,
            file: file, line: line)
    return
  }
}

/// Make sure the AST for two regex strings get compared differently.
func parseNotEqualTest(
  _ lhs: String, _ rhs: String,
  syntax: SyntaxOptions = .traditional,
  file: StaticString = #file, line: UInt = #line
) {
  let lhsAST = try! parse(lhs, syntax)
  let rhsAST = try! parse(rhs, syntax)
  if lhsAST == rhsAST || lhsAST._dump() == rhsAST._dump() {
    XCTFail("""
              AST: \(lhsAST._dump())
              Should not be equal to: \(rhsAST._dump())
              """,
            file: file, line: line)
  }
}

func rangeTest(
  _ input: String, syntax: SyntaxOptions = .traditional,
  _ expectedRange: (String) -> Range<Int>,
  at locFn: (AST.Node) -> SourceLocation = \.location,
  file: StaticString = #file, line: UInt = #line
) {
  let ast = try! parse(input, syntax).root
  let range = input.offsets(of: locFn(ast).range)
  let expected = expectedRange(input)

  guard range == expected else {
    XCTFail("""
            Expected range: "\(expected)"
            Found range: "\(range)"
            """,
            file: file, line: line)
    return
  }
}

func diagnosticTest(
  _ input: String, _ expected: ParseError,
  syntax: SyntaxOptions = .traditional,
  file: StaticString = #file, line: UInt = #line
) {
  do {
    let ast = try parse(input, syntax)
    XCTFail("""

      Passed \(ast)
      But expected error: \(expected)
    """, file: file, line: line)
  } catch let e as Source.LocatedError<ParseError> {
    guard e.error == expected else {
      XCTFail("""

        Expected: \(expected)
        Actual: \(e.error)
      """, file: file, line: line)
      return
    }
  } catch let e {
    XCTFail("Error without source location: \(e)", file: file, line: line)
  }
}

func diagnosticWithDelimitersTest(
  _ input: String, _ expected: ParseError, ignoreTrailing: Bool = false,
  file: StaticString = #file, line: UInt = #line
) {
  // First try lexing.
  let literal = delimiterLexingTest(
    input, ignoreTrailing: ignoreTrailing, file: file, line: line)

  do {
    let orig = try parseWithDelimiters(literal)
    let ast = orig.root
    XCTFail("""

      Passed \(ast)
      But expected error: \(expected)
    """, file: file, line: line)
  } catch let e as Source.LocatedError<ParseError> {
    guard e.error == expected else {
      XCTFail("""

        Expected: \(expected)
        Actual: \(e.error)
      """, file: file, line: line)
      return
    }
  } catch let e {
    XCTFail("Error without source location: \(e)", file: file, line: line)
  }
}

func delimiterLexingDiagnosticTest(
  _ input: String, _ expected: DelimiterLexError.Kind,
  syntax: SyntaxOptions = .traditional,
  file: StaticString = #file, line: UInt = #line
) {
  do {
    _ = try input.withCString { ptr in
      try lexRegex(
        start: ptr, end: ptr + input.count, delimiters: Delimiter.allDelimiters)
    }
    XCTFail("""
      Passed, but expected error: \(expected)
    """, file: file, line: line)
  } catch let e as DelimiterLexError {
    guard e.kind == expected else {
      XCTFail("""

        Expected: \(expected)
        Actual: \(e.kind)
      """, file: file, line: line)
      return
    }
  } catch let e {
    XCTFail("Unexpected error type: \(e)", file: file, line: line)
  }
}

func libswiftDiagnosticMessageTest(
  _ input: String, _ expectedErr: String, file: StaticString = #file,
  line: UInt = #line
) {
  var errPtr: UnsafePointer<CChar>?
  var version: CUnsignedInt = 0

  libswiftParseRegexLiteral(
    input, &errPtr, &version, /*captureStructure*/ nil,
    /*captureStructureSize*/ 0
  )

  guard let errPtr = errPtr else {
    XCTFail("Unexpected test pass", file: file, line: line)
    return
  }
  let err = String(cString: errPtr)
  XCTAssertEqual(expectedErr, err, file: file, line: line)
}

extension RegexTests {
  func testParse() {
    parseTest(
      "abc", concat("a", "b", "c"))
    parseTest(
      #"abc\+d*"#,
      concat("a", "b", "c", "+", zeroOrMore(of: "d")))
    parseTest(
      "a(b)", concat("a", capture("b")),
      captures: .atom())
    parseTest(
      "abc(?:de)+fghi*k|j",
      alt(
        concat(
          "a", "b", "c",
          oneOrMore(
            of: nonCapture(concat("d", "e"))),
          "f", "g", "h", zeroOrMore(of: "i"), "k"),
        "j"))
    parseTest(
      "a(?:b|c)?d",
      concat("a", zeroOrOne(
        of: nonCapture(alt("b", "c"))), "d"))
    parseTest(
      "a?b??c+d+?e*f*?",
      concat(
        zeroOrOne(of: "a"), zeroOrOne(.reluctant, of: "b"),
        oneOrMore(of: "c"), oneOrMore(.reluctant, of: "d"),
        zeroOrMore(of: "e"), zeroOrMore(.reluctant, of: "f")))

    parseTest(
      "(.)*(.*)",
      concat(
        zeroOrMore(of: capture(atom(.any))),
        capture(zeroOrMore(of: atom(.any)))),
      captures: .tuple([.optional(.atom()), .atom()]))
    parseTest(
      "((.))*((.)?)",
      concat(
        zeroOrMore(of: capture(capture(atom(.any)))),
        capture(zeroOrOne(of: capture(atom(.any))))),
      captures: .tuple([
        .optional(.atom()), .optional(.atom()), .atom(), .optional(.atom())
      ]))
    parseTest(
      #"abc\d"#,
      concat("a", "b", "c", escaped(.decimalDigit)))

    // MARK: Alternations

    parseTest(
      "a|b?c",
      alt("a", concat(zeroOrOne(of: "b"), "c")))
    parseTest(
      "(a|b)c",
      concat(capture(alt("a", "b")), "c"),
      captures: .atom())
    parseTest(
      "(a)|b",
      alt(capture("a"), "b"),
      captures: .optional(.atom()))
    parseTest(
      "(a)|(b)|c",
      alt(capture("a"), capture("b"), "c"),
      captures: .tuple(.optional(.atom()), .optional(.atom())))
    parseTest(
      "((a|b))c",
      concat(capture(capture(alt("a", "b"))), "c"),
      captures: .tuple([.atom(), .atom()]))
    parseTest(
      "(?:((a|b)))*?c",
      concat(quant(
        .zeroOrMore, .reluctant,
        nonCapture(capture(capture(alt("a", "b"))))), "c"),
      captures: .tuple(.optional(.atom()), .optional(.atom())))
    parseTest(
      "(a)|b|(c)d",
      alt(capture("a"), "b", concat(capture("c"), "d")),
      captures: .tuple([.optional(.atom()), .optional(.atom())]))

    // Alternations with empty branches are permitted.
    parseTest("|", alt(empty(), empty()))
    parseTest("(|)", capture(alt(empty(), empty())), captures: .atom())
    parseTest("a|", alt("a", empty()))
    parseTest("|b", alt(empty(), "b"))
    parseTest("|b|", alt(empty(), "b", empty()))
    parseTest("a|b|", alt("a", "b", empty()))
    parseTest("||c|", alt(empty(), empty(), "c", empty()))
    parseTest("|||", alt(empty(), empty(), empty(), empty()))
    parseTest("a|||d", alt("a", empty(), empty(), "d"))

    // MARK: Unicode scalars

    parseTest(
      #"a\u0065b\u{00000065}c\x65d\U00000065"#,
      concat("a", scalar("e"),
             "b", scalar("e"),
             "c", scalar("e"),
             "d", scalar("e")))

    parseTest(#"\u{00000000000000000000000000A}"#, scalar("\u{A}"))
    parseTest(#"\x{00000000000000000000000000A}"#, scalar("\u{A}"))
    parseTest(#"\o{000000000000000000000000007}"#, scalar("\u{7}"))

    parseTest(#"\o{70}"#, scalar("\u{38}"))
    parseTest(#"\0"#, scalar("\u{0}"))
    parseTest(#"\01"#, scalar("\u{1}"))
    parseTest(#"\070"#, scalar("\u{38}"))
    parseTest(#"\07A"#, concat(scalar("\u{7}"), "A"))
    parseTest(#"\08"#, concat(scalar("\u{0}"), "8"))
    parseTest(#"\0707"#, scalar("\u{1C7}"))

    parseTest(#"[\0]"#, charClass(scalar_m("\u{0}")))
    parseTest(#"[\01]"#, charClass(scalar_m("\u{1}")))
    parseTest(#"[\070]"#, charClass(scalar_m("\u{38}")))

    parseTest(#"[\07A]"#, charClass(scalar_m("\u{7}"), "A"))
    parseTest(#"[\08]"#, charClass(scalar_m("\u{0}"), "8"))
    parseTest(#"[\0707]"#, charClass(scalar_m("\u{1C7}")))

    // TODO: These are treated as octal sequences by PCRE, we should warn and
    // suggest user prefix with 0.
    parseTest(#"[\1]"#, charClass("1"))
    parseTest(#"[\123]"#, charClass("1", "2", "3"))
    parseTest(#"[\101]"#, charClass("1", "0", "1"))
    parseTest(#"[\7777]"#, charClass("7", "7", "7", "7"))
    parseTest(#"[\181]"#, charClass("1", "8", "1"))

    // We take *up to* the first two valid digits for \x. No valid digits is 0.
    parseTest(#"\x"#, scalar("\u{0}"))
    parseTest(#"\x5"#, scalar("\u{5}"))
    parseTest(#"\xX"#, concat(scalar("\u{0}"), "X"))
    parseTest(#"\x5X"#, concat(scalar("\u{5}"), "X"))
    parseTest(#"\x12ab"#, concat(scalar("\u{12}"), "a", "b"))

    // MARK: Character classes

    parseTest(#"abc\d"#, concat("a", "b", "c", escaped(.decimalDigit)))

    parseTest(
      "[-|$^:?+*())(*-+-]",
      charClass(
        "-", "|", "$", "^", ":", "?", "+", "*", "(", ")", ")",
        "(", range_m("*", "+"), "-"))

    parseTest(
      "[a-b-c]", charClass(range_m("a", "b"), "-", "c"))

    parseTest("[-a-]", charClass("-", "a", "-"))

    parseTest("[a-z]", charClass(range_m("a", "z")))

    // FIXME: AST builder helpers for custom char class types
    parseTest("[a-d--a-c]", charClass(
      .setOperation([range_m("a", "d")], .init(faking: .subtraction), [range_m("a", "c")])
    ))

    parseTest("[-]", charClass("-"))

    // Empty character classes are forbidden, therefore these are character
    // classes containing literal ']'.
    parseTest("[]]", charClass("]"))
    parseTest("[]a]", charClass("]", "a"))
    parseTest("(?x)[ ]]", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      charClass("]")
    ))
    parseTest("(?x)[ ]  ]", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      charClass("]")
    ))
    parseTest("(?x)[ ] a ]", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      charClass("]", "a")
    ))

    // These are metacharacters in certain contexts, but normal characters
    // otherwise.
    parseTest(
      ":-]", concat(":", "-", "]"))

    parseTest(
      "[^abc]", charClass("a", "b", "c", inverted: true))
    parseTest(
      "[a^]", charClass("a", "^"))

    // These are custom character classes, not invalid POSIX character classes.
    // TODO: This behavior is subtle, we ought to warn.
    parseTest("[[:space]]", charClass(charClass(":", "s", "p", "a", "c", "e")))
    parseTest("[:a]", charClass(":", "a"))
    parseTest("[a:]", charClass("a", ":"))
    parseTest("[:]", charClass(":"))
    parseTest("[[:]]", charClass(charClass(":")))
    parseTest("[[:a=b=c:]]", charClass(charClass(":", "a", "=", "b", "=", "c", ":")))

    parseTest(#"[[:a[b]:]]"#, charClass(charClass(":", "a", charClass("b"), ":")))
    parseTest(#"[[:a]][:]"#, concat(charClass(charClass(":", "a")), charClass(":")))
    parseTest(#"[[:a]]"#, charClass(charClass(":", "a")))
    parseTest(#"[[:}]]"#, charClass(charClass(":", "}")))
    parseTest(#"[[:{]]"#, charClass(charClass(":", "{")))
    parseTest(#"[[:}:]]"#, charClass(charClass(":", "}", ":")))

    parseTest(
      #"[:[:space:]:]"#,
      charClass(":", posixProp_m(.binary(.whitespace)), ":")
    )
    parseTest(
      #"[:a[:space:]b:]"#,
      charClass(":", "a", posixProp_m(.binary(.whitespace)), "b", ":")
    )

    // ICU parses a custom character class if it sees any of its known escape
    // sequences in a POSIX character property (though it appears to exclude
    // character class escapes e.g '\d'). We do so for any escape sequence as
    // '\' is not a valid character property character.
    parseTest(#"[:\Q:]\E]"#, charClass(":", quote_m(":]")))
    parseTest(#"[:\a:]"#, charClass(":", atom_m(.escaped(.alarm)), ":"))
    parseTest(#"[:\d:]"#, charClass(":", atom_m(.escaped(.decimalDigit)), ":"))
    parseTest(#"[:\\:]"#, charClass(":", "\\", ":"))
    parseTest(#"[:\:]"#, charClass(":", ":"))

    parseTest(
      #"\D\S\W"#,
      concat(
        escaped(.notDecimalDigit),
        escaped(.notWhitespace),
        escaped(.notWordCharacter)))

    parseTest(
      #"[\dd]"#, charClass(atom_m(.escaped(.decimalDigit)), "d"))

    parseTest(
      #"[^[\D]]"#,
      charClass(charClass(atom_m(.escaped(.notDecimalDigit))),
                inverted: true))
    parseTest(
      "[[ab][bc]]",
      charClass(charClass("a", "b"), charClass("b", "c")))
    parseTest(
      "[[ab]c[de]]",
      charClass(charClass("a", "b"), "c", charClass("d", "e")))

    parseTest(#"[ab[:space:]\d[:^upper:]cd]"#,
              charClass("a", "b",
                        posixProp_m(.binary(.whitespace)),
                        atom_m(.escaped(.decimalDigit)),
                        posixProp_m(.binary(.uppercase), inverted: true),
                        "c", "d"))

    // Like ICU, we allow POSIX character properties outside of custom character
    // classes. This also appears to be suggested by UTS#18.
    // TODO: We should likely emit a warning.
    parseTest("[:space:]", posixProp(.binary(.whitespace)))
    parseTest("[:script=Greek:]", posixProp(.script(.greek)))

    parseTest("[[[:space:]]]", charClass(charClass(
      posixProp_m(.binary(.whitespace))
    )))

    parseTest("[[:alnum:]]", charClass(posixProp_m(.posix(.alnum))))
    parseTest("[[:blank:]]", charClass(posixProp_m(.posix(.blank))))
    parseTest("[[:graph:]]", charClass(posixProp_m(.posix(.graph))))
    parseTest("[[:print:]]", charClass(posixProp_m(.posix(.print))))
    parseTest("[[:word:]]", charClass(posixProp_m(.posix(.word))))
    parseTest("[[:xdigit:]]", charClass(posixProp_m(.posix(.xdigit))))

    parseTest("[[:ascii:]]", charClass(posixProp_m(.ascii)))
    parseTest("[[:cntrl:]]", charClass(posixProp_m(.generalCategory(.control))))
    parseTest("[[:digit:]]", charClass(posixProp_m(.generalCategory(.decimalNumber))))
    parseTest("[[:lower:]]", charClass(posixProp_m(.binary(.lowercase))))
    parseTest("[[:punct:]]", charClass(posixProp_m(.generalCategory(.punctuation))))
    parseTest("[[:space:]]", charClass(posixProp_m(.binary(.whitespace))))
    parseTest("[[:upper:]]", charClass(posixProp_m(.binary(.uppercase))))

    parseTest("[[:UPPER:]]", charClass(posixProp_m(.binary(.uppercase))))

    parseTest("[[:isALNUM:]]", charClass(posixProp_m(.posix(.alnum))))
    parseTest("[[:AL_NUM:]]", charClass(posixProp_m(.posix(.alnum))))
    parseTest("[[:script=Greek:]]", charClass(posixProp_m(.script(.greek))))

    parseTest("[*]", charClass("*"))
    parseTest("[{0}]", charClass("{", "0", "}"))

    parseTest(#"[\f-\e]"#, charClass(
      range_m(.escaped(.formfeed), .escaped(.escape))))
    parseTest(#"[\a-\b]"#, charClass(
      range_m(.escaped(.alarm), .escaped(.backspace))))
    parseTest(#"[\n-\r]"#, charClass(
      range_m(.escaped(.newline), .escaped(.carriageReturn))))
    parseTest(#"[\t-\t]"#, charClass(
      range_m(.escaped(.tab), .escaped(.tab))))

    parseTest(#"[\cX-\cY\C-A-\C-B\M-\C-A-\M-\C-B\M-A-\M-B]"#, charClass(
      range_m(.keyboardControl("X"), .keyboardControl("Y")),
      range_m(.keyboardControl("A"), .keyboardControl("B")),
      range_m(.keyboardMetaControl("A"), .keyboardMetaControl("B")),
      range_m(.keyboardMeta("A"), .keyboardMeta("B"))
    ))

    parseTest(#"[\N{DOLLAR SIGN}-\N{APOSTROPHE}]"#, charClass(
      range_m(.namedCharacter("DOLLAR SIGN"), .namedCharacter("APOSTROPHE"))))

    // MARK: Operators

    parseTest(
      #"[a[bc]de&&[^bc]\d]+"#,
      oneOrMore(of: charClass(
        .setOperation(
          ["a", charClass("b", "c"), "d", "e"],
          .init(faking: .intersection),
          [charClass("b", "c", inverted: true), atom_m(.escaped(.decimalDigit))]
        ))))

    parseTest(
      "[a&&b]",
      charClass(
        .setOperation(["a"], .init(faking: .intersection), ["b"])))

    parseTest(
      "[abc--def]",
      charClass(.setOperation(["a", "b", "c"], .init(faking: .subtraction), ["d", "e", "f"])))

    // We left-associate for chained operators.
    parseTest(
      "[ab&&b~~cd]",
      charClass(
        .setOperation(
          [.setOperation(["a", "b"], .init(faking: .intersection), ["b"])],
          .init(faking: .symmetricDifference),
          ["c", "d"])))

    // Operators are only valid in custom character classes.
    parseTest(
      "a&&b", concat("a", "&", "&", "b"))
    parseTest(
      "&?", zeroOrOne(of: "&"))
    parseTest(
      "&&?", concat("&", zeroOrOne(of: "&")))
    parseTest(
      "--+", concat("-", oneOrMore(of: "-")))
    parseTest(
      "~~*", concat("~", zeroOrMore(of: "~")))

    parseTest(
      "[ &&  ]",
      charClass(.setOperation([" "], .init(faking: .intersection), [" ", " "]))
    )
    parseTest("(?x)[ a && b ]", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      charClass(.setOperation(["a"], .init(faking: .intersection), ["b"]))
    ))

    // MARK: Quotes

    parseTest(
      #"a\Q .\Eb"#,
      concat("a", quote(" ."), "b"))
    parseTest(
      #"a\Q \Q \\.\Eb"#,
      concat("a", quote(#" \Q \\."#), "b"))

    // This follows the PCRE behavior.
    parseTest(#"\Q\\E"#, quote("\\"))

    parseTest(#"a" ."b"#, concat("a", quote(" ."), "b"),
              syntax: .experimental)
    parseTest(#"a" .""b""#, concat("a", quote(" ."), quote("b")),
              syntax: .experimental)
    parseTest(#"a" .\"\"b""#, concat("a", quote(" .\"\"b")),
              syntax: .experimental)
    parseTest(#""\"""#, quote("\""), syntax: .experimental)

    // Quotes in character classes.
    parseTest(#"[\Q-\E]"#, charClass(quote_m("-")))
    parseTest(#"[\Qa-b[[*+\\E]"#, charClass(quote_m("a-b[[*+\\")))

    parseTest(#"["-"]"#, charClass(quote_m("-")), syntax: .experimental)
    parseTest(#"["a-b[[*+\""]"#, charClass(quote_m(#"a-b[[*+""#)),
              syntax: .experimental)

    parseTest(#"["-"]"#, charClass(range_m("\"", "\"")))

    // MARK: Escapes

    // Not metachars, but we allow their escape as ASCII.
    parseTest(#"\<"#, "<")
    parseTest(#"\ "#, " ")
    parseTest(#"\\"#, "\\")

    // Escaped U+3000 IDEOGRAPHIC SPACE.
    parseTest(#"\\#u{3000}"#, "\u{3000}")

    // Control and meta controls.
    parseTest(#"\c "#, atom(.keyboardControl(" ")))
    parseTest(#"\c!"#, atom(.keyboardControl("!")))
    parseTest(#"\c~"#, atom(.keyboardControl("~")))
    parseTest(#"\C--"#, atom(.keyboardControl("-")))
    parseTest(#"\M-\C-a"#, atom(.keyboardMetaControl("a")))
    parseTest(#"\M-\C--"#, atom(.keyboardMetaControl("-")))
    parseTest(#"\M-a"#, atom(.keyboardMeta("a")))

    // MARK: Comments

    parseTest(
      #"a(?#comment)b"#,
      concat("a", "b"))
    parseTest(
      #"a(?#. comment)b"#,
      concat("a", "b"))

    // MARK: Quantification

    parseTest("a*", zeroOrMore(of: "a"))
    parseTest(" +", oneOrMore(of: " "))

    parseTest(
      #"a{1,2}"#,
      quantRange(1...2, of: "a"))
    parseTest(
      #"a{,2}"#,
      upToN(2, of: "a"))
    parseTest(
      #"a{2,}"#,
      nOrMore(2, of: "a"))
    parseTest(
      #"a{1}"#,
      exactly(1, of: "a"))
    parseTest(
      #"a{1,2}?"#,
      quantRange(1...2, .reluctant, of: "a"))
    parseTest(
      #"a{0}"#,
      exactly(0, of: "a"))
    parseTest(
      #"a{0,0}"#,
      quantRange(0...0, of: "a"))

    // Make sure ranges get treated as literal if invalid.
    parseTest("{", "{")
    parseTest("{,", concat("{", ","))
    parseTest("{}", concat("{", "}"))
    parseTest("{,}", concat("{", ",", "}"))
    parseTest("{,6", concat("{", ",", "6"))
    parseTest("{6", concat("{", "6"))
    parseTest("{6,", concat("{", "6", ","))
    parseTest("{+", oneOrMore(of: "{"))
    parseTest("{6,+", concat("{", "6", oneOrMore(of: ",")))
    parseTest("x{", concat("x", "{"))
    parseTest("x{}", concat("x", "{", "}"))
    parseTest("x{,}", concat("x", "{", ",", "}"))
    parseTest("x{,6", concat("x", "{", ",", "6"))
    parseTest("x{6", concat("x", "{", "6"))
    parseTest("x{6,", concat("x", "{", "6", ","))
    parseTest("x{+", concat("x", oneOrMore(of: "{")))
    parseTest("x{6,+", concat("x", "{", "6", oneOrMore(of: ",")))

    // TODO: We should emit a diagnostic for this.
    parseTest("x{3, 5}", concat("x", "{", "3", ",", " ", "5", "}"))
    parseTest("{3, 5}", concat("{", "3", ",", " ", "5", "}"))
    parseTest("{3 }", concat("{", "3", " ", "}"))

    // MARK: Groups

    // Named captures
    parseTest(
      #"a(?<label>b)c"#,
      concat("a", namedCapture("label", "b"), "c"),
      captures: .atom(name: "label"))
    parseTest(
      #"a(?<label1>b)c(?<label2>d)"#,
      concat(
        "a", namedCapture("label1", "b"), "c", namedCapture("label2", "d")),
      captures: .tuple([.atom(name: "label1"), .atom(name: "label2")]))
    parseTest(
      #"a(?'label'b)c"#,
      concat("a", namedCapture("label", "b"), "c"),
      captures: .atom(name: "label"))
    parseTest(
      #"a(?P<label>b)c"#,
      concat("a", namedCapture("label", "b"), "c"),
      captures: .atom(name: "label"))
    parseTest(
      #"a(?P<label>b)c"#,
      concat("a", namedCapture("label", "b"), "c"),
      captures: .atom(name: "label"))

    // Balanced captures
    parseTest(#"(?<a-c>)"#, balancedCapture(name: "a", priorName: "c", empty()),
              captures: .atom(name: "a"))
    parseTest(#"(?<-c>)"#, balancedCapture(name: nil, priorName: "c", empty()),
              captures: .atom())
    parseTest(#"(?'a-b'c)"#, balancedCapture(name: "a", priorName: "b", "c"),
              captures: .atom(name: "a"))

    // Other groups
    parseTest(
      #"a(?:b)c"#,
      concat("a", nonCapture("b"), "c"))
    parseTest(
      #"a(?|b)c"#,
      concat("a", nonCaptureReset("b"), "c"))
    parseTest(
      #"a(?>b)c"#,
      concat("a", atomicNonCapturing("b"), "c"))
    parseTest(
      "a(*atomic:b)c",
      concat("a", atomicNonCapturing("b"), "c"))

    parseTest("a(?=b)c", concat("a", lookahead("b"), "c"))
    parseTest("a(*pla:b)c", concat("a", lookahead("b"), "c"))
    parseTest("a(*positive_lookahead:b)c", concat("a", lookahead("b"), "c"))

    parseTest("a(?!b)c", concat("a", negativeLookahead("b"), "c"))
    parseTest("a(*nla:b)c", concat("a", negativeLookahead("b"), "c"))
    parseTest("a(*negative_lookahead:b)c",
              concat("a", negativeLookahead("b"), "c"))

    parseTest("a(?<=b)c", concat("a", lookbehind("b"), "c"))
    parseTest("a(*plb:b)c", concat("a", lookbehind("b"), "c"))
    parseTest("a(*positive_lookbehind:b)c", concat("a", lookbehind("b"), "c"))

    parseTest("a(?<!b)c", concat("a", negativeLookbehind("b"), "c"))
    parseTest("a(*nlb:b)c", concat("a", negativeLookbehind("b"), "c"))
    parseTest("a(*negative_lookbehind:b)c",
              concat("a", negativeLookbehind("b"), "c"))

    parseTest("a(?*b)c", concat("a", nonAtomicLookahead("b"), "c"))
    parseTest("a(*napla:b)c", concat("a", nonAtomicLookahead("b"), "c"))
    parseTest("a(*non_atomic_positive_lookahead:b)c",
              concat("a", nonAtomicLookahead("b"), "c"))

    parseTest("a(?<*b)c", concat("a", nonAtomicLookbehind("b"), "c"))
    parseTest("a(*naplb:b)c", concat("a", nonAtomicLookbehind("b"), "c"))
    parseTest("a(*non_atomic_positive_lookbehind:b)c",
              concat("a", nonAtomicLookbehind("b"), "c"))

    parseTest("a(*sr:b)c", concat("a", scriptRun("b"), "c"))
    parseTest("a(*script_run:b)c", concat("a", scriptRun("b"), "c"))

    parseTest("a(*asr:b)c", concat("a", atomicScriptRun("b"), "c"))
    parseTest("a(*atomic_script_run:b)c",
              concat("a", atomicScriptRun("b"), "c"))

    // Matching option changing groups.
    parseTest("(?-)", changeMatchingOptions(
      matchingOptions()
    ))
    parseTest("(?i)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive)
    ))
    parseTest("(?m)", changeMatchingOptions(
      matchingOptions(adding: .multiline)
    ))
    parseTest("(?x)", changeMatchingOptions(
      matchingOptions(adding: .extended)
    ))
    parseTest("(?xx)", changeMatchingOptions(
      matchingOptions(adding: .extraExtended)
    ))
    parseTest("(?xxx)", changeMatchingOptions(
      matchingOptions(adding: .extraExtended, .extended)
    ))
    parseTest("(?P)", changeMatchingOptions(
      matchingOptions(adding: .asciiOnlyPOSIXProps)
    ))
    parseTest("(?-i)", changeMatchingOptions(
      matchingOptions(removing: .caseInsensitive)
    ))
    parseTest("(?i-s)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive, removing: .singleLine)
    ))
    parseTest("(?i-is)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive,
                      removing: .caseInsensitive, .singleLine)
    ))

    parseTest("(?:)", nonCapture(empty()))
    parseTest("(?-:)", changeMatchingOptions(
      matchingOptions(), empty()
    ))
    parseTest("(?i:)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive), empty()
    ))
    parseTest("(?-i:)", changeMatchingOptions(
      matchingOptions(removing: .caseInsensitive), empty()
    ))
    parseTest("(?P:)", changeMatchingOptions(
      matchingOptions(adding: .asciiOnlyPOSIXProps), empty()
    ))

    parseTest("(?^)", changeMatchingOptions(
      unsetMatchingOptions()
    ))
    parseTest("(?^:)", changeMatchingOptions(
      unsetMatchingOptions(), empty()
    ))
    parseTest("(?^ims:)", changeMatchingOptions(
      unsetMatchingOptions(adding: .caseInsensitive, .multiline, .singleLine),
      empty()
    ))
    parseTest("(?^J:)", changeMatchingOptions(
      unsetMatchingOptions(adding: .allowDuplicateGroupNames), empty()
    ))
    parseTest("(?^y{w}:)", changeMatchingOptions(
      unsetMatchingOptions(adding: .textSegmentWordMode), empty()
    ))

    let allOptions: [AST.MatchingOption.Kind] = [
      .caseInsensitive, .allowDuplicateGroupNames, .multiline, .noAutoCapture,
      .singleLine, .reluctantByDefault, .extraExtended, .extended,
      .unicodeWordBoundaries, .asciiOnlyDigit, .asciiOnlyPOSIXProps,
      .asciiOnlySpace, .asciiOnlyWord, .textSegmentGraphemeMode,
      .textSegmentWordMode, .graphemeClusterSemantics, .unicodeScalarSemantics,
      .byteSemantics
    ]
    parseTest("(?iJmnsUxxxwDPSWy{g}y{w}Xub-iJmnsUxxxwDPSW)", changeMatchingOptions(
      matchingOptions(adding: allOptions, removing: allOptions.dropLast(5))
    ))
    parseTest("(?iJmnsUxxxwDPSWy{g}y{w}Xub-iJmnsUxxxwDPSW:)", changeMatchingOptions(
      matchingOptions(adding: allOptions, removing: allOptions.dropLast(5)), empty()
    ))

    parseTest(
      "a(b(?i)c)d", concat(
        "a",
        capture(concat(
          "b",
          changeMatchingOptions(matchingOptions(adding: .caseInsensitive)),
          "c"
        )),
        "d"
      ),
      captures: .atom()
    )
    parseTest(
      "(a(?i)b(c)d)", capture(concat(
        "a",
        changeMatchingOptions(matchingOptions(adding: .caseInsensitive)),
        "b",
        capture("c"),
        "d"
      )),
      captures: .tuple(.atom(), .atom())
    )
    parseTest(
      "(a(?i)b(?#hello)c)", capture(concat(
        "a",
        changeMatchingOptions(matchingOptions(adding: .caseInsensitive)),
        "b",
        "c"
      )),
      captures: .atom()
    )

    parseTest("ab(?i)c|def|gh", alt(
      concat(
        "a",
        "b",
        changeMatchingOptions(matchingOptions(adding: .caseInsensitive)),
        "c"
      ),
      concat("d", "e", "f"),
      concat("g", "h")
    ))

    parseTest("(a|b(?i)c|d)", capture(alt(
      "a",
      concat(
        "b",
        changeMatchingOptions(matchingOptions(adding: .caseInsensitive)),
        "c"
      ),
      "d"
    )), captures: .atom())

    // MARK: References

    // \1 ... \9 are always backreferences.
    for i in 1 ... 9 {
      parseTest("\\\(i)", backreference(.absolute(i)))
      parseTest(
        "()()()()()()()()()\\\(i)",
        concat(Array(repeating: capture(empty()), count: 9)
               + [backreference(.absolute(i))]),
        captures: .tuple(Array(repeating: .atom(), count: 9))
      )
    }

    parseTest(#"\10"#, backreference(.absolute(10)))
    parseTest(#"\18"#, backreference(.absolute(18)))
    parseTest(#"\7777"#, backreference(.absolute(7777)))
    parseTest(#"\91"#, backreference(.absolute(91)))

    parseTest(
      #"()()()()()()()()()()\10"#,
      concat(Array(repeating: capture(empty()), count: 10)
             + [backreference(.absolute(10))]),
      captures: .tuple(Array(repeating: .atom(), count: 10))
    )
    parseTest(
      #"()()()()()()()()()\10()"#,
      concat(Array(repeating: capture(empty()), count: 9)
             + [backreference(.absolute(10)), capture(empty())]),
      captures: .tuple(Array(repeating: .atom(), count: 10))
    )
    parseTest(#"()()\10"#, concat(
      capture(empty()), capture(empty()), backreference(.absolute(10))),
              captures: .tuple(.atom(), .atom())
    )

    // A capture of three empty captures.
    let fourCaptures = capture(
      concat(capture(empty()), capture(empty()), capture(empty()))
    )
    parseTest(
      // There are 9 capture groups in total here.
      #"((()()())(()()()))\10"#, concat(capture(concat(
        fourCaptures, fourCaptures)), backreference(.absolute(10))),
      captures: .tuple(Array(repeating: .atom(), count: 9))
    )
    parseTest(
      // There are 10 capture groups in total here.
      #"((()()())()(()()()))\10"#,
      concat(capture(concat(fourCaptures, capture(empty()), fourCaptures)),
             backreference(.absolute(10))),
      captures: .tuple(Array(repeating: .atom(), count: 10))
    )
    parseTest(
      // There are 10 capture groups in total here.
      #"((((((((((\10))))))))))"#,
      capture(capture(capture(capture(capture(capture(capture(capture(capture(
        capture(backreference(.absolute(10)))))))))))),
      captures: .tuple(Array(repeating: .atom(), count: 10))
    )

    // The cases from http://pcre.org/current/doc/html/pcre2pattern.html#digitsafterbackslash:
    parseTest(#"\040"#, scalar(" "))
    parseTest(
      String(repeating: "()", count: 40) + #"\040"#,
      concat(Array(repeating: capture(empty()), count: 40) + [scalar(" ")]),
      captures: .tuple(Array(repeating: .atom(), count: 40))
    )
    parseTest(#"\40"#, backreference(.absolute(40)))
    parseTest(
      String(repeating: "()", count: 40) + #"\40"#,
      concat(Array(repeating: capture(empty()), count: 40)
             + [backreference(.absolute(40))]),
      captures: .tuple(Array(repeating: .atom(), count: 40))
    )

    parseTest(#"\7"#, backreference(.absolute(7)))

    parseTest(#"\11"#, backreference(.absolute(11)))
    parseTest(
      String(repeating: "()", count: 11) + #"\11"#,
      concat(Array(repeating: capture(empty()), count: 11)
             + [backreference(.absolute(11))]),
      captures: .tuple(Array(repeating: .atom(), count: 11))
    )
    parseTest(#"\011"#, scalar("\u{9}"))
    parseTest(
      String(repeating: "()", count: 11) + #"\011"#,
      concat(Array(repeating: capture(empty()), count: 11) + [scalar("\u{9}")]),
      captures: .tuple(Array(repeating: .atom(), count: 11))
    )

    parseTest(#"\0113"#, scalar("\u{4B}"))
    parseTest(#"\113"#, backreference(.absolute(113)))
    parseTest(#"\377"#, backreference(.absolute(377)))
    parseTest(#"\81"#, backreference(.absolute(81)))

    parseTest(#"\g1"#, backreference(.absolute(1)))
    parseTest(#"\g001"#, backreference(.absolute(1)))
    parseTest(#"\g52"#, backreference(.absolute(52)))
    parseTest(#"\g-01"#, backreference(.relative(-1)))
    parseTest(#"\g+30"#, backreference(.relative(30)))

    parseTest(#"\g{1}"#, backreference(.absolute(1)))
    parseTest(#"\g{001}"#, backreference(.absolute(1)))
    parseTest(#"\g{52}"#, backreference(.absolute(52)))
    parseTest(#"\g{-01}"#, backreference(.relative(-1)))
    parseTest(#"\g{+30}"#, backreference(.relative(30)))
    parseTest(#"\k<+4>"#, backreference(.relative(4)))
    parseTest(#"\k<2>"#, backreference(.absolute(2)))
    parseTest(#"\k'-3'"#, backreference(.relative(-3)))
    parseTest(#"\k'1'"#, backreference(.absolute(1)))

    parseTest(#"\k{a0}"#, backreference(.named("a0")))
    parseTest(#"\k<bc>"#, backreference(.named("bc")))
    parseTest(#"\g{abc}"#, backreference(.named("abc")))
    parseTest(#"(?P=abc)"#, backreference(.named("abc")))

    // Oniguruma recursion levels.
    parseTest(#"\k<bc-0>"#, backreference(.named("bc"), recursionLevel: 0))
    parseTest(#"\k<a+0>"#, backreference(.named("a"), recursionLevel: 0))
    parseTest(#"\k<1+1>"#, backreference(.absolute(1), recursionLevel: 1))
    parseTest(#"\k<3-8>"#, backreference(.absolute(3), recursionLevel: -8))
    parseTest(#"\k'-3-8'"#, backreference(.relative(-3), recursionLevel: -8))
    parseTest(#"\k'bc-8'"#, backreference(.named("bc"), recursionLevel: -8))
    parseTest(#"\k'+3-8'"#, backreference(.relative(3), recursionLevel: -8))
    parseTest(#"\k'+3+8'"#, backreference(.relative(3), recursionLevel: 8))

    parseTest(#"(?R)"#, subpattern(.recurseWholePattern))
    parseTest(#"(?0)"#, subpattern(.recurseWholePattern))
    parseTest(#"(?1)"#, subpattern(.absolute(1)))
    parseTest(#"(?+12)"#, subpattern(.relative(12)))
    parseTest(#"(?-2)"#, subpattern(.relative(-2)))
    parseTest(#"(?&hello)"#, subpattern(.named("hello")))
    parseTest(#"(?P>P)"#, subpattern(.named("P")))

    parseTest(#"[(?R)]"#, charClass("(", "?", "R", ")"))
    parseTest(#"[(?&a)]"#, charClass("(", "?", "&", "a", ")"))
    parseTest(#"[(?1)]"#, charClass("(", "?", "1", ")"))

    parseTest(#"\g<1>"#, subpattern(.absolute(1)))
    parseTest(#"\g<001>"#, subpattern(.absolute(1)))
    parseTest(#"\g'52'"#, subpattern(.absolute(52)))
    parseTest(#"\g'-01'"#, subpattern(.relative(-1)))
    parseTest(#"\g'+30'"#, subpattern(.relative(30)))
    parseTest(#"\g'abc'"#, subpattern(.named("abc")))

    // Backreferences are not valid in custom character classes.
    parseTest(#"[\8]"#, charClass("8"))
    parseTest(#"[\9]"#, charClass("9"))

    // MARK: Character names.

    parseTest(#"\N{abc}"#, atom(.namedCharacter("abc")))
    parseTest(#"[\N{abc}]"#, charClass(atom_m(.namedCharacter("abc"))))
    parseTest(#"\N{abc}+"#, oneOrMore(of: atom(.namedCharacter("abc"))))
    parseTest(
      #"\N {2}"#,
      concat(atom(.escaped(.notNewline)), exactly(2, of: " "))
    )

    parseTest(#"\N{AA}"#, atom(.namedCharacter("AA")))
    parseTest(#"\N{U+AA}"#, scalar("\u{AA}"))
    parseTest(#"\N{U+0123A}"#, scalar("\u{123A}"))
    parseTest(#"\N{U+0000FFFF}"#, scalar("\u{FFFF}"))

    // MARK: Character properties.

    parseTest(#"\p{L}"#,
              prop(.generalCategory(.letter)))
    parseTest(#"\p{gc=L}"#,
              prop(.generalCategory(.letter)))
    parseTest(#"\p{Lu}"#,
              prop(.generalCategory(.uppercaseLetter)))
    parseTest(#"\P{Cc}"#,
              prop(.generalCategory(.control), inverted: true))
    parseTest(#"\P{Z}"#,
              prop(.generalCategory(.separator), inverted: true))

    parseTest(#"[\p{C}]"#, charClass(prop_m(.generalCategory(.other))))
    parseTest(
      #"\p{C}+"#,
      oneOrMore(of: prop(.generalCategory(.other))))

    // UAX44-LM3 means all of the below are equivalent.
    let lowercaseLetter = prop(.generalCategory(.lowercaseLetter))
    parseTest(#"\p{ll}"#, lowercaseLetter)
    parseTest(#"\p{gc=ll}"#, lowercaseLetter)
    parseTest(#"\p{General_Category=Ll}"#, lowercaseLetter)
    parseTest(#"\p{General-Category=isLl}"#, lowercaseLetter)
    parseTest(#"\p{  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ g_ c =-  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ general ca-tegory =  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{- general category =  is__l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ general category -=  IS__l_ l  _ }"#, lowercaseLetter)

    parseTest(#"\p{Any}"#, prop(.any))
    parseTest(#"\p{Assigned}"#, prop(.assigned))
    parseTest(#"\p{ascii}"#, prop(.ascii))
    parseTest(#"\p{isAny}"#, prop(.any))

    parseTest(#"\p{sc=grek}"#, prop(.script(.greek)))
    parseTest(#"\p{sc=isGreek}"#, prop(.script(.greek)))
    parseTest(#"\p{Greek}"#, prop(.scriptExtension(.greek)))
    parseTest(#"\p{isGreek}"#, prop(.scriptExtension(.greek)))
    parseTest(#"\P{Script=Latn}"#, prop(.script(.latin), inverted: true))
    parseTest(#"\p{script=zzzz}"#, prop(.script(.unknown)))
    parseTest(#"\p{ISscript=iszzzz}"#, prop(.script(.unknown)))
    parseTest(#"\p{scx=bamum}"#, prop(.scriptExtension(.bamum)))
    parseTest(#"\p{ISBAMUM}"#, prop(.scriptExtension(.bamum)))

    parseTest(#"\p{alpha}"#, prop(.binary(.alphabetic)))
    parseTest(#"\p{DEP}"#, prop(.binary(.deprecated)))
    parseTest(#"\P{DEP}"#, prop(.binary(.deprecated), inverted: true))
    parseTest(#"\p{alphabetic=True}"#, prop(.binary(.alphabetic)))
    parseTest(#"\p{emoji=t}"#, prop(.binary(.emoji)))
    parseTest(#"\p{Alpha=no}"#, prop(.binary(.alphabetic, value: false)))
    parseTest(#"\P{Alpha=no}"#, prop(.binary(.alphabetic, value: false), inverted: true))
    parseTest(#"\p{isAlphabetic}"#, prop(.binary(.alphabetic)))
    parseTest(#"\p{isAlpha=isFalse}"#, prop(.binary(.alphabetic, value: false)))

    parseTest(#"\p{In_Runic}"#, prop(.onigurumaSpecial(.inRunic)))

    parseTest(#"\p{Xan}"#, prop(.pcreSpecial(.alphanumeric)))
    parseTest(#"\p{Xps}"#, prop(.pcreSpecial(.posixSpace)))
    parseTest(#"\p{Xsp}"#, prop(.pcreSpecial(.perlSpace)))
    parseTest(#"\p{Xuc}"#, prop(.pcreSpecial(.universallyNamed)))
    parseTest(#"\p{Xwd}"#, prop(.pcreSpecial(.perlWord)))

    parseTest(#"\p{alnum}"#, prop(.posix(.alnum)))
    parseTest(#"\p{is_alnum}"#, prop(.posix(.alnum)))
    parseTest(#"\p{blank}"#, prop(.posix(.blank)))
    parseTest(#"\p{graph}"#, prop(.posix(.graph)))
    parseTest(#"\p{print}"#, prop(.posix(.print)))
    parseTest(#"\p{word}"#,  prop(.posix(.word)))
    parseTest(#"\p{xdigit}"#, prop(.posix(.xdigit)))

    // MARK: Conditionals

    parseTest(#"(?(1))"#, conditional(
      .groupMatched(ref(1)), trueBranch: empty(), falseBranch: empty()))
    parseTest(#"(?(1)|)"#, conditional(
      .groupMatched(ref(1)), trueBranch: empty(), falseBranch: empty()))
    parseTest(#"(?(1)a)"#, conditional(
      .groupMatched(ref(1)), trueBranch: "a", falseBranch: empty()))
    parseTest(#"(?(1)a|)"#, conditional(
      .groupMatched(ref(1)), trueBranch: "a", falseBranch: empty()))
    parseTest(#"(?(1)|b)"#, conditional(
      .groupMatched(ref(1)), trueBranch: empty(), falseBranch: "b"))
    parseTest(#"(?(1)a|b)"#, conditional(
      .groupMatched(ref(1)), trueBranch: "a", falseBranch: "b"))

    parseTest(#"(?(1)(a|b|c)|d)"#, conditional(
      .groupMatched(ref(1)),
      trueBranch: capture(alt("a", "b", "c")),
      falseBranch: "d"
    ), captures: .optional(.atom()))

    parseTest(#"(?(+3))"#, conditional(
      .groupMatched(ref(plus: 3)), trueBranch: empty(), falseBranch: empty()))
    parseTest(#"(?(-21))"#, conditional(
      .groupMatched(ref(minus: 21)), trueBranch: empty(), falseBranch: empty()))

    // Oniguruma recursion levels.
    parseTest(#"(?(1+1))"#, conditional(
      .groupMatched(ref(1, recursionLevel: 1)),
      trueBranch: empty(), falseBranch: empty())
    )
    parseTest(#"(?(-1+1))"#, conditional(
      .groupMatched(ref(minus: 1, recursionLevel: 1)),
      trueBranch: empty(), falseBranch: empty())
    )
    parseTest(#"(?(1-3))"#, conditional(
      .groupMatched(ref(1, recursionLevel: -3)),
      trueBranch: empty(), falseBranch: empty())
    )
    parseTest(#"(?(+1-3))"#, conditional(
      .groupMatched(ref(plus: 1, recursionLevel: -3)),
      trueBranch: empty(), falseBranch: empty())
    )
    parseTest(
      #"(?<a>)(?(a+5))"#,
      concat(namedCapture("a", empty()), conditional(
        .groupMatched(ref("a", recursionLevel: 5)),
        trueBranch: empty(), falseBranch: empty()
      )),
      captures: .atom(name: "a")
    )
    parseTest(
      #"(?<a1>)(?(a1-5))"#,
      concat(namedCapture("a1", empty()), conditional(
        .groupMatched(ref("a1", recursionLevel: -5)),
        trueBranch: empty(), falseBranch: empty()
      )),
      captures: .atom(name: "a1")
    )

    parseTest(#"(?(1))?"#, zeroOrOne(of: conditional(
      .groupMatched(ref(1)), trueBranch: empty(), falseBranch: empty())))

    parseTest(#"(?(R)a|b)"#, conditional(
      .recursionCheck, trueBranch: "a", falseBranch: "b"))
    parseTest(#"(?(R1))"#, conditional(
      .groupRecursionCheck(ref(1)), trueBranch: empty(), falseBranch: empty()))
    parseTest(#"(?(R&abc)a|b)"#, conditional(
      .groupRecursionCheck(ref("abc")), trueBranch: "a", falseBranch: "b"))

    parseTest(#"(?(<abc>)a|b)"#, conditional(
      .groupMatched(ref("abc")), trueBranch: "a", falseBranch: "b"))
    parseTest(#"(?('abc')a|b)"#, conditional(
      .groupMatched(ref("abc")), trueBranch: "a", falseBranch: "b"))

    parseTest(#"(?(abc)a|b)"#, conditional(
      groupCondition(.capture, concat("a", "b", "c")),
      trueBranch: "a", falseBranch: "b"
    ), captures: .atom())

    parseTest(#"(?(?:abc)a|b)"#, conditional(
      groupCondition(.nonCapture, concat("a", "b", "c")),
      trueBranch: "a", falseBranch: "b"
    ))

    parseTest(#"(?(?=abc)a|b)"#, conditional(
      groupCondition(.lookahead, concat("a", "b", "c")),
      trueBranch: "a", falseBranch: "b"
    ))
    parseTest(#"(?(?!abc)a|b)"#, conditional(
      groupCondition(.negativeLookahead, concat("a", "b", "c")),
      trueBranch: "a", falseBranch: "b"
    ))
    parseTest(#"(?(?<=abc)a|b)"#, conditional(
      groupCondition(.lookbehind, concat("a", "b", "c")),
      trueBranch: "a", falseBranch: "b"
    ))
    parseTest(#"(?(?<!abc)a|b)"#, conditional(
      groupCondition(.negativeLookbehind, concat("a", "b", "c")),
      trueBranch: "a", falseBranch: "b"
    ))

    parseTest(#"(?((a)?(b))(a)+|b)"#, conditional(
      groupCondition(.capture, concat(
        zeroOrOne(of: capture("a")), capture("b")
      )),
      trueBranch: oneOrMore(of: capture("a")),
      falseBranch: "b"
    ), captures: .tuple([
      .atom(), .optional(.atom()), .atom(), .optional(.atom())
    ]))

    parseTest(#"(?(?:(a)?(b))(a)+|b)"#, conditional(
      groupCondition(.nonCapture, concat(
        zeroOrOne(of: capture("a")), capture("b")
      )),
      trueBranch: oneOrMore(of: capture("a")),
      falseBranch: "b"
    ), captures: .tuple([
      .optional(.atom()), .atom(), .optional(.atom())
    ]))

    parseTest(#"(?<xxx>y)(?(xxx)a|b)"#, concat(
      namedCapture("xxx", "y"),
      conditional(.groupMatched(ref("xxx")), trueBranch: "a", falseBranch: "b")
    ), captures: .atom(name: "xxx"))

    parseTest(#"(?(1)(?(2)(?(3)))|a)"#, conditional(
      .groupMatched(ref(1)),
      trueBranch: conditional(.groupMatched(ref(2)),
                              trueBranch: conditional(.groupMatched(ref(3)),
                                                      trueBranch: empty(),
                                                      falseBranch: empty()),
                              falseBranch: empty()),
      falseBranch: "a"))

    parseTest(#"(?(DEFINE))"#, conditional(
      .defineGroup, trueBranch: empty(), falseBranch: empty()))

    parseTest(#"(?(VERSION>=3.1))"#, conditional(
      pcreVersionCheck(.greaterThanOrEqual, 3, 1),
      trueBranch: empty(), falseBranch: empty())
    )
    parseTest(#"(?(VERSION=0.1))"#, conditional(
      pcreVersionCheck(.equal, 0, 1),
      trueBranch: empty(), falseBranch: empty())
    )

    // MARK: Callouts

    // PCRE callouts

    parseTest(#"(?C)"#, pcreCallout(.number(0)))
    parseTest(#"(?C0)"#, pcreCallout(.number(0)))
    parseTest(#"(?C20)"#, pcreCallout(.number(20)))
    parseTest("(?C{abc})", pcreCallout(.string("abc")))

    for delim in ["`", "'", "\"", "^", "%", "#", "$"] {
      parseTest("(?C\(delim)hello\(delim))", pcreCallout(.string("hello")))
    }

    // Oniguruma named callouts

    parseTest("(*X)", onigurumaNamedCallout("X"))
    parseTest("(*foo[t])", onigurumaNamedCallout("foo", tag: "t"))
    parseTest("(*foo[a0]{b})", onigurumaNamedCallout("foo", tag: "a0", args: "b"))
    parseTest("(*foo{b})", onigurumaNamedCallout("foo", args: "b"))
    parseTest("(*foo[a]{a,b,c})", onigurumaNamedCallout("foo", tag: "a", args: "a", "b", "c"))
    parseTest("(*foo{a,b,c})", onigurumaNamedCallout("foo", args: "a", "b", "c"))
    parseTest("(*foo{%%$,!!,>>})", onigurumaNamedCallout("foo", args: "%%$", "!!", ">>"))
    parseTest("(*foo{a, b, c})", onigurumaNamedCallout("foo", args: "a", " b", " c"))

    // Oniguruma 'of contents' callouts

    parseTest("(?{x})", onigurumaCalloutOfContents("x"))
    parseTest("(?{{{x}}y}}})", onigurumaCalloutOfContents("x}}y"))
    parseTest("(?{{{x}}})", onigurumaCalloutOfContents("x"))
    parseTest("(?{x}[tag])", onigurumaCalloutOfContents("x", tag: "tag"))
    parseTest("(?{x}[tag]<)", onigurumaCalloutOfContents("x", tag: "tag", direction: .inRetraction))
    parseTest("(?{x}X)", onigurumaCalloutOfContents("x", direction: .both))
    parseTest("(?{x}>)", onigurumaCalloutOfContents("x"))
    parseTest("(?{\\x})", onigurumaCalloutOfContents("\\x"))
    parseTest("(?{\\})", onigurumaCalloutOfContents("\\"))

    // MARK: Backtracking directives

    parseTest("(*ACCEPT)?", zeroOrOne(of: backtrackingDirective(.accept)))
    parseTest(
      "(*ACCEPT:a)??",
      zeroOrOne(.reluctant, of: backtrackingDirective(.accept, name: "a"))
    )
    parseTest("(*:a)", backtrackingDirective(.mark, name: "a"))
    parseTest("(*MARK:a)", backtrackingDirective(.mark, name: "a"))
    parseTest("(*F)", backtrackingDirective(.fail))
    parseTest("(*COMMIT)", backtrackingDirective(.commit))
    parseTest("(*SKIP)", backtrackingDirective(.skip))
    parseTest("(*SKIP:SKIP)", backtrackingDirective(.skip, name: "SKIP"))
    parseTest("(*PRUNE)", backtrackingDirective(.prune))
    parseTest("(*THEN)", backtrackingDirective(.then))

    // MARK: Oniguruma absent functions

    parseTest("(?~)", absentRepeater(empty()))
    parseTest("(?~abc)", absentRepeater(concat("a", "b", "c")))
    parseTest("(?~a+)", absentRepeater(oneOrMore(of: "a")))
    parseTest("(?~~)", absentRepeater("~"))
    parseTest("(?~a|b|c)", absentRepeater(alt("a", "b", "c")))
    parseTest("(?~(a))", absentRepeater(capture("a")), captures: .empty)
    parseTest("(?~)*", zeroOrMore(of: absentRepeater(empty())))

    parseTest("(?~|abc)", absentStopper(concat("a", "b", "c")))
    parseTest("(?~|a+)", absentStopper(oneOrMore(of: "a")))
    parseTest("(?~|~)", absentStopper("~"))
    parseTest("(?~|(a))", absentStopper(capture("a")), captures: .empty)
    parseTest("(?~|a){2}", exactly(2, of: absentStopper("a")))

    parseTest("(?~|a|b)", absentExpression("a", "b"))
    parseTest("(?~|~|~)", absentExpression("~", "~"))
    parseTest("(?~|(a)|(?:b))", absentExpression(capture("a"), nonCapture("b")),
              captures: .empty)
    parseTest("(?~|(a)|(?:(b)|c))", absentExpression(
      capture("a"), nonCapture(alt(capture("b"), "c"))
    ), captures: .optional(.atom()))
    parseTest("(?~|a|b)?", zeroOrOne(of: absentExpression("a", "b")))

    parseTest("(?~|)", absentRangeClear())

    // TODO: It's not really clear what this means, but Oniguruma parses it...
    // Maybe we should diagnose it?
    parseTest("(?~|)+", oneOrMore(of: absentRangeClear()))

    // MARK: Global matching options

    parseTest("(*CR)(*UTF)(*LIMIT_DEPTH=3)", ast(
      empty(), opts: .newlineMatching(.carriageReturnOnly), .utfMode,
      .limitDepth(.init(faking: 3))
    ))

    parseTest(
      "(*BSR_UNICODE)3", ast("3", opts: .newlineSequenceMatching(.anyUnicode)))
    parseTest(
      "(*BSR_ANYCRLF)", ast(
        empty(), opts: .newlineSequenceMatching(.anyCarriageReturnOrLinefeed)))

    // TODO: Diagnose on multiple line matching modes?
    parseTest(
      "(*CR)(*LF)(*CRLF)(*ANYCRLF)(*ANY)(*NUL)",
      ast(empty(), opts: [
        .carriageReturnOnly, .linefeedOnly, .carriageAndLinefeedOnly,
        .anyCarriageReturnOrLinefeed, .anyUnicode, .nulCharacter
      ].map { .newlineMatching($0) }))

    parseTest(
      """
      (*LIMIT_DEPTH=3)(*LIMIT_HEAP=1)(*LIMIT_MATCH=2)(*NOTEMPTY)\
      (*NOTEMPTY_ATSTART)(*NO_AUTO_POSSESS)(*NO_DOTSTAR_ANCHOR)(*NO_JIT)\
      (*NO_START_OPT)(*UTF)(*UCP)a
      """,
      ast("a", opts:
        .limitDepth(.init(faking: 3)), .limitHeap(.init(faking: 1)),
        .limitMatch(.init(faking: 2)), .notEmpty, .notEmptyAtStart,
        .noAutoPossess, .noDotStarAnchor, .noJIT, .noStartOpt, .utfMode,
        .unicodeProperties
      )
    )

    parseTest("[(*CR)]", charClass("(", "*", "C", "R", ")"))

    // MARK: Trivia

    parseTest("[(?#abc)]", charClass("(", "?", "#", "a", "b", "c", ")"))
    parseTest("# abc", concat("#", " ", "a", "b", "c"))

    // MARK: Matching option changing

    parseTest(
      "(?x) # hello",
      changeMatchingOptions(matchingOptions(adding: .extended))
    )
    parseTest(
      "(?xx) # hello",
      changeMatchingOptions(matchingOptions(adding: .extraExtended))
    )
    parseTest("(?x) \\# abc", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "#", "a", "b", "c"
    ))
    parseTest("(?xx) \\ ", concat(
      changeMatchingOptions(matchingOptions(adding: .extraExtended)), " "
    ))

    parseTest(
      "(?x) a (?^) b", concat(
        changeMatchingOptions(matchingOptions(adding: .extended)),
        "a",
        changeMatchingOptions(unsetMatchingOptions()),
        " ", "b"
      )
    )

    // End of line comments aren't applicable in custom char classes.
    // TODO: ICU supports this.
    parseTest("(?x)[ # abc]", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      charClass("#", "a", "b", "c")
    ))

    parseTest("(?x)a b c[d e f]", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "a", "b", "c", charClass("d", "e", "f")
    ))
    parseTest("(?xx)a b c[d e f]", concat(
      changeMatchingOptions(matchingOptions(adding: .extraExtended)),
      "a", "b", "c", charClass("d", "e", "f")
    ))
    parseTest("(?x)a b c(?-x)d e f", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "a", "b", "c",
      changeMatchingOptions(matchingOptions(removing: .extended)),
      "d", " ", "e", " ", "f"
    ))
    parseTest("(?x)a b c(?-xx)d e f", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "a", "b", "c",
      changeMatchingOptions(matchingOptions(removing: .extraExtended)),
      "d", " ", "e", " ", "f"
    ))
    parseTest("(?xx)a b c(?-x)d e f", concat(
      changeMatchingOptions(matchingOptions(adding: .extraExtended)),
      "a", "b", "c",
      changeMatchingOptions(matchingOptions(removing: .extended)),
      "d", " ", "e", " ", "f"
    ))
    parseTest("(?x)a b c(?^i)d e f", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "a", "b", "c",
      changeMatchingOptions(unsetMatchingOptions(adding: .caseInsensitive)),
      "d", " ", "e", " ", "f"
    ))
    parseTest("(?x)a b c(?^x)d e f", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "a", "b", "c",
      changeMatchingOptions(unsetMatchingOptions(adding: .extended)),
      "d", "e", "f"
    ))
    parseTest("(?:(?x)a b c)d e f", concat(
      nonCapture(concat(
        changeMatchingOptions(matchingOptions(adding: .extended)),
        "a", "b", "c"
      )),
      "d", " ", "e", " ", "f"
    ))
    parseTest("(?x:a b c)# hi", concat(changeMatchingOptions(
      matchingOptions(adding: .extended),
      concat("a", "b", "c")), "#", " ", "h", "i")
    )

    parseTest("(?x-x)a b c", concat(
      changeMatchingOptions(
        matchingOptions(adding: .extended, removing: .extended)
      ),
      "a", " ", "b", " ", "c"
    ))
    parseTest("(?xxx-x)a b c", concat(
      changeMatchingOptions(
        matchingOptions(adding: .extraExtended, .extended, removing: .extended)
      ),
      "a", " ", "b", " ", "c"
    ))
    parseTest("(?xx-i)a b c", concat(
      changeMatchingOptions(
        matchingOptions(adding: .extraExtended, removing: .caseInsensitive)
      ),
      "a", "b", "c"
    ))

    // PCRE states that whitespace seperating quantifiers is permitted under
    // extended syntax http://pcre.org/current/doc/html/pcre2api.html#SEC20
    parseTest("(?x)a *", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      zeroOrMore(of: "a")
    ))
    parseTest("(?x)a + ?", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      oneOrMore(.reluctant, of: "a")
    ))
    parseTest("(?x)a {2,4}", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      quantRange(2 ... 4, of: "a")
    ))

    // PCRE states that whitespace won't be ignored within a range.
    // http://pcre.org/current/doc/html/pcre2api.html#SEC20
    // TODO: We ought to warn on this, and produce a range anyway.
    parseTest("(?x)a{1, 3}", concat(
      changeMatchingOptions(matchingOptions(adding: .extended)),
      "a", "{", "1", ",", "3", "}"
    ))

    // Test that we cover the list of whitespace characters covered by PCRE.
    parseTest(
      "(?x)a\t\u{A}\u{B}\u{C}\u{D}\u{85}\u{200E}\u{200F}\u{2028}\u{2029} b",
      concat(
        changeMatchingOptions(matchingOptions(adding: .extended)),
        "a", "b"
      ))
    parseTest(
      "(?x)[a\t\u{A}\u{B}\u{C}\u{D}\u{85}\u{200E}\u{200F}\u{2028}\u{2029} b]",
      concat(
        changeMatchingOptions(matchingOptions(adding: .extended)),
        charClass("a", "b")
      ))

    parseTest(#"(?i:)?"#, zeroOrOne(of: changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive), empty()
    )))

    // Test multi-line comment handling.
    parseTest(
      """
      # a
      bc # d
      ef# g
      # h
      """,
      concat("b", "c", "e", "f"),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      # a\r\
      bc # d\r\
      ef# g\r\
      # h\r
      """,
      concat("b", "c", "e", "f"),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      # a\r\
      bc # d\r\
      ef# g\r\
      # h\r
      """,
      concat("b", "c", "e", "f"),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      # a\r
      bc # d\r
      ef# g\r
      # h\r
      """,
      concat("b", "c", "e", "f"),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      # a\n\r\
      bc # d\n\r\
      ef# g\n\r\
      # h\n\r
      """,
      concat("b", "c", "e", "f"),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*CR)
      # a
      bc # d
      ef# g
      # h
      """,
      ast(empty(), opts: .newlineMatching(.carriageReturnOnly)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*CR)\r\
      # a\r\
      bc # d\r\
      ef# g\r\
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.carriageReturnOnly)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*LF)
      # a
      bc # d
      ef# g
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.linefeedOnly)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*CRLF)
      # a
      bc # d
      ef# g
      # h
      """,
      ast(empty(), opts: .newlineMatching(.carriageAndLinefeedOnly)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*CRLF)
      # a\r
      bc # d\r
      ef# g\r
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.carriageAndLinefeedOnly)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*ANYCRLF)
      # a
      bc # d
      ef# g
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.anyCarriageReturnOrLinefeed)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*ANYCRLF)
      # a\r\
      bc # d\r\
      ef# g\r\
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.anyCarriageReturnOrLinefeed)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*ANYCRLF)
      # a\r
      bc # d\r
      ef# g\r
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.anyCarriageReturnOrLinefeed)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*ANY)
      # a
      bc # d
      ef# g
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.anyUnicode)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      # a\u{2028}\
      bc # d
      ef# g\u{2028}\
      # h
      """,
      concat("e", "f"),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*ANY)
      # a\u{2028}\
      bc # d\u{2028}\
      ef# g\u{2028}\
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.anyUnicode)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*NUL)
      # a
      bc # d\0\
      ef# g
      # h
      """,
      ast(concat("e", "f"), opts: .newlineMatching(.nulCharacter)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*NUL)
      # a\0\
      bc # d\0\
      ef# g\0\
      # h
      """,
      ast(concat("b", "c", "e", "f"), opts: .newlineMatching(.nulCharacter)),
      syntax: .extendedSyntax
    )
    parseTest(
      """
      (*CR)(*NUL)
      # a\0\
      bc # d\0\
      ef# g\0\
      # h
      """,
      ast(concat("b", "c", "e", "f"),
          opts: .newlineMatching(.carriageReturnOnly),
                .newlineMatching(.nulCharacter)
         ),
      syntax: .extendedSyntax
    )

    // MARK: Parse with delimiters

    parseWithDelimitersTest("/a b/", concat("a", " ", "b"))
    parseWithDelimitersTest("#/a b/#", concat("a", " ", "b"))
    parseWithDelimitersTest("##/a b/##", concat("a", " ", "b"))
    parseWithDelimitersTest("#|a b|#", concat("a", "b"))

    parseWithDelimitersTest("re'a b'", concat("a", " ", "b"))
    parseWithDelimitersTest("rx'a b'", concat("a", "b"))

    parseWithDelimitersTest("#|[a b]|#", charClass("a", "b"))
    parseWithDelimitersTest(
      "#|(?-x)[a b]|#", concat(
        changeMatchingOptions(matchingOptions(removing: .extended)),
        charClass("a", " ", "b")
      ))
    parseWithDelimitersTest("#|[[a ] b]|#", charClass(charClass("a"), "b"))

    // Non-semantic whitespace between quantifier characters for consistency
    // with PCRE.
    parseWithDelimitersTest("#|a * ?|#", zeroOrMore(.reluctant, of: "a"))

    // End-of-line comments aren't enabled by default in experimental syntax.
    parseWithDelimitersTest("#|#abc|#", concat("#", "a", "b", "c"))
    parseWithDelimitersTest("#|(?x)#abc|#", changeMatchingOptions(
      matchingOptions(adding: .extended))
    )

    parseWithDelimitersTest("#|||#", alt(empty(), empty()))
    parseWithDelimitersTest("#||||#", alt(empty(), empty(), empty()))
    parseWithDelimitersTest("#|a||#", alt("a", empty()))

    parseWithDelimitersTest("re'x*'", zeroOrMore(of: "x"))

    parseWithDelimitersTest(#"re'🔥🇩🇰'"#, concat("🔥", "🇩🇰"))
    parseWithDelimitersTest(#"re'🔥✅'"#, concat("🔥", "✅"))

    // Printable ASCII characters.
    delimiterLexingTest(##"re' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'"##)

    // Make sure we can handle a combining accent as first character.
    parseWithDelimitersTest("/\u{301}/", "\u{301}")

    delimiterLexingTest("/a/#", ignoreTrailing: true)

    // MARK: Multiline

    parseWithDelimitersTest("#/\n/#", empty())
    parseWithDelimitersTest("#/\r/#", empty())
    parseWithDelimitersTest("#/\r\n/#", empty())
    parseWithDelimitersTest("#/\n\t\t  /#", empty())
    parseWithDelimitersTest("#/  \t\t\n\t\t  /#", empty())

    parseWithDelimitersTest("#/\n a \n/#", "a")
    parseWithDelimitersTest("#/\r a \r/#", "a")
    parseWithDelimitersTest("#/\r\n a \r\n/#", "a")
    parseWithDelimitersTest("#/\n a \n\t\t  /#", "a")
    parseWithDelimitersTest("#/\t  \n a \n\t\t  /#", "a")

    parseWithDelimitersTest("""
      #/
      a
        b
           c
         /#
      """, concat("a", "b", "c"))

    parseWithDelimitersTest("""
      #/
      a    # comment
        b # another
      #
         /#
      """, concat("a", "b"))

    // Make sure (?^) is ignored.
    parseWithDelimitersTest("""
      #/
      (?^)
      # comment
      /#
      """, changeMatchingOptions(unsetMatchingOptions())
    )

    // (?x) has no effect.
    parseWithDelimitersTest("""
      #/
      (?x)
      # comment
      /#
      """, changeMatchingOptions(matchingOptions(adding: .extended))
    )

    // MARK: Delimiter skipping: Make sure we can skip over the ending delimiter
    // if it's clear that it's part of the regex syntax.

    parseWithDelimitersTest(
      #"re'(?'a_bcA0'\')'"#, namedCapture("a_bcA0", "'"))
    parseWithDelimitersTest(
      #"re'(?'a_bcA0-c1A'x*)'"#,
      balancedCapture(name: "a_bcA0", priorName: "c1A", zeroOrMore(of: "x")))

    parseWithDelimitersTest(
      #"rx' (?'a_bcA0' a b)'"#, concat(namedCapture("a_bcA0", concat("a", "b"))))

    parseWithDelimitersTest(
      #"re'(?('a_bcA0')x|y)'"#, conditional(
        .groupMatched(ref("a_bcA0")), trueBranch: "x", falseBranch: "y"))
    parseWithDelimitersTest(
      #"re'(?('+20')\')'"#, conditional(
        .groupMatched(ref(plus: 20)), trueBranch: "'", falseBranch: empty()))

    parseWithDelimitersTest(
      #"re'a\k'b0A''"#, concat("a", backreference(.named("b0A"))))
    parseWithDelimitersTest(
      #"re'\k'+2-1''"#, backreference(.relative(2), recursionLevel: -1))

    parseWithDelimitersTest(
      #"re'a\g'b0A''"#, concat("a", subpattern(.named("b0A"))))
    parseWithDelimitersTest(
      #"re'\g'-1'\''"#, concat(subpattern(.relative(-1)), "'"))

    parseWithDelimitersTest(
      #"re'(?C'a*b\c 🔥_ ;')'"#, pcreCallout(.string(#"a*b\c 🔥_ ;"#)))

    // Fine, because we don't end up skipping.
    delimiterLexingTest(#"re'(?'"#)
    delimiterLexingTest(#"re'(?('"#)
    delimiterLexingTest(#"re'\k'"#)
    delimiterLexingTest(#"re'\g'"#)
    delimiterLexingTest(#"re'(?C'"#)

    // Not a valid group name, but we can still skip over it.
    delimiterLexingTest(#"re'(?'🔥')'"#)

    // Escaped, so don't skip. These will ignore the ending `'` as we've already
    // closed the literal.
    parseWithDelimitersTest(
      #"re'\(?''"#, zeroOrOne(of: "("), ignoreTrailing: true
    )
    parseWithDelimitersTest(
      #"re'\\k''"#, concat("\\", "k"), ignoreTrailing: true
    )
    parseWithDelimitersTest(
      #"re'\\g''"#, concat("\\", "g"), ignoreTrailing: true
    )
    parseWithDelimitersTest(
      #"re'\(?C''"#, concat(zeroOrOne(of: "("), "C"), ignoreTrailing: true
    )
    delimiterLexingTest(#"re'(\?''"#, ignoreTrailing: true)
    delimiterLexingTest(#"re'\(?(''"#, ignoreTrailing: true)

    // MARK: Parse not-equal

    // Make sure dumping output correctly reflects differences in AST.
    parseNotEqualTest(#"abc"#, #"abd"#)
    parseNotEqualTest(#" "#, #""#)

    parseNotEqualTest(#"[\p{Any}]"#, #"[[:Any:]]"#)

    parseNotEqualTest(#"[abc[:space:]\d]+"#,
                      #"[abc[:upper:]\d]+"#)

    parseNotEqualTest(#"[abc[:space:]\d]+"#,
                      #"[ac[:space:]\d]+"#)

    parseNotEqualTest(#"[abc[:space:]\d]+"#,
                      #"[acc[:space:]\s]+"#)

    parseNotEqualTest(#"[abc[:space:]\d]+"#,
                      #"[acc[:space:]\d]*"#)

    parseNotEqualTest(#"([a-c&&e]*)+"#,
                      #"([a-d&&e]*)+"#)

    parseNotEqualTest(#"[abc]"#, #"[a b c]"#)

    parseNotEqualTest(#"\1"#, #"\10"#)

    parseNotEqualTest("(?^:)", ("(?-:)"))
    parseNotEqualTest("(?^i:)", ("(?i:)"))
    parseNotEqualTest("(?i)", ("(?i:)"))
    parseNotEqualTest("(?i)", ("(?m)"))
    parseNotEqualTest("(?i-s)", ("(?i-m)"))
    parseNotEqualTest("(?i-s:)", ("(?i-m:)"))
    parseNotEqualTest("(?y{w}:)", ("(?y{g}:)"))

    parseNotEqualTest("|", "||")
    parseNotEqualTest("a|", "|")
    parseNotEqualTest("a|b", "|")

    parseNotEqualTest(#"\1"#, #"\2"#)
    parseNotEqualTest(#"\k'a'"#, #"\k'b'"#)
    parseNotEqualTest(#"(?1)"#, #"(?2)"#)
    parseNotEqualTest(#"(?+1)"#, #"(?1)"#)
    parseNotEqualTest(#"(?&a)"#, #"(?&b)"#)
    parseNotEqualTest(#"\k<a-1>"#, #"\k<a-2>"#)
    parseNotEqualTest(#"\k<a>"#, #"\k<a-2>"#)

    parseNotEqualTest(#"\Qabc\E"#, #"\Qdef\E"#)
    parseNotEqualTest(#""abc""#, #""def""#)

    parseNotEqualTest(#"(?(1)a|)"#, #"(?(1)b|)"#)
    parseNotEqualTest(#"(?(1)|)"#, #"(?(1)b|)"#)
    parseNotEqualTest(#"(?(1)|a)"#, #"(?(1)|b)"#)
    parseNotEqualTest(#"(?(2)|)"#, #"(?(1)|)"#)
    parseNotEqualTest(#"(?(R1)|)"#, #"(?(R2)|)"#)
    parseNotEqualTest(#"(?(R&abc)|)"#, #"(?(R&def)|)"#)
    parseNotEqualTest(#"(?(VERSION=0.1))"#, #"(?(VERSION=0.2))"#)
    parseNotEqualTest(#"(?(VERSION=0.1))"#, #"(?(VERSION>=0.1))"#)

    parseNotEqualTest("(?C0)", "(?C1)")
    parseNotEqualTest("(?C0)", "(?C'hello')")

    parseNotEqualTest("(*X)", "(*Y)")
    parseNotEqualTest("(*X[a])", "(*X[b])")
    parseNotEqualTest("(*X[a]{a})", "(*X[a]{b})")
    parseNotEqualTest("(*X[a]{a})", "(*X[a])")
    parseNotEqualTest("(*X{a})", "(*X[a]{a})")
    parseNotEqualTest("(*X{a})", "(*X{a,b})")

    parseNotEqualTest("(?{a})", "(?{b})")
    parseNotEqualTest("(?{a}[a])", "(?{a}[b])")
    parseNotEqualTest("(?{a})", "(?{a}[a])")
    parseNotEqualTest("(?{a}X)", "(?{a})")
    parseNotEqualTest("(?{a}<)", "(?{a}X)")

    parseNotEqualTest("(*ACCEPT)", "(*ACCEPT:a)")
    parseNotEqualTest("(*MARK:a)", "(*MARK:b)")
    parseNotEqualTest("(*:a)", "(*:b)")
    parseNotEqualTest("(*FAIL)", "(*SKIP)")

    parseNotEqualTest("(?<a-b>)", "(?<a-c>)")
    parseNotEqualTest("(?<c-b>)", "(?<a-b>)")
    parseNotEqualTest("(?<-b>)", "(?<a-b>)")

    parseNotEqualTest("(?~|)", "(?~|a)")
    parseNotEqualTest("(?~|a)", "(?~|b)")
    parseNotEqualTest("(?~|a)", "(?~|a|)")
    parseNotEqualTest("(?~|a|b)", "(?~|a|)")
    parseNotEqualTest("(?~|a|b)", "(?~|a|c)")
    parseNotEqualTest("(?~)", "(?~|)")
    parseNotEqualTest("(?~a)", "(?~b)")

    parseNotEqualTest("(*CR)", "(*LF)")
    parseNotEqualTest("(*LIMIT_DEPTH=3)", "(*LIMIT_DEPTH=1)")
    parseNotEqualTest("(*UTF)", "(*LF)")
    parseNotEqualTest("(*LF)", "(*BSR_ANYCRLF)")
  }

  func testParseSourceLocations() throws {
    func entireRange(input: String) -> Range<Int> {
      0 ..< input.count
    }
    func insetRange(by i: Int) -> (String) -> Range<Int> {
      { i ..< $0.count - i }
    }
    func range(_ indices: Range<Int>) -> (String) -> Range<Int> {
      { _ in indices }
    }

    // MARK: Alternations

    typealias Alt = AST.Alternation

    let alternations = [
      "|", "a|", "|b", "a|b", "abc|def", "a|b|c|d", "a|b|", "|||", "a|||d",
      "||c|"
    ]

    // Make sure we correctly compute source ranges for alternations.
    for alt in alternations {
      rangeTest(alt, entireRange)
      rangeTest("(\(alt))", insetRange(by: 1), at: \.children![0].location)
    }

    rangeTest("|", entireRange, at: { $0.as(Alt.self)!.pipes[0] })
    rangeTest("a|", range(1 ..< 2), at: { $0.as(Alt.self)!.pipes[0] })
    rangeTest("a|b", range(1 ..< 2), at: { $0.as(Alt.self)!.pipes[0] })
    rangeTest("|||", range(1 ..< 2), at: { $0.as(Alt.self)!.pipes[1] })

    // MARK: Custom character classes

    rangeTest("[a-z]", range(2 ..< 3), at: {
      $0.as(CustomCC.self)!.members[0].as(CustomCC.Range.self)!.dashLoc
    })

    // MARK: References

    rangeTest(#"\k<a+2>"#, range(3 ..< 6), at: {
      $0.as(AST.Atom.self)!.as(AST.Reference.self)!.innerLoc
    })
    rangeTest(#"\k<-1+2>"#, range(3 ..< 7), at: {
      $0.as(AST.Atom.self)!.as(AST.Reference.self)!.innerLoc
    })

    // MARK: Callout

    typealias Callout = AST.Atom.Callout

    rangeTest(#"(?C0)"#, range(3 ..< 4), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.PCRE.self)!.arg.location
    })
    rangeTest(#"(?C)"#, range(3 ..< 3), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.PCRE.self)!.arg.location
    })

    rangeTest(#"(*abc[ta]{a,b})"#, range(2 ..< 5), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaNamed.self)!.name.location
    })
    rangeTest(#"(*abc[ta]{a,b})"#, range(5 ..< 6), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaNamed.self)!.tag!.leftBracket
    })
    rangeTest(#"(*abc[ta]{a,b})"#, range(8 ..< 9), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaNamed.self)!.tag!.rightBracket
    })
    rangeTest(#"(*abc[ta]{a,b})"#, range(9 ..< 10), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaNamed.self)!.args!.leftBrace
    })
    rangeTest(#"(*abc[ta]{a,b})"#, range(12 ..< 13), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaNamed.self)!.args!.args[1].location
    })
    rangeTest(#"(*abc[ta]{a,b})"#, range(13 ..< 14), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaNamed.self)!.args!.rightBrace
    })

    rangeTest(#"(?{{{abc}}}[t]X)"#, range(2 ..< 5), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaOfContents.self)!.openBraces
    })
    rangeTest(#"(?{{{abc}}}[t]X)"#, range(8 ..< 11), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaOfContents.self)!.closeBraces
    })
    rangeTest(#"(?{{{abc}}}[t]X)"#, range(11 ..< 12), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaOfContents.self)!.tag!.leftBracket
    })
    rangeTest(#"(?{{{abc}}}[t]X)"#, range(13 ..< 14), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaOfContents.self)!.tag!.rightBracket
    })
    rangeTest(#"(?{{{abc}}}[t]X)"#, range(14 ..< 15), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaOfContents.self)!.direction.location
    })
    rangeTest(#"(?{a})"#, range(5 ..< 5), at: {
      $0.as(AST.Atom.self)!.as(Callout.self)!
        .as(Callout.OnigurumaOfContents.self)!.direction.location
    })

    // MARK: Conditionals

    rangeTest("(?(1))", entireRange)
    rangeTest("(?(1)a|)", entireRange)

    rangeTest("(?(1)|)", range(5 ..< 6), at: {
      $0.as(AST.Conditional.self)!.pipe!
    })

    rangeTest("(?(1))", range(3 ..< 4), at: {
      $0.as(AST.Conditional.self)!.condition.location
    })
    rangeTest("(?(-1+2))", range(3 ..< 7), at: {
      $0.as(AST.Conditional.self)!.condition.location
    })
    rangeTest("(?(VERSION>=4.1))", range(3 ..< 15), at: {
      $0.as(AST.Conditional.self)!.condition.location
    })
    rangeTest("(?(xxx))", range(2 ..< 7), at: {
      $0.as(AST.Conditional.self)!.condition.location
    })

    // MARK: Absent functions

    rangeTest("(?~a)", entireRange)
    rangeTest("(?~|)", entireRange)
    rangeTest("(?~|a)", entireRange)
    rangeTest("(?~|a|b)", entireRange)
  }

  func testParseErrors() {
    // MARK: Unbalanced delimiters.

    diagnosticTest("(", .expected(")"))
    diagnosticTest(")", .unbalancedEndOfGroup)
    diagnosticTest(")))", .unbalancedEndOfGroup)
    diagnosticTest("())()", .unbalancedEndOfGroup)

    diagnosticTest("[", .expectedCustomCharacterClassMembers)
    diagnosticTest("[^", .expectedCustomCharacterClassMembers)

    diagnosticTest(#"\u{5"#, .expected("}"))
    diagnosticTest(#"\x{5"#, .expected("}"))
    diagnosticTest(#"\N{A"#, .expected("}"))
    diagnosticTest(#"\N{U+A"#, .expected("}"))
    diagnosticTest(#"\p{a"#, .unknownProperty(key: nil, value: "a"))
    diagnosticTest(#"\p{a="#, .emptyProperty)
    diagnosticTest(#"\p{a=}"#, .emptyProperty)
    diagnosticTest(#"\p{a=b"#, .unknownProperty(key: "a", value: "b"))
    diagnosticTest(#"\p{aaa[b]}"#, .unknownProperty(key: nil, value: "aaa"))
    diagnosticTest(#"\p{a=b=c}"#, .unknownProperty(key: "a", value: "b"))
    diagnosticTest(#"(?#"#, .expected(")"))
    diagnosticTest(#"(?x"#, .expected(")"))

    diagnosticTest(#"(?"#, .expectedGroupSpecifier)
    diagnosticTest(#"(?^"#, .expected(")"))
    diagnosticTest(#"(?^i"#, .expected(")"))

    diagnosticTest(#"(?y)"#, .expected("{"))
    diagnosticTest(#"(?y{)"#, .expected("g"))
    diagnosticTest(#"(?y{g)"#, .expected("}"))
    diagnosticTest(#"(?y{x})"#, .expected("g"))

    diagnosticTest(#"(?P"#, .expected(")"))
    diagnosticTest(#"(?R"#, .expected(")"))

    diagnosticTest(#"\Qab"#, .expected("\\E"))
    diagnosticTest("\\Qab\\", .expected("\\E"))
    diagnosticTest(#""ab"#, .expected("\""), syntax: .experimental)
    diagnosticTest(#""ab\""#, .expected("\""), syntax: .experimental)
    diagnosticTest("\"ab\\", .expectedEscape, syntax: .experimental)

    diagnosticTest("(?C", .expected(")"))

    diagnosticTest("(?<", .expectedIdentifier(.groupName))
    diagnosticTest("(?<a", .expected(">"))
    diagnosticTest("(?<a-", .expectedIdentifier(.groupName))
    diagnosticTest("(?<a--", .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest("(?<a-b", .expected(">"))
    diagnosticTest("(?<a-b>", .expected(")"))

    // MARK: Character classes

    diagnosticTest("[a", .expected("]"))

    // The first ']' of a custom character class is literal, so these are
    // missing the closing bracket.
    diagnosticTest("[]", .expected("]"))
    diagnosticTest("(?x)[  ]", .expected("]"))

    diagnosticTest("[&&]", .expectedCustomCharacterClassMembers)
    diagnosticTest("[a&&]", .expectedCustomCharacterClassMembers)
    diagnosticTest("[&&a]", .expectedCustomCharacterClassMembers)
    diagnosticTest("(?x)[ && ]", .expectedCustomCharacterClassMembers)
    diagnosticTest("(?x)[ &&a]", .expectedCustomCharacterClassMembers)
    diagnosticTest("(?x)[a&& ]", .expectedCustomCharacterClassMembers)

    diagnosticTest("[:a", .expected("]"))
    diagnosticTest("[:a:", .expected("]"))
    diagnosticTest("[[:a", .expected("]"))
    diagnosticTest("[[:a:", .expected("]"))
    diagnosticTest("[[:a[:]", .expected("]"))

    diagnosticTest("[::]", .emptyProperty)
    diagnosticTest("[:=:]", .emptyProperty)
    diagnosticTest("[[::]]", .emptyProperty)
    diagnosticTest("[[:=:]]", .emptyProperty)

    // MARK: Bad escapes

    diagnosticTest("\\", .expectedEscape)

    // TODO: Custom diagnostic for control sequence
    diagnosticTest(#"\c"#, .unexpectedEndOfInput)

    // TODO: Custom diagnostic for expected backref
    diagnosticTest(#"\g"#, .invalidEscape("g"))
    diagnosticTest(#"\k"#, .invalidEscape("k"))

    // TODO: Custom diagnostic for backref in custom char class
    diagnosticTest(#"[\g]"#, .invalidEscape("g"))
    diagnosticTest(#"[\g+30]"#, .invalidEscape("g"))
    diagnosticTest(#"[\g{1}]"#, .invalidEscape("g"))
    diagnosticTest(#"[\k'a']"#, .invalidEscape("k"))

    // TODO: Custom diagnostic for missing '\Q'
    diagnosticTest(#"\E"#, .invalidEscape("E"))

    // Non-ASCII non-whitespace cases.
    diagnosticTest(#"\🔥"#, .invalidEscape("🔥"))
    diagnosticTest(#"\🇩🇰"#, .invalidEscape("🇩🇰"))
    diagnosticTest(#"\e\#u{301}"#, .invalidEscape("e\u{301}"))
    diagnosticTest(#"\\#u{E9}"#, .invalidEscape("é"))
    diagnosticTest(#"\˂"#, .invalidEscape("˂"))

    // MARK: Character properties

    diagnosticTest(#"\p{Lx}"#, .unknownProperty(key: nil, value: "Lx"))
    diagnosticTest(#"\p{gcL}"#, .unknownProperty(key: nil, value: "gcL"))
    diagnosticTest(#"\p{x=y}"#, .unknownProperty(key: "x", value: "y"))
    diagnosticTest(#"\p{aaa(b)}"#, .unknownProperty(key: nil, value: "aaa(b)"))
    diagnosticTest("[[:a():]]", .unknownProperty(key: nil, value: "a()"))
    diagnosticTest(#"\p{aaa\p{b}}"#, .unknownProperty(key: nil, value: "aaa"))
    diagnosticTest(#"[[:{:]]"#, .unknownProperty(key: nil, value: "{"))

    // MARK: Matching options

    diagnosticTest("(?-y{g})", .cannotRemoveTextSegmentOptions)
    diagnosticTest("(?-y{w})", .cannotRemoveTextSegmentOptions)

    diagnosticTest("(?-X)", .cannotRemoveSemanticsOptions)
    diagnosticTest("(?-u)", .cannotRemoveSemanticsOptions)
    diagnosticTest("(?-b)", .cannotRemoveSemanticsOptions)

    diagnosticTest("(?a)", .unknownGroupKind("?a"))
    diagnosticTest("(?y{)", .expected("g"))

    // Extended syntax may not be removed in multi-line mode.
    diagnosticWithDelimitersTest("""
      #/
      (?-x)a b
      /#
      """, .cannotRemoveExtendedSyntaxInMultilineMode
    )
    diagnosticWithDelimitersTest("""
      #/
      (?-xx)a b
      /#
      """, .cannotRemoveExtendedSyntaxInMultilineMode
    )
    diagnosticWithDelimitersTest("""
      #/
      (?-x:a b)
      /#
      """, .cannotRemoveExtendedSyntaxInMultilineMode
    )
    diagnosticWithDelimitersTest("""
      #/
      (?-xx:a b)
      /#
      """, .cannotRemoveExtendedSyntaxInMultilineMode
    )

    // MARK: Group specifiers

    diagnosticTest(#"(*"#, .unknownGroupKind("*"))

    diagnosticTest(#"(?k)"#, .unknownGroupKind("?k"))
    diagnosticTest(#"(?P#)"#, .invalidMatchingOption("#"))

    diagnosticTest(#"(?<#>)"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"(?'1A')"#, .identifierCannotStartWithNumber(.groupName))

    // TODO: It might be better if tried to consume up to the closing `'` and
    // diagnosed an invalid group name based on that.
    diagnosticTest(#"(?'abc ')"#, .expected("'"))

    diagnosticTest("(?'🔥')", .identifierMustBeAlphaNumeric(.groupName))

    diagnosticTest(#"(?'-')"#, .expectedIdentifier(.groupName))
    diagnosticTest(#"(?'--')"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"(?'a-b-c')"#, .expected("'"))

    diagnosticTest("(?x)(? : )", .unknownGroupKind("? "))

    // MARK: Quantifiers

    diagnosticTest("*", .quantifierRequiresOperand("*"))
    diagnosticTest("+", .quantifierRequiresOperand("+"))
    diagnosticTest("?", .quantifierRequiresOperand("?"))
    diagnosticTest("*?", .quantifierRequiresOperand("*?"))
    diagnosticTest("{5}", .quantifierRequiresOperand("{5}"))
    diagnosticTest("{1,3}", .quantifierRequiresOperand("{1,3}"))

    // MARK: Unicode scalars

    diagnosticTest(#"\u{G}"#, .expectedNumber("G", kind: .hex))

    // MARK: Matching options

    diagnosticTest(#"(?^-"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?^-)"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?^i-"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?^i-m)"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?i)?"#, .notQuantifiable)

    // MARK: References

    diagnosticTest(#"\k''"#, .expectedIdentifier(.groupName))
    diagnosticTest(#"(?&)"#, .expectedIdentifier(.groupName))
    diagnosticTest(#"(?P>)"#, .expectedIdentifier(.groupName))

    diagnosticTest(#"\g{0}"#, .cannotReferToWholePattern)
    diagnosticTest(#"(?(0))"#, .cannotReferToWholePattern)

    diagnosticTest(#"(?&&)"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"(?&-1)"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"(?P>+1)"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"(?P=+1)"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"\k'#'"#, .identifierMustBeAlphaNumeric(.groupName))
    diagnosticTest(#"(?&#)"#, .identifierMustBeAlphaNumeric(.groupName))

    diagnosticTest(#"(?P>1)"#, .identifierCannotStartWithNumber(.groupName))
    diagnosticTest(#"\k{1}"#, .identifierCannotStartWithNumber(.groupName))

    diagnosticTest(#"\g<1-1>"#, .expected(">"))
    diagnosticTest(#"\g{1-1}"#, .expected("}"))
    diagnosticTest(#"\k{a-1}"#, .expected("}"))
    diagnosticTest(#"\k{a-}"#, .expected("}"))

    diagnosticTest(#"\k<a->"#, .expectedNumber("", kind: .decimal))
    diagnosticTest(#"\k<1+>"#, .expectedNumber("", kind: .decimal))

    // MARK: Conditionals

    diagnosticTest(#"(?(1)a|b|c)"#, .tooManyBranchesInConditional(3))
    diagnosticTest(#"(?(1)||)"#, .tooManyBranchesInConditional(3))
    diagnosticTest(#"(?(?i))"#, .unknownGroupKind("?("))

    // MARK: Callouts

    // PCRE callouts
    diagnosticTest("(?C-1)", .unknownCalloutKind("(?C-1)"))
    diagnosticTest("(?C-1", .unknownCalloutKind("(?C-1)"))

    // Oniguruma named callouts
    diagnosticTest("(*bar[", .expectedIdentifier(.onigurumaCalloutTag))
    diagnosticTest("(*bar[%", .identifierMustBeAlphaNumeric(.onigurumaCalloutTag))
    diagnosticTest("(*bar{", .expectedCalloutArgument)
    diagnosticTest("(*bar}", .expected(")"))
    diagnosticTest("(*bar]", .expected(")"))

    // Oniguruma 'of contents' callouts
    diagnosticTest("(?{", .expected("}"))
    diagnosticTest("(?{}", .expectedNonEmptyContents)
    diagnosticTest("(?{x}", .expected(")"))
    diagnosticTest("(?{x}}", .expected(")"))
    diagnosticTest("(?{{x}}", .expected(")"))
    diagnosticTest("(?{{x}", .expected("}"))
    diagnosticTest("(?{x}[", .expectedIdentifier(.onigurumaCalloutTag))
    diagnosticTest("(?{x}[%", .identifierMustBeAlphaNumeric(.onigurumaCalloutTag))
    diagnosticTest("(?{x}[a]", .expected(")"))
    diagnosticTest("(?{x}[a]K", .expected(")"))
    diagnosticTest("(?{x}[a]X", .expected(")"))
    diagnosticTest("(?{{x}y}", .expected("}"))

    // MARK: Backtracking directives

    diagnosticTest("(*MARK)", .backtrackingDirectiveMustHaveName("MARK"))
    diagnosticTest("(*:)", .expectedNonEmptyContents)
    diagnosticTest("(*MARK:a)?", .notQuantifiable)
    diagnosticTest("(*FAIL)+", .notQuantifiable)
    diagnosticTest("(*COMMIT:b)*", .notQuantifiable)
    diagnosticTest("(*PRUNE:a)??", .notQuantifiable)
    diagnosticTest("(*SKIP:a)*?", .notQuantifiable)
    diagnosticTest("(*F)+?", .notQuantifiable)
    diagnosticTest("(*:a){2}", .notQuantifiable)

    // MARK: Oniguruma absent functions

    diagnosticTest("(?~", .expected(")"))
    diagnosticTest("(?~|", .expected(")"))
    diagnosticTest("(?~|a|b|c)", .tooManyAbsentExpressionChildren(3))
    diagnosticTest("(?~||||)", .tooManyAbsentExpressionChildren(4))

    // MARK: Global matching options

    diagnosticTest("a(*CR)", .globalMatchingOptionNotAtStart("(*CR)"))
    diagnosticTest("(*CR)a(*LF)", .globalMatchingOptionNotAtStart("(*LF)"))
    diagnosticTest("(*LIMIT_HEAP)", .expected("="))
    diagnosticTest("(*LIMIT_DEPTH=", .expectedNumber("", kind: .decimal))

    // TODO: This diagnostic could be better.
    diagnosticTest("(*LIMIT_DEPTH=-1", .expectedNumber("", kind: .decimal))
  }

  func testDelimiterLexingErrors() {

    // MARK: Printable ASCII

    delimiterLexingDiagnosticTest(#"re'\\#n'"#, .unterminated)
    for i: UInt8 in 0x1 ..< 0x20 where i != 0xA && i != 0xD { // U+A & U+D are \n and \r.
      delimiterLexingDiagnosticTest("re'\(UnicodeScalar(i))'", .unprintableASCII)
    }
    delimiterLexingDiagnosticTest("re'\n'", .unterminated)
    delimiterLexingDiagnosticTest("re'\r'", .unterminated)
    delimiterLexingDiagnosticTest("re'\u{7F}'", .unprintableASCII)

    // MARK: Delimiter skipping

    delimiterLexingDiagnosticTest("re'(?''", .unterminated)
    delimiterLexingDiagnosticTest("re'(?'abc'", .unterminated)
    delimiterLexingDiagnosticTest("re'(?('abc'", .unterminated)
    delimiterLexingDiagnosticTest(#"re'\k'ab_c0+-'"#, .unterminated)
    delimiterLexingDiagnosticTest(#"re'\g'ab_c0+-'"#, .unterminated)

    // MARK: Unbalanced extended syntax
    delimiterLexingDiagnosticTest("#/a/", .unterminated)
    delimiterLexingDiagnosticTest("##/a/#", .unterminated)

    // MARK: Multiline

    // Can only be done if pound signs are used.
    delimiterLexingDiagnosticTest("/\n/", .unterminated)

    // Opening and closing delimiters must be on a newline.
    delimiterLexingDiagnosticTest("#/a\n/#", .unterminated)
    delimiterLexingDiagnosticTest("#/\na/#", .multilineClosingNotOnNewline)
    delimiterLexingDiagnosticTest("#/\n#/#", .multilineClosingNotOnNewline)
  }

  func testlibswiftDiagnostics() {
    libswiftDiagnosticMessageTest(
      "#/[x*/#", "cannot parse regular expression: expected ']'")
  }
}
