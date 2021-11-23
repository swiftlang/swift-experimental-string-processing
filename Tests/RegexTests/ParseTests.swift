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
    self = .atom(.char(value))
  }
}
extension Atom: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .char(value)
  }
}
extension CharacterClass.CharacterSetComponent: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .character(value)
  }
}
extension CustomCharacterClass.Member: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .atom(.char(value))
  }
}

class RegexTests: XCTestCase {}

func lexTest(
  _ input: String,
  _ expecting: [Token],
  syntax: SyntaxOptions = .traditional
) {
  let toks = Lexer(Source(input, syntax))
  let actual = toks.filter(\.isSemantic)
  if !expecting.elementsEqual(actual) {
    // breakpoint
    XCTAssertEqual(expecting, actual)
  }
}

func lexTest(
  _ input: String,
  _ expecting: Token...,
  syntax: SyntaxOptions = .traditional
) {
  lexTest(input, expecting, syntax: syntax)
}

extension RegexTests {
  func testLex() {
    _ = #"""
        Note: Since everything's String-based, use raw strings for backslashes.
        Examples:
          "abc" -> ｢abc｣
          #"abc\+d*"# -> ｢abc+d｣ star
          "abc(de)+fghi*k|j" ->
              ｢abc｣ lparen ｢de｣ rparen plus ｢fghi｣ star ｢k｣ pipe ｢j｣

        Gramatically invalid but lexically accepted examples:
          #"|*\\"# -> pipe star ｢\\｣
          ")ab(+" -> rparen ｢ab｣ lparen plus
        """#
    func esc(_ c: Character) -> Token {
      .character(c, isEscaped: true)
    }

    // Gramatically valid
    lexTest(
      "abc", "a", "b", "c")
    lexTest(
      #"ab\c"#, "a", "b", esc("c"))
    lexTest(
      #"abc\+d*"#, "a", "b", "c", esc("+"), "d", .star)
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
      .leftParen, .question, ":", "a", .pipe, "b",
      .rightParen, "c")
    lexTest(
      #"a\u0065b\u{65}c\x65d"#,
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
      "&", "&", .anchor(.lineStart), "-", .anchor(.lineStart), "-", "~", "~")
    lexTest(
      "[]]&&",
      .leftSquareBracket, .rightSquareBracket, "]", "&", "&")
    lexTest(
      #"[]]&\&"#,
      .leftSquareBracket, .rightSquareBracket, "]", "&", esc("&"))

    // Gramatically invalid (yet lexically valid)
    lexTest(
      #"|*\\"#, .pipe, .star, esc(#"\"#))
    lexTest(
      ")ab(+", .rightParen, "a", "b", .leftParen, .plus)
    lexTest(
      "...",
      .builtinCharClass(.any), .builtinCharClass(.any), .builtinCharClass(.any))
    lexTest(
      "[[[]&&]]&&",
      .leftSquareBracket, .leftSquareBracket,
      .leftSquareBracket, .rightSquareBracket,
      .setOperator(.doubleAmpersand), .rightSquareBracket,
      .rightSquareBracket, "&", "&")

    lexTest(#"$\A\B[\A\B$]"#, .anchor(.lineEnd), .anchor(.stringStart),
            .anchor(.nonWordBoundary), .leftSquareBracket, esc("A"), esc("B"),
            "$", .rightSquareBracket)

    let specialChars = [
      .tab, .carriageReturn, .formFeed, .bell, .escape, .newline
    ].map(Token.specialCharEscape)

    lexTest(#"\t\r\f\a\e\n[\t\r\f\a\e\n]"#,
            specialChars + [.leftSquareBracket] + specialChars +
            [.rightSquareBracket])

    // \b is a word boundary outside of a character class, otherwise it's
    // backspace.
    lexTest(#"[\b]\b"#, .leftSquareBracket, .specialCharEscape(.backspace),
            .rightSquareBracket, .anchor(.wordBoundary))
    lexTest(#"[\b"#, .leftSquareBracket, .specialCharEscape(.backspace))

    // '.' is a character class, but only outside a custom char class.
    lexTest(#"[.].\."#, .leftSquareBracket, ".", .rightSquareBracket,
            .builtinCharClass(.any), esc("."))

    // Valid both inside and outside a custom char class.
    let universalCharClasses = [
      .digit, .whitespace, .word, .horizontalWhitespace, .verticalWhitespace,
      .digit.inverted, .whitespace.inverted, .word.inverted,
      .horizontalWhitespace.inverted, .verticalWhitespace.inverted
    ].map(Token.builtinCharClass)

    lexTest(#"\d\s\w\h\v\D\S\W\H\V[\d\s\w\h\v\D\S\W\H\V]"#,
            universalCharClasses + [.leftSquareBracket] +
            universalCharClasses + [.rightSquareBracket])

    // Valid only outside a custom char class.
    lexTest(#"[\N\R\X]\N\R\X"#,
            .leftSquareBracket, esc("N"), esc("R"), esc("X"),
            .rightSquareBracket,
            .builtinCharClass(.newlineSequence.inverted),
            .builtinCharClass(.newlineSequence),
            .builtinCharClass(.anyGrapheme))
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
    _ = #"""
        Examples:
            "abc" -> .concat(｢abc｣)
            #"abc\+d*"# -> .concat(｢abc+｣ .zeroOrMore(｢d｣))
            "abc(?:de)+fghi*k|j" ->
                .alt(.concat(｢abc｣, .oneOrMore(.group(.concat(｢de｣))),
                             ｢fgh｣ .zeroOrMore(｢i｣), ｢k｣),
                     ｢j｣)
        """#

    func alt(_ asts: AST...) -> AST { return .alternation(asts) }
    func concat(_ asts: AST...) -> AST { return .concatenation(asts) }
    func charClass(
      _ members: CustomCharacterClass.Member...,
      inverted: Bool = false
    ) -> AST {
      let cc = CustomCharacterClass(
        start: inverted ? .inverted : .normal, members: members
      )
      return .customCharacterClass(cc)
    }
    func charClass(
      _ members: CustomCharacterClass.Member...,
      inverted: Bool = false
    ) -> CustomCharacterClass.Member {
      let cc = CustomCharacterClass(
        start: inverted ? .inverted : .normal, members: members
      )
      return .custom(cc)
    }
    func posixSet(
      _ set: Unicode.POSIXCharacterSet, inverted: Bool = false
    ) -> Atom {
      return .named(.init(inverted: inverted, set: set))
    }

    parseTest(
      "abc", concat("a", "b", "c"))
    parseTest(
      #"abc\+d*"#,
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
          .greedy, .group(.capture(), .any)),
        .group(
          .capture(), .zeroOrMore(.greedy, .any))))
    parseTest(
      #"abc\d"#,
      concat("a", "b", "c", .atom(.escaped(.decimalDigit))))
    parseTest(
      #"a\u0065b\u{00000065}c\x65d\U00000065"#,
      concat("a", .atom(.scalar("e")),
             "b", .atom(.scalar("e")),
             "c", .atom(.scalar("e")),
             "d", .atom(.scalar("e"))))

    parseTest(
      "[-|$^:?+*())(*-+-]",
      charClass(
        "-", "|", "$", "^", ":", "?", "+", "*", "(", ")", ")",
        "(", .range("*", "+"), "-"))

    parseTest(
      "[a-b-c]", charClass(.range("a", "b"), "-", "c"))

    parseTest("[-a-]", charClass("-", "a", "-"))

    parseTest("[a-z]", charClass(.range("a", "z")))

    parseTest("[a-d--a-c]", charClass(
      .setOperation([.range("a", "d")], .subtraction, [.range("a", "c")])
    ))

    parseTest("[-]", charClass("-"))

    // These are metacharacters in certain contexts, but normal characters
    // otherwise.
    parseTest(
      ":-]", concat(":", "-", "]"))

    parseTest(
      "[^abc]", charClass("a", "b", "c", inverted: true))
    parseTest(
      "[a^]", charClass("a", "^"))

    parseTest(
      #"\D\S\W"#,
      concat(
        .atom(.escaped(.notDecimalDigit)),
        .atom(.escaped(.notWhitespace)),
        .atom(.escaped(.notWordCharacter))))

    parseTest(
      #"[\dd]"#, charClass(.atom(.escaped(.decimalDigit)), "d"))

    parseTest(
      #"[^[\D]]"#,
      charClass(charClass(.atom(.escaped(.notDecimalDigit))),
                inverted: true))
    parseTest(
      "[[ab][bc]]",
      charClass(charClass("a", "b"), charClass("b", "c")))
    parseTest(
      "[[ab]c[de]]",
      charClass(charClass("a", "b"), "c", charClass("d", "e")))

    typealias POSIX = Atom.POSIXSet
    parseTest(#"[ab[:space:]\d[:^upper:]cd]"#,
              charClass("a", "b", .atom(posixSet(.space)),
                        .atom(.escaped(.decimalDigit)),
                        .atom(posixSet(.upper, inverted: true)), "c", "d"))

    parseTest("[[[:space:]]]",
              charClass(charClass(.atom(posixSet(.space)))))

    parseTest(
      #"[a[bc]de&&[^bc]\d]+"#,
      .oneOrMore(.greedy, charClass(
        .setOperation(
          ["a", charClass("b", "c"), "d", "e"],
          .intersection,
          [charClass("b", "c", inverted: true), .atom(.escaped(.decimalDigit))]
        ))))

    parseTest(
      "[a&&b]",
      charClass(
        .setOperation(["a"], .intersection, ["b"])))

    parseTest(
      "[abc--def]",
      charClass(.setOperation(["a", "b", "c"], .subtraction, ["d", "e", "f"])))

    // We left-associate for chained operators.
    parseTest(
      "[ab&&b~~cd]",
      charClass(
        .setOperation(
          [.setOperation(["a", "b"], .intersection, ["b"])],
          .symmetricDifference,
          ["c", "d"])))

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

    parseTest(
      #"a\Q .\Eb"#,
      concat("a", .quote(" ."), "b"))
    parseTest(
      #"a\Q \Q \\.\Eb"#,
      concat("a", .quote(#" \Q \\."#), "b"))

    parseTest(
      #"a(?#. comment)b"#,
      concat("a", "b"))

    parseTest(
      #"a{1,2}"#,
      .quantification(.range(.greedy, 1...2), "a"))
    parseTest(
      #"a{,2}"#,
      .quantification(.upToN(.greedy, 2), "a"))
    parseTest(
      #"a{1,}"#,
      .quantification(.nOrMore(.greedy, 1), "a"))
    parseTest(
      #"a{1}"#,
      .quantification(.exactly(.greedy, 1), "a"))
    parseTest(
      #"a{1,2}?"#,
      .quantification(.range(.reluctant, 1...2), "a"))

    // Named captures
    parseTest(
      #"a(?<label>b)c"#,
      concat("a", .namedCapture("label", "b"), "c"))
    parseTest(
      #"a(?'label'b)c"#,
      concat("a", .namedCapture("label", "b"), "c"))
    parseTest(
      #"a(?P<label>b)c"#,
      concat("a", .namedCapture("label", "b"), "c"))
    parseTest(
      #"a(?P<label>b)c"#,
      concat("a", .namedCapture("label", "b"), "c"))

    // Other groups
    parseTest(
      #"a(?:b)c"#,
      concat("a", .nonCapture("b"), "c"))
    parseTest(
      #"a(?|b)c"#,
      concat("a", .nonCaptureReset("b"), "c"))
    parseTest(
      #"a(?>b)c"#,
      concat("a", .atomicNonCapturing("b"), "c"))



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

