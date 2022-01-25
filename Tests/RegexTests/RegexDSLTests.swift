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
@testable import _StringProcessing

class RegexDSLTests: XCTestCase {
  func testSimpleStrings() throws {
    let regex = Regex {
      "a"
      Character("b").capture() // Character
      "1".tryCapture { Int($0) } // Int
    }
    // Assert the inferred capture type.
    let _: Tuple3<Substring, Substring, Int>.Type = type(of: regex).Match.self
    let maybeMatch = "ab1".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertEqual(match.match, Tuple3("ab1", "b", 1))

    let substring = "ab1"[...]
    let substringMatch = try XCTUnwrap(
      substring.match(regex))
    XCTAssertEqual(match.match, substringMatch.match)
  }

  func testCharacterClasses() throws {
    let regex = Regex {
      CharacterClass.any
      CharacterClass.whitespace.capture() // Character
      "c".capture() // Substring
    }
    // Assert the inferred capture type.
    let _: Tuple3<Substring, Substring, Substring>.Type = type(of: regex).Match.self
    let maybeMatch = "a c".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertTrue(match.match == Tuple3("a c", " ", "c"))
  }

  func testCombinators() throws {
    let regex = Regex {
      "a".+
      oneOrMore(Character("b")).capture() // Substring
      many("c").capture() // Substring
      CharacterClass.hexDigit.capture().* // [Substring]
      "e".?
      ("t" | "k").capture() // Substring
    }
    // Assert the inferred capture type.
    let _: Tuple5<Substring, Substring, Substring, [Substring], Substring>.Type
      = type(of: regex).Match.self
    let maybeMatch = "aaaabccccdddk".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertTrue(
      match.match
        == Tuple5("aaaabccccdddk", "b", "cccc", ["d", "d", "d"], "k"))
  }

  func testNestedGroups() throws {
    let regex = Regex {
      "a".+
      oneOrMore {
        oneOrMore("b").capture()
        many("c").capture()
        "d".capture().*
        "e".?
      }
    }
    // Assert the inferred capture type.
    let _: Tuple2<Substring, [Tuple3<Substring, Substring, [Substring]>]>.Type
      = type(of: regex).Match.self
    let maybeMatch = "aaaabccccddd".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertEqual(match.match.1.count, 1)
    XCTAssertEqual(match.match.0, "aaaabccccddd")
    XCTAssertTrue(
      match.match.1[0]
        == Tuple3("b", "cccc", ["d", "d", "d"]))
  }

  func testCapturelessQuantification() throws {
    // This test is to make sure that a captureless quantification, when used
    // straight out of the quantifier (without being wrapped in a builder), is
    // able to produce a regex whose `Match` type does not contain any sort of
    // void.
    let regex = many(.digit)
    // Assert the inferred capture type.
    let _: Substring.Type = type(of: regex).Match.self
    let input = "123123"
    let match = try XCTUnwrap(input.match(regex)?.match)
    XCTAssertTrue(match == input)
  }

  func testQuantificationWithTransformedCapture() throws {
    // This test is to make sure transformed capture type information is
    // correctly propagated from the DSL into the bytecode and that the engine
    // is reconstructing the right types upon quantification (both empty and
    // non-empty).
    enum Word: Int32 {
      case apple
      case orange

      init?(_ string: Substring) {
        switch string {
        case "apple": self = .apple
        case "orange": self = .orange
        default: return nil
        }
      }
    }
    let regex = Regex {
      "a".+
      oneOrMore(.whitespace)
      optionally {
        oneOrMore(.digit).capture { Int($0)! }
      }
      many {
        oneOrMore(.whitespace)
        oneOrMore(.word).capture { Word($0)! }
      }
    }
    // Assert the inferred capture type.
    let _: Tuple3<Substring, Int?, [Word]>.Type = type(of: regex).Match.self
    do {
      let input = "aaa 123 apple orange apple"
      let match = input.match(regex)?.match.tuple
      let (whole, number, words) = try XCTUnwrap(match)
      XCTAssertTrue(whole == input)
      XCTAssertEqual(number, 123)
      XCTAssertEqual(words, [.apple, .orange, .apple])
    }
    do {
      let input = "aaa   "
      let match = input.match(regex)?.match.tuple
      let (whole, number, words) = try XCTUnwrap(match)
      XCTAssertTrue(whole == input)
      XCTAssertEqual(number, nil)
      XCTAssertTrue(words.isEmpty)
    }
  }

  func testNestedCaptureTypes() throws {
    let regex1 = Regex {
      "a".+
      Regex {
        oneOrMore("b").capture()
        "e".?
      }.capture()
    }
    let _: Tuple3<Substring, Substring, Substring>.Type
      = type(of: regex1).Match.self
    let regex2 = Regex {
      "a".+
      Regex {
        "b".tryCapture { Int($0) }.*
        "e".?
      }.capture()
    }
    let _: Tuple3<Substring, Substring, [Int]>.Type
      = type(of: regex2).Match.self
    let regex3 = Regex {
      "a".+
      Regex {
        "b".tryCapture { Int($0) }
        "c".tryCapture { Double($0) }.*
        "e".?
      }.capture()
    }
    let _: Tuple4<Substring, Substring, Int, [Double]>.Type
      = type(of: regex3).Match.self
    let regex4 = Regex {
      "a".+
      oneOrMore {
        oneOrMore("b").capture()
        many("c").capture()
        "d".capture().*
        "e".?
      }.capture()
    }
    let _: Tuple3<
      Substring, Substring, [Tuple3<Substring, Substring, [Substring]>]>.Type
      = type(of: regex4).Match.self
  }

  func testUnicodeScalarPostProcessing() throws {
    let spaces = Regex {
      many {
        CharacterClass.whitespace
      }
    }

    let unicodeScalar = Regex {
      oneOrMore {
        CharacterClass.hexDigit
      }
      spaces
    }

    let unicodeData = Regex {
      unicodeScalar
      optionally {
        ".."
        unicodeScalar
      }

      ";"
      spaces

      oneOrMore {
        CharacterClass.word
      }.capture()

      many {
        CharacterClass.any
      }
    }

    // Assert the inferred capture type.
    let _: Tuple2<Substring, Substring>.Type = type(of: unicodeData).Match.self

    let unicodeLine =
      "1BCA0..1BCA3  ; Control # Cf   [4] SHORTHAND FORMAT LETTER OVERLAP..SHORTHAND FORMAT UP STEP"
    let match = try XCTUnwrap(unicodeLine.match(unicodeData))
    XCTAssertEqual(match.0, Substring(unicodeLine))
    XCTAssertEqual(match.1, "Control")
  }

  func testGraphemeBreakData() throws {
    let line = """
      A6F0..A6F1    ; Extend # Mn   [2] BAMUM COMBINING MARK KOQNDON..BAMUM COMBINING MARK TUKWENTIS
      """
    
    let regexWithCapture = Regex {
      oneOrMore(CharacterClass.hexDigit).capture(Unicode.Scalar.init(hex:))
      optionally {
        ".."
        oneOrMore(CharacterClass.hexDigit).capture(Unicode.Scalar.init(hex:))
      }
      oneOrMore(CharacterClass.whitespace)
      ";"
      oneOrMore(CharacterClass.whitespace)
      oneOrMore(CharacterClass.word).capture()
      many(CharacterClass.any)
    } // Regex<(Substring, Unicode.Scalar?, Unicode.Scalar??, Substring)>
    do {
      // Assert the inferred capture type.
      typealias ExpectedMatch = Tuple4<
        Substring, Unicode.Scalar?, Unicode.Scalar??, Substring
      >
      let _: ExpectedMatch.Type = type(of: regexWithCapture).Match.self
      let maybeMatchResult = line.match(regexWithCapture)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match.tuple
      XCTAssertEqual(wholeMatch, Substring(line))
      XCTAssertEqual(lower, Unicode.Scalar(0xA6F0))
      XCTAssertEqual(upper, Unicode.Scalar(0xA6F1))
      XCTAssertEqual(propertyString, "Extend")
    }

    let regexWithTryCapture = Regex {
      oneOrMore(CharacterClass.hexDigit).tryCapture(Unicode.Scalar.init(hex:))
      optionally {
        ".."
        oneOrMore(CharacterClass.hexDigit).tryCapture(Unicode.Scalar.init(hex:))
      }
      oneOrMore(CharacterClass.whitespace)
      ";"
      oneOrMore(CharacterClass.whitespace)
      oneOrMore(CharacterClass.word).capture()
      many(CharacterClass.any)
    } // Regex<(Substring, Unicode.Scalar, Unicode.Scalar?, Substring)>
    do {
      // Assert the inferred capture type.
      typealias ExpectedMatch = Tuple4<
        Substring, Unicode.Scalar, Unicode.Scalar?, Substring
      >
      let _: ExpectedMatch.Type = type(of: regexWithTryCapture).Match.self
      let maybeMatchResult = line.match(regexWithTryCapture)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match.tuple
      XCTAssertEqual(wholeMatch, Substring(line))
      XCTAssertEqual(lower, Unicode.Scalar(0xA6F0))
      XCTAssertEqual(upper, Unicode.Scalar(0xA6F1))
      XCTAssertEqual(propertyString, "Extend")
    }

    do {
      let regexLiteral = try MockRegexLiteral(
        #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#,
        matching: Tuple4<Substring, Substring, Substring?, Substring>.self)
      let maybeMatchResult = line.match(regexLiteral)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match.tuple
      XCTAssertEqual(wholeMatch, Substring(line))
      XCTAssertEqual(lower, "A6F0")
      XCTAssertEqual(upper, "A6F1")
      XCTAssertEqual(propertyString, "Extend")
    }
  }

  func testDynamicCaptures() throws {
    do {
      let regex = try Regex("aabcc.")
      let line = "aabccd"
      let captures = try XCTUnwrap(line.match(regex)?.1)
      XCTAssertEqual(captures, .empty)
    }
    do {
      let regex = try Regex(
        #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#)
      let line = """
        A6F0..A6F1    ; Extend # Mn   [2] BAMUM COMBINING MARK KOQNDON..BAMUM \
        COMBINING MARK TUKWENTIS
        """
      let captures = try XCTUnwrap(line.match(regex)?.1)
      XCTAssertEqual(
        captures,
        .tuple([
          .substring("A6F0"),
          .optional(.substring("A6F1")),
          .substring("Extend")]))
    }
  }
}

extension Unicode.Scalar {
  // Convert a hexadecimal string to a scalar
  init?<S: StringProtocol>(hex: S) {
    guard let val = UInt32(hex, radix: 16), let scalar = Self(val) else {
      return nil
    }
    self = scalar
  }
}
