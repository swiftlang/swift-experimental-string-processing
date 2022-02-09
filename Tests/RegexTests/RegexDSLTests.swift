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
  func _testDSLCaptures<Content: RegexProtocol, CaptureType>(
    _ tests: (input: String, expectedCaptures: CaptureType?)...,
    captureType: CaptureType.Type,
    _ equivalence: (CaptureType, CaptureType) -> Bool,
    file: StaticString = #file,
    line: UInt = #line,
    @RegexBuilder _ content: () -> Content
  ) throws {
    let regex = Regex(content())
    for (input, maybeExpectedCaptures) in tests {
      let maybeMatch = input.match(regex)
      if let expectedCaptures = maybeExpectedCaptures {
        let match = try XCTUnwrap(maybeMatch, file: file, line: line)
        let captures = try XCTUnwrap(match.match as? CaptureType, file: file, line: line)
        XCTAssertTrue(
          equivalence(captures, expectedCaptures),
          "'\(captures)' is not equal to the expected '\(expectedCaptures)'.",
          file: file, line: line)
      } else {
        XCTAssertNil(maybeMatch, file: file, line: line)
      }
    }
  }

  func testSimpleStrings() throws {
    let regex = Regex {
      "a"
      Character("b").capture() // Character
      "1".tryCapture { Int($0) } // Int
    }
    // Assert the inferred capture type.
    let _: (Substring, Substring, Int).Type = type(of: regex).Match.self
    let maybeMatch = "ab1".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertTrue(match.match == ("ab1", "b", 1))

    let substring = "ab1"[...]
    let substringMatch = try XCTUnwrap(substring.match(regex))
    XCTAssertTrue(match.match == substringMatch.match)
  }

  func testCharacterClasses() throws {
    try _testDSLCaptures(
      ("a c", ("a c", " ", "c")),
      captureType: (Substring, Substring, Substring).self, ==)
    {
      CharacterClass.any
      CharacterClass.whitespace.capture() // Substring
      "c".capture() // Substring
    }
  }

  func testAlternation() throws {
    do {
      let regex = oneOf {
        "aaa"
      }
      XCTAssertTrue("aaa".match(regex)?.match == "aaa")
      XCTAssertNil("aab".match(regex)?.match)
    }
    do {
      let regex = oneOf {
        "aaa"
        "bbb"
        "ccc"
      }
      XCTAssertTrue("aaa".match(regex)?.match == "aaa")
      XCTAssertNil("aab".match(regex)?.match)
      XCTAssertTrue("bbb".match(regex)?.match == "bbb")
      XCTAssertTrue("ccc".match(regex)?.match == "ccc")
    }
    do {
      let regex = Regex {
        "ab"
        oneOf {
          "c"
          "def"
        }.capture().+
      }
      XCTAssertTrue(
        try XCTUnwrap("abc".match(regex)?.match) == ("abc", ["c"]))
    }
    do {
      let regex = oneOf {
        "aaa"
        "bbb"
        "ccc"
      }
      XCTAssertTrue("aaa".match(regex)?.match == "aaa")
      XCTAssertNil("aab".match(regex)?.match)
      XCTAssertTrue("bbb".match(regex)?.match == "bbb")
      XCTAssertTrue("ccc".match(regex)?.match == "ccc")
    }
    do {
      let regex = oneOf {
        "aaa".capture()
      }
      XCTAssertTrue(
        try XCTUnwrap("aaa".match(regex)?.match) == ("aaa", "aaa"))
      XCTAssertNil("aab".match(regex)?.match)
    }
    do {
      let regex = oneOf {
        "aaa".capture()
        "bbb".capture()
        "ccc".capture()
      }
      XCTAssertTrue(
        try XCTUnwrap("aaa".match(regex)?.match) == ("aaa", "aaa", nil, nil))
      XCTAssertTrue(
        try XCTUnwrap("bbb".match(regex)?.match) == ("bbb", nil, "bbb", nil))
      XCTAssertTrue(
        try XCTUnwrap("ccc".match(regex)?.match) == ("ccc", nil, nil, "ccc"))
      XCTAssertNil("aab".match(regex)?.match)
    }
  }

  func testCombinators() throws {
    try _testDSLCaptures(
      ("aaaabccccdddkj", ("aaaabccccdddkj", "b", "cccc", ["d", "d", "d"], "k", nil, "j")),
      captureType: (Substring, Substring, Substring, [Substring], Substring, Substring?, Substring?).self, ==)
    {
      "a".+
      oneOrMore(Character("b")).capture() // Substring
      many("c").capture() // Substring
      CharacterClass.hexDigit.capture().* // [Substring]
      "e".?
      ("t" | "k").capture() // Substring
      oneOf { "k".capture(); "j".capture() } // (Substring?, Substring?)
    }
  }
  
  func testQuantificationBehavior() throws {
    try _testDSLCaptures(
      ("abc1def2", ("abc1def2", ["2"])),
      captureType: (Substring, [Substring]).self, ==)
    {
      oneOrMore {
        oneOrMore(.word)
        CharacterClass.digit.capture()
      }
    }

    try _testDSLCaptures(
      ("abc1def2", ("abc1def2", ["1", "2"])),
      captureType: (Substring, [Substring]).self, ==)
    {
      oneOrMore {
        oneOrMore(.word, .reluctantly)
        CharacterClass.digit.capture()
      }
    }

    try _testDSLCaptures(
      ("abc1def2", ("abc1def2", ["1", "2"])),
      captureType: (Substring, [Substring]).self, ==)
    {
      oneOrMore {
        oneOrMore(.reluctantly) {
          CharacterClass.word
        }
        CharacterClass.digit.capture()
      }
    }
  }

  func testNestedGroups() throws {
    try _testDSLCaptures(
      ("aaaabccccddd", ("aaaabccccddd", [("b", "cccc", ["d", "d", "d"])])),
      captureType: (Substring, [(Substring, Substring, [Substring])]).self, ==)
    {
      "a".+
      oneOrMore {
        oneOrMore("b").capture()
        many("c").capture()
        "d".capture().*
        "e".?
      }
    }
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
    try _testDSLCaptures(
      ("aaa 123 apple orange apple", ("aaa 123 apple orange apple", 123, [.apple, .orange, .apple])),
      ("aaa     ", ("aaa     ", nil, [])),
      captureType: (Substring, Int?, [Word]).self, ==)
    {
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
  }

  func testNestedCaptureTypes() throws {
    let regex1 = Regex {
      "a".+
      Regex {
        oneOrMore("b").capture()
        "e".?
      }.capture()
    }
    let _: (Substring, Substring, Substring).Type
      = type(of: regex1).Match.self
    let regex2 = Regex {
      "a".+
      Regex {
        "b".tryCapture { Int($0) }.*
        "e".?
      }.capture()
    }
    let _: (Substring, Substring, [Int]).Type
      = type(of: regex2).Match.self
    let regex3 = Regex {
      "a".+
      Regex {
        "b".tryCapture { Int($0) }
        "c".tryCapture { Double($0) }.*
        "e".?
      }.capture()
    }
    let _: (Substring, Substring, Int, [Double]).Type
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
    let _: (
      Substring, Substring, [(Substring, Substring, [Substring])]).Type
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
    let _: (Substring, Substring).Type = type(of: unicodeData).Match.self

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
      typealias ExpectedMatch = (
        Substring, Unicode.Scalar?, Unicode.Scalar??, Substring
      )
      let _: ExpectedMatch.Type = type(of: regexWithCapture).Match.self
      let maybeMatchResult = line.match(regexWithCapture)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match
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
      typealias ExpectedMatch = (
        Substring, Unicode.Scalar, Unicode.Scalar?, Substring
      )
      let _: ExpectedMatch.Type = type(of: regexWithTryCapture).Match.self
      let maybeMatchResult = line.match(regexWithTryCapture)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match
      XCTAssertEqual(wholeMatch, Substring(line))
      XCTAssertEqual(lower, Unicode.Scalar(0xA6F0))
      XCTAssertEqual(upper, Unicode.Scalar(0xA6F1))
      XCTAssertEqual(propertyString, "Extend")
    }

    do {
      let regexLiteral = try MockRegexLiteral(
        #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#,
        matching: (Substring, Substring, Substring?, Substring).self)
      let maybeMatchResult = line.match(regexLiteral)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match
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

// MARK: Extra == functions

// (Substring, [(Substring, Substring, [Substring])])
typealias S_AS = (Substring, [(Substring, Substring, [Substring])])

func ==(lhs: S_AS, rhs: S_AS) -> Bool {
  lhs.0 == rhs.0 && lhs.1.elementsEqual(rhs.1, by: ==)
}

func == <T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
  l: (T0, T1, T2, T3, T4, T5, T6), r: (T0, T1, T2, T3, T4, T5, T6)
) -> Bool {
  l.0 == r.0 && (l.1, l.2, l.3, l.4, l.5, l.6) == (r.1, r.2, r.3, r.4, r.5, r.6)
}
