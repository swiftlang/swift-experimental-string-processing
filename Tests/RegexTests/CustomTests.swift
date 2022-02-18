import _StringProcessing
import XCTest

// A nibbler processes a single character from a string
private protocol Nibbler:
  MatchingCollectionConsumer, RegexProtocol
where Consumed == String {
  func nibble(_: Character) -> Match?
}

extension Nibbler {
  // Default implementation, just feed the character in
  func matchingConsuming(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> (upperBound: Consumed.Index, match: Match)? {
    guard !range.isEmpty else {
      // FIXME: Do we have a full story here?
      return nil
    }
    let idx = range.lowerBound

    guard let res = nibble(consumed[idx]) else {
      return nil
    }
    return (consumed.index(after: idx), res)
  }
}


// A number nibbler
private struct Numbler: Nibbler {
  typealias Match = Int
  func nibble(_ c: Character) -> Int? {
    c.wholeNumberValue
  }
}

// An ASCII value nibbler
private struct Asciibbler: Nibbler {
  typealias Match = UInt8
  func nibble(_ c: Character) -> UInt8? {
    c.asciiValue
  }
}

extension RegexTests {

  // TODO: Refactor below into more exhaustive, declarative
  // tests.
  func testMatchingConsumers() {

    let regex = Regex {
      Numbler()
      Asciibbler()
    }

    guard let result = "4t".match(regex) else {
      XCTFail()
      return
    }
    XCTAssert(result.match == "4t")

    XCTAssertNil("4".match(regex))
    XCTAssertNil("t".match(regex))
    XCTAssertNil("t4".match(regex))

    let regex2 = Regex {
      oneOrMore {
        Numbler()
      }
    }

    guard let res2 = "ab123c".firstMatch(of: regex2) else {
      XCTFail()
      return
    }

    XCTAssertEqual(res2.match, "123")

    let regex3 = Regex {
      capture {
        oneOrMore {
          Numbler()
        }
      }
    }

    guard let res3 = "ab123c".firstMatch(of: regex3) else {
      XCTFail()
      return
    }

    XCTAssertEqual(res3.match, "123")
    XCTAssertEqual(res3.result.0, "123")
    XCTAssertEqual(res3.result.1, "123")

    let regex4 = Regex {
      oneOrMore {
        capture { Numbler() }
      }
    }

    guard let res4 = "ab123c".firstMatch(of: regex4) else {
      XCTFail()
      return
    }

    XCTAssertEqual(res4.result.0, "123")
    XCTAssertEqual(res4.result.1, 3)
  }

}
