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

func diagnose(
  _ input: String,
  expecting expected: ParseError,
  _ syntax: SyntaxOptions = .traditional,
  _ f: (inout Source) throws -> (),
  file: StaticString = #file,
  line: UInt = #line
) {
  var src = Source(input)
  do {
    try f(&src)
    XCTFail("""
      Passed, but expected error: \(expected)
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
    fatalError("Should be unreachable: \(e)")
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

    // TODO: want to dummy print out source ranges, etc, test that.
  }


  func testCompilerInterface() throws {
    func delim(_ kind: Delimiter.Kind, poundCount: Int = 0) -> Delimiter {
      Delimiter(kind, poundCount: poundCount)
    }
    let testCases: [(String, (String, Delimiter)?)] = [
      ("/abc/", ("abc", delim(.forwardSlash))),
      ("#/abc/#", ("abc", delim(.forwardSlash, poundCount: 1))),
      ("###/abc/###", ("abc", delim(.forwardSlash, poundCount: 3))),
      ("#|abc|#", ("abc", delim(.experimental))),

      // Multiline
      ("#/\na\nb\n/#", ("\na\nb\n", delim(.forwardSlash, poundCount: 1))),
      ("#/ \na\nb\n  /#", (" \na\nb\n  ", delim(.forwardSlash, poundCount: 1))),
      ("##/ \na\nb\n  /##", (" \na\nb\n  ", delim(.forwardSlash, poundCount: 2))),

      // TODO: Null characters are lexically valid, similar to string literals,
      // but we ought to warn the user about them.
      ("#|ab\0c|#", ("ab\0c", delim(.experimental))),
      ("'abc'", nil),
      ("#/abc/def/#", ("abc/def", delim(.forwardSlash, poundCount: 1))),
      ("#|abc|def|#", ("abc|def", delim(.experimental))),
      ("#/abc\\/#def/#", ("abc\\/#def", delim(.forwardSlash, poundCount: 1))),
      ("#|abc\\|#def|#", ("abc\\|#def", delim(.experimental))),
      ("#/abc|#def/#", ("abc|#def", delim(.forwardSlash, poundCount: 1))),
      ("#|abc/#def|#", ("abc/#def", delim(.experimental))),
      ("#/abc|#def/", nil),
      ("#|abc/#def#", nil),
      ("#/abc\n/#", nil),
      ("#/abc\r/#", nil),

      (#"re'abcre\''"#, (#"abcre\'"#, delim(.reSingleQuote))),
      (#"re'\'"#, nil)
    ]

    for (input, expected) in testCases {
      input.withCString {
        let endPtr = $0 + input.utf8.count
        assert(endPtr.pointee == 0)
        guard let out = try? lexRegex(
          start: $0, end: endPtr, delimiters: Delimiter.allDelimiters)
        else {
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

    // TODO: Remove the lexing code for these if we no longer need them.
    let disabledDelimiters: [String] = [
      "#|x|#", "re'x'", "rx'y'"
    ]

    for input in disabledDelimiters {
      try input.withCString {
        let endPtr = $0 + input.utf8.count
        assert(endPtr.pointee == 0)
        do {
          _ = try lexRegex(start: $0, end: endPtr)
          XCTFail()
        } catch let e as DelimiterLexError {
          XCTAssertEqual(e.kind, .unknownDelimiter)
        }
      }
    }
  }
}
