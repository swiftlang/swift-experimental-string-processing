//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@testable import _MatchingEngine
@testable import _StringProcessing
import XCTest


private let dplus = oneOrMore(
  of: atom(.escaped(.decimalDigit)))
private let dotAST = concat(
  dplus, ".", dplus, ".", dplus, ".", dplus)
private let dotASTQuoted = concat(
  dplus, quote("."), dplus, quote("."), dplus, quote("."), dplus)

extension RegexTests {

  func testSemanticWhitespace() {
    parseTest(
      #"\d+\.\d+\.\d+\.\d+"#,
      dotAST, syntax: .traditional)
    parseTest(
      #" \d+ \. \d+ \. \d+ \. \d+ "#,
      dotAST, syntax: .experimental)

    parseTest(#"a b c"#, concat("a", " ", "b", " ", "c"), syntax: .traditional)
  }

  func testExperimentalQuotes() {
    let quoteAST = concat(
      "a", quote(" ."), "b")
    parseTest(
      #"a\Q .\Eb"#,
      quoteAST, syntax: .traditional)
    parseTest(
      #"a \Q .\E b"#,
      quoteAST, syntax: .experimental)
    parseTest(
      #"a" ."b"#,
      quoteAST, syntax: .experimentalQuotes)
    parseTest(
      #"a " ." b"#,
      quoteAST, syntax: .experimental)

    parseTest(
      #" \d+ \. \d+ \. \d+ \. \d+ "#,
      dotAST, syntax: .experimental)
    parseTest(
      #" \d+ "." \d+ "." \d+ "." \d+ "#,
      dotASTQuoted, syntax: .experimental)
  }

  func testExperimentalRanges() {
    parseTest(
      #"a{1,2}"#,
      quantRange(1...2, of: "a"))
    parseTest(
      #"a{1...2}"#,
      quantRange(1...2, of: "a"),
      syntax: .experimentalRanges)
    parseTest(
      #"a{1..<3}"#,
      quantRange(1...2, of: "a"),
      syntax: .experimentalRanges)

    parseTest(
      #"a{,2}"#,
      upToN(2, of: "a"))
    parseTest(
      #"a{...2}"#,
      upToN(2, of: "a"),
      syntax: .experimental)
    parseTest(
      #"a{..<3}"#,
      upToN(2, of: "a"),
      syntax: .experimental)

    parseTest(
      #"a{1,}"#,
      nOrMore(1, of: "a"))
    parseTest(
      #"a{1...}"#,
      nOrMore(1, of: "a"),
      syntax: .experimental)
  }

  func testExperimentalCaptures() {
    parseTest(
      #"a(?:b)c"#,
      concat("a", nonCapture("b"), "c"))
    parseTest(
      #"a(_:b)c"#,
      concat("a", nonCapture("b"), "c"),
      syntax: .experimentalCaptures)

    // TODO: `(name: .*)`
  }

  func testExperimentalComments() {
//    lexTest(
//      #"(?#. network ) \d+ \. \d+"#,
//      .comment(" network "), esc("d"), .plus,
//      esc("."), esc("d"), .plus,
//      syntax: .nonSemanticWhitespace)
//    lexTest(
//      #"/* network */ \d+ \. \d+"#,
//      .comment(" network "), esc("d"), .plus,
//      esc("."), esc("d"), .plus,
//      syntax: .experimental)
//
//    // TODO: better trivia stuff
//    parseTest(
//      "(?#. comment)b",
//      concat(trivia(), "b")
//    )
  }
}
