import XCTest
@testable import _MatchingEngine
@testable import _StringProcessing
import Exercises

func matchTest(
  _ regex: String,
  input: String,
  match: String?,
  syntax: SyntaxOptions = .traditional,
  enableTracing: Bool = false,
  dumpAST: Bool = false,
  xfail: Bool = false,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  do {
    var consumer = try RegexConsumer<String>(parsing: regex)
    consumer.vm.engine.enableTracing = enableTracing
    guard let range = input.firstRange(of: consumer) else {
      if match == nil {
        return
      }
      throw "match not found for \(regex) in \(input)"
    }

    if xfail {
      XCTAssertNotEqual(String(input[range]), match, file: file, line: line)
    } else {
      XCTAssertEqual(String(input[range]), match, file: file, line: line)
    }
  } catch {
    if !xfail {
      XCTFail("\(error)", file: file, line: line)
    }
    return
  }
}

func matchTests(
  _ regex: String,
  _ tests: (input: String, match: String?)...,
  syntax: SyntaxOptions = .traditional,
  enableTracing: Bool = false,
  dumpAST: Bool = false,
  xfail: Bool = false
) {
  for (input, match) in tests {
    matchTest(
      regex,
      input: input,
      match: match,
      syntax: syntax,
      enableTracing: enableTracing,
      dumpAST: dumpAST,
      xfail: xfail)
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
      "(.)*(.*)", input: "123abcxyz", match: "123abcxyz")
    matchTest(
      #"abc\d"#, input: "xyzabc123", match: "abc1")

    // MARK: Alternations

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

    // Alternations with empty branches are permitted.
    matchTest("|", input: "ab", match: "")
    matchTest("(|)", input: "ab", match: "")
    matchTest("a|", input: "ab", match: "a")
    matchTest("a|", input: "ba", match: "")
    matchTest("|b", input: "ab", match: "")
    matchTest("|b", input: "ba", match: "")
    matchTest("|b|", input: "ab", match: "")
    matchTest("|b|", input: "ba", match: "")
    matchTest("a|b|", input: "ab", match: "a")
    matchTest("a|b|", input: "ba", match: "b")
    matchTest("a|b|", input: "ca", match: "")
    matchTest("||c|", input: "ab", match: "")
    matchTest("||c|", input: "cb", match: "")
    matchTest("|||", input: "ab", match: "")
    matchTest("a|||d", input: "bc", match: "")
    matchTest("a|||d", input: "abc", match: "a")
    matchTest("a|||d", input: "d", match: "")

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
      input: "123a .bxyz", match: "a .b")
    matchTest(
      #"a\Q \Q \\.\Eb"#,
      input: #"123a \Q \\.bxyz"#, match: #"a \Q \\.b"#)
    matchTest(
      #"\d\Q...\E"#,
      input: "Countdown: 3... 2... 1...", match: "3...")

    // MARK: Comments

    matchTest(
      #"a(?#comment)b"#, input: "123abcxyz", match: "ab")
    matchTest(
      #"a(?#. comment)b"#, input: "123abcxyz", match: "ab")
  }

  func testMatchQuantification() {
    // MARK: Quantification

    matchTest(
      #"a{1,2}"#, input: "123aaaxyz", match: "aa")
    matchTest(
      #"a{,2}"#, input: "123aaaxyz", match: "")
    matchTest(
      #"a{,2}x"#, input: "123aaaxyz", match: "aax")
    matchTest(
      #"a{,2}x"#, input: "123xyz", match: "x")
    matchTest(
      #"a{2,}"#, input: "123aaaxyz", match: "aaa")
    matchTest(
      #"a{1}"#, input: "123aaaxyz", match: "a")
    matchTest(
      #"a{1,2}?"#, input: "123aaaxyz", match: "a")
    matchTest(
      #"a{1,2}?x"#, input: "123aaaxyz", match: "aax")

    matchTest("a.*", input: "dcba", match: "a")

    matchTest("a*", input: "", match: "")
    matchTest("a*", input: "a", match: "a")
    matchTest("a*", input: "aaa", match: "aaa")

    matchTest("a*?", input: "", match: "")
    matchTest("a*?", input: "a", match: "")
    matchTest("a*?a", input: "aaa", match: "a")
    matchTest("xa*?x", input: "_xx__", match: "xx")
    matchTest("xa*?x", input: "_xax__", match: "xax")
    matchTest("xa*?x", input: "_xaax__", match: "xaax")

    matchTest("a+", input: "", match: nil)
    matchTest("a+", input: "a", match: "a")
    matchTest("a+", input: "aaa", match: "aaa")

    matchTest("a+?", input: "", match: nil)
    matchTest("a+?", input: "a", match: "a")
    matchTest("a+?a", input: "aaa", match: "aa")
    matchTest("xa+?x", input: "_xx__", match: nil)
    matchTest("xa+?x", input: "_xax__", match: "xax")
    matchTest("xa+?x", input: "_xaax__", match: "xaax")

    matchTest("a??", input: "", match: "")
    matchTest("a??", input: "a", match: "")
    matchTest("a??a", input: "aaa", match: "a")
    matchTest("xa??x", input: "_xx__", match: "xx")
    matchTest("xa??x", input: "_xax__", match: "xax")
    matchTest("xa??x", input: "_xaax__", match: nil)

    // Possessive .* will consume entire input
    matchTests(
      ".*+x",
      ("abc", nil), ("abcx", nil), ("", nil))

    matchTests(
      "a+b",
      ("abc", "ab"),
      ("aaabc", "aaab"),
      ("b", nil))
    matchTests(
      "a++b",
      ("abc", "ab"),
      ("aaabc", "aaab"),
      ("b", nil))
    matchTests(
      "a+?b",
      ("abc", "ab"),
      ("aaabc", "aaab"), // firstRange will match from front
      ("b", nil))

    matchTests(
      "a+a",
      ("babc", nil),
      ("baaabc", "aaa"),
      ("bb", nil))
    matchTests(
      "a++a",
      ("babc", nil),
      ("baaabc", nil),
      ("bb", nil))
    matchTests(
      "a+?a",
      ("babc", nil),
      ("baaabc", "aa"),
      ("bb", nil))


    matchTests(
      "a{2,4}a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", "aaa"),
      ("baaaaabc", "aaaaa"),
      ("baaaaaaaabc", "aaaaa"),
      ("bb", nil))
    matchTests(
      "a{,4}a",
      ("babc", "a"),
      ("baabc", "aa"),
      ("baaabc", "aaa"),
      ("baaaaabc", "aaaaa"),
      ("baaaaaaaabc", "aaaaa"),
      ("bb", nil))
    matchTests(
      "a{2,}a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", "aaa"),
      ("baaaaabc", "aaaaa"),
      ("baaaaaaaabc", "aaaaaaaa"),
      ("bb", nil))

    matchTests(
      "a{2,4}?a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", "aaa"),
      ("baaaaabc", "aaa"),
      ("baaaaaaaabc", "aaa"),
      ("bb", nil))
    matchTests(
      "a{,4}?a",
      ("babc", "a"),
      ("baabc", "a"),
      ("baaabc", "a"),
      ("baaaaabc", "a"),
      ("baaaaaaaabc", "a"),
      ("bb", nil))
    matchTests(
      "a{2,}?a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", "aaa"),
      ("baaaaabc", "aaa"),
      ("baaaaaaaabc", "aaa"),
      ("bb", nil))

    matchTests(
      "a{2,4}+a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", nil),
      ("baaaaabc", "aaaaa"),
      ("baaaaaaaabc", "aaaaa"),
      ("bb", nil))
    matchTests(
      "a{,4}+a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", nil),
      ("baaaaabc", "aaaaa"),
      ("baaaaaaaabc", "aaaaa"),
      ("bb", nil))
    matchTests(
      "a{2,}+a",
      ("babc", nil),
      ("baabc", nil),
      ("baaabc", nil),
      ("baaaaabc", nil),
      ("baaaaaaaabc", nil),
      ("bb", nil))


    matchTests(
      "(?:a{2,4}?b)+",
      ("aab", "aab"),
      ("aabaabaab", "aabaabaab"),
      ("aaabaaaabaabab", "aaabaaaabaab")
      // TODO: Nested reluctant reentrant example, xfailed
    )

    // TODO: After captures, easier to test these
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
  }

  func testCharacterProperties() {
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

  func testAssertions() {
    // MARK: Assertions
    matchTest(
      #"\d+(?= dollars)"#,
      input: "Price: 100 dollars", match: "100")
    matchTest(
      #"\d+(?= pesos)"#,
      input: "Price: 100 dollars", match: nil)
    matchTest(
      #"(?=\d+ dollars)\d+"#,
      input: "Price: 100 dollars", match: "100",
      xfail: true) // TODO

    matchTest(
      #"\d+(*pla: dollars)"#,
      input: "Price: 100 dollars", match: "100")
    matchTest(
      #"\d+(*positive_lookahead: dollars)"#,
      input: "Price: 100 dollars", match: "100")

    matchTest(
      #"\d+(?! dollars)"#,
      input: "Price: 100 pesos", match: "100")
    matchTest(
      #"\d+(?! dollars)"#,
      input: "Price: 100 dollars", match: "10")
    matchTest(
      #"(?!\d+ dollars)\d+"#,
      input: "Price: 100 pesos", match: "100")
    matchTest(
      #"\d+(*nla: dollars)"#,
      input: "Price: 100 pesos", match: "100")
    matchTest(
      #"\d+(*negative_lookahead: dollars)"#,
      input: "Price: 100 pesos", match: "100")

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
  }

  func testMatchAnchors() {
    // MARK: Anchors
    matchTests(
      #"^\d+"#,
      ("123", "123"),
      (" 123", nil),
      ("123 456", "123"),
      (" 123 \n456", "456"),
      (" \n123 \n456", "123"))

    matchTests(
      #"\d+$"#,
      ("123", "123"),
      (" 123", "123"),
      (" 123 \n456", "456"),
      (" 123\n456", "123"),
      ("123 456", "456"))

    matchTests(
      #"\A\d+"#,
      ("123", "123"),
      (" 123", nil),
      (" 123 \n456", nil),
      (" 123\n456", nil),
      ("123 456", "123"))

    matchTests(
      #"\d+\Z"#,
      ("123", "123"),
      (" 123", "123"),
      ("123\n", "123"),
      (" 123\n", "123"),
      (" 123 \n456", "456"),
      (" 123\n456", "456"),
      (" 123\n456\n", "456"),
      ("123 456", "456"))


    matchTests(
      #"\d+\z"#,
      ("123", "123"),
      (" 123", "123"),
      ("123\n", nil),
      (" 123\n", nil),
      (" 123 \n456", "456"),
      (" 123\n456", "456"),
      (" 123\n456\n", nil),
      ("123 456", "456"))

    matchTests(
      #"\d+\b"#,
      ("123", "123"),
      (" 123", "123"),
      ("123 456", "123"))
    matchTests(
      #"\d+\b\s\b\d+"#,
      ("123", nil),
      (" 123", nil),
      ("123 456", "123 456"))

    matchTests(
      #"\B\d+"#,
      ("123", "23"),
      (" 123", "23"),
      ("123 456", "23"))

    // TODO: \G and \K

    // TODO: Oniguruma \y and \Y

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
    matchTest(#"(.)\10"#, input: "a\u{8}b", match: "a\u{8}")

    matchTest(#"(.)\g001"#, input: "112", match: "11", xfail: true)
    matchTest(#"(.)(.)\g-02"#, input: "abac", match: "aba", xfail: true)
    matchTest(#"(?<a>.)(.)\k<a>"#, input: "abac", match: "aba", xfail: true)
    matchTest(#"\g'+2'(.)(.)"#, input: "abac", match: "aba", xfail: true)
  }
  
  func testAllMatches() throws {
    let line = """
      A6F0..A6F1    ; Extend # Mn   [2] BAMUM COMBINING MARK KOQNDON..BAMUM COMBINING MARK TUKWENTIS
      """

    let nonMatching = line.allMatches(Regex { "zZzZzZz" })
    XCTAssertFalse(nonMatching.hasElements())
    
    let regexLiteral = r(#"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+)"#).regex
       as Regex<Tuple3<Substring, Substring?, Substring>>
    
    let lineAll = line.allMatches(regexLiteral)
    XCTAssertEqual(lineAll.elementCount(), 1)
    
    let expectedMatchCount = 1364
    let expectedInitialCaptures: [(Substring, Substring?, Substring)] = [
      ("0600", "0605", "Prepend"),
      ("06DD", nil, "Prepend"),
      ("070F", nil, "Prepend"),
    ]
    
    let dataAll = graphemeBreakData.allMatches(regexLiteral)
    XCTAssertEqual(dataAll.elementCount(), expectedMatchCount)
    XCTAssertTrue(
      dataAll.prefix(expectedInitialCaptures.count).map(\.match.tuple)
        .elementsEqual(expectedInitialCaptures, by: ==))
    
    let endOfFirstMatch = dataAll.first(where: { _ in true })!.range.upperBound
    let dataFromSubstring = graphemeBreakData[endOfFirstMatch...]
      .allMatches(regexLiteral)
    XCTAssertEqual(dataFromSubstring.elementCount(), expectedMatchCount - 1)
    XCTAssertTrue(
      dataFromSubstring.prefix(expectedInitialCaptures.count - 1).map(\.match.tuple)
        .elementsEqual(expectedInitialCaptures.dropFirst(), by: ==))

    let digitsOrX = r(#"\d*|x"#).regex as Regex<Substring>
    let digitsOrXString = "x1"
    
    let allDigitsOrX = digitsOrXString.allMatches(digitsOrX)
    XCTAssertEqual(allDigitsOrX.elementCount(), 3)
    XCTAssertEqual(
      allDigitsOrX.map { digitsOrXString[$0.range] },
      ["",    // empty range before 'x'
       "1",   // the '1' digit
       ""     // empty range after '1'
      ])
    // With the Perl approach to advancing after empty matches, this yields:
    //   ["",    // empty range before 'x'
    //    "x",
    //    "1",
    //    ""     // empty range after '1'
    //   ]
  }

}

