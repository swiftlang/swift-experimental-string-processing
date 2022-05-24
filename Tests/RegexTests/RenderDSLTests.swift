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

import XCTest
import _RegexParser
@_spi(PatternConverter) @testable
import _StringProcessing

class RenderDSLTests: XCTestCase {}

func testConversion(
  _ regex: String,
  _ expectedDSL: String,
  file: StaticString = #file, line: UInt = #line
) throws {
  let ast = try _RegexParser.parse(regex, .semantic, .traditional)
  let actualDSL = renderAsBuilderDSL(ast: ast)._trimmingSuffix(while: \.isWhitespace)
  XCTAssertEqual(actualDSL, expectedDSL[...], file: file, line: line)
}

extension RenderDSLTests {
  func testSimpleConversions() throws {
    try testConversion(#"ab+c"#, """
      Regex {
        "a"
        OneOrMore {
          "b"
        }
        "c"
      }
      """)

    try testConversion(#"(?:a*)b?(c+)"#, """
      Regex {
        ZeroOrMore {
          "a"
        }
        Optionally {
          "b"
        }
        Capture {
          OneOrMore {
            "c"
          }
        }
      }
      """)
    
    try testConversion(#"\d+"#, """
      Regex {
        OneOrMore {
          .digit
        }
      }
      """)
    try XCTExpectFailure("Invalid leading dot syntax in non-initial position") {
      try testConversion(#":\d:"#, """
        Regex {
          ":"
          CharacterClass.digit
          ":"
        }
        """)
    }
  }
  
  func testOptions() throws {
    try XCTExpectFailure("Options like '(?i)' aren't converted") {
      try testConversion(#"(?i)abc"#, """
        Regex {
          "abc"
        }.ignoresCase()
        """)
    }

    try XCTExpectFailure("Options like '(?i:...)' aren't converted") {
      try testConversion(#"(?i:abc)"#, """
        Regex {
          "abc"
        }.ignoresCase()
        """)
    }
  }
  
  func testAlternations() throws {
    try testConversion(#"a|b"#, """
      Regex {
        ChoiceOf {
          "a"
          "b"
        }
      }
      """)
    
    try XCTExpectFailure("Concatenations in alternations aren't grouped") {
      try testConversion(#"\da|b"#, """
        Regex {
          ChoiceOf {
            Regex {
              .digit
              "a"
            }
            "bc"
          }
        }
        """)
    }
  }
  
  func testQuoting() throws {
    try testConversion(#"\\\"a\""#, #"""
      Regex {
        "\\\"a\""
      }
      """#)
  }
}
