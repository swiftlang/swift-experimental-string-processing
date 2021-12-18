import XCTest
@testable import _MatchingEngine
@testable import _StringProcessing

func matchTest(
  _ regex: String,
  input: String,
  match: String,
  syntax: SyntaxOptions = .traditional,
  enableTracing: Bool = false,
  dumpAST: Bool = false,
  xfail: Bool = false
) {
  do {
    var consumer = try RegexConsumer<String>(parsing: regex)
    consumer.vm.engine.enableTracing = enableTracing
    guard let range = input.firstRange(of: consumer) else {
      throw "expect xfail"
    }

    if xfail {
      XCTAssertNotEqual(String(input[range]), match)
    } else {
      XCTAssertEqual(String(input[range]), match)
    }
  } catch {
    XCTAssert(xfail)
    return
  }
}

extension RegexTests {
  func testMatch() {
    matchTest(
      "abc", input: "123abcxyz", match: "abc")
    matchTest(
      #"abc\+d*"#, input: "123abc+xyz", match: "abc+")
    matchTest(
      #"abc\+d*"#, input: "123abc+dddxyz", match: "abc+ddd")
    matchTest(
      "a(b)", input: "123abcxyz", match: "ab")
    matchTest(
      "abc(?:de)+fghi*k|j", input: "123abcdefghijxyz", match: "j")
    matchTest(
      "abc(?:de)+fghi*k|j", input: "123abcdedefghkxyz", match: "abcdedefghk")
    matchTest(
      "a(?:b|c)?d", input: "123adxyz", match: "ad")
    matchTest(
      "a(?:b|c)?d", input: "123abdxyz", match: "abd")
    matchTest(
      "a(?:b|c)?d", input: "123acdxyz", match: "acd")
    matchTest(
      "a?b??c+d+?e*f*?", input: "123abcdefxyz", match: "abcde")
    matchTest(
      "a?b??c+d+?e*f*?", input: "123bcddefxyz", match: "bcd")
    matchTest(
      "a|b?c", input: "123axyz", match: "a")
    matchTest(
      "a|b?c", input: "123bcxyz", match: "bc")
    matchTest(
      "(a|b)c", input: "123abcxyz", match: "bc")
    matchTest(
      "(.)*(.*)", input: "123abcxyz", match: "123abcxyz")
    matchTest(
      #"abc\d"#, input: "xyzabc123", match: "abc1")

    // MARK: Unicode scalars

    matchTest(
      #"a\u0065b\u{00000065}c\x65d\U00000065"#,
      input: "123aebecedexyz", match: "aebecede")

    matchTest(
      #"\u{00000000000000000000000000A}"#,
      input: "123\nxyz", match: "\n")
    matchTest(
      #"\x{00000000000000000000000000A}"#,
      input: "123\nxyz", match: "\n")
    matchTest(
      #"\o{000000000000000000000000007}"#,
      input: "123\u{7}xyz", match: "\u{7}")

    matchTest(#"\o{70}"#, input: "1238xyz", match: "8")
    matchTest(#"\0"#, input: "123\0xyz", match: "\0")
    matchTest(#"\01"#, input: "123\u{1}xyz", match: "\u{1}")
    matchTest(#"\070"#, input: "1238xyz", match: "8")
    matchTest(#"\07A"#, input: "123\u{7}Axyz", match: "\u{7}A")
    matchTest(#"\08"#, input: "123\08xyz", match: "\08")
    matchTest(#"\0707"#, input: "12387xyz", match: "87")

    // code point sequence
    matchTest(#"\u{61 62 63}"#, input: "123abcxyz", match: "abc", xfail: true)


    // MARK: Quotes

    matchTest(
      #"a\Q .\Eb"#,
      input: "123a .bxyz", match: "a .b", xfail: true)
    matchTest(
      #"a\Q \Q \\.\Eb"#,
      input: #"123a \Q \\.bxyz"#, match: #"a \Q \\.b"#, xfail: true)
    matchTest(
      #"\d\Q...\E"#,
      input: "Countdown: 3... 2... 1...", match: "3...", xfail: true)

    // MARK: Comments

    matchTest(
      #"a(?#comment)b"#, input: "123abcxyz", match: "ab")
    matchTest(
      #"a(?#. comment)b"#, input: "123abcxyz", match: "ab")

    // MARK: Quantification

    matchTest(
      #"a{1,2}"#, input: "123aaaxyz", match: "aa", xfail: true)
    matchTest(
      #"a{,2}"#, input: "123aaaxyz", match: "", xfail: true)
    matchTest(
      #"a{,2}x"#, input: "123aaaxyz", match: "aax", xfail: true)
    matchTest(
      #"a{,2}x"#, input: "123xyz", match: "x", xfail: true)
    matchTest(
      #"a{2,}"#, input: "123aaaxyz", match: "aaa", xfail: true)
    matchTest(
      #"a{1}"#, input: "123aaaxyz", match: "a")
    matchTest(
      #"a{1,2}?"#, input: "123aaaxyz", match: "a", xfail: true)
    matchTest(
      #"a{1,2}?x"#, input: "123aaaxyz", match: "aax", xfail: true)
  }

  func testMatchCharacterClasses() {
    // MARK: Character classes

    matchTest(#"abc\d"#, input: "xyzabc123", match: "abc1")

    matchTest(
      "[-|$^:?+*())(*-+-]", input: "123(abc)xyz", match: "(")
    matchTest(
      "[-|$^:?+*())(*-+-]", input: "123-abcxyz", match: "-")
    matchTest(
      "[-|$^:?+*())(*-+-]", input: "123^abcxyz", match: "^")

    matchTest(
      "[a-b-c]", input: "123abcxyz", match: "a")
    matchTest(
      "[a-b-c]", input: "123-abcxyz", match: "-")

    matchTest("[-a-]", input: "123abcxyz", match: "a")
    matchTest("[-a-]", input: "123-abcxyz", match: "-")

    matchTest("[a-z]", input: "123abcxyz", match: "a")
    matchTest("[a-z]", input: "123ABCxyz", match: "x")
    matchTest("[a-z]", input: "123-abcxyz", match: "a")

    // Character class subtraction
    matchTest("[a-d--a-c]", input: "123abcdxyz", match: "d")

    matchTest("[-]", input: "123-abcxyz", match: "-")

    // These are metacharacters in certain contexts, but normal characters
    // otherwise.
    matchTest(":-]", input: "123:-]xyz", match: ":-]")

    matchTest(
      "[^abc]", input: "123abcxyz", match: "1")
    matchTest(
      "[a^]", input: "123abcxyz", match: "a")

    matchTest(
      #"\D\S\W"#, input: "123ab-xyz", match: "ab-")

    matchTest(
      #"[\dd]"#, input: "xyzabc123", match: "1")
    matchTest(
      #"[\dd]"#, input: "xyzabcd123", match: "d")

    matchTest(
      #"[^[\D]]"#, input: "xyzabc123", match: "1")
    matchTest(
      "[[ab][bc]]", input: "123abcxyz", match: "a")
    matchTest(
      "[[ab][bc]]", input: "123cbaxyz", match: "c")
    matchTest(
      "[[ab]c[de]]", input: "123abcxyz", match: "a")
    matchTest(
      "[[ab]c[de]]", input: "123cbaxyz", match: "c")

    matchTest(
      #"[ab[:space:]\d[:^upper:]cd]"#,
      input: "123abcxyz", match: "1")
    matchTest(
      #"[ab[:space:]\d[:^upper:]cd]"#,
      input: "xyzabc123", match: "x")
    matchTest(
      #"[ab[:space:]\d[:^upper:]cd]"#,
      input: "XYZabc123", match: "a")
    matchTest(
      #"[ab[:space:]\d[:^upper:]cd]"#,
      input: "XYZ abc123", match: " ")

    matchTest("[[[:space:]]]", input: "123 abc xyz", match: " ")

    matchTest("[[:alnum:]]", input: "[[:alnum:]]", match: "a")
    matchTest("[[:blank:]]", input: "123\tabc xyz", match: "\t")

    matchTest(
      "[[:graph:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")
    matchTest(
      "[[:print:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: " ")

    matchTest(
      "[[:word:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")
    matchTest(
      "[[:xdigit:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")

    matchTest("[[:isALNUM:]]", input: "[[:alnum:]]", match: "a")
    matchTest("[[:AL_NUM:]]", input: "[[:alnum:]]", match: "a")

    // Unfortunately, scripts are not part of stdlib...
    matchTest(
      "[[:script=Greek:]]", input: "123αβγxyz", match: "α",
      xfail: true)

    // MARK: Operators

    matchTest(
      #"[a[bc]de&&[^bc]\d]+"#, input: "123bcdxyz", match: "d")

    // Empty intersection never matches, should this be a compile time error?
    // matchTest("[a&&b]", input: "123abcxyz", match: "")

    matchTest(
      "[abc--def]", input: "123abcxyz", match: "a")

    // We left-associate for chained operators.
    matchTest(
      "[ab&&b~~cd]", input: "123abcxyz", match: "b")
    matchTest(
      "[ab&&b~~cd]", input: "123acdxyz", match: "c") // this doesn't match NSRegularExpression's behavior

    // Operators are only valid in custom character classes.
    matchTest(
      "a&&b", input: "123a&&bcxyz", match: "a&&b")
    matchTest(
      "&?", input: "123a&&bcxyz", match: "")
    matchTest(
      "&&?", input: "123a&&bcxyz", match: "&&")
    matchTest(
      "--+", input: "123---xyz", match: "---")
    matchTest(
      "~~*", input: "123~~~xyz", match: "~~~")

    // MARK: Character names.

    matchTest(#"\N{ASTERISK}"#, input: "123***xyz", match: "*")
    matchTest(#"[\N{ASTERISK}]"#, input: "123***xyz", match: "*")
    matchTest(
      #"\N{ASTERISK}+"#, input: "123***xyz", match: "***")
    matchTest(
      #"\N {2}"#, input: "123  xyz", match: "3  ")

    matchTest(#"\N{U+2C}"#, input: "123,xyz", match: ",")
    matchTest(#"\N{U+1F4BF}"#, input: "123💿xyz", match: "💿")
    matchTest(#"\N{U+00001F4BF}"#, input: "123💿xyz", match: "💿")

    // MARK: Character properties.

    matchTest(#"\p{L}"#, input: "123abcXYZ", match: "a")
    matchTest(#"\p{gc=L}"#, input: "123abcXYZ", match: "a")
    matchTest(#"\p{Lu}"#, input: "123abcXYZ", match: "X")

    matchTest(
      #"\P{Cc}"#, input: "\n\n\nXYZ", match: "X")
    matchTest(
      #"\P{Z}"#, input: "   XYZ", match: "X")

    matchTest(#"[\p{C}]"#, input: "123\n\n\nXYZ", match: "\n")
    matchTest(#"\p{C}+"#, input: "123\n\n\nXYZ", match: "\n\n\n")

    // UAX44-LM3 means all of the below are equivalent.
    matchTest(#"\p{ll}"#, input: "123abcXYZ", match: "a")
    matchTest(#"\p{gc=ll}"#, input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{General_Category=Ll}"#, input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{General-Category=isLl}"#,
      input: "123abcXYZ", match: "a")
    matchTest(#"\p{  __l_ l  _ }"#, input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{ g_ c =-  __l_ l  _ }"#, input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{ general ca-tegory =  __l_ l  _ }"#,
      input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{- general category =  is__l_ l  _ }"#,
      input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{ general category -=  IS__l_ l  _ }"#,
      input: "123abcXYZ", match: "a")

    matchTest(#"\p{Any}"#, input: "123abcXYZ", match: "1")
    matchTest(#"\p{Assigned}"#, input: "123abcXYZ", match: "1")
    matchTest(#"\p{ascii}"#, input: "123abcXYZ", match: "1")
    matchTest(#"\p{isAny}"#, input: "123abcXYZ", match: "1")

    // Unfortunately, scripts are not part of stdlib...
    matchTest(
      #"\p{sc=grek}"#, input: "123αβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\p{sc=isGreek}"#, input: "123αβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\p{Greek}"#, input: "123αβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\p{isGreek}"#, input: "123αβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\P{Script=Latn}"#, input: "abcαβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\p{script=Greek}"#, input: "123αβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\p{ISscript=isGreek}"#, input: "123αβγxyz", match: "α",
      xfail: true)
    matchTest(
      #"\p{scx=bamum}"#, input: "123ꚠꚡꚢxyz", match: "ꚠ",
      xfail: true)
    matchTest(
      #"\p{ISBAMUM}"#, input: "123ꚠꚡꚢxyz", match: "ꚠ",
      xfail: true)

    matchTest(#"\p{alpha}"#, input: "123abcXYZ", match: "a")
    matchTest(#"\P{alpha}"#, input: "123abcXYZ", match: "1")
    matchTest(
      #"\p{alphabetic=True}"#, input: "123abcXYZ", match: "a")

    // This is actually available-ed...
    matchTest(
      #"\p{emoji=t}"#, input: "123💿xyz", match: "a",
      xfail: true)

    matchTest(#"\p{Alpha=no}"#, input: "123abcXYZ", match: "1")
    matchTest(#"\P{Alpha=no}"#, input: "123abcXYZ", match: "a")
    matchTest(#"\p{isAlphabetic}"#, input: "123abcXYZ", match: "a")
    matchTest(
      #"\p{isAlpha=isFalse}"#, input: "123abcXYZ", match: "1")

    // Oniguruma special support not in stdlib
    matchTest(
      #"\p{In_Runic}"#, input: "123ᚠᚡᚢXYZ", match: "ᚠ",
    xfail: true)

    // TODO: PCRE special
    matchTest(
      #"\p{Xan}"#, input: "[[:alnum:]]", match: "a",
      xfail: true)
    matchTest(
      #"\p{Xps}"#, input: "123 abc xyz", match: " ",
      xfail: true)
    matchTest(
      #"\p{Xsp}"#, input: "123 abc xyz", match: " ",
      xfail: true)
    matchTest(
      #"\p{Xuc}"#, input: "$var", match: "$",
      xfail: true)
    matchTest(
      #"\p{Xwd}"#, input: "[[:alnum:]]", match: "a",
      xfail: true)

    matchTest(#"\p{alnum}"#, input: "[[:alnum:]]", match: "a")
    matchTest(#"\p{is_alnum}"#, input: "[[:alnum:]]", match: "a")

    matchTest(#"\p{blank}"#, input: "123\tabc xyz", match: "\t")
    matchTest(
      #"\p{graph}"#,
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")

    matchTest(
      #"\p{print}"#,
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: " ")
    matchTest(
      #"\p{word}"#,
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")
    matchTest(
      #"\p{xdigit}"#,
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")

    matchTest("[[:alnum:]]", input: "[[:alnum:]]", match: "a")
    matchTest("[[:blank:]]", input: "123\tabc xyz", match: "\t")
    matchTest("[[:graph:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")
    matchTest("[[:print:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: " ")
    matchTest("[[:word:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")
    matchTest("[[:xdigit:]]",
      input: "\u{7}\u{1b}\u{a}\n\r\t abc", match: "a")
  }

  func testMatchGroups() {
    // MARK: Groups

    // Named captures
    matchTest(
      #"a(?<label>b)c"#, input: "123abcxyz", match: "abc")
    matchTest(
      #"a(?'label'b)c"#, input: "123abcxyz", match: "abc")
    matchTest(
      #"a(?P<label>b)c"#, input: "123abcxyz", match: "abc")

    // Other groups
    matchTest(
      #"a(?:b)c"#, input: "123abcxyz", match: "abc")
    matchTest(
      "(?|(a)|(b)|(c))", input: "123abcxyz", match: "a")

    matchTest(
      #"(?:a|.b)c"#, input: "123abcacxyz", match: "abc")
    matchTest(
      #"(?>a|.b)c"#, input: "123abcacxyz", match: "ac", xfail: true)
    matchTest(
      "(*atomic:a|.b)c", input: "123abcacxyz", match: "ac", xfail: true)
    matchTest(
      #"(?:a+)[a-z]c"#, input: "123aacacxyz", match: "aac")
    matchTest(
      #"(?>a+)[a-z]c"#, input: "123aacacxyz", match: "ac", xfail: true)

    matchTest(
      #"\d+(?= dollars)"#,
      input: "Price: 100 dollars", match: "100", xfail: true)
    matchTest(
      #"(?=\d+ dollars)\d+"#,
      input: "Price: 100 dollars", match: "100", xfail: true)
    matchTest(
      #"\d+(*pla: dollars)"#,
      input: "Price: 100 dollars", match: "100", xfail: true)
    matchTest(
      #"\d+(*positive_lookahead: dollars)"#,
      input: "Price: 100 dollars", match: "100", xfail: true)

    matchTest(
      #"\d+(?! dollars)"#,
      input: "Price: 100 pesos", match: "100", xfail: true)
    matchTest(
      #"(?!\d+ dollars)\d+"#,
      input: "Price: 100 pesos", match: "100", xfail: true)
    matchTest(
      #"\d+(*nla: dollars)"#,
      input: "Price: 100 pesos", match: "100", xfail: true)
    matchTest(
      #"\d+(*negative_lookahead: dollars)"#,
      input: "Price: 100 pesos", match: "100", xfail: true)

    matchTest(
      #"(?<=USD)\d+"#, input: "Price: USD100", match: "100", xfail: true)
    matchTest(
      #"(*plb:USD)\d+"#, input: "Price: USD100", match: "100", xfail: true)
    matchTest(
      #"(*positive_lookbehind:USD)\d+"#,
      input: "Price: USD100", match: "100", xfail: true)
    // engines generally enforce that lookbehinds are fixed width
    matchTest(
      #"\d{3}(?<=USD\d{3})"#, input: "Price: USD100", match: "100", xfail: true)

    matchTest(
      #"(?<!USD)\d+"#, input: "Price: JYP100", match: "100", xfail: true)
    matchTest(
      #"(*nlb:USD)\d+"#, input: "Price: JYP100", match: "100", xfail: true)
    matchTest(
      #"(*negative_lookbehind:USD)\d+"#,
      input: "Price: JYP100", match: "100", xfail: true)
    // engines generally enforce that lookbehinds are fixed width
    matchTest(
      #"\d{3}(?<!USD\d{3})"#, input: "Price: JYP100", match: "100", xfail: true)

    // TODO: Test example where non-atomic is significant
    matchTest(
      #"\d+(?* dollars)"#,
      input: "Price: 100 dollars", match: "100", xfail: true)
    matchTest(
      #"(?*\d+ dollars)\d+"#,
      input: "Price: 100 dollars", match: "100", xfail: true)
    matchTest(
      #"\d+(*napla: dollars)"#,
      input: "Price: 100 dollars", match: "100", xfail: true)
    matchTest(
      #"\d+(*non_atomic_positive_lookahead: dollars)"#,
      input: "Price: 100 dollars", match: "100", xfail: true)

    // TODO: Test example where non-atomic is significant
    matchTest(
      #"(?<*USD)\d+"#, input: "Price: USD100", match: "100", xfail: true)
    matchTest(
      #"(*naplb:USD)\d+"#, input: "Price: USD100", match: "100", xfail: true)
    matchTest(
      #"(*non_atomic_positive_lookbehind:USD)\d+"#,
      input: "Price: USD100", match: "100", xfail: true)
    // engines generally enforce that lookbehinds are fixed width
    matchTest(
      #"\d{3}(?<*USD\d{3})"#, input: "Price: USD100", match: "100", xfail: true)

    // https://www.effectiveperlprogramming.com/2019/03/match-only-the-same-unicode-script/
    matchTest(
      #"abc(*sr:\d+)xyz"#, input: "abc۵۲۸528੫੨੮xyz", match: "۵۲۸", xfail: true)
    matchTest(
      #"abc(*script_run:\d+)xyz"#,
      input: "abc۵۲۸528੫੨੮xyz", match: "۵۲۸", xfail: true)

    // TODO: Test example where atomic is significant
    matchTest(
      #"abc(*asr:\d+)xyz"#, input: "abc۵۲۸528੫੨੮xyz", match: "۵۲۸", xfail: true)
    matchTest(
      #"abc(*atomic_script_run:\d+)xyz"#,
      input: "abc۵۲۸528੫੨੮xyz", match: "۵۲۸", xfail: true)


  }

  func testMatchReferences() {
    // TODO: Implement backreference/subpattern matching.
    matchTest(#"(.)\1"#, input: "112", match: "11", xfail: true)
    matchTest(#"(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)\10"#,
              input: "aaaaaaaaabbc", match: "aaaaaaaaabb", xfail: true)
    matchTest(#"(.)\10"#, input: "a\u{8}b", match: "a\u{8}", xfail: true)

    matchTest(#"(.)\g001"#, input: "112", match: "11", xfail: true)
    matchTest(#"(.)(.)\g-02"#, input: "abac", match: "aba", xfail: true)
    matchTest(#"(?<a>.)(.)\k<a>"#, input: "abac", match: "aba", xfail: true)
    matchTest(#"\g'+2'(.)(.)"#, input: "abac", match: "aba", xfail: true)
  }
}

