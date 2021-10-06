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
    try forEachEngine { engine in
      let maybeMatch = "abc".match(using: engine) {
        "a"
        "b".capture()
        "c".capture()
      }
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [["b"], ["c"]])
    }
  }

  func testCharacterClasses() throws {
    try forEachEngine { engine in
      let maybeMatch = "a c".match(using: engine) {
        CharacterClass.any
        CharacterClass.whitespace.capture()
        "c".capture()
      }
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [[" "], ["c"]])
    }
  }

  func testCombinators() throws {
    try forEachEngine { engine in
      let maybeMatch = "aaaabccccdddk".match {
        "a".+
        OneOrMore("b").capture()
        Repeat("c").capture()
        "d".capture().*
        "e".?
        ("t" | "k").capture()
      }
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [["b"], ["cccc"], ["d", "d", "d"], ["k"]])
    }
  }

  func testNestedGroups() throws {
    try forEachEngine { engine in
      let maybeMatch = "aaaabccccddd".match(using: engine) {
        "a".+
        OneOrMore {
          OneOrMore("b").capture()
          Repeat("c").capture()
          "d".capture().*
          "e".?
        }.capture()
      }
      let match = try XCTUnwrap(maybeMatch)
      XCTAssertEqual(match.capturedSubstrings, [["bccccddd"], ["b"], ["cccc"], ["d", "d", "d"]])
    }
  }

  func testUnicodeScalarPostProcessing() throws {
    // FIXME: HareVM currently fails at assertion `assert(bunny.sp < input.endIndex)`.
    try forEachEngine(except: HareVM.self) { engine in
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

      let unicodeLine =
        "1BCA0..1BCA3  ; Control # Cf   [4] SHORTHAND FORMAT LETTER OVERLAP..SHORTHAND FORMAT UP STEP"
      let match = try XCTUnwrap(unicodeLine.match(unicodeData, using: engine))
      XCTAssertEqual(match.capturedSubstrings, [["Control"]])
    }
  }
}
