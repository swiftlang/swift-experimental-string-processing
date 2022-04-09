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
import _StringProcessing
@testable import RegexBuilder

// A nibbler processes a single character from a string
private protocol Nibbler: CustomRegexComponent {
  func nibble(_: Character) -> Output?
}

extension Nibbler {
  // Default implementation, just feed the character in
  func match(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) -> (upperBound: String.Index, output: Output)? {
    guard index != bounds.upperBound, let res = nibble(input[index]) else {
      return nil
    }
    return (input.index(after: index), res)
  }
}


// A number nibbler
private struct Numbler: Nibbler {
  typealias Output = Int
  func nibble(_ c: Character) -> Int? {
    c.wholeNumberValue
  }
}

// An ASCII value nibbler
private struct Asciibbler: Nibbler {
  typealias Output = UInt8
  func nibble(_ c: Character) -> UInt8? {
    c.asciiValue
  }
}

enum MatchCall {
  case match
  case firstMatch
}

func customTest<Match: Equatable>(
  _ regex: Regex<Match>,
  _ tests: (input: String, call: MatchCall, match: Match?)...
) {
  for (input, call, match) in tests {
    let result: Match?
    switch call {
    case .match:
      result = input.matchWhole(regex)?.output
    case .firstMatch:
      result = input.firstMatch(of: regex)?.output
    }
    XCTAssertEqual(result, match)
  }
}

class CustomRegexComponentTests: XCTestCase {
  // TODO: Refactor below into more exhaustive, declarative
  // tests.
  func testCustomRegexComponents() {
    customTest(
      Regex {
        Numbler()
        Asciibbler()
      },
      ("4t", .match, "4t"),
      ("4", .match, nil),
      ("t", .match, nil),
      ("t x1y z", .firstMatch, "1y"),
      ("t4", .match, nil))

    customTest(
      Regex {
        OneOrMore { Numbler() }
      },
      ("ab123c", .firstMatch, "123"),
      ("abc", .firstMatch, nil),
      ("55z", .match, nil),
      ("55z", .firstMatch, "55"))

    customTest(
      Regex {
        Numbler()
      },
      ("ab123c", .firstMatch, 1),
      ("abc", .firstMatch, nil),
      ("55z", .match, nil),
      ("55z", .firstMatch, 5))

    // TODO: Convert below tests to better infra. Right now
    // it's hard because `Match` is constrained to be
    // `Equatable` which tuples cannot be.

    let regex3 = Regex {
      Capture {
        OneOrMore {
          Numbler()
        }
      }
    }

    guard let res3 = "ab123c".firstMatch(of: regex3) else {
      XCTFail()
      return
    }

    XCTAssertEqual(res3.range, "ab123c".index(atOffset: 2)..<"ab123c".index(atOffset: 5))
    XCTAssertEqual(res3.output.0, "123")
    XCTAssertEqual(res3.output.1, "123")

    let regex4 = Regex {
      OneOrMore {
        Capture { Numbler() }
      }
    }

    guard let res4 = "ab123c".firstMatch(of: regex4) else {
      XCTFail()
      return
    }

    XCTAssertEqual(res4.output.0, "123")
    XCTAssertEqual(res4.output.1, 3)
  }

  func testRegexAbort() {

    enum Radix: Hashable {
      case dot
      case comma
    }
    struct Abort: Error, Hashable {}

    let hexRegex = Regex {
      Capture { OneOrMore(.hexDigit) }
      TryCapture { CharacterClass.any } transform: { c -> Radix? in
        switch c {
        case ".": return Radix.dot
        case ",": return Radix.comma
        case "❗️":
          // Malicious! Toxic levels of emphasis detected.
          throw Abort()
        default:
          // Not a radix
          return nil
        }
      }
      Capture { OneOrMore(.hexDigit) }
    }
    // hexRegex: Regex<(Substring, Substring, Radix?, Substring)>
    // TODO: Why is Radix optional?

    do {
      guard let m = try hexRegex.matchWhole("123aef.345") else {
        XCTFail()
        return
      }
      XCTAssertEqual(m.0, "123aef.345")
      XCTAssertEqual(m.1, "123aef")
      XCTAssertEqual(m.2, .dot)
      XCTAssertEqual(m.3, "345")
    } catch {
      XCTFail()
    }

    do {
      _ = try hexRegex.matchWhole("123aef❗️345")
      XCTFail()
    } catch let e as Abort {
      XCTAssertEqual(e, Abort())
    } catch {
      XCTFail()
    }

  }
}
