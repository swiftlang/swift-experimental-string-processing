@testable import _MatchingEngine

import XCTest
@testable import _StringProcessing

extension AST: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = _StringProcessing.atom(.char(value))
  }
}
extension AST.Atom: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = atom_a(.char(value))
  }
}
extension AST.CustomCharacterClass.Member: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = atom_m((.char(value)))
  }
}


class RegexTests: XCTestCase {}

func parseTest(
  _ input: String, _ expecting: AST,
  syntax: SyntaxOptions = .traditional
) {
  let orig = try! parse(input, syntax)
  let ast = orig//.strippingTrivia!
  guard ast == expecting
          || ast._dump() == expecting._dump() // EQ workaround
  else {
    XCTFail("""

              Expected: \(expecting._dump())
              Found:    \(ast._dump())
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
        zeroOrMore(.greedy, capture(atom(.any))),
        capture(zeroOrMore(.greedy, atom(.any)))))
    parseTest(
      #"abc\d"#,
      concat("a", "b", "c", escaped(.decimalDigit)))
    parseTest(
      #"a\u0065b\u{00000065}c\x65d\U00000065"#,
      concat("a", scalar("e"),
             "b", scalar("e"),
             "c", scalar("e"),
             "d", scalar("e")))

    parseTest(
      "[-|$^:?+*())(*-+-]",
      charClass(
        "-", "|", "$", "^", ":", "?", "+", "*", "(", ")", ")",
        "(", .range("*", "+"), "-"))

    parseTest(
      "[a-b-c]", charClass(.range("a", "b"), "-", "c"))

    parseTest("[-a-]", charClass("-", "a", "-"))

    parseTest("[a-z]", charClass(.range("a", "z")))

    // FIXME: AST builder helpers for custom char class types
    parseTest("[a-d--a-c]", charClass(
      .setOperation([.range("a", "d")], .init(faking: .subtraction), [.range("a", "c")])
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
        escaped(.notDecimalDigit),
        escaped(.notWhitespace),
        escaped(.notWordCharacter)))

    parseTest(
      #"[\dd]"#, charClass(atom_m(.escaped(.decimalDigit)), "d"))

    parseTest(
      #"[^[\D]]"#,
      charClass(charClass(atom_m(.escaped(.notDecimalDigit))),
                inverted: true))
    parseTest(
      "[[ab][bc]]",
      charClass(charClass("a", "b"), charClass("b", "c")))
    parseTest(
      "[[ab]c[de]]",
      charClass(charClass("a", "b"), "c", charClass("d", "e")))

    typealias POSIX = AST.Atom.POSIXSet
    parseTest(#"[ab[:space:]\d[:^upper:]cd]"#,
              charClass("a", "b", posixSet_m(.space),
                        atom_m(.escaped(.decimalDigit)),
                        posixSet_m(.upper, inverted: true), "c", "d"))

    parseTest("[[[:space:]]]",
              charClass(charClass(posixSet_m(.space))))

    parseTest(
      #"[a[bc]de&&[^bc]\d]+"#,
      oneOrMore(.greedy, charClass(
        .setOperation(
          ["a", charClass("b", "c"), "d", "e"],
          .init(faking: .intersection),
          [charClass("b", "c", inverted: true), atom_m(.escaped(.decimalDigit))]
        ))))

    parseTest(
      "[a&&b]",
      charClass(
        .setOperation(["a"], .init(faking: .intersection), ["b"])))

    parseTest(
      "[abc--def]",
      charClass(.setOperation(["a", "b", "c"], .init(faking: .subtraction), ["d", "e", "f"])))

    // We left-associate for chained operators.
    parseTest(
      "[ab&&b~~cd]",
      charClass(
        .setOperation(
          [.setOperation(["a", "b"], .init(faking: .intersection), ["b"])],
          .init(faking: .symmetricDifference),
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
      concat("a", quote(" ."), "b"))
    parseTest(
      #"a\Q \Q \\.\Eb"#,
      concat("a", quote(#" \Q \\."#), "b"))

    parseTest(
      #"a(?#. comment)b"#,
      concat("a", "b"))

    parseTest(
      #"a{1,2}"#,
      quantRange(.greedy, 1...2, "a"))
    parseTest(
      #"a{,2}"#,
      upToN(.greedy, 2, "a"))
    parseTest(
      #"a{2,}"#,
      nOrMore(.greedy, 2, "a"))
    parseTest(
      #"a{1}"#,
      exactly(.greedy, 1, "a"))
    parseTest(
      #"a{1,2}?"#,
      quantRange(.reluctant, 1...2, "a"))

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
    parseTest(#"\N{abc}"#, atom(.namedCharacter("abc")))
    parseTest(#"[\N{abc}]"#, charClass(atom_m(.namedCharacter("abc"))))
    parseTest(
      #"\N{abc}+"#,
      oneOrMore(.greedy,
                atom(.namedCharacter("abc"))))
    parseTest(
      #"\N {2}"#,
      concat(atom(.escaped(.notNewline)),
             exactly(.greedy, 2, " ")))

    // MARK: Character properties.

    parseTest(#"\p{L}"#,
              prop(.generalCategory(.letter)))
    parseTest(#"\p{gc=L}"#,
              prop(.generalCategory(.letter)))
    parseTest(#"\p{Lu}"#,
              prop(.generalCategory(.uppercaseLetter)))
    parseTest(#"\P{Cc}"#,
              prop(.generalCategory(.control), inverted: true))
    parseTest(#"\P{Z}"#,
              prop(.generalCategory(.separator), inverted: true))

    parseTest(#"[\p{C}]"#, charClass(prop_m(.generalCategory(.other))))
    parseTest(
      #"\p{C}+"#,
      oneOrMore(.greedy, prop(.generalCategory(.other))))

    parseTest(#"\p{Lx}"#, prop(.other(key: nil, value: "Lx")))
    parseTest(#"\p{gcL}"#, prop(.other(key: nil, value: "gcL")))
    parseTest(#"\p{x=y}"#, prop(.other(key: "x", value: "y")))

    // UAX44-LM3 means all of the below are equivalent.
    let lowercaseLetter = prop(.generalCategory(.lowercaseLetter))
    parseTest(#"\p{ll}"#, lowercaseLetter)
    parseTest(#"\p{gc=ll}"#, lowercaseLetter)
    parseTest(#"\p{General_Category=Ll}"#, lowercaseLetter)
    parseTest(#"\p{General-Category=isLl}"#, lowercaseLetter)
    parseTest(#"\p{  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ g_ c =-  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ general ca-tegory =  __l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{- general category =  is__l_ l  _ }"#, lowercaseLetter)
    parseTest(#"\p{ general category -=  IS__l_ l  _ }"#, lowercaseLetter)

    parseTest(#"\p{Any}"#, prop(.any))
    parseTest(#"\p{Assigned}"#, prop(.assigned))
    parseTest(#"\p{ascii}"#, prop(.ascii))
    parseTest(#"\p{isAny}"#, prop(.any))

    parseTest(#"\p{sc=grek}"#, prop(.script(.greek)))
    parseTest(#"\p{sc=isGreek}"#, prop(.script(.greek)))
    parseTest(#"\p{Greek}"#, prop(.script(.greek)))
    parseTest(#"\p{isGreek}"#, prop(.script(.greek)))
    parseTest(#"\P{Script=Latn}"#, prop(.script(.latin), inverted: true))
    parseTest(#"\p{script=zzzz}"#, prop(.script(.unknown)))
    parseTest(#"\p{ISscript=iszzzz}"#, prop(.script(.unknown)))
    parseTest(#"\p{scx=bamum}"#, prop(.scriptExtension(.bamum)))
    parseTest(#"\p{ISBAMUM}"#, prop(.script(.bamum)))

    parseTest(#"\p{alpha}"#, prop(.binary(.alphabetic)))
    parseTest(#"\p{DEP}"#, prop(.binary(.deprecated)))
    parseTest(#"\P{DEP}"#, prop(.binary(.deprecated), inverted: true))
    parseTest(#"\p{alphabetic=True}"#, prop(.binary(.alphabetic)))
    parseTest(#"\p{emoji=t}"#, prop(.binary(.emoji)))
    parseTest(#"\p{Alpha=no}"#, prop(.binary(.alphabetic, value: false)))
    parseTest(#"\P{Alpha=no}"#, prop(.binary(.alphabetic, value: false), inverted: true))
    parseTest(#"\p{isAlphabetic}"#, prop(.binary(.alphabetic)))
    parseTest(#"\p{isAlpha=isFalse}"#, prop(.binary(.alphabetic, value: false)))

    parseTest(#"\p{In_Runic}"#, prop(.onigurumaSpecial(.inRunic)))

    parseTest(#"\p{Xan}"#, prop(.pcreSpecial(.alphanumeric)))
    parseTest(#"\p{Xps}"#, prop(.pcreSpecial(.posixSpace)))
    parseTest(#"\p{Xsp}"#, prop(.pcreSpecial(.perlSpace)))
    parseTest(#"\p{Xuc}"#, prop(.pcreSpecial(.universallyNamed)))
    parseTest(#"\p{Xwd}"#, prop(.pcreSpecial(.perlWord)))

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

