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
  let ast = try _RegexParser.parse(regex, .traditional)
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
        OneOrMore(.digit)
      }
      """)
    
    try testConversion(#":\d:"#, """
      Regex {
        ":"
        One(.digit)
        ":"
      }
      """)
  }

  func testDot() throws {
    try testConversion(#".+"#, #"""
      Regex {
        OneOrMore {
          /./
        }
      }
      """#)
    try testConversion(#"a.c"#, #"""
      Regex {
        "a"
        /./
        "c"
      }
      """#)
  }

  func testAnchor() throws {
    try testConversion(#"^(?:a|b|c)$"#, #"""
      Regex {
        /^/
        ChoiceOf {
          "a"
          "b"
          "c"
        }
        /$/
      }
      """#)
    
    try testConversion(#"foo(?=bar)"#, #"""
      Regex {
        "foo"
        Lookahead {
          "bar"
        }
      }
      """#)
    
    try testConversion(#"abc(?=def(?!ghi)|xyz)"#, #"""
      Regex {
        "abc"
        Lookahead {
          ChoiceOf {
            Regex {
              "def"
              NegativeLookahead {
                "ghi"
              }
            }
            "xyz"
          }
        }
      }
      """#)
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
    
    try testConversion(#"\da|bc"#, """
      Regex {
        ChoiceOf {
          Regex {
            One(.digit)
            "a"
          }
          "bc"
        }
      }
      """)
  }
  
  func testQuoting() throws {
    try testConversion(#"\\"a""#, #"""
      Regex {
        "\\\"a\""
      }
      """#)
  }

  func testScalar() throws {
    try testConversion(#"\u{B4}"#, #"""
      Regex {
        "\u{B4}"
      }
      """#)
    try testConversion(#"\u{301}"#, #"""
      Regex {
        "\u{301}"
      }
      """#)
    try testConversion(#"[\u{301}]"#, #"""
      Regex {
        One(.anyOf("\u{301}"))
      }
      """#)
    try testConversion(#"[abc\u{301}]"#, #"""
      Regex {
        One(.anyOf("abc\u{301}"))
      }
      """#)

    // TODO: We ought to try and preserve the scalar syntax here.
    try testConversion(#"a\u{301}"#, #"""
      Regex {
        "á"
      }
      """#)
  }
}
