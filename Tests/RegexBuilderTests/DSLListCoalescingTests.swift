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
@testable @_spi(RegexBuilder) import _StringProcessing
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
    let extraNested = Regex {
      "a"
      Regex {
        "X"
        Regex {
          OneOrMore(.digit)
        }
      }
    }
    let nestedBefore = Regex {
      "a"
      Regex {
        Regex {
          "X"
        }
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
    runTest(extraNested)
    runTest(nestedBefore)
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

  // MARK: - `coalesce(withFirstAtomIn:)` unit tests

  func testCoalesceStackedConcatenations() {
    // Handle one concatenation directly nested in another --
    // RegexBuilder never emits this, but the coalescing algorithm can/
    // should still handle this
    var lhs = DSLList([.quotedLiteral("a", display: nil)])
    var rhs = DSLList([
      .concatenation(2),               // outer: [inner-concat, .word]
      .concatenation(2),               // inner: [X, .digit]
      .atom(.char("X")),
      .atom(.characterClass(.digit)),
      .atom(.characterClass(.word)),
    ])

    lhs.coalesce(withFirstAtomIn: &rhs)

    XCTAssertEqual(lhs.nodes, [.quotedLiteral("aX", display: "aX")])
    XCTAssertEqual(rhs.nodes, [
      .concatenation(2),
      .concatenation(1),
      .atom(.characterClass(.digit)),
      .atom(.characterClass(.word)),
    ])
  }

  func testCoalesceStackedConcatenationsEmpty() {
    // Same as above, but the inner concatenation collapses to
    // `.empty`
    var lhs = DSLList([.quotedLiteral("a", display: nil)])
    var rhs = DSLList([
      .concatenation(2),               // outer: [inner-concat, .digit]
      .concatenation(1),               //   inner: [X]
      .atom(.char("X")),
      .atom(.characterClass(.digit)),
    ])

    lhs.coalesce(withFirstAtomIn: &rhs)

    XCTAssertEqual(lhs.nodes, [.quotedLiteral("aX", display: "aX")])
    XCTAssertEqual(rhs.nodes, [
      .concatenation(2),
      .empty,
      .atom(.characterClass(.digit)),
    ])
  }

  func testCoalesceStackedWrapperNodes() {
    // Check that any wrapper nodes before the concatenation get stripped
    var lhs = DSLList([.quotedLiteral("a", display: nil)])
    var rhs = DSLList([
      .concatenation(2),                  // [wrapped-X, .word]
      .limitCaptureNesting,
      .ignoreCapturesInTypedOutput,
      .atom(.char("X")),
      .atom(.characterClass(.word)),
    ])

    lhs.coalesce(withFirstAtomIn: &rhs)

    XCTAssertEqual(rhs.nodes, [
      .concatenation(1),
      .atom(.characterClass(.word)),
    ])
  }

  func testCoalesceNoEnclosingConcatenation() {
    // If the coalesced atom's ancestors are only wrapper nodes,
    // coalescing should eat the whole `rhs`
    var lhs = DSLList([.quotedLiteral("a", display: nil)])
    var rhs = DSLList([
      .limitCaptureNesting,
      .ignoreCapturesInTypedOutput,
      .atom(.char("X")),
    ])

    lhs.coalesce(withFirstAtomIn: &rhs)

    XCTAssertEqual(lhs.nodes, [.quotedLiteral("aX", display: "aX")])
    XCTAssertEqual(rhs.nodes, [])
  }

  func testCoalesceSingleConcatenation() {
    // If the coalesced atom's is the sole member of a top-level
    // concatenation, coalescing should only leave an `.empty` node
    var lhs = DSLList([.quotedLiteral("a", display: nil)])
    var rhs = DSLList([
      .concatenation(1),
      .atom(.char("X")),
    ])

    lhs.coalesce(withFirstAtomIn: &rhs)

    XCTAssertEqual(lhs.nodes, [.quotedLiteral("aX", display: "aX")])
    XCTAssertEqual(rhs.nodes, [.empty])
  }

  func testCoalesceStopsAtNonWrapperNonConcatenation() {
    // This shouldn't coalesce at all
    var lhs = DSLList([.quotedLiteral("a", display: nil)])
    var rhs = DSLList([
      .orderedChoice(2),
      .atom(.char("X")),
      .atom(.characterClass(.word)),
    ])

	let originals = (lhs, rhs)
    lhs.coalesce(withFirstAtomIn: &rhs)

    XCTAssertEqual(lhs.nodes, originals.0.nodes)
    XCTAssertEqual(rhs.nodes, originals.1.nodes)
  }
}


extension DSLTree.Node: @retroactive Equatable {
  public static func == (lhs: DSLTree.Node, rhs: DSLTree.Node) -> Bool {
    switch (lhs, rhs) {
    case (.concatenation(let l), .concatenation(let r)): return l == r
    case (.orderedChoice(let l), .orderedChoice(let r)): return l == r
    case (.quotedLiteral(let ls, let ld), .quotedLiteral(let rs, let rd)):
      return ls == rs && ld == rd
    case (.atom(let l), .atom(let r)):
      switch (l, r) {
      case (.char(let lc), .char(let rc)): 
      	return lc == rc
      case (.characterClass(let lc), .characterClass(let rc)): 
      	return lc == rc
      default: return false
      }
    case (.empty, .empty),
     (.limitCaptureNesting, .limitCaptureNesting),
     (.ignoreCapturesInTypedOutput, .ignoreCapturesInTypedOutput): 
     return true
    default: return false
    }
  }
}
