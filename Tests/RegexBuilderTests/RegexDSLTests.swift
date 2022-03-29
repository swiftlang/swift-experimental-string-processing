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

class RegexDSLTests: XCTestCase {
  func _testDSLCaptures<Content: RegexComponent, MatchType>(
    _ tests: (input: String, expectedCaptures: MatchType?)...,
    matchType: MatchType.Type,
    _ equivalence: (MatchType, MatchType) -> Bool,
    file: StaticString = #file,
    line: UInt = #line,
    @RegexComponentBuilder _ content: () -> Content
  ) throws {
    let regex = Regex(content())
    for (input, maybeExpectedCaptures) in tests {
      let maybeMatch = input.match(regex)
      if let expectedCaptures = maybeExpectedCaptures {
        let match = try XCTUnwrap(maybeMatch, file: file, line: line)
        XCTAssertTrue(
          type(of: regex).Output.self == MatchType.self,
          """
          Expected match type: \(MatchType.self)
          Actual match type: \(type(of: regex).Output.self)
          """)
        let captures = try XCTUnwrap(match.output as? MatchType, file: file, line: line)
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
      Capture(Character("b")) // Character
      TryCapture("1") { Int($0) } // Int
    }
    // Assert the inferred capture type.
    let _: (Substring, Substring, Int).Type = type(of: regex).Output.self
    let maybeMatch = "ab1".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertTrue(match.output == ("ab1", "b", 1))

    let substring = "ab1"[...]
    let substringMatch = try XCTUnwrap(substring.match(regex))
    XCTAssertTrue(match.output == substringMatch.output)
  }

  func testCharacterClasses() throws {
    try _testDSLCaptures(
      ("a c", ("a c", " ", "c")),
      matchType: (Substring, Substring, Substring).self, ==)
    {
      .any
      Capture(.whitespace) // Substring
      Capture("c") // Substring
    }
  }

  func testMatchResultDotZeroWithoutCapture() throws {
    let match = try XCTUnwrap("aaa".match { OneOrMore { "a" } })
    XCTAssertEqual(match.0, "aaa")
  }

  func testAlternation() throws {
    do {
      let regex = ChoiceOf {
        "aaa"
      }
      XCTAssertTrue("aaa".match(regex)?.output == "aaa")
      XCTAssertNil("aab".match(regex)?.output)
    }
    do {
      let regex = ChoiceOf {
        "aaa"
        "bbb"
        "ccc"
      }
      XCTAssertTrue("aaa".match(regex)?.output == "aaa")
      XCTAssertNil("aab".match(regex)?.output)
      XCTAssertTrue("bbb".match(regex)?.output == "bbb")
      XCTAssertTrue("ccc".match(regex)?.output == "ccc")
    }
    do {
      let regex = Regex {
        "ab"
        OneOrMore {
          Capture {
            ChoiceOf {
              "c"
              "def"
            }
          }
        }
      }
      XCTAssertTrue(
        try XCTUnwrap("abc".match(regex)?.output) == ("abc", "c"))
    }
    do {
      let regex = ChoiceOf {
        "aaa"
        "bbb"
        "ccc"
      }
      XCTAssertTrue("aaa".match(regex)?.output == "aaa")
      XCTAssertNil("aab".match(regex)?.output)
      XCTAssertTrue("bbb".match(regex)?.output == "bbb")
      XCTAssertTrue("ccc".match(regex)?.output == "ccc")
    }
    do {
      let regex = ChoiceOf {
        Capture("aaa")
      }
      XCTAssertTrue(
        try XCTUnwrap("aaa".match(regex)?.output) == ("aaa", "aaa"))
      XCTAssertNil("aab".match(regex)?.output)
    }
    do {
      let regex = ChoiceOf {
        Capture("aaa")
        Capture("bbb")
        Capture("ccc")
      }
      XCTAssertTrue(
        try XCTUnwrap("aaa".match(regex)?.output) == ("aaa", "aaa", nil, nil))
      XCTAssertTrue(
        try XCTUnwrap("bbb".match(regex)?.output) == ("bbb", nil, "bbb", nil))
      XCTAssertTrue(
        try XCTUnwrap("ccc".match(regex)?.output) == ("ccc", nil, nil, "ccc"))
      XCTAssertNil("aab".match(regex)?.output)
    }
  }

  func testCombinators() throws {
    try _testDSLCaptures(
      ("aaaabccccdddkj", ("aaaabccccdddkj", "b", "cccc", "d", "k", nil, "j")),
      matchType: (Substring, Substring, Substring, Substring?, Substring, Substring?, Substring?).self, ==)
    {
      OneOrMore("a")
      Capture(OneOrMore(Character("b"))) // Substring
      Capture(ZeroOrMore("c")) // Substring
      ZeroOrMore(Capture(.hexDigit)) // Substring?
      Optionally("e")
      Capture {
        ChoiceOf {
          "t"
          "k"
        }
      } // Substring
      ChoiceOf { Capture("k"); Capture("j") } // (Substring?, Substring?)
    }
  }
  
  func testOptions() throws {
    try _testDSLCaptures(
      ("abc", "abc"),
      ("ABC", "ABC"),
      ("abcabc", "abcabc"),
      ("abcABCaBc", "abcABCaBc"),
      matchType: Substring.self, ==) {
        OneOrMore {
          "abc"
        }.caseSensitive(false)
      }
    
    // Multiple options on one component wrap successively, but do not
    // override - equivalent to each option attached to a wrapping `Regex`.
    try _testDSLCaptures(
      ("abc", "abc"),
      ("ABC", "ABC"),
      ("abcabc", "abcabc"),
      ("abcABCaBc", "abcABCaBc"),
      matchType: Substring.self, ==) {
        OneOrMore {
          "abc"
        }
        .caseSensitive(false)
        .caseSensitive(true)
      }

    // An option on an outer component doesn't override an option set on an
    // inner component.
    try _testDSLCaptures(
      ("abc", "abc"),
      ("ABC", "ABC"),
      ("ABCde", "ABCde"),
      ("ABCDE", nil),
      ("abcabc", "abcabc"),
      ("abcdeABCdeaBcde", "abcdeABCdeaBcde"),
      matchType: Substring.self, ==) {
        OneOrMore {
          "abc".caseSensitive(false)
          Optionally("de")
        }
        .caseSensitive(true)
      }
  }
  
  func testQuantificationBehavior() throws {
    try _testDSLCaptures(
      ("abc1def2", ("abc1def2", "2")),
      matchType: (Substring, Substring).self, ==)
    {
      OneOrMore {
        OneOrMore(.word)
        Capture(.digit)
      }
    }

    try _testDSLCaptures(
      ("abc1def2", ("abc1def2", "2")),
      matchType: (Substring, Substring).self, ==)
    {
      OneOrMore {
        OneOrMore(.word, .reluctantly)
        Capture(.digit)
      }
    }

    try _testDSLCaptures(
      ("abc1def2", ("abc1def2", "2")),
      matchType: (Substring, Substring).self, ==)
    {
      OneOrMore {
        OneOrMore(.reluctantly) {
          .word
        }
        Capture(.digit)
      }
    }
    
    try _testDSLCaptures(
      ("abc1def2", "abc1def2"),
      matchType: Substring.self, ==)
    {
      Repeat(2...) {
        Repeat(count: 3) {
          CharacterClass.word
        }
        CharacterClass.digit
      }
    }
    
    try _testDSLCaptures(
      ("aaabbbcccdddeeefff", "aaabbbcccdddeeefff"),
      ("aaaabbbcccdddeeefff", nil),
      ("aaacccdddeeefff", nil),
      ("aaabbbcccccccdddeeefff", nil),
      ("aaabbbcccddddddeeefff", nil),
      ("aaabbbcccdddefff", nil),
      ("aaabbbcccdddeee", "aaabbbcccdddeee"),
      matchType: Substring.self, ==)
    {
      Repeat(count: 3) { "a" }
      Repeat(1...) { "b" }
      Repeat(2...5) { "c" }
      Repeat(..<5) { "d" }
      Repeat(2...) { "e" }
      Repeat(0...) { "f" }
    }
  }
  
  func testAssertions() throws {
    try _testDSLCaptures(
      ("aaaaab", "aaaaab"),
      ("caaaaab", nil),
      ("aaaaabc", nil),
      matchType: Substring.self, ==)
    {
      Anchor.startOfLine
      OneOrMore("a")
      "b"
      Anchor.endOfLine
    }
    
    try _testDSLCaptures(
      ("Cafe\u{301}", nil),
      ("Cafe", "Cafe"),
      matchType: Substring.self, ==)
    {
      OneOrMore(.word)
      UnicodeScalar("e")
      Anchor.textSegmentBoundary
    }

    try _testDSLCaptures(
      ("aaaaa1", "aaaaa1"),
      ("aaaaa2", nil),
      ("aaaaa", nil),
      ("aaaaab", nil),
      matchType: Substring.self, ==)
    {
      OneOrMore("a")
      lookahead(CharacterClass.digit)
      lookahead("2", negative: true)
      CharacterClass.word
    }
  }

  func testNestedGroups() throws {
    return;

    // TODO: clarify what the nesting story is

    /*
    try _testDSLCaptures(
      ("aaaabccccddd", ("aaaabccccddd", [("b", "cccc", ["d", "d", "d"])])),
      matchType: (Substring, [(Substring, Substring, [Substring])]).self, ==)
    {
      "a".+
      OneOrMore {
        Capture(OneOrMore("b"))
        Capture(ZeroOrMore("c"))
        Capture("d").*
        "e".?
      }
    }
     */
  }

  func testCapturelessQuantification() throws {
    // This test is to make sure that a captureless quantification, when used
    // straight out of the quantifier (without being wrapped in a builder), is
    // able to produce a regex whose `Match` type does not contain any sort of
    // void.
    let regex = ZeroOrMore(.digit)
    // Assert the inferred capture type.
    let _: Substring.Type = type(of: regex).Output.self
    let input = "123123"
    let match = try XCTUnwrap(input.match(regex)?.output)
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
      ("aaa 123 apple orange apple", ("aaa 123 apple orange apple", 123, .apple)),
      ("aaa     ", ("aaa     ", nil, nil)),
      matchType: (Substring, Int?, Word?).self, ==)
    {
      OneOrMore("a")
      OneOrMore(.whitespace)
      Optionally {
        Capture(OneOrMore(.digit)) { Int($0)! }
      }
      ZeroOrMore {
        OneOrMore(.whitespace)
        Capture(OneOrMore(.word)) { Word($0)! }
      }
    }
  }

  func testNestedCaptureTypes() throws {
    let regex1 = Regex {
      OneOrMore("a")
      Capture {
        Capture(OneOrMore("b"))
        Optionally("e")
      }
    }
    let _: (Substring, Substring, Substring).Type
      = type(of: regex1).Output.self
    let regex2 = Regex {
      OneOrMore("a")
      Capture {
        ZeroOrMore {
          TryCapture("b") { Int($0) }
        }
        Optionally("e")
      }
    }
    let _: (Substring, Substring, Int?).Type
      = type(of: regex2).Output.self
    let regex3 = Regex {
      OneOrMore("a")
      Capture {
        TryCapture("b") { Int($0) }
        ZeroOrMore {
          TryCapture("c") { Double($0) }
        }
        Optionally("e")
      }
    }
    let _: (Substring, Substring, Int, Double?).Type
      = type(of: regex3).Output.self
    let regex4 = Regex {
      OneOrMore("a")
      Capture {
        OneOrMore {
          Capture(OneOrMore("b"))
          Capture(ZeroOrMore("c"))
          ZeroOrMore(Capture("d"))
          Optionally("e")
        }
      }
    }
    let _: (
      Substring, Substring, Substring, Substring, Substring?).Type
      = type(of: regex4).Output.self
  }

  func testUnicodeScalarPostProcessing() throws {
    let spaces = Regex {
      ZeroOrMore {
        .whitespace
      }
    }

    let unicodeScalar = Regex {
      OneOrMore {
        .hexDigit
      }
      spaces
    }

    let unicodeData = Regex {
      unicodeScalar
      Optionally {
        ".."
        unicodeScalar
      }

      ";"
      spaces

      Capture {
        OneOrMore {
          .word
        }
      }

      ZeroOrMore {
        .any
      }
    }

    // Assert the inferred capture type.
    let _: (Substring, Substring).Type = type(of: unicodeData).Output.self

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
      Capture {
        OneOrMore(.hexDigit)
      } transform: { Unicode.Scalar(hex: $0) }
      Optionally {
        ".."
        Capture {
          OneOrMore(.hexDigit)
        } transform: { Unicode.Scalar(hex: $0) }
      }
      OneOrMore(.whitespace)
      ";"
      OneOrMore(.whitespace)
      Capture(OneOrMore(.word))
      ZeroOrMore(.any)
    } // Regex<(Substring, Unicode.Scalar?, Unicode.Scalar??, Substring)>
    do {
      // Assert the inferred capture type.
      typealias ExpectedMatch = (
        Substring, Unicode.Scalar?, Unicode.Scalar??, Substring
      )
      let _: ExpectedMatch.Type = type(of: regexWithCapture).Output.self
      let maybeMatchResult = line.match(regexWithCapture)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.output
      XCTAssertEqual(wholeMatch, Substring(line))
      XCTAssertEqual(lower, Unicode.Scalar(0xA6F0))
      XCTAssertEqual(upper, Unicode.Scalar(0xA6F1))
      XCTAssertEqual(propertyString, "Extend")
    }

    let regexWithTryCapture = Regex {
      TryCapture {
        OneOrMore(.hexDigit)
      } transform: {
        Unicode.Scalar(hex: $0)
      }
      Optionally {
        ".."
        TryCapture {
          OneOrMore(.hexDigit)
        } transform: {
          Unicode.Scalar(hex: $0)
        }
      }
      OneOrMore(.whitespace)
      ";"
      OneOrMore(.whitespace)
      Capture(OneOrMore(.word))
      ZeroOrMore(.any)
    } // Regex<(Substring, Unicode.Scalar, Unicode.Scalar?, Substring)>
    do {
      // Assert the inferred capture type.
      typealias ExpectedMatch = (
        Substring, Unicode.Scalar, Unicode.Scalar?, Substring
      )
      let _: ExpectedMatch.Type = type(of: regexWithTryCapture).Output.self
      let maybeMatchResult = line.match(regexWithTryCapture)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.output
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
      let (wholeMatch, lower, upper, propertyString) = matchResult.output
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
      let match = try XCTUnwrap(line.match(regex))
      XCTAssertEqual(match.0, line[...])
      let output = match.output
      XCTAssertEqual(output[0].substring, line[...])
    }
    do {
      let regex = try Regex(
        #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#)
      let line = """
        A6F0..A6F1    ; Extend # Mn   [2] BAMUM COMBINING MARK KOQNDON..BAMUM \
        COMBINING MARK TUKWENTIS
        """
      let match = try XCTUnwrap(line.match(regex))
      XCTAssertEqual(match.0, line[...])
      let output = match.output
      XCTAssertEqual(output[0].substring, line[...])
      XCTAssertTrue(output[1].substring == "A6F0")
      XCTAssertTrue(output[2].substring == "A6F1")
      XCTAssertTrue(output[3].substring == "Extend")
      let typedOutput = try XCTUnwrap(output.as(
        (Substring, Substring, Substring?, Substring).self))
      XCTAssertEqual(typedOutput.0, line[...])
      XCTAssertTrue(typedOutput.1 == "A6F0")
      XCTAssertTrue(typedOutput.2 == "A6F1")
      XCTAssertTrue(typedOutput.3 == "Extend")
    }
  }

  func testBackreference() throws {
    try _testDSLCaptures(
      ("abc#41#42abcabcabc", ("abc#41#42abcabcabc", "abc", 42, "abc", nil)),
      matchType: (Substring, Substring, Int?, Substring?, Substring?).self, ==)
    {
      let a = Reference(Substring.self)
      let b = Reference(Int.self)
      Capture("abc", as: a)
      ZeroOrMore {
        TryCapture(as: b) {
          "#"
          OneOrMore(.digit)
        } transform: {
          Int($0.dropFirst())
        }
      }
      a
      ZeroOrMore {
        Capture(a)
      }
      Optionally {
        "b"
        Capture(a)
      }
    }

    // Match result referencing a `Reference`.
    do {
      let a = Reference(Substring.self)
      let b = Reference(Int.self)
      let regex = Regex {
        Capture("abc", as: a)
        ZeroOrMore {
          TryCapture(as: b) {
            "#"
            OneOrMore(.digit)
          } transform: {
            Int($0.dropFirst())
          }
        }
        a
        ZeroOrMore {
          Capture(b)
        }
        Optionally {
          Capture(a)
        }
      }
      let input = "abc#41#42abc#42#42"
      let result = try XCTUnwrap(input.match(regex))
      XCTAssertEqual(result[a], "abc")
      XCTAssertEqual(result[b], 42)
    }

    // Post-hoc captured references
    // #"(?:\w\1|:(\w):)+"#
    try _testDSLCaptures(
      (":a:baca:o:boco", (":a:baca:o:boco", "o")),
      matchType: (Substring, Substring?).self,
      ==
    ) {
      // NOTE: "expression too complex to type check" when inferring the generic
      // parameter.
      OneOrMore {
        let a = Reference(Substring.self)
        ChoiceOf<(Substring, Substring?)> {
          Regex {
            .word
            a
          }
          Regex {
            ":"
            Capture(.word, as: a)
            ":"
          }
        }
      }
    }
  }
  
  func testSemanticVersionExample() {
    struct SemanticVersion: Equatable {
      var major: Int
      var minor: Int
      var patch: Int
      var dev: String?
    }
    struct SemanticVersionParser: CustomRegexComponent {
      typealias Output = SemanticVersion
      func match(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
      ) -> (upperBound: String.Index, output: SemanticVersion)? {
        let regex = Regex {
          TryCapture(OneOrMore(.digit)) { Int($0) }
          "."
          TryCapture(OneOrMore(.digit)) { Int($0) }
          Optionally {
            "."
            TryCapture(OneOrMore(.digit)) { Int($0) }
          }
          Optionally {
            "-"
            Capture(OneOrMore(.word))
          }
        }

        guard let match = input[index..<bounds.upperBound].firstMatch(of: regex),
              match.range.lowerBound == index
        else { return nil }

        let result = SemanticVersion(
          major: match.result.1,
          minor: match.result.2,
          patch: match.result.3 ?? 0,
          dev: match.result.4.map(String.init))
        return (match.range.upperBound, result)
      }
    }
    
    let versions = [
      ("1.0", SemanticVersion(major: 1, minor: 0, patch: 0)),
      ("1.0.1", SemanticVersion(major: 1, minor: 0, patch: 1)),
      ("12.100.5-dev", SemanticVersion(major: 12, minor: 100, patch: 5, dev: "dev")),
    ]
    
    let parser = SemanticVersionParser()
    for (str, version) in versions {
      XCTAssertEqual(str.match(parser)?.output, version)
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

func == <T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
  l: (T0, T1, T2, T3, T4, T5, T6), r: (T0, T1, T2, T3, T4, T5, T6)
) -> Bool {
  l.0 == r.0 && (l.1, l.2, l.3, l.4, l.5, l.6) == (r.1, r.2, r.3, r.4, r.5, r.6)
}
