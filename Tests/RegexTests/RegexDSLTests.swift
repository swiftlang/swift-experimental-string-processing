import XCTest
@testable import _StringProcessing

class RegexDSLTests: XCTestCase {
  func testSimpleStrings() throws {
    let regex = Regex {
      "a"
      Character("b").capture() // Character
      "1".capture { Int($0)! } // Int
    }
    // Assert the inferred capture type.
    let _: Tuple3<Substring, Substring, Int>.Type = type(of: regex).Match.self
    let maybeMatch = "ab1".match(regex)
    let match = try XCTUnwrap(maybeMatch)
    XCTAssertTrue(match.match == Tuple3("ab1", "b", 1))
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
      OneOrMore(Character("b")).capture() // Substring
      Repeat("c").capture() // Substring
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

// TODO: Fix nested group captures.
//  func testNestedGroups() throws {
//    let regex = Regex {
//      "a".+
//      OneOrMore {
//        OneOrMore("b").capture()
//        Repeat("c").capture()
//        "d".capture().*
//        "e".?
//      }
//    }
//    // Assert the inferred capture type.
//    let _: Tuple2<Substring, [Tuple3<Substring, Substring, [Substring]>]>.Type
//      = type(of: regex).Match.self
//    let maybeMatch = "aaaabccccddd".match(regex)
//    let match = try XCTUnwrap(maybeMatch)
//    XCTAssertEqual(match.match.1.count, 1)
//    XCTAssertEqual(match.match.0, "aaaabccccddd")
//    XCTAssertTrue(
//      match.match.1[0]
//        == Tuple3("b", "cccc", ["d", "d", "d"]))
//  }

  // Note: Types of nested captures should be flat, but are currently nested
  // due to the lack of variadic generics. Without it, we cannot effectively
  // express type constraints to concatenate splatted tuples.
  func testNestedCaptureTypes() throws {
    let regex1 = Regex {
      "a".+
      Regex {
        OneOrMore("b").capture()
        "e".?
      }.capture()
    }
    let _: Tuple2<Substring, Tuple2<Substring, Substring>>.Type
      = type(of: regex1).Match.self
    let regex2 = Regex {
      "a".+
      Regex {
        "b".capture { Int($0)! }.*
        "e".?
      }.capture()
    }
    let _: Tuple2<Substring, Tuple2<Substring, [Int]>>.Type
      = type(of: regex2).Match.self
    let regex3 = Regex {
      "a".+
      Regex {
        "b".capture { Int($0)! }
        "c".capture { Double($0)! }.*
        "e".?
      }.capture()
    }
    let _: Tuple2<Substring, Tuple3<Substring, Int, [Double]>>.Type
      = type(of: regex3).Match.self
    let regex4 = Regex {
      "a".+
      OneOrMore {
        OneOrMore("b").capture()
        Repeat("c").capture()
        "d".capture().*
        "e".?
      }.capture()
    }
    let _: Tuple2<
      Substring, Tuple2<
        Substring, [Tuple3<Substring, Substring, [Substring]>]>>.Type
      = type(of: regex4).Match.self
  }

  func testUnicodeScalarPostProcessing() throws {
    let spaces = Regex {
      Repeat {
        CharacterClass.whitespace
      }
    }

    let unicodeScalar = Regex {
      OneOrMore {
        CharacterClass.hexDigit
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

      OneOrMore {
        CharacterClass.word
      }.capture()

      Repeat {
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
    let regex = Regex {
      OneOrMore(CharacterClass.hexDigit).capture()
      Optionally {
        ".."
        OneOrMore(CharacterClass.hexDigit).capture()
      }
      OneOrMore(CharacterClass.whitespace)
      ";"
      OneOrMore(CharacterClass.whitespace)
      OneOrMore(CharacterClass.word).capture()
      Repeat(CharacterClass.any)
    }
    // Assert the inferred capture type.
    typealias ExpectedMatch = Tuple4<
      Substring, Substring, Substring?, Substring
    >
    let _: ExpectedMatch.Type = type(of: regex).Match.self
    func run<R: RegexProtocol>(
      _ regex: R
    ) throws where R.Match == ExpectedMatch {
      let maybeMatchResult = line.match(regex)
      let matchResult = try XCTUnwrap(maybeMatchResult)
      let (wholeMatch, lower, upper, propertyString) = matchResult.match.tuple
      XCTAssertEqual(wholeMatch, Substring(line))
      XCTAssertEqual(lower, "A6F0")
      XCTAssertEqual(upper, "A6F1")
      XCTAssertEqual(propertyString, "Extend")
    }
    let regexLiteral = try MockRegexLiteral(
      #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#,
      matching: Tuple4<Substring, Substring, Substring?, Substring>.self)
    try run(regex)
    try run(regexLiteral)
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
