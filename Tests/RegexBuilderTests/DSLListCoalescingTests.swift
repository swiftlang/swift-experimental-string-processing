//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RegexBuilder

// Regression tests for `DSLList.coalesce(withFirstAtomIn:)`, which merges
// adjacent literal atoms across `RegexComponentBuilder` component boundaries.
@available(SwiftStdlib 5.7, *)
class DSLListCoalescingTests: XCTestCase {

  // MARK: Trailing content after the coalesce point

  func testNestedTrailingQuantifier() throws {
    let flat = Regex {
      "a"
      "X"
      OneOrMore(.digit)
    }
    let nested = Regex {
      "a"
      Regex {
        "X"
        OneOrMore(.digit)
      }
    }
    let mixed = Regex {
      "a"
      #/X\d+/#
    }
    let nestedMixed = Regex {
      "a"
      Regex {
        #/X\d+/#
      }
    }
    let complexNestedMixed = Regex {
      #/a/#
      Regex {
        #/X/#
        #/\d+/#
      }
    }
    let literal = #/aX\d+/#

    func runTest(_ regex: Regex<Substring>) {
      XCTAssertTrue("aX0".contains(regex))
      XCTAssertFalse("aX".contains(regex))
    }
    
    runTest(flat)
    runTest(nested)
    runTest(mixed)
    runTest(nestedMixed)
    runTest(complexNestedMixed)
    runTest(literal)
  }

  func testNestedTrailingQuantifier_threeSiblings() throws {
    let nested = Regex {
      "a"
      Regex {
        "X"
        OneOrMore(.digit)
        "Y"
      }
    }
    XCTAssertTrue("aX0Y".contains(nested))
    XCTAssertFalse("aX0".contains(nested))
    XCTAssertFalse("aXY".contains(nested))
    XCTAssertFalse("aX".contains(nested))
  }

  func testNestedTrailingAnchor() throws {
    let nested = Regex {
      "a"
      Regex {
        "X"
        Anchor.wordBoundary
      }
    }
    XCTAssertTrue("aX yz".contains(nested))
    XCTAssertFalse("aXyz".contains(nested))
  }

  func testNestedTrailingCaptureGroup() throws {
    let nested = Regex {
      "a"
      Regex {
        "X"
        Capture(OneOrMore(.digit))
      }
    }
    let match = try XCTUnwrap("aX123".wholeMatch(of: nested))
    XCTAssertEqual(match.output.1, "123")
    XCTAssertNil("aX".wholeMatch(of: nested))
  }

  // MARK: Leading content before the coalesce point

  func testNestedLeadingLiteral() throws {
    let nested = Regex {
      Regex {
        OneOrMore(.digit)
        "a"
      }
      "X"
    }
    XCTAssertTrue("123aX".contains(nested))
    XCTAssertFalse("123a".contains(nested))
    XCTAssertFalse("aX".contains(nested))
  }

  func testNestedOnBothSides() throws {
    let nested = Regex {
      Regex {
        OneOrMore(.digit)
        "a"
      }
      Regex {
        "X"
        OneOrMore(.word)
      }
    }
    XCTAssertTrue("123aXyz".contains(nested))
    XCTAssertFalse("123aX".contains(nested))
    XCTAssertFalse("123a".contains(nested))
  }

  // MARK: Nesting depth

  func testDoublyNestedTrailingQuantifier() throws {
    let nested = Regex {
      "a"
      Regex {
        Regex {
          "X"
          OneOrMore(.digit)
        }
      }
    }
    XCTAssertTrue("aX0".contains(nested))
    XCTAssertFalse("aX".contains(nested))
  }

  func testTriplyNestedAllLiteral() throws {
    let nested = Regex {
      "a"
      Regex {
        Regex {
          "b"
          "c"
        }
      }
      "d"
    }
    let siblings = Regex {
      "a"
      Regex {
        Regex {
          "b"
          "c"
        }
        Regex {
          "b"
          "c"
        }
      }
      "d"
    }
    XCTAssertTrue("abcd".contains(nested))
    XCTAssertFalse("abc".contains(nested))
    XCTAssertFalse("abcx".contains(nested))

    XCTAssertTrue("abcbcd".contains(siblings))
    XCTAssertFalse("abcbc".contains(siblings))
    XCTAssertFalse("abcd".contains(siblings))
  }

  // MARK: Interaction with non-literal wrapper nodes

  func testNestedWithLabeledCaptureAfterCoalesce() throws {
    let nested = Regex {
      "a"
      Regex {
        "X"
        #/(?<number>\d+)/#
        "Y"
      }
    }
    XCTAssertTrue("aX123Y".contains(nested))
    XCTAssertFalse("aX123".contains(nested))
    XCTAssertFalse("aXY".contains(nested))
  }

  func testNestedInsideChoiceOf() throws {
    let nested = ChoiceOf {
      Regex {
        "a"
        Regex {
          "X"
          OneOrMore(.digit)
        }
      }
      "z"
    }
    XCTAssertTrue("aX0".contains(nested))
    XCTAssertFalse("aX".contains(nested))
    XCTAssertTrue("z".contains(nested))
  }

  func testNestedInsideOptionally() throws {
    let nested = Regex {
      Optionally {
        Regex {
          "a"
          Regex {
            "X"
            OneOrMore(.digit)
          }
        }
      }
      "!"
    }
    XCTAssertNotNil("aX0!".wholeMatch(of: nested))
    XCTAssertNil("aX!".wholeMatch(of: nested))
    XCTAssertNotNil("!".wholeMatch(of: nested))
  }

  // MARK: Unicode scalar coalescing across nesting, with trailing content

  func testNestedScalarCoalescingWithTrailingQuantifier() throws {
    let nested = Regex {
      "e" as Character
      Regex {
        "\u{301}" as UnicodeScalar
        OneOrMore(.digit)
      }
    }
    XCTAssertTrue("é123".contains(nested))
    XCTAssertFalse("é".contains(nested))
    XCTAssertFalse("e123".contains(nested))
  }

  // MARK: Non-coalescable boundary

  func testNoCoalesceAcrossCaptureGroup() throws {
    let nested = Regex {
      Capture("a")
      Regex {
        "X"
        OneOrMore(.digit)
      }
    }
    let match = try XCTUnwrap("aX0".wholeMatch(of: nested))
    XCTAssertEqual(match.output.1, "a")
    XCTAssertNil("aX".wholeMatch(of: nested))
  }
}
