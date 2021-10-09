import XCTest
@testable import RegexDSL
import Regex
import Util
import TestSupport

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
      "c".capture() // Substring
    }
    let _: (Character, Substring).Type = type(of: regex).CaptureValue.self
    try forEachEngine { engine in
      let maybeMatch = "abc".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [["b"], ["c"]])
    }
  }

  func testCharacterClasses() throws {
    let regex = Regex {
      CharacterClass.any
      CharacterClass.whitespace.capture() // Character
      "c".capture() // Substring
    }
    // Assert the inferred capture type.
    let _: (Character, Substring).Type = type(of: regex).CaptureValue.self
    try forEachEngine { engine in
      let maybeMatch = "a c".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [[" "], ["c"]])
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
    let _: ([Character], [Substring], [Character], Substring).Type
      = type(of: regex).CaptureValue.self
    try forEachEngine { engine in
      let maybeMatch = "aaaabccccdddk".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(
        match.capturedSubstrings,
        [["b"], ["cccc"], ["d", "d", "d"], ["k"]])
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
      }.capture()
    }
    // Assert the inferred capture type.
    let _: [([Substring], [Substring], [Substring])].Type = type(of: regex).CaptureValue.self
    try forEachEngine { engine in
      let maybeMatch = "aaaabccccddd".match(regex, using: engine)
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [["bccccddd"], ["b"], ["cccc"], ["d", "d", "d"]])
    }
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
    let _: [Character].Type = type(of: unicodeData).CaptureValue.self

    // FIXME: HareVM currently fails at assertion `assert(bunny.sp < input.endIndex)`.
    try forEachEngine(except: HareVM.self) { engine in
      let unicodeLine =
        "1BCA0..1BCA3  ; Control # Cf   [4] SHORTHAND FORMAT LETTER OVERLAP..SHORTHAND FORMAT UP STEP"
      let match = try XCTUnwrap(unicodeLine.match(unicodeData, using: engine))
      XCTAssertEqual(match.capturedSubstrings, [["Control"]])
    }
  }

  func testGraphemeBreakData() {
//    func graphemeBreakPropertyDataDSL(
//      forLine line: String
//    ) -> GraphemeBreakScalars? {
//      let capScalar = Regex {
//        OneOrMore(CharacterClass.hexDigit).capture()
//      }
//
//      let m = line.match( Regex {
//        OneOrMore(CharacterClass.hexDigit).capture()
//
//        Optionally {
//          ".."
//          OneOrMore(CharacterClass.hexDigit).capture()
//        }
//
//        OneOrMore(CharacterClass.whitespace)
//        ";"
//        OneOrMore(CharacterClass.whitespace)
//
//        OneOrMore(CharacterClass.word).capture()
//
//        Repeat(CharacterClass.anyCharacter)
//      })
//
//      return m?.captures.map {
//        (lower: Substring,
//         upper: Substring?,
//         property: Substring
//        ) -> GraphemeBreakScalars in
//        let lowerScalar = Unicode.Scalar(hex: lower)!
//        let upperScalar = upper != nil ? Unicode.Scalar(hex: upper!)! : lower
//        let property = Unicode.GraphemeBreakProperty(property)!
//        return GraphemeBreakScalars(
//          lowerScalar ... upperScalar, property)
//      }
//    }


    for line in graphemeBreakData.split(separator: "\n") {
      let line = String(line)

      XCTAssertEqual(
        graphemeBreakPropertyData(forLine: line),
        graphemeBreakPropertyData_consumers(forLine: line))

    }
  }
}
