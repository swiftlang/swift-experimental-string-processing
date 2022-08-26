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
  _ f: (inout Parser) -> (),
  file: StaticString = #file,
  line: UInt = #line
) {
  var parser = Parser(Source(input), syntax: syntax)
  f(&parser)

  let diags = parser.diags.diags
  guard diags.count == 1 else {
    XCTFail("""
      Expected single diagnostic
    """, file: file, line: line)
    return
  }

  let error = diags[0].underlyingParseError!
  guard error == expected else {
    XCTFail("""

      Expected: \(expected)
      Actual: \(error)
    """, file: file, line: line)
    return
  }
}

extension RegexTests {
  func testLexicalAnalysis() {
    diagnose("a", expecting: .expected("b")) { p in
      p.expect("b")
    }

    diagnose("", expecting: .unexpectedEndOfInput) { p in
      p.expectNonEmpty()
    }
    diagnose("a", expecting: .unexpectedEndOfInput) { p in
      p.expect("a") // Ok
      p.expectNonEmpty() // Error
    }

    let bigNum = "12345678901234567890"
    diagnose(bigNum, expecting: .numberOverflow(bigNum)) { p in
      _ = p.lexNumber()
    }

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
