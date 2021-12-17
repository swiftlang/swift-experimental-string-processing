@testable import _MatchingEngine
@testable import _StringProcessing

import XCTest

extension RegexTests {

  func testUnit() {
    XCTAssert(SourceLocation.fake.isFake)
    XCTAssert(group(.capture, "a").location.isFake)

    let ast = try! parse("(a)", .traditional)
    XCTAssert(ast.location.isReal)
  }

  func testRender() {
    // Test top-level source range tracking from an example
    // "Flat" because it will extract immediate children of
    // concatenations and alternations, but not recurse.
    //
    // Input should be a concatenation or alternation
    func flatTest(_ str: String, _ expected: [String]) {
      guard let ast = try? parse(str, .traditional) else {
        XCTFail("Fail to parse: \(str)")
        return
      }
      let nodes = ast.children?.filter(\.location.isReal)
      let tracked = nodes?.map {
        String(str[$0.location.range])
      }
      XCTAssertEqual(expected, tracked)
    }

    // FIXME: We don't track atoms yet, but this at least
    // checks for groups and quantifiers
    flatTest("a(b)c", ["a", "(b)" , "c"])
    flatTest("a(b)c+", ["a", "(b)", "c+"])
    flatTest("a*?b(c(d))", ["a*?", "b", "(c(d))"])
    flatTest("[abc]*?d", ["[abc]*?" , "d"])
    flatTest("a(?:b)", ["a", "(?:b)"])
    flatTest("a|b|c|", ["a", "b", "c", ""])
    flatTest("a|(b)|", ["a", "(b)", ""])

    func renderTest(_ str: String, _ expected: [String]) {
      let lines = try! parse(
        str, .traditional
      )._render(in: str)
      func fail() {
        XCTFail("""
          expected:
            \(expected.joined(separator: "\n    "))
          saw:
            \(lines.joined(separator: "\n    "))
        """)
      }
      guard lines.count == expected.count else {
        fail()
        return
      }
      for (e, l) in zip(expected, lines) {
        guard e.elementsEqual(l) else {
          fail()
          return
        }
      }
    }

    // AST constructors fake ranges, nothing to render
    XCTAssertEqual([], concat("a", "b")._render(in: "ab"))

    renderTest("ab", [
               "^^",
               "-^",
    ])

    renderTest("a(b)c+(d(e))f(?:gh)", [
               "^ ^ ^  ^ ^  ^   ^^ ",
               " --^-^  --^     -^ ",
               "       ---^  -----^",
               "      -----^       ",
               "------------------^"
    ])

    // TODO: Find out best way to test quantifier values

    // TODO: Find out way to render value-members of AST, not
    // just children
  }

  func testErrors() {
    // Note: These don't really "test" anything, but good to
    // see our output...
    print("\(ParseError.emptyProperty)")
    print("\(ParseError.expectedNumber("abc", kind: .decimal))")
    print("\(ParseError.expectedNumber("abc", kind: .hex))")
  }
}
