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
    // "Flat" because it will extract immediate children of
    // concatenations and alternations, but not recurse.
    //
    // Input should be a concatenation or alternation
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
    flatTest("a(?:b)", [/* "a",*/ "(?:b)"])
    flatTest("a|b|c|", [/* "a", "b", "c", */ ""])
    flatTest("a|(b)|", [/* "a", */ "(b)", ""])

    func renderTest(_ str: String, _ expected: [String]) {
      let lines = try! parse(
        str, .traditional
      )._render(in: str)
      guard lines.count == expected.count else {
        XCTFail("""
          expected:
            \(expected.joined(separator: "\n    "))
          saw:
            \(lines.joined(separator: "\n    "))
        """)
        return
      }
      for (e, l) in zip(expected, lines) {
        XCTAssertEqual(e, l)
      }
    }

    // AST constructors fake ranges, nothing to render
    XCTAssertEqual([], concat("a", "b")._render(in: "ab"))

    // FIXME: Atoms currently don't track locations
    renderTest("ab", [
            /* "^^", */
               "-^",
    ])

    // FIXME: Groups do, however
    // FIXME: This isn't an ideal leaf rendering...
    renderTest("a(b)c+(d(e))f(?:g)", [
           /*  "^^^ ^^^^^^  ^--^^ ", */
               " --^-^  --^       ",
               "       ---^       ",
               "      -----^ ----^", // should be  higher
               "-----------------^"
    ])
  }
}
