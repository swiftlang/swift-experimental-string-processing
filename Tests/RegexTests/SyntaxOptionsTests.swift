@testable import Regex
import XCTest

private let dplus = AST.quantification(
  .oneOrMore(.greedy), .characterClass(.digit))
private let dotAST = AST.concatenation([
  dplus, ".", dplus, ".", dplus, ".", dplus])

extension RegexTests {

  func testSemanticWhitespace() {
    lexTest("a b", "a", " ", "b", syntax: .traditional)
    lexTest("a b", "a", "b", syntax: .nonSemanticWhitespace)

    parseTest(
      #"\d+\.\d+\.\d+\.\d+"#,
      dotAST, syntax: .traditional)
    parseTest(
      #" \d+ \. \d+ \. \d+ \. \d+ "#,
      dotAST, syntax: .modern)
  }
}
