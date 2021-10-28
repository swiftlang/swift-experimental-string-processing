import XCTest
@testable import Regex
import Util

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
extension RECode.Instruction: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .character(value)
  }
}


extension RECode: Equatable {
  public static func ==(lhs: RECode, rhs: RECode) -> Bool {
    return lhs.instructions == rhs.instructions
    && lhs.labels == rhs.labels && lhs.options == rhs.options
  }
}

struct ExpectedPass {
  let input: String
  let range: Range<String.Index>
  let expected: String
  let expectedCaptures: [[String]]

  init(
    _ input: String,
    offsets: Offsets? = nil,
    expected: String,
    expectedCaptures: [[String]] = []
  ) {
    self.input = input
    self.range = input.flatmapOffsets(offsets)
    self.expected = expected
    self.expectedCaptures = expectedCaptures
  }
}


struct TestCase {
  let regex: String
  let pass: [ExpectedPass]
  let fail: [String]
  let range: Range<String.Index>
  let mode: MatchMode
  let expected: (String?, [[String]])

  init(regex: String, input: String) {
    fatalError()
  }
}

struct TestExpectation<CaptureValue> {
  let content: String?
  let captures: CaptureValue
  // A function that determines
  let capturesEqual: (CaptureValue, CaptureValue) -> Bool

  init(
    _ content: String? = nil,
    captures: CaptureValue,
    capturesEqual: @escaping (CaptureValue, CaptureValue) -> Bool
  ) {
    self.content = content
    self.captures = captures
    self.capturesEqual = capturesEqual
  }

  init(_ content: String? = nil) where CaptureValue == Void {
    self.content = content
    self.captures = ()
    self.capturesEqual = { _, _ in true }
  }

  func isExpectedCapture(_ actualCaptures: CaptureValue) -> Bool {
    capturesEqual(actualCaptures, captures)
  }

  func isExpectedContentIfSpecified(_ actualContent: Substring) -> Bool {
    return content.map { $0 == actualContent } ?? true
  }
}

func performTest<CaptureValue>(
  regex: String,
  input: String,
  offsets: Offsets? = nil,
  mode: MatchMode = .wholeString,
  expectedCaptureType: CaptureValue.Type,
  expecting expectation: TestExpectation<CaptureValue>?
) {
  let code = try! compile(regex)
  let lonesomeGeorge = TortoiseVM(code)
  let harvey = HareVM(code)
  func report(name: String,
              matchedRange: Range<String.Index>?,
              actualCaptures: Any?,
              expectedCaptures: CaptureValue?
  ) -> String {
    return """
      \(name) failed
      Regex:    \(regex)
      Input:    \(input)
      Matched range: \(String(describing: matchedRange))
      Matched content: \(matchedRange.map { "\"\(input[$0])\"" } ?? "none")
      Expected captures: \(expectedCaptures.map { "\"\($0)\": \(type(of: $0))" } ?? "none")
      Saw: \(actualCaptures.map { "\"\($0)\": \(type(of: $0))" } ?? "none")
      """
  }
  func run(_ vm: VirtualMachine, name: String) {
    let range = input.flatmapOffsets(offsets)
    let actualResult = vm.execute(input: input, in: range, mode)
    switch (actualResult, expectation) {
    case let (result?, expectation?) where CaptureValue.self != Void.self:
      guard expectation.isExpectedContentIfSpecified(input[result.range]),
            let actualCapture = result.captures.value as? CaptureValue,
            expectation.isExpectedCapture(actualCapture) else {
        XCTFail(report(
          name: name,
          matchedRange: result.range,
          actualCaptures: result.captures.value,
          expectedCaptures: expectation.captures))
        break
      }
    case (_?, nil), (nil, _?):
      XCTFail(report(
        name: name,
        matchedRange: actualResult?.range,
        actualCaptures: actualResult?.captures.value,
        expectedCaptures: expectation?.captures))
    default:
      break;
    }
  }
  run(lonesomeGeorge, name: "Lonesome George")
  run(harvey, name: "Harvey")
}

class RegexTests: XCTestCase {
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
    func performTest(_ input: String, _ expecting: Token...) {
      XCTAssertEqual(Array(Lexer(Source(input))), expecting)
    }

    // Gramatically valid
    performTest("abc", "a", "b", "c")
    performTest("abc\\+d*", "a", "b", "c", "+", "d", .star)
    performTest("abc(de)+fghi*k|j",
                "a", "b", "c", .leftParen, "d", "e", .rightParen, .plus,
                "f", "g", "h", "i", .star, "k", .pipe, "j")
    performTest("a(b|c)?d", "a",
                .leftParen, "b", .pipe, "c", .rightParen, .question, "d")
    performTest("a|b?c", "a", .pipe, "b", .question, "c")
    performTest("(?:a|b)c", .leftParen, .question, .colon, "a", .pipe, "b", .rightParen, "c")
    performTest("a\\u0065b\\u{65}c\\x65d",
                "a", .unicodeScalar("e"),
                "b", .unicodeScalar("e"),
                "c", .unicodeScalar("e"), "d")

    // Gramatically invalid (yet lexically valid)
    performTest("|*\\\\", .pipe, .star, "\\")
    performTest(")ab(+", .rightParen, "a", "b", .leftParen, .plus)
    performTest("...", .dot, .dot, .dot)
  }

  func testParse() {
    _ = """
        Examples:
            "abc" -> .concat(｢abc｣)
            "abc\\+d*" -> .concat(｢abc+｣ .many(｢d｣))
            "abc(?:de)+fghi*k|j" ->
                .alt(.concat(｢abc｣, .oneOrMore(.group(.concat(｢de｣))),
                             ｢fgh｣ .many(｢i｣), ｢k｣),
                     ｢j｣)
        """
    func performTest(_ input: String, _ expecting: AST) {
      let ast = try! parse(input)
      guard ast == expecting else {
        XCTFail("""

                  Expected: \(expecting)
                  Found:    \(ast)
                  """)

        return
      }
    }

    func alt(_ asts: AST...) -> AST { return .alternation(asts) }
    func concat(_ asts: AST...) -> AST { return .concatenation(asts) }

    performTest("abc", concat("a", "b", "c"))
    performTest("abc\\+d*", concat("a", "b", "c", "+", .many("d")))
    performTest("abc\\+d*?", concat("a", "b", "c", "+", .lazyMany("d")))
    performTest("abc(?:de)+fghi*k|j",
                alt(concat("a", "b", "c",
                           .oneOrMore(.group(concat("d", "e"))),
                           "f", "g", "h", .many("i"), "k"),
                    "j"))
    performTest("a(?:b|c)?d", concat("a", .zeroOrOne(.group(alt("b", "c"))),
                                   "d"))
    performTest("a|b?c", alt("a", concat(.zeroOrOne("b"), "c")))
    performTest("(a|b)c", concat(.capturingGroup(alt("a", "b")), "c"))
    performTest("(.)*(.*)", concat(.many(.capturingGroup(.characterClass(.any))), .capturingGroup(.many(.characterClass(.any)))))
    performTest("abc\\d",concat("a", "b", "c", .characterClass(.digit)))
    performTest("a\\u0065b\\u{00000065}c\\x65d\\U00000065",
                concat("a", .unicodeScalar("e"),
                       "b", .unicodeScalar("e"),
                       "c", .unicodeScalar("e"),
                       "d", .unicodeScalar("e")))

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

  func testCompile() {
    func performTest(_ input: String, _ expecting: RECode) {
      let recode = try! compile(input)
      guard recode == expecting else {
        XCTFail("""

                  Expected: \(expecting)
                  Found:    \(recode)
                  """)
        return
      }
    }

    func recode(
      _ list: RECode.Instruction..., labels: [Int] = [], splits: [Int] = []
    ) -> RECode {
      return RECode(instructions: list + [.accept],
                    labels: labels.map { InstructionAddress($0) },
                    splits: splits.map { InstructionAddress($0) },
                    options: .none)
    }
    func label(_ id: Int) -> RECode.Instruction {
      return .label(LabelId(id))
    }
    func split(disfavoring id: Int) -> RECode.Instruction {
      return .split(disfavoring: LabelId(id))
    }
    func goto(label id: Int) -> RECode.Instruction {
      return .goto(label: LabelId(id))
    }

    performTest("abc", recode("a", "b", "c"))
    performTest("abc\\+d*",
                recode("a", "b", "c", "+", label(0),
                       split(disfavoring: 1), "d", goto(label: 0),
                       label(1),
                       labels: [4, 8]))

    performTest("abc(?:de)+fghi*k|j",
                recode(split(disfavoring: 1),
                       .beginGroup,
                       "a", "b", "c",
                       .beginGroup,
                       label(2),
                       .beginGroup,
                       "d", "e",
                       .endGroup,
                       split(disfavoring: 3), goto(label: 2),
                       label(3),
                       .captureArray,
                       .endGroup,
                       "f", "g", "h",
                       label(4),
                       split(disfavoring: 5), "i", goto(label: 4),
                       label(5), "k",
                       .endGroup,
                       goto(label: 0),
                       label(1), "j",
                       label(0),
                       labels: [29, 27, 6, 13, 19, 23]))
    performTest("a(?:b|c)?d",
                recode(.beginGroup,
                       "a",
                       .beginGroup,
                       split(disfavoring: 0),
                       .beginGroup,
                       split(disfavoring: 3), "b",
                       goto(label: 2),
                       label(3), "c",
                       label(2),
                       .endGroup,
                       .captureSome,
                       .goto(label: 1),
                       label(0), .captureNil,
                       .label(1),
                       .endGroup,
                       "d",
                       .endGroup,
                       labels: [14, 16, 10, 8],
                       splits: [3, 5]))
    performTest("a(b|c)?d",
                recode(.beginGroup,
                       "a",
                       .beginGroup,
                       split(disfavoring: 0),
                       .beginCapture,
                       split(disfavoring: 3), "b", goto(label: 2),
                       label(3), "c",
                       label(2),
                       .endCapture(),
                       .captureSome,
                       goto(label: 1),
                       label(0),
                       .captureNil,
                       label(1),
                       .endGroup,
                       "d",
                       .endGroup,
                       labels: [14, 16, 10, 8],
                       splits: [3, 5]))
    performTest("a(b|c)*",
                recode(.beginGroup,
                       "a",
                       .beginGroup,
                       .label(0),
                       .split(disfavoring: 1),
                       .beginCapture,
                       .split(disfavoring: 3),
                       "b",
                       .goto(label: 2),
                       .label(3),
                       "c",
                       .label(2),
                       .endCapture(),
                       .goto(label: 0),
                       .label(1),
                       .captureArray,
                       .endGroup,
                       .endGroup,
                       labels: [3, 14, 11, 9],
                       splits: [4, 6]))
    performTest("(a*)*",
                recode(.beginGroup,
                       label(0), split(disfavoring: 1), .beginCapture,
                       label(2), split(disfavoring: 3), "a", goto(label: 2),
                       label(3), .endCapture(), goto(label: 0),
                       label(1),
                       .captureArray,
                       .endGroup,
                       labels: [1, 11, 4, 8], splits: [2, 5]))
    performTest("(?:.*)*",
                recode(.beginGroup,
                       label(0), split(disfavoring: 1),
                       .beginGroup,
                       label(2), split(disfavoring: 3), .characterClass(.any), goto(label: 2),
                       label(3),
                       .endGroup,
                       goto(label: 0),
                       label(1),
                       .captureArray,
                       .endGroup,
                       labels: [1, 11, 4, 8], splits: [2, 5]))
    performTest("a.*?b+",
                recode("a",
                       label(0), split(disfavoring: 1), goto(label: 2),
                       label(1), .characterClass(.any), goto(label: 0),
                       label(2),
                       label(3), "b", split(disfavoring: 4),
                       goto(label: 3), label(4),
                       labels: [1, 4, 7, 8, 12], splits: [2, 10]))
  }

  func testVMs() {
    let tests: Array<(String, pass: [String], fail: [String])> = [
      ("a|b", ["a", "b"], ["ab", "c"]),
      ("a.b", ["abb", "aab", "acb"], ["ab", "c", "abc"]),
      ("a|b?c", ["a", "c", "bc"], ["ab", "ac"]),
      ("abc*", ["abc", "ab", "abcc", "abccccc"], ["a", "c", "abca"]),
      ("abc*?", ["abc", "ab", "abcc", "abccccc"], ["a", "c", "abca"]),
      ("abc+def", ["abcdef", "abccccccdef"], ["abc", "abdef"]),
      ("ab(cdef)*", ["ab", "abcdef", "abcdefcdefcdef"],
       ["abc", "cdef", "abcde", "abcdeff"]),
      ("ab(c|def)+", ["abc", "abdef", "abcdef", "abdefdefcdefc"],
       ["ab", "c", "abca"]),
      
      ("a\\sb", ["a b"], ["ab", "a  b"]),
      ("a\\s+b", ["a b", "a    b"], ["ab", "a    c"]),
      ("a\\dbc", ["a1bc"], ["ab2", "a1b", "a11b2", "a1b22"]),
      ("a\\db\\dc", ["a1b3c"], ["ab2", "a1b", "a11b2", "a1b22"]),
      ("a\\d\\db\\dc", ["a12b3c"], ["ab2", "a1b", "a11b2", "a1b22"]),

      ("Caf\\u{65}\\u0301", ["Cafe\u{301}"], ["Café", "Cafe"]),
      ("Caf\\x65\\u0301", ["Cafe\u{301}"], ["Café", "Cafe"]),

      // Pathological (at least for HareVM and for now Tortoise too)
      //            ("(a*)*", ["a"], ["b"])
    ]

    // Matching tests
    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(
          regex: regex, input: pass, expectedCaptureType: Void.self, expecting: .init(pass))
      }
      for fail in fails {
        performTest(
          regex: regex, input: fail, expectedCaptureType: Void.self, expecting: nil)
      }
    }

    // Singly nested capture tests
    performTest(
      regex: "a(b)c", input: "abc",
      expectedCaptureType: Substring.self, expecting: .init(captures: "b", capturesEqual: ==))
    performTest(
      regex: "a(.)c", input: "axc",
      expectedCaptureType: Substring.self, expecting: .init(captures: "x", capturesEqual: ==))
    performTest(
      regex: "a(b)c(d)ef", input: "abcdef",
      expectedCaptureType: (Substring, Substring).self,
      expecting: .init(captures: ("b", "d"), capturesEqual: ==))
    performTest(
      regex: "a(b*)c(d+)ef", input: "acddddef",
      expectedCaptureType: (Substring, Substring).self,
      expecting: .init(captures: ("", "dddd"), capturesEqual: ==))
    performTest(regex: "a(b*)c(d+)ef", input: "abbcdef",
      expectedCaptureType: (Substring, Substring).self,
      expecting: .init(captures: ("bb", "d"), capturesEqual: ==))
    // performTest(regex: "(?a*)*", input: "aaaa",
    //   expectedCaptureType: Substring.self,
    //   expecting: .init(captures: "aaaa", capturesEqual: ==))
  }
  
  func testMatchLevel() {
    let tests: Array<(String, chars: [String], unicodes: [String])> = [
      ("..", ["e\u{301}e\u{301}"], ["e\u{301}"]),
    ]

    for (regex, characterInputs, scalarInputs) in tests {
      let code = try! compile(regex)
      let harvey = HareVM(code)
      
      let scalarCode = code.withMatchLevel(.unicodeScalar)
      let scalarHarvey = HareVM(scalarCode)
            
      for input in characterInputs {
        XCTAssertNotNil(harvey.execute(input: input))
        XCTAssertNil(scalarHarvey.execute(input: input))
      }

      for input in scalarInputs {
        XCTAssertNotNil(scalarHarvey.execute(input: input))
        XCTAssertNil(harvey.execute(input: input))
      }
    }
  }

  func testPartialMatches() {
    let tests: Array<(String, pass: [(String, matched: String)], fail: [String])> = [
      ("a+",
       pass: [("aaa", matched: "aaa"),
              ("ab", matched: "a"),
              ("aab", matched: "aa"),
              ("a", matched: "a"),
             ],
       fail: ["b", ""]),
      ("a|b",
       pass: [
        ("a", matched: "a"),
        ("ab", matched: "a"),
        ("ba", matched: "b"),
        ("bc", matched: "b"),
       ],
       fail: ["c", "d", ""]
      ),
      (".*a+", // greedy
       pass: [("  a  aaa", matched: "aaa"),
             ],
       fail: ["b", ""]),
      (".*?a+", // lazy
       pass: [("  a  aaa", matched: "a"),
             ],
       fail: ["b", ""]),
    ]

    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(
          regex: regex, input: pass.0, mode: .partialFromFront,
          expectedCaptureType: Void.self,
          expecting: .init(pass.matched))
      }
      for fail in fails {
        performTest(
          regex: regex, input: fail, mode: .partialFromFront,
          expectedCaptureType: Void.self,
          expecting: nil)
      }
    }
  }

  func testSubrangeMatches() {
    // whole subrange
    let tests: Array<
      (String,
       pass: [(String, offsets: (lower: Int, upper: Int), matched: String)],
       fail: [(String, offsets: (lower: Int, upper: Int))])
    > = [
      ("a",
       pass: [
        ("a", offsets: (0, 0), matched: "a"),
        ("ab", offsets: (0, -1), matched: "a"),
        ("ba", offsets: (1, 0), matched: "a"),
       ],
       fail: [
        ("a", offsets: (1, 0)),
        ("a", offsets: (0, -1)),
        ("ab", offsets: (1, 0)),
        ("ba", offsets: (0, -1)),
        ("ab", offsets: (0, 0)),
       ])
    ]

    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(
          regex: regex,
          input: pass.0,
          offsets: pass.offsets,
          mode: .wholeString,
          expectedCaptureType: Void.self,
          expecting: .init(pass.matched))
      }
      for fail in fails {
        performTest(
          regex: regex,
          input: fail.0,
          offsets: fail.offsets,
          mode: .wholeString,
          expectedCaptureType: Void.self,
          expecting: nil)
      }
    }

    // partial subrange from front
  }
}

