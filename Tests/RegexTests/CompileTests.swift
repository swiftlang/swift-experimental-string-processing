
@testable import _MatchingEngine
@testable import _StringProcessing

import XCTest

extension RegexTests {

  func testCompileQuantification() throws {

    // NOTE: While we might change how we compile
    // quantifications, they should be compiled equivalently
    // for different syntactic expressions.
    let equivalents: Array<[String]> = [
      ["a*", "a{0,}"],
      ["a+", "a{1,}"],
      ["a?", "a{0,1}", "a{,1}"],

      ["a*?", "a{0,}?"],
      ["a+?", "a{1,}?"],
      ["a??", "a{0,1}?", "a{,1}?"],

      ["a*+", "a{0,}+"],
      ["a++", "a{1,}+"],
      ["a?+", "a{0,1}+", "a{,1}+"],
    ]

    for row in equivalents {
      let progs = try row.map {
        try _compileRegex($0).engine.program
      }
      let ref = progs.first!
      for prog in progs.dropFirst() {
        XCTAssert(ref.instructions.elementsEqual(
          prog.instructions))

      }
    }
  }
}
