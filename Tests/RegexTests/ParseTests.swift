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

@testable import _MatchingEngine

import XCTest
@testable import _StringProcessing

extension AST: ExpressibleByExtendedGraphemeClusterLiteral {
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
    XCTFail("Malformed capture structure serialization")
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

func parseWithDelimitersTest(
  _ input: String, _ expecting: AST,
  file: StaticString = #file, line: UInt = #line
) {
  // First try lexing.
  input.withCString { ptr in
    let (contents, delim, end) = try! lexRegex(start: ptr,
                                               end: ptr + input.count)
    XCTAssertEqual(end, ptr + input.count, file: file, line: line)

    let (parseContents, parseDelim) = droppingRegexDelimiters(input)
    XCTAssertEqual(contents, parseContents, file: file, line: line)
    XCTAssertEqual(delim, parseDelim, file: file, line: line)
  }

  let orig = try! parseWithDelimiters(input)
  let ast = orig
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
              """)
  }
}

func rangeTest(
  _ input: String, syntax: SyntaxOptions = .traditional,
  _ expectedRange: (String) -> Range<Int>,
  at locFn: (AST) -> SourceLocation = \.location,
  file: StaticString = #file, line: UInt = #line
) {
  let ast = try! parse(input, syntax)
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

extension RegexTests {
  func testParse() {
    parseTest(
      "abc", concat("a", "b", "c"))
    parseTest(
      #"abc\+d*"#,
      concat("a", "b", "c", "+", zeroOrMore(.eager, "d")))
    parseTest(
      "a(b)", concat("a", capture("b")),
      captures: .atom())
    parseTest(
      "abc(?:de)+fghi*k|j",
      alt(
        concat(
          "a", "b", "c",
          oneOrMore(
            .eager, nonCapture(concat("d", "e"))),
          "f", "g", "h", zeroOrMore(.eager, "i"), "k"),
        "j"))
    parseTest(
      "a(?:b|c)?d",
      concat("a", zeroOrOne(
        .eager, nonCapture(alt("b", "c"))), "d"))
    parseTest(
      "a?b??c+d+?e*f*?",
      concat(
        zeroOrOne(.eager, "a"), zeroOrOne(.reluctant, "b"),
        oneOrMore(.eager, "c"), oneOrMore(.reluctant, "d"),
        zeroOrMore(.eager, "e"), zeroOrMore(.reluctant, "f")))

    parseTest(
      "(.)*(.*)",
      concat(
        zeroOrMore(.eager, capture(atom(.any))),
        capture(zeroOrMore(.eager, atom(.any)))),
      captures: .tuple([.array(.atom()), .atom()]))
    parseTest(
      "((.))*((.)?)",
      concat(
        zeroOrMore(.eager, capture(capture(atom(.any)))),
        capture(zeroOrOne(.eager, capture(atom(.any))))),
      captures: .tuple([
        .array(.atom()), .array(.atom()), .atom(), .optional(.atom())
      ]))
    parseTest(
      #"abc\d"#,
      concat("a", "b", "c", escaped(.decimalDigit)))

    // MARK: Alternations

    parseTest(
      "a|b?c",
      alt("a", concat(zeroOrOne(.eager, "b"), "c")))
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
      captures: .tuple(.array(.atom()), .array(.atom())))
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
    parseTest(#"\0707"#, concat(scalar("\u{38}"), "7"))

    parseTest(#"[\0]"#, charClass(scalar_m("\u{0}")))
    parseTest(#"[\01]"#, charClass(scalar_m("\u{1}")))
    parseTest(#"[\070]"#, charClass(scalar_m("\u{38}")))

    parseTest(#"[\07A]"#, charClass(scalar_m("\u{7}"), "A"))
    parseTest(#"[\08]"#, charClass(scalar_m("\u{0}"), "8"))
    parseTest(#"[\0707]"#, charClass(scalar_m("\u{38}"), "7"))

    parseTest(#"[\1]"#, charClass(scalar_m("\u{1}")))
    parseTest(#"[\123]"#, charClass(scalar_m("\u{53}")))
    parseTest(#"[\101]"#, charClass(scalar_m("\u{41}")))
    parseTest(#"[\7777]"#, charClass(scalar_m("\u{1FF}"), "7"))
    parseTest(#"[\181]"#, charClass(scalar_m("\u{1}"), "8", "1"))

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

    // These are metacharacters in certain contexts, but normal characters
    // otherwise.
    parseTest(
      ":-]", concat(":", "-", "]"))

    parseTest(
      "[^abc]", charClass("a", "b", "c", inverted: true))
    parseTest(
      "[a^]", charClass("a", "^"))

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

    // MARK: Operators

    parseTest(
      #"[a[bc]de&&[^bc]\d]+"#,
      oneOrMore(.eager, charClass(
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
      "&?", zeroOrOne(.eager, "&"))
    parseTest(
      "&&?", concat("&", zeroOrOne(.eager, "&")))
    parseTest(
      "--+", concat("-", oneOrMore(.eager, "-")))
    parseTest(
      "~~*", concat("~", zeroOrMore(.eager, "~")))

    // MARK: Quotes

    parseTest(
      #"a\Q .\Eb"#,
      concat("a", quote(" ."), "b"))
    parseTest(
      #"a\Q \Q \\.\Eb"#,
      concat("a", quote(#" \Q \\."#), "b"))

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

    // MARK: Comments

    parseTest(
      #"a(?#comment)b"#,
      concat("a", "b"))
    parseTest(
      #"a(?#. comment)b"#,
      concat("a", "b"))

    // MARK: Quantification

    parseTest(
      #"a{1,2}"#,
      quantRange(.eager, 1...2, "a"))
    parseTest(
      #"a{,2}"#,
      upToN(.eager, 2, "a"))
    parseTest(
      #"a{2,}"#,
      nOrMore(.eager, 2, "a"))
    parseTest(
      #"a{1}"#,
      exactly(.eager, 1, "a"))
    parseTest(
      #"a{1,2}?"#,
      quantRange(.reluctant, 1...2, "a"))
    parseTest(
      #"a{0}"#,
      exactly(.eager, 0, "a"))
    parseTest(
      #"a{0,0}"#,
      quantRange(.eager, 0...0, "a"))

    // Make sure ranges get treated as literal if invalid.
    parseTest("{", "{")
    parseTest("{,", concat("{", ","))
    parseTest("{}", concat("{", "}"))
    parseTest("{,}", concat("{", ",", "}"))
    parseTest("{,6", concat("{", ",", "6"))
    parseTest("{6", concat("{", "6"))
    parseTest("{6,", concat("{", "6", ","))
    parseTest("{+", oneOrMore(.eager, "{"))
    parseTest("{6,+", concat("{", "6", oneOrMore(.eager, ",")))
    parseTest("x{", concat("x", "{"))
    parseTest("x{}", concat("x", "{", "}"))
    parseTest("x{,}", concat("x", "{", ",", "}"))
    parseTest("x{,6", concat("x", "{", ",", "6"))
    parseTest("x{6", concat("x", "{", "6"))
    parseTest("x{6,", concat("x", "{", "6", ","))
    parseTest("x{+", concat("x", oneOrMore(.eager, "{")))
    parseTest("x{6,+", concat("x", "{", "6", oneOrMore(.eager, ",")))

    // TODO: We should emit a diagnostic for this.
    parseTest("x{3, 5}", concat("x", "{", "3", ",", " ", "5", "}"))

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
      matchingOptions(), isIsolated: true, empty())
    )
    parseTest("(?i)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive),
      isIsolated: true, empty())
    )
    parseTest("(?m)", changeMatchingOptions(
      matchingOptions(adding: .multiline),
      isIsolated: true, empty())
    )
    parseTest("(?x)", changeMatchingOptions(
      matchingOptions(adding: .extended),
      isIsolated: true, empty())
    )
    parseTest("(?xx)", changeMatchingOptions(
      matchingOptions(adding: .extraExtended),
      isIsolated: true, empty())
    )
    parseTest("(?xxx)", changeMatchingOptions(
      matchingOptions(adding: .extraExtended, .extended),
      isIsolated: true, empty())
    )
    parseTest("(?P)", changeMatchingOptions(
      matchingOptions(adding: .asciiOnlyPOSIXProps), isIsolated: true, empty())
    )
    parseTest("(?-i)", changeMatchingOptions(
      matchingOptions(removing: .caseInsensitive),
      isIsolated: true, empty())
    )
    parseTest("(?i-s)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive, removing: .singleLine),
      isIsolated: true, empty())
    )
    parseTest("(?i-is)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive,
                      removing: .caseInsensitive, .singleLine),
      isIsolated: true, empty())
    )

    parseTest("(?:)", nonCapture(empty()))
    parseTest("(?-:)", changeMatchingOptions(
      matchingOptions(), isIsolated: false, empty())
    )
    parseTest("(?i:)", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive),
      isIsolated: false, empty())
    )
    parseTest("(?-i:)", changeMatchingOptions(
      matchingOptions(removing: .caseInsensitive),
      isIsolated: false, empty())
    )
    parseTest("(?P:)", changeMatchingOptions(
      matchingOptions(adding: .asciiOnlyPOSIXProps), isIsolated: false, empty())
    )

    parseTest("(?^)", changeMatchingOptions(
      unsetMatchingOptions(),
      isIsolated: true, empty())
    )
    parseTest("(?^:)", changeMatchingOptions(
      unsetMatchingOptions(),
      isIsolated: false, empty())
    )
    parseTest("(?^ims:)", changeMatchingOptions(
      unsetMatchingOptions(adding: .caseInsensitive, .multiline, .singleLine),
      isIsolated: false, empty())
    )
    parseTest("(?^J:)", changeMatchingOptions(
      unsetMatchingOptions(adding: .allowDuplicateGroupNames),
      isIsolated: false, empty())
    )
    parseTest("(?^y{w}:)", changeMatchingOptions(
      unsetMatchingOptions(adding: .textSegmentWordMode),
      isIsolated: false, empty())
    )

    let allOptions: [AST.MatchingOption.Kind] = [
      .caseInsensitive, .allowDuplicateGroupNames, .multiline, .noAutoCapture,
      .singleLine, .reluctantByDefault, .extraExtended, .extended,
      .unicodeWordBoundaries, .asciiOnlyDigit, .asciiOnlyPOSIXProps,
      .asciiOnlySpace, .asciiOnlyWord, .textSegmentGraphemeMode,
      .textSegmentWordMode, .graphemeClusterSemantics, .unicodeScalarSemantics,
      .byteSemantics
    ]
    parseTest("(?iJmnsUxxxwDPSWy{g}y{w}Xub-iJmnsUxxxwDPSW)", changeMatchingOptions(
      matchingOptions(
        adding: allOptions,
        removing: allOptions.dropLast(5)
      ),
      isIsolated: true, empty())
    )
    parseTest("(?iJmnsUxxxwDPSWy{g}y{w}Xub-iJmnsUxxxwDPSW:)", changeMatchingOptions(
      matchingOptions(
        adding: allOptions,
        removing: allOptions.dropLast(5)
      ),
      isIsolated: false, empty())
    )

    parseTest(
      "a(b(?i)c)d", concat("a", capture(concat("b", changeMatchingOptions(
        matchingOptions(adding: .caseInsensitive),
        isIsolated: true, "c"))), "d"),
      captures: .atom()
    )
    parseTest(
      "(a(?i)b(c)d)", capture(concat("a", changeMatchingOptions(
        matchingOptions(adding: .caseInsensitive),
        isIsolated: true, concat("b", capture("c"), "d")))),
      captures: .tuple(.atom(), .atom())
    )
    parseTest(
      "(a(?i)b(?#hello)c)", capture(concat("a", changeMatchingOptions(
        matchingOptions(adding: .caseInsensitive),
        isIsolated: true, concat("b", "c")))),
      captures: .atom()
    )

    // TODO: This is Oniguruma's behavior, but PCRE treats it as:
    //     ab(?i:c)|(?i:def)|(?i:gh)
    // instead. We ought to have a mode to emulate that.
    parseTest("ab(?i)c|def|gh", concat("a", "b", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive), isIsolated: true,
      alt("c", concat("d", "e", "f"), concat("g", "h")))))

    parseTest("(a|b(?i)c|d)", capture(alt("a", concat("b", changeMatchingOptions(
      matchingOptions(adding: .caseInsensitive), isIsolated: true,
      alt("c", "d"))))),
      captures: .atom())

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

    // TODO: Some of these behaviors are unintuitive, we should likely warn on
    // some of them.
    parseTest(#"\10"#, scalar("\u{8}"))
    parseTest(#"\18"#, concat(scalar("\u{1}"), "8"))
    parseTest(#"\7777"#, concat(scalar("\u{1FF}"), "7"))
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
             + [scalar("\u{8}"), capture(empty())]),
      captures: .tuple(Array(repeating: .atom(), count: 10))
    )
    parseTest(#"()()\10"#,
              concat(capture(empty()), capture(empty()), scalar("\u{8}")),
              captures: .tuple(.atom(), .atom()))

    // A capture of three empty captures.
    let fourCaptures = capture(
      concat(capture(empty()), capture(empty()), capture(empty()))
    )
    parseTest(
      // There are 9 capture groups in total here.
      #"((()()())(()()()))\10"#,
      concat(capture(concat(fourCaptures, fourCaptures)), scalar("\u{8}")),
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
    parseTest(#"\40"#, scalar(" "))
    parseTest(
      String(repeating: "()", count: 40) + #"\40"#,
      concat(Array(repeating: capture(empty()), count: 40)
             + [backreference(.absolute(40))]),
      captures: .tuple(Array(repeating: .atom(), count: 40))
    )

    parseTest(#"\7"#, backreference(.absolute(7)))

    parseTest(#"\11"#, scalar("\u{9}"))
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

    parseTest(#"\0113"#, concat(scalar("\u{9}"), "3"))
    parseTest(#"\113"#, scalar("\u{4B}"))
    parseTest(#"\377"#, scalar("\u{FF}"))
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
    parseTest(#"[\g]"#, charClass("g"))
    parseTest(#"[\g+30]"#, charClass("g", "+", "3", "0"))
    parseTest(#"[\g{1}]"#, charClass("g", "{", "1", "}"))
    parseTest(#"[\k'a']"#, charClass("k", "'", "a", "'"))

    parseTest(#"\g"#, atom(.char("g")))
    parseTest(#"\k"#, atom(.char("k")))

    // MARK: Character names.

    parseTest(#"\N{abc}"#, atom(.namedCharacter("abc")))
    parseTest(#"[\N{abc}]"#, charClass(atom_m(.namedCharacter("abc"))))
    parseTest(
      #"\N{abc}+"#,
      oneOrMore(.eager,
                atom(.namedCharacter("abc"))))
    parseTest(
      #"\N {2}"#,
      concat(atom(.escaped(.notNewline)),
             exactly(.eager, 2, " ")))

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
      oneOrMore(.eager, prop(.generalCategory(.other))))

    parseTest(#"\p{Lx}"#, prop(.other(key: nil, value: "Lx")))
    parseTest(#"\p{gcL}"#, prop(.other(key: nil, value: "gcL")))
    parseTest(#"\p{x=y}"#, prop(.other(key: "x", value: "y")))

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
    parseTest(#"\p{Greek}"#, prop(.script(.greek)))
    parseTest(#"\p{isGreek}"#, prop(.script(.greek)))
    parseTest(#"\P{Script=Latn}"#, prop(.script(.latin), inverted: true))
    parseTest(#"\p{script=zzzz}"#, prop(.script(.unknown)))
    parseTest(#"\p{ISscript=iszzzz}"#, prop(.script(.unknown)))
    parseTest(#"\p{scx=bamum}"#, prop(.scriptExtension(.bamum)))
    parseTest(#"\p{ISBAMUM}"#, prop(.script(.bamum)))

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

    parseTest(#"(?(1))?"#, zeroOrOne(.eager, conditional(
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
        zeroOrOne(.eager, capture("a")), capture("b")
      )),
      trueBranch: oneOrMore(.eager, capture("a")),
      falseBranch: "b"
    ), captures: .tuple([
      .atom(), .optional(.atom()), .atom(), .optional(.array(.atom()))
    ]))

    parseTest(#"(?(?:(a)?(b))(a)+|b)"#, conditional(
      groupCondition(.nonCapture, concat(
        zeroOrOne(.eager, capture("a")), capture("b")
      )),
      trueBranch: oneOrMore(.eager, capture("a")),
      falseBranch: "b"
    ), captures: .tuple([
      .optional(.atom()), .atom(), .optional(.array(.atom()))
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

    parseTest(#"(?C)"#, callout(.number(0)))
    parseTest(#"(?C0)"#, callout(.number(0)))
    parseTest(#"(?C20)"#, callout(.number(20)))
    parseTest("(?C{abc})", callout(.string("abc")))

    for delim in ["`", "'", "\"", "^", "%", "#", "$"] {
      parseTest("(?C\(delim)hello\(delim))", callout(.string("hello")))
    }

    // MARK: Backtracking directives

    parseTest("(*ACCEPT)?", zeroOrOne(.eager, backtrackingDirective(.accept)))
    parseTest(
      "(*ACCEPT:a)??",
      zeroOrOne(.reluctant, backtrackingDirective(.accept, name: "a"))
    )
    parseTest("(*:a)", backtrackingDirective(.mark, name: "a"))
    parseTest("(*MARK:a)", backtrackingDirective(.mark, name: "a"))
    parseTest("(*F)", backtrackingDirective(.fail))
    parseTest("(*COMMIT)", backtrackingDirective(.commit))
    parseTest("(*SKIP)", backtrackingDirective(.skip))
    parseTest("(*SKIP:SKIP)", backtrackingDirective(.skip, name: "SKIP"))
    parseTest("(*PRUNE)", backtrackingDirective(.prune))
    parseTest("(*THEN)", backtrackingDirective(.then))

    // MARK: Parse with delimiters

    parseWithDelimitersTest("'/a b/'", concat("a", " ", "b"))
    parseWithDelimitersTest("'|a b|'", concat("a", "b"))

    parseWithDelimitersTest("'|||'", alt(empty(), empty()))
    parseWithDelimitersTest("'||||'", alt(empty(), empty(), empty()))
    parseWithDelimitersTest("'|a||'", alt("a", empty()))

    // MARK: Parse not-equal

    // Make sure dumping output correctly reflects differences in AST.
    parseNotEqualTest(#"abc"#, #"abd"#)

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

    parseNotEqualTest("(*ACCEPT)", "(*ACCEPT:a)")
    parseNotEqualTest("(*MARK:a)", "(*MARK:b)")
    parseNotEqualTest("(*:a)", "(*:b)")
    parseNotEqualTest("(*FAIL)", "(*SKIP)")

    parseNotEqualTest("(?<a-b>)", "(?<a-c>)")
    parseNotEqualTest("(?<c-b>)", "(?<a-b>)")
    parseNotEqualTest("(?<-b>)", "(?<a-b>)")
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
  }

  func testParseErrors() {
    // MARK: Closing delimiters.

    diagnosticTest("(", .expected(")"))

    diagnosticTest(#"\u{5"#, .expected("}"))
    diagnosticTest(#"\x{5"#, .expected("}"))
    diagnosticTest(#"\N{A"#, .expected("}"))
    diagnosticTest(#"\N{U+A"#, .expected("}"))
    diagnosticTest(#"\p{a"#, .expected("}"))
    diagnosticTest(#"\p{a="#, .expected("}"))
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

    diagnosticTest("(?<", .expectedGroupName)
    diagnosticTest("(?<a", .expected(">"))
    diagnosticTest("(?<a-", .expectedGroupName)
    diagnosticTest("(?<a--", .groupNameMustBeAlphaNumeric)
    diagnosticTest("(?<a-b", .expected(">"))
    diagnosticTest("(?<a-b>", .expected(")"))

    // MARK: Text Segment options

    diagnosticTest("(?-y{g})", .cannotRemoveTextSegmentOptions)
    diagnosticTest("(?-y{w})", .cannotRemoveTextSegmentOptions)

    // MARK: Semantic Level options

    diagnosticTest("(?-X)", .cannotRemoveSemanticsOptions)
    diagnosticTest("(?-u)", .cannotRemoveSemanticsOptions)
    diagnosticTest("(?-b)", .cannotRemoveSemanticsOptions)

    // MARK: Group specifiers

    diagnosticTest(#"(*"#, .unknownGroupKind("*"))
    diagnosticTest("(*X)", .unknownGroupKind("*X"))

    diagnosticTest(#"(?k)"#, .unknownGroupKind("?k"))
    diagnosticTest(#"(?P#)"#, .invalidMatchingOption("#"))

    diagnosticTest(#"(?<#>)"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"(?'1A')"#, .groupNameCannotStartWithNumber)

    diagnosticTest(#"(?'-')"#, .expectedGroupName)
    diagnosticTest(#"(?'--')"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"(?'a-b-c')"#, .expected("'"))

    // MARK: Matching options

    diagnosticTest(#"(?^-"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?^-)"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?^i-"#, .cannotRemoveMatchingOptionsAfterCaret)
    diagnosticTest(#"(?^i-m)"#, .cannotRemoveMatchingOptionsAfterCaret)

    // MARK: References

    diagnosticTest(#"\k''"#, .expectedGroupName)
    diagnosticTest(#"(?&)"#, .expectedGroupName)
    diagnosticTest(#"(?P>)"#, .expectedGroupName)

    diagnosticTest(#"\g{0}"#, .cannotReferToWholePattern)
    diagnosticTest(#"(?(0))"#, .cannotReferToWholePattern)

    diagnosticTest(#"(?&&)"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"(?&-1)"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"(?P>+1)"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"(?P=+1)"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"\k'#'"#, .groupNameMustBeAlphaNumeric)
    diagnosticTest(#"(?&#)"#, .groupNameMustBeAlphaNumeric)

    diagnosticTest(#"(?P>1)"#, .groupNameCannotStartWithNumber)
    diagnosticTest(#"\k{1}"#, .groupNameCannotStartWithNumber)

    diagnosticTest(#"\g<1-1>"#, .expected(">"))
    diagnosticTest(#"\g{1-1}"#, .expected("}"))
    diagnosticTest(#"\k{a-1}"#, .expected("}"))
    diagnosticTest(#"\k{a-}"#, .expected("}"))

    diagnosticTest(#"\k<a->"#, .expectedNumber("", kind: .decimal))
    diagnosticTest(#"\k<1+>"#, .expectedNumber("", kind: .decimal))

    // MARK: Conditionals

    diagnosticTest(#"(?(1)a|b|c)"#, .tooManyBranchesInConditional(3))
    diagnosticTest(#"(?(1)||)"#, .tooManyBranchesInConditional(3))
    diagnosticTest(#"(?(?i))"#, .unsupportedCondition("implicitly scoped group"))

    // MARK: Callouts

    diagnosticTest("(?C-1)", .unknownCalloutKind("(?C-1)"))
    diagnosticTest("(?C-1", .unknownCalloutKind("(?C-1)"))

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
  }
}
