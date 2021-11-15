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

  func testSwiftyQuotes() {
    func esc(_ c: Character) -> Token {
      .character(c, isEscaped: true)
    }

    lexTest(
      #"a\Q .\Eb"#,
      "a", .startQuote, esc(" "), esc("."), .endQuote, "b",
      syntax: .traditional)

    // If we're quoted, whitespace is quoted too
    lexTest(
      #"a\Q .\Eb"#,
      "a", .startQuote, esc(" "), esc("."), .endQuote, "b",
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
      quoteAST, syntax: .swiftyQuotes)
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

}
