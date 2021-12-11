@testable import _MatchingEngine
import _StringProcessing

import XCTest

extension RegexTests {

  func testUnit() {
    XCTAssert(_fakeRange.isFake)
    XCTAssert(group(.capture, "a").sourceRange.isFake)

    let ast = try! parse("(a)", .traditional)
    XCTAssert(ast.sourceRange.isReal)
  }

  func testRender() {
    // Test top-level source range tracking from an example
    func flatTest(_ str: String, _ expected: [String]) {
      guard let ast = try? parse(str, .traditional) else {
        XCTFail("Fail to parse: \(str)")
        return
      }
      let nodes = ast.children?.filter(\.sourceRange.isReal)
      let tracked = nodes?.map {
        String(str[$0.sourceRange])
      }
      XCTAssertEqual(expected, tracked)
    }

    // FIXME: We don't track atoms yet, but this at least
    // checks for groups and quantifiers
    flatTest("a(b)c", [/*"a",*/ "(b)" /*, "c" */])
    flatTest("a(b)c+", [/*"a",*/ "(b)", "c+"])
    flatTest("a*?b(c(d))", ["a*?", /*"b",*/ "(c(d))"])
    flatTest("[abc]*?d", ["[abc]*?" /*, "d"*/])

    func renderTest(_ str: String, _ expected: [String]) {
      let lines = try! parse(
        str, .traditional
      )._render(in: str)
      XCTAssertEqual(expected, lines)
    }

    // AST constructors fake ranges, nothing to render
    XCTAssertEqual([], concat("a", "b")._render(in: "ab"))

    // FIXME: Atoms currently don't track locations
    renderTest("ab", [])

    // FIXME: Groups do, however
    renderTest("a(b)c+(d(e))f", [
               " --^-^  --^  ",
               "      -----^ ",
    ])
  }

}
