@testable import _MatchingEngine
@testable import _StringProcessing
import XCTest


private let dplus = oneOrMore(
  .greedy, .atom(.escaped(.decimalDigit)))
private let dotAST = concat(
  dplus, ".", dplus, ".", dplus, ".", dplus)

extension RegexTests {

  func testSemanticWhitespace() {
    parseTest(
      #"\d+\.\d+\.\d+\.\d+"#,
      dotAST, syntax: .traditional)
    parseTest(
      #" \d+ \. \d+ \. \d+ \. \d+ "#,
      dotAST, syntax: .modern)

    parseTest(#"a b c"#, concat("a", " ", "b", " ", "c"), syntax: .traditional)
  }

  func testModernQuotes() {
//
//    lexTest(
//      #"a\Q .\Eb"#,
//      "a", .quote(" ."), "b",
//      syntax: .traditional)
//
//    // If we're quoted, whitespace is quoted too
//    lexTest(
//      #"a\Q .\Eb"#,
//      "a", .quote(" ."), "b",
//      syntax: .nonSemanticWhitespace)

    let quoteAST = concat(
      "a", quote(" ."), "b")
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

    parseTest(
      #"a{1,2}"#,
      quantRange(.greedy, 1...2, "a"))
    parseTest(
      #"a{1...2}"#,
      quantRange(.greedy, 1...2, "a"),
      syntax: .modernRanges)
    parseTest(
      #"a{1..<3}"#,
      quantRange(.greedy, 1...2, "a"),
      syntax: .modernRanges)

    parseTest(
      #"a{,2}"#,
      upToN(.greedy, 2, "a"))
    parseTest(
      #"a{...2}"#,
      upToN(.greedy, 2, "a"),
      syntax: .modern)
    parseTest(
      #"a{..<3}"#,
      upToN(.greedy, 2, "a"),
      syntax: .modern)

    parseTest(
      #"a{1,}"#,
      nOrMore(.greedy, 1, "a"))
    parseTest(
      #"a{1...}"#,
      nOrMore(.greedy, 1, "a"),
      syntax: .modern)
  }

  func testModernCaptures() {
    parseTest(
      #"a(?:b)c"#,
      concat("a", nonCapture("b"), "c"))
    parseTest(
      #"a(_:b)c"#,
      concat("a", nonCapture("b"), "c"),
      syntax: .modernCaptures)

    // TODO: `(name: .*)`
  }

  func testModernComments() {
//    lexTest(
//      #"(?#. network ) \d+ \. \d+"#,
//      .comment(" network "), esc("d"), .plus,
//      esc("."), esc("d"), .plus,
//      syntax: .nonSemanticWhitespace)
//    lexTest(
//      #"/* network */ \d+ \. \d+"#,
//      .comment(" network "), esc("d"), .plus,
//      esc("."), esc("d"), .plus,
//      syntax: .modern)
  }
}
