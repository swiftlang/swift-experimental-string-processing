import XCTest
@testable import RegexDSL
import Regex
import Util

class RegexDSLTests: XCTestCase {
  static let engines: [VirtualMachine.Type] = [HareVM.self, TortoiseVM.self]

  func forEachEngine(
    except exceptions: VirtualMachine.Type...,
    do body: (VirtualMachine.Type) throws -> Void
  ) rethrows -> Void {
    for engine in Self.engines {
      if !exceptions.contains(where: { $0 == engine }) {
        try body(engine)
      }
    }
  }

  func testSimpleStrings() throws {
    let regex = Regex {
      "a"
      Character("b").capture() // Character
      "1".capture { Int($0)! } // Int
    }
    // Assert the inferred capture type.
    let _: (Substring, Int).Type = type(of: regex).Capture.self
    try forEachEngine { engine in
      let maybeMatch = "ab1".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertTrue(match.captures == ("b", 1))
    }
  }

  func testCharacterClasses() throws {
    let regex = Regex {
      CharacterClass.any
      CharacterClass.whitespace.capture() // Character
      "c".capture() // Substring
    }
    // Assert the inferred capture type.
    let _: (Substring, Substring).Type = type(of: regex).Capture.self
    try forEachEngine { engine in
      let maybeMatch = "a c".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertTrue(match.captures == (" ", "c"))
    }
  }

  func testCombinators() throws {
    let regex = Regex {
      "a".+
      OneOrMore(Character("b")).capture() // [Character]
      Repeat("c").capture() // [Substring]
      CharacterClass.hexDigit.capture().* // [Character]
      "e".?
      ("t" | "k").capture() // Substring
    }
    // Assert the inferred capture type.
    let _: (Substring, Substring, [Substring], Substring).Type
      = type(of: regex).Capture.self
    try forEachEngine { engine in
      let maybeMatch = "aaaabccccdddk".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertTrue(
        match.captures
          == ("b", "cccc", ["d", "d", "d"], "k"))
    }
  }

  func testNestedGroups() throws {
    let regex = Regex {
      "a".+
      OneOrMore {
        OneOrMore("b").capture()
        Repeat("c").capture()
        "d".capture().*
        "e".?
      }
    }
    // Assert the inferred capture type.
    let _: [(Substring, Substring, [Substring])].Type = type(of: regex).Capture.self
    try forEachEngine { engine in
      let maybeMatch = "aaaabccccddd".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.captures.count, 1)
      XCTAssertTrue(
        match.captures[0]
          == ("b", "cccc", ["d", "d", "d"]))
    }
  }

  func testNestedCaptureTypes() throws {
    let regex1 = Regex {
      "a".+
      Regex {
        OneOrMore("b").capture()
        "e".?
      }.capture()
    }
    let _: (Substring, Substring).Type = type(of: regex1).Capture.self
    let regex2 = Regex {
      "a".+
      Regex {
        "b".capture { Int($0)! }.*
        "e".?
      }.capture()
    }
    let _: (Substring, [Int]).Type = type(of: regex2).Capture.self
    let regex3 = Regex {
      "a".+
      Regex {
        "b".capture { Int($0)! }
        "c".capture { Double($0)! }.*
        "e".?
      }.capture()
    }
    let _: (Substring, Int, [Double]).Type = type(of: regex3).Capture.self
    let regex4 = Regex {
      "a".+
      OneOrMore {
        OneOrMore("b").capture()
        Repeat("c").capture()
        "d".capture().*
        "e".?
      }.capture()
    }
    let _: (Substring, [(Substring, Substring, [Substring])]).Type = type(of: regex4).Capture.self
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
    let _: Substring.Type = type(of: unicodeData).Capture.self

    try forEachEngine { engine in
      let unicodeLine =
        "1BCA0..1BCA3  ; Control # Cf   [4] SHORTHAND FORMAT LETTER OVERLAP..SHORTHAND FORMAT UP STEP"
      let match = try XCTUnwrap(unicodeLine.match(unicodeData, using: engine))
      XCTAssertEqual(match.captures, "Control")
    }
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
    typealias Capture = (Substring, Substring?, Substring)
    let _: Capture.Type = type(of: regex).Capture.self
    func run<R: RegexProtocol>(
      _ regex: R
    ) throws where R.Capture == Capture {
      try forEachEngine { engine in
        let maybeMatchResult = line.match(regex, using: engine)
        let matchResult = try XCTUnwrap(maybeMatchResult)
        let (lower, upper, propertyString) = matchResult.captures
        XCTAssertEqual(lower, "A6F0")
        XCTAssertEqual(upper, "A6F1")
        XCTAssertEqual(propertyString, "Extend")
      }
    }
    let regexLiteral = try MockRegexLiteral(
        #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#,
        capturing: (Substring, Substring?, Substring).self)
    try run(regex)
    try run(regexLiteral)
  }

  func testDynamicCaptures() throws {
    let regex = try Regex(#"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#)
    let line = """
      A6F0..A6F1    ; Extend # Mn   [2] BAMUM COMBINING MARK KOQNDON..BAMUM COMBINING MARK TUKWENTIS
      """
    let captures = try XCTUnwrap(line.match(regex)?.captures)
    XCTAssertEqual(
        captures,
        .tuple([.substring("A6F0"), .optional(.substring("A6F1")), .substring("Extend")]))
  }
}
