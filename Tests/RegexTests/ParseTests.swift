@testable import _MatchingEngine

import XCTest
@testable import _StringProcessing

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
extension CustomCharacterClass.Member: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .atom(.char(value))
  }
}


class RegexTests: XCTestCase {}

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
    parseTest(
      "abc", concat("a", "b", "c"))
    parseTest(
      #"abc\+d*"#,
      concat("a", "b", "c", "+", zeroOrMore(.greedy, "d")))
    parseTest(
      "a(b)", concat("a", capture("b")))
    parseTest(
      "abc(?:de)+fghi*k|j",
      alt(
        concat(
          "a", "b", "c",
          oneOrMore(
            .greedy, nonCapture(concat("d", "e"))),
          "f", "g", "h", zeroOrMore(.greedy, "i"), "k"),
        "j"))
    parseTest(
      "a(?:b|c)?d",
      concat("a", zeroOrOne(
        .greedy, nonCapture(alt("b", "c"))), "d"))
    parseTest(
      "a?b??c+d+?e*f*?",
      concat(
        zeroOrOne(.greedy, "a"), zeroOrOne(.reluctant, "b"),
        oneOrMore(.greedy, "c"), oneOrMore(.reluctant, "d"),
        zeroOrMore(.greedy, "e"), zeroOrMore(.reluctant, "f")))
    parseTest(
      "a|b?c",
      alt("a", concat(zeroOrOne(.greedy, "b"), "c")))
    parseTest(
      "(a|b)c",
      concat(capture(alt("a", "b")), "c"))
    parseTest(
      "(.)*(.*)",
      concat(
        zeroOrMore(.greedy, capture(.any)),
        capture(zeroOrMore(.greedy, .any))))
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
      oneOrMore(.greedy, charClass(
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
      "&?", zeroOrOne(.greedy, "&"))
    parseTest(
      "&&?", concat("&", zeroOrOne(.greedy, "&")))
    parseTest(
      "--+", concat("-", oneOrMore(.greedy, "-")))
    parseTest(
      "~~*", concat("~", zeroOrMore(.greedy, "~")))

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
      concat("a", namedCapture("label", "b"), "c"))
    parseTest(
      #"a(?'label'b)c"#,
      concat("a", namedCapture("label", "b"), "c"))
    parseTest(
      #"a(?P<label>b)c"#,
      concat("a", namedCapture("label", "b"), "c"))
    parseTest(
      #"a(?P<label>b)c"#,
      concat("a", namedCapture("label", "b"), "c"))

    // Other groups
    parseTest(
      #"a(?:b)c"#,
      concat("a", nonCapture("b"), "c"))
    parseTest(
      #"a(?|b)c"#,
      concat("a", nonCaptureReset("b"), "c"))
    parseTest(
      #"a(?>b)c"#,
      concat("a", atomicNonCapturing("b"), "c"))

    // MARK: Character names.
    parseTest(#"\N{abc}"#, .atom(.namedCharacter("abc")))
    parseTest(#"[\N{abc}]"#, charClass(.atom(.namedCharacter("abc"))))
    parseTest(#"\N{abc}+"#, .quantification(.oneOrMore(.greedy),
                                            .atom(.namedCharacter("abc"))))
    parseTest(#"\N {2}"#, concat(
      .atom(.escaped(.notNewline)), .quantification(.exactly(.greedy, 2), " ")
    ))

    // MARK: Character properties.

    parseTest(#"\p{L}"#,
              .atom(prop(.generalCategory(.letter))))
    parseTest(#"\p{gc=L}"#,
              .atom(prop(.generalCategory(.letter))))
    parseTest(#"\p{Lu}"#,
              .atom(prop(.generalCategory(.uppercaseLetter))))
    parseTest(#"\P{Cc}"#,
                .atom(prop(.generalCategory(.control), inverted: true)))
    parseTest(#"\P{Z}"#,
                .atom(prop(.generalCategory(.separator), inverted: true)))

    parseTest(#"[\p{C}]"#, charClass(.atom(prop(.generalCategory(.other)))))
    parseTest(#"\p{C}+"#, .quantification(.oneOrMore(.greedy),
                          .atom(prop(.generalCategory(.other)))))

    parseTest(#"\p{Lx}"#, .atom(prop(.other(key: nil, value: "Lx"))))
    parseTest(#"\p{gcL}"#, .atom(prop(.other(key: nil, value: "gcL"))))
    parseTest(#"\p{x=y}"#, .atom(prop(.other(key: "x", value: "y"))))

    // UAX44-LM3 means all of the below are equivalent.
    let lowercaseLetter = AST.atom(prop(.generalCategory(.lowercaseLetter)))
    parseTest(#"\p{ll}"#, lowercaseLetter)
    parseTest(#"\p{gc=ll}"#, lowercaseLetter)
    parseTest(#"\p{General_Category=Ll}"#, lowercaseLetter)
    parseTest(#"\p{General-Category=isLl}"#, lowercaseLetter)
    parseTest(#"\p{  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ g_ c =-  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ general ca-tegory =  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{- general category =  is__l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ general category -=  IS__l_ l  _ }"#, lowercaseLetter)

    parseTest(#"\p{Any}"#, .atom(prop(.any)))
    parseTest(#"\p{Assigned}"#, .atom(prop(.assigned)))
    parseTest(#"\p{ascii}"#, .atom(prop(.ascii)))
    parseTest(#"\p{isAny}"#, .atom(prop(.any)))

    parseTest(#"\p{sc=grek}"#, .atom(prop(.script(.greek))))
    parseTest(#"\p{sc=isGreek}"#, .atom(prop(.script(.greek))))
    parseTest(#"\p{Greek}"#, .atom(prop(.script(.greek))))
    parseTest(#"\p{isGreek}"#, .atom(prop(.script(.greek))))
    parseTest(#"\P{Script=Latn}"#, .atom(prop(.script(.latin), inverted: true)))
    parseTest(#"\p{script=zzzz}"#, .atom(prop(.script(.unknown))))
    parseTest(#"\p{ISscript=iszzzz}"#, .atom(prop(.script(.unknown))))
    parseTest(#"\p{scx=bamum}"#, .atom(prop(.scriptExtension(.bamum))))
    parseTest(#"\p{ISBAMUM}"#, .atom(prop(.script(.bamum))))

    parseTest(#"\p{alpha}"#, .atom(prop(.binary(.alphabetic))))
    parseTest(#"\p{DEP}"#, .atom(prop(.binary(.deprecated))))
    parseTest(#"\P{DEP}"#, .atom(prop(.binary(.deprecated), inverted: true)))
    parseTest(#"\p{alphabetic=True}"#, .atom(prop(.binary(.alphabetic))))
    parseTest(#"\p{emoji=t}"#, .atom(prop(.binary(.emoji))))
    parseTest(#"\p{Alpha=no}"#, .atom(prop(.binary(.alphabetic, value: false))))
    parseTest(#"\P{Alpha=no}"#, .atom(prop(.binary(.alphabetic, value: false), inverted: true)))
    parseTest(#"\p{isAlphabetic}"#, .atom(prop(.binary(.alphabetic))))
    parseTest(#"\p{isAlpha=isFalse}"#, .atom(prop(.binary(.alphabetic, value: false))))

    parseTest(#"\p{In_Runic}"#, .atom(prop(.onigurumaSpecial(.inRunic))))

    parseTest(#"\p{Xan}"#, .atom(prop(.pcreSpecial(.alphanumeric))))
    parseTest(#"\p{Xps}"#, .atom(prop(.pcreSpecial(.posixSpace))))
    parseTest(#"\p{Xsp}"#, .atom(prop(.pcreSpecial(.perlSpace))))
    parseTest(#"\p{Xuc}"#, .atom(prop(.pcreSpecial(.universallyNamed))))
    parseTest(#"\p{Xwd}"#, .atom(prop(.pcreSpecial(.perlWord))))

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

