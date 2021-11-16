@testable import Regex
import XCTest

private func esc(_ c: Character) -> Token {
  .character(c, isEscaped: true)
}


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

  func testModernQuotes() {

    lexTest(
      #"a\Q .\Eb"#,
      "a", .quote(" ."), "b",
      syntax: .traditional)

    // If we're quoted, whitespace is quoted too
    lexTest(
      #"a\Q .\Eb"#,
      "a", .quote(" ."), "b",
      syntax: .nonSemanticWhitespace)

    func concat(_ asts: AST...) -> AST { return .concatenation(asts) }
    let quoteAST = concat(
      "a", .quote(" ."), "b")
    parseTest(
      #"a\Q .\Eb"#,
      quoteAST, syntax: .traditional)
    parseTest(
      #"a \Q .\E b"#,
      quoteAST, syntax: .modern)
    parseTest(
      #"a" ."b"#,
      quoteAST, syntax: .modernQuotes)
    parseTest(
      #"a " ." b"#,
      quoteAST, syntax: .modern)

    parseTest(
      #" \d+ \. \d+ \. \d+ \. \d+ "#,
      dotAST, syntax: .modern)
    parseTest(
      #" \d+ "." \d+ "." \d+ "." \d+ "#,
      dotAST, syntax: .modern)
  }

  func testModernComments() {
    lexTest(
      #"(?#. network ) \d+ \. \d+"#,
      .comment(" network "), esc("d"), .plus,
      esc("."), esc("d"), .plus,
      syntax: .nonSemanticWhitespace)
    lexTest(
      #"/* network */ \d+ \. \d+"#,
      .comment(" network "), esc("d"), .plus,
      esc("."), esc("d"), .plus,
      syntax: .modern)
  }
}
