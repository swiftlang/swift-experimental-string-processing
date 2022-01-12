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

func diagnose(
  _ input: String,
  expecting expected: ParseError,
  _ syntax: SyntaxOptions = .traditional,
  _ f: (inout Source) throws -> ()
) {
  var src = Source(input, syntax)
  do {
    try f(&src)
    XCTFail("""
      Passed, but expected error: \(expected)
    """)
  } catch let e as Source.LocatedError<ParseError> {
    guard e.error == expected else {
      XCTFail("""

        Expected: \(expected)
        Actual: \(e.error)")
      """)
      return
    }
  } catch let e {
    fatalError("Should be unreachable: \(e)")
  }
}

extension Source {
  @discardableResult
  fileprivate mutating func lexBasicAtom() throws -> AST.Atom? {
    try lexAtom(isInCustomCharacterClass: false, priorGroupCount: 0)
  }
}

extension RegexTests {
  func testLexicalAnalysis() {
    diagnose("a", expecting: .expected("b")) { src in
      try src.expect("b")
    }

    diagnose("", expecting: .unexpectedEndOfInput) { src in
      try src.expectNonEmpty()
    }
    diagnose("a", expecting: .unexpectedEndOfInput) { src in
      try src.expect("a") // Ok
      try src.expectNonEmpty() // Error
    }

    let bigNum = "12345678901234567890"
    diagnose(bigNum, expecting: .numberOverflow(bigNum)) { src in
      _ = try src.lexNumber()
    }

    func diagnoseUniScalarOverflow(_ input: String, base: Character) {
      let scalars = input.first == "{"
                  ? String(input.dropFirst().dropLast())
                  : input
      diagnose(
        input,
        expecting: .numberOverflow(scalars)
      ) { src in
        _ = try src.expectUnicodeScalar(escapedCharacter: base)
      }
    }
    func diagnoseUniScalar(
      _ input: String,
      base: Character,
      expectedDigits numDigits: Int
    ) {
      let scalars = input.first == "{"
                  ? String(input.dropFirst().dropLast())
                  : input
      diagnose(
        input,
        expecting: .expectedNumDigits(scalars, numDigits)
      ) { src in
        _ = try src.expectUnicodeScalar(escapedCharacter: base)
      }
      _ = scalars
    }

    diagnoseUniScalar(
      "12", base: "u", expectedDigits: 4)
    diagnoseUniScalar(
      "12", base: "U", expectedDigits: 8)
    diagnoseUniScalarOverflow("{123456789}", base: "u")
    diagnoseUniScalarOverflow("{123456789}", base: "x")

    // Text segment options
    diagnose("(?-y{g})", expecting: .cannotRemoveTextSegmentOptions) {
      _ = try $0.lexGroupStart()
    }
    diagnose("(?-y{w})", expecting: .cannotRemoveTextSegmentOptions) {
      _ = try $0.lexGroupStart()
    }

    // Test expected group.
    diagnose(#"(*"#, expecting: .misc("Quantifier '*' must follow operand")) {
      _ = try $0.lexGroupStart()
    }

    // Test expected closing delimiters.
    diagnose(#"\u{5"#, expecting: .expected("}")) { try $0.lexBasicAtom() }
    diagnose(#"\x{5"#, expecting: .expected("}")) { try $0.lexBasicAtom() }
    diagnose(#"\N{A"#, expecting: .expected("}")) { try $0.lexBasicAtom() }
    diagnose(#"\N{U+A"#, expecting: .expected("}")) { try $0.lexBasicAtom() }
    diagnose(#"\p{a"#, expecting: .expected("}")) { try $0.lexBasicAtom() }
    diagnose(#"\p{a="#, expecting: .expected("}")) { try $0.lexBasicAtom() }
    diagnose(#"(?#"#, expecting: .expected(")")) { _ = try $0.lexComment() }
    diagnose(#"(?x"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }

    diagnose(#"(?"#, expecting: .expectedGroupSpecifier) {
      _ = try $0.lexGroupStart()
    }

    diagnose(#"(?^"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?^i"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?^-"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?^-)"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?^i-"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?^i-m)"#, expecting: .expected(")")) { _ = try $0.lexGroupStart() }

    diagnose(#"(?y)"#, expecting: .expected("{")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?y{)"#, expecting: .expected("g")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?y{g)"#, expecting: .expected("}")) { _ = try $0.lexGroupStart() }
    diagnose(#"(?y{x})"#, expecting: .expected("g")) { _ = try $0.lexGroupStart() }

    diagnose(#"(?k)"#, expecting: .misc("Unknown group kind '(?k'")) {
      _ = try $0.lexGroupStart()
    }

    diagnose(#"\Qab"#, expecting: .expected("\\E")) { _ = try $0.lexQuote() }
    diagnose(#"\Qab\"#, expecting: .expected("\\E")) { _ = try $0.lexQuote() }
    diagnose(#""ab"#, expecting: .expected("\""), .experimental) { _ = try $0.lexQuote() }
    diagnose(#""ab\""#, expecting: .expected("\""), .experimental) { _ = try $0.lexQuote() }
    diagnose(#""ab\"#, expecting: .unexpectedEndOfInput, .experimental) { _ = try $0.lexQuote() }

    diagnose(#"\k''"#, expecting: .expectedNonEmptyContents) { _ = try $0.lexBasicAtom() }

    // TODO: want to dummy print out source ranges, etc, test that.
  }


  func testCompilerInterface() {
    let testCases: [(String, (String, Delimiter)?)] = [
      ("'/abc/'", ("abc", .traditional)),
      ("'|abc|'", ("abc", .experimental)),

      // TODO: Null characters are lexically valid, similar to string literals,
      // but we ought to warn the user about them.
      ("'|ab\0c|'", ("ab\0c", .experimental)),
      ("'abc'", nil),
      ("'/abc/def/'", ("abc/def", .traditional)),
      ("'|abc|def|'", ("abc|def", .experimental)),
      ("'/abc\\/'def/'", ("abc\\/'def", .traditional)),
      ("'|abc\\|'def|'", ("abc\\|'def", .experimental)),
      ("'/abc|'def/'", ("abc|'def", .traditional)),
      ("'|abc/'def|'", ("abc/'def", .experimental)),
      ("'/abc|'def/", nil),
      ("'|abc/'def'", nil),
      ("'/abc\n/'", nil),
      ("'/abc\r/'", nil),
    ]

    for (input, expected) in testCases {
      input.withCString {
        let endPtr = $0 + input.utf8.count
        assert(endPtr.pointee == 0)
        guard let out = try? lexRegex(start: $0, end: endPtr) else {
          XCTAssertNil(expected)
          return
        }
        XCTAssertEqual(expected?.0, out.0)
        XCTAssertEqual(expected?.1, out.1)

        let droppedDelimiters = droppingRegexDelimiters(input)
        XCTAssertEqual(expected?.0, droppedDelimiters.0)
        XCTAssertEqual(expected?.1, droppedDelimiters.1)
      }
    }
  }
}
