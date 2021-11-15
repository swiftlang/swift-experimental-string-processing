import XCTest
@testable import Regex

extension Token: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .character(value, isEscaped: false)
  }
}
extension AST: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .character(value)
  }
}
extension CharacterClass.CharacterSetComponent: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .character(value)
  }
}

class RegexTests: XCTestCase {}

func lexTest(
  _ input: String,
  _ expecting: Token...,
  syntax: SyntaxOptions = .traditional
) {
  let toks = Lexer(Source(input, syntax))
  let actual = toks.filter(\.isSemantic)
  if !expecting.elementsEqual(actual) {
    // breakpoint
    XCTAssertEqual(expecting, actual)
  }
}

extension RegexTests {
  func testLex() {
    _ = """
        Note: Since everything's String-based, escape backslashes.
              Literal backslashes are thus double-escaped, i.e. "\\\\"
        Examples:
          "abc" -> ｢abc｣
          "abc\\+d*" -> ｢abc+d｣ star
          "abc(de)+fghi*k|j" ->
              ｢abc｣ lparen ｢de｣ rparen plus ｢fghi｣ star ｢k｣ pipe ｢j｣

        Gramatically invalid but lexically accepted examples:
          "|*\\\\" -> pipe star ｢\\｣
          ")ab(+" -> rparen ｢ab｣ lparen plus
        """
    func esc(_ c: Character) -> Token {
      .character(c, isEscaped: true)
    }

    // Gramatically valid
    lexTest(
      "abc", "a", "b", "c")
    lexTest(
      "ab\\c", "a", "b", esc("c"))
    lexTest(
      "abc\\+d*", "a", "b", "c", esc("+"), "d", .star)
    lexTest(
      "abc(de)+fghi*k|j",
      "a", "b", "c", .leftParen, "d", "e", .rightParen,
      .plus, "f", "g", "h", "i", .star, "k", .pipe, "j")
    lexTest(
      "a(b|c)?d",
      "a", .leftParen, "b", .pipe, "c", .rightParen, .question, "d")
    lexTest(
      "a|b?c", "a", .pipe, "b", .question, "c")
    lexTest(
      "(?:a|b)c",
      .leftParen, .question, .colon, "a", .pipe, "b",
      .rightParen, "c")
    lexTest(
      "a\\u0065b\\u{65}c\\x65d",
      "a", .unicodeScalar("e"),
      "b", .unicodeScalar("e"),
      "c", .unicodeScalar("e"), "d")
    lexTest(
      "[^a&&b--c~~d]",
      .leftSquareBracket, .caret, "a",
      .setOperator(.doubleAmpersand), "b",
      .setOperator(.doubleDash), "c",
      .setOperator(.doubleTilda), "d",
      .rightSquareBracket)
    lexTest(
      "&&^-^-~~",
      "&", "&", .caret, .minus, .caret, .minus, "~", "~")
    lexTest(
      "[]]&&",
      .leftSquareBracket, .rightSquareBracket,
      .rightSquareBracket, "&", "&")
    lexTest(
      "[]]&\\&",
      .leftSquareBracket, .rightSquareBracket,
      .rightSquareBracket, "&", esc("&"))

    // Gramatically invalid (yet lexically valid)
    lexTest(
      "|*\\\\", .pipe, .star, esc("\\"))
    lexTest(
      ")ab(+", .rightParen, "a", "b", .leftParen, .plus)
    lexTest(
      "...", .dot, .dot, .dot)
    lexTest(
      "[[[]&&]]&&",
      .leftSquareBracket, .leftSquareBracket,
      .leftSquareBracket, .rightSquareBracket,
      .setOperator(.doubleAmpersand), .rightSquareBracket,
      .rightSquareBracket, "&", "&")

    // TODO: Lex unit testing is probably better formulated
    // as parse tests. We might want a pull-based testing
    // harness instead of running it for the sequence of tokens.

    lexTest(
      #"a\Q .\Eb"#,
      "a", .startQuote, esc(" "), esc("."), .endQuote, "b")
    lexTest(
      #"a\Q \Q \\.\Eb"#,
      "a", .startQuote,
      esc(" "), esc("\\"), esc("Q"), esc(" "),
      esc("\\"), esc("\\"), esc("."),
      .endQuote, "b")

  }
}

func parseTest(
  _ input: String, _ expecting: AST,
  syntax: SyntaxOptions = .traditional
) {
  let orig = try! parse(input, syntax)
  let ast = orig.strippingTrivia!
  guard ast == expecting
          || ast._dump() == expecting._dump() // EQ workaround
  else {
    XCTFail("""

              Expected: \(expecting)
              Found:    \(ast)
              """)
    return
  }
}

extension RegexTests {
  func testParse() {
    _ = """
        Examples:
            "abc" -> .concat(｢abc｣)
            "abc\\+d*" -> .concat(｢abc+｣ .zeroOrMore(｢d｣))
            "abc(?:de)+fghi*k|j" ->
                .alt(.concat(｢abc｣, .oneOrMore(.group(.concat(｢de｣))),
                             ｢fgh｣ .zeroOrMore(｢i｣), ｢k｣),
                     ｢j｣)
        """

    func alt(_ asts: AST...) -> AST { return .alternation(asts) }
    func concat(_ asts: AST...) -> AST { return .concatenation(asts) }
    func charClass(
      _ comps: CharacterClass.CharacterSetComponent...,
      inverted: Bool = false
    ) -> AST {
      .characterClass(.custom(comps).withInversion(inverted))
    }
    func charClass(
      _ comps: CharacterClass.CharacterSetComponent...,
      inverted: Bool = false
    ) -> CharacterClass.CharacterSetComponent {
      .characterClass(.custom(comps).withInversion(inverted))
    }

    parseTest(
      "abc", concat("a", "b", "c"))
    parseTest(
      "abc\\+d*",
      concat("a", "b", "c", "+", .zeroOrMore(.greedy, "d")))
    parseTest(
      "a(b)", concat("a", .group(.capture(), "b")))
    parseTest(
      "abc(?:de)+fghi*k|j",
      alt(
        concat(
          "a", "b", "c",
          .oneOrMore(
            .greedy, .group(.nonCapture(), concat("d", "e"))),
          "f", "g", "h", .zeroOrMore(.greedy, "i"), "k"),
        "j"))
    parseTest(
      "a(?:b|c)?d",
      concat("a", .zeroOrOne(
        .greedy, .group(.nonCapture(), alt("b", "c"))), "d"))
    parseTest(
      "a?b??c+d+?e*f*?",
      concat(
        .zeroOrOne(.greedy, "a"), .zeroOrOne(.reluctant, "b"),
        .oneOrMore(.greedy, "c"), .oneOrMore(.reluctant, "d"),
        .zeroOrMore(.greedy, "e"), .zeroOrMore(.reluctant, "f")))
    parseTest(
      "a|b?c",
      alt("a", concat(.zeroOrOne(.greedy, "b"), "c")))
    parseTest(
      "(a|b)c",
      concat(.group(.capture(), alt("a", "b")), "c"))
    parseTest(
      "(.)*(.*)",
      concat(
        .zeroOrMore(
          .greedy, .group(.capture(), .characterClass(.any))),
        .group(
          .capture(), .zeroOrMore(.greedy, .characterClass(.any)))))
    parseTest(
      "abc\\d", concat("a", "b", "c", .characterClass(.digit)))
    parseTest(
      "a\\u0065b\\u{00000065}c\\x65d\\U00000065",
      concat("a", .unicodeScalar("e"),
             "b", .unicodeScalar("e"),
             "c", .unicodeScalar("e"),
             "d", .unicodeScalar("e")))

    parseTest(
      "[-|$^:?+*())(*-+-]",
      charClass(
        "-", "|", "$", "^", ":", "?", "+", "*", "(", ")", ")",
        "(", .range("*" ... "+"), "-"))

    parseTest(
      "[a-b-c]", charClass(.range("a" ... "b"), "-", "c"))

    // These are metacharacters in certain contexts, but normal characters
    // otherwise.
    parseTest(
      ":-]", concat(":", "-", "]"))

    parseTest(
      "[^abc]", charClass("a", "b", "c", inverted: true))
    parseTest(
      "[a^]", charClass("a", "^"))

    parseTest(
      "\\D\\S\\W",
      concat(.characterClass(.digit.inverted),
             .characterClass(.whitespace.inverted),
             .characterClass(.word.inverted)))

    parseTest(
      "[\\dd]", charClass(.characterClass(.digit), "d"))

    parseTest(
      "[^[\\D]]",
      charClass(charClass(.characterClass(.digit.inverted)),
                inverted: true))
    parseTest(
      "[[ab][bc]]",
      charClass(charClass("a", "b"), charClass("b", "c")))
    parseTest(
      "[[ab]c[de]]",
      charClass(charClass("a", "b"), "c", charClass("d", "e")))

    parseTest(
      "[[ab]&&[^bc]\\d]+",
      .oneOrMore(.greedy, charClass(
        .setOperation(
          lhs: charClass("a", "b"),
          op: .intersection,
          rhs: charClass("b", "c", inverted: true)
        ),
        .characterClass(.digit))))

    parseTest(
      "[a&&b]",
      charClass(
        .setOperation(lhs: "a", op: .intersection, rhs: "b")))

    // We left-associate for chained operators.
    parseTest(
      "[a&&b~~c]",
      charClass(
        .setOperation(
          lhs: .setOperation(lhs: "a", op: .intersection, rhs: "b"),
          op: .symmetricDifference,
          rhs: "c")))

    // Operators are only valid in custom character classes.
    parseTest(
      "a&&b", concat("a", "&", "&", "b"))
    parseTest(
      "&?", .zeroOrOne(.greedy, "&"))
    parseTest(
      "&&?", concat("&", .zeroOrOne(.greedy, "&")))
    parseTest(
      "--+", concat("-", .oneOrMore(.greedy, "-")))
    parseTest(
      "~~*", concat("~", .zeroOrMore(.greedy, "~")))

    // TODO: failure tests
  }

  func testParseErrors() {

    func performErrorTest(_ input: String, _ expecting: String) {
      //      // Quick pattern match against AST to extract error nodes
      //      let ast = parse2(input)
      //      print(ast)
    }

    performErrorTest("(", "")


  }

}

