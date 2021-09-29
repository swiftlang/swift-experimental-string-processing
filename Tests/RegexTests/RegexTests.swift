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
    && lhs.numCaptures == rhs.numCaptures
  }
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
    performTest("(?a|b)c", .leftParen, .question, "a", .pipe, "b", .rightParen, "c")

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
            "abc(de)+fghi*k|j" ->
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
    performTest("abc(de)+fghi*k|j",
                alt(concat("a", "b", "c",
                           .oneOrMore(.group(concat("d", "e"))),
                           "f", "g", "h", .many("i"), "k"),
                    "j"))
    performTest("a(b|c)?d", concat("a", .zeroOrOne(.group(alt("b", "c"))),
                                   "d"))
    performTest("a|b?c", alt("a", concat(.zeroOrOne("b"), "c")))
    performTest("(?a|b)c", concat(.capturingGroup(alt("a", "b")), "c"))
    performTest("(?.)*(?.*)", concat(.many(.capturingGroup(.any)), .capturingGroup(.many(.any))))

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
      _ list: RECode.Instruction..., labels: Array<Int> = [],
      numCaptures: Int = 0
    ) -> RECode {
      return RECode(instructions: list + [.accept],
                    labels: labels.map { InstructionAddress($0) }, splits: [],
                    numCaptures: numCaptures, options: .none)
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
    func cap(_ id: Int) -> RECode.Instruction {
      return .beginCapture(CaptureId(id))
    }
    func endCap(_ id: Int) -> RECode.Instruction {
      return .endCapture(CaptureId(id))
    }

    performTest("abc", recode("a", "b", "c"))
    performTest("abc\\+d*",
                recode("a", "b", "c", "+", label(0),
                       split(disfavoring: 1), "d", goto(label: 0),
                       label(1),
                       labels: [4, 8]))

    performTest("abc(de)+fghi*k|j",
                recode(split(disfavoring: 1), "a", "b", "c",
                       label(2), "d", "e",
                       split(disfavoring: 3), goto(label: 2),
                       label(3), "f", "g", "h",
                       label(4),
                       split(disfavoring: 5), "i", goto(label: 4),
                       label(5), "k", goto(label: 0),
                       label(1), "j",
                       label(0),
                       labels: [22, 20, 4, 9, 13, 17]))
    performTest("a(b|c)?d",
                recode("a",
                       split(disfavoring: 0),
                       split(disfavoring: 2), "b", goto(label: 1),
                       label(2), "c",
                       label(1),
                       label(0), "d",
                       labels: [8, 7, 5]))
    performTest("a(?b|c)?d",
                recode("a",
                       split(disfavoring: 0),
                       cap(0),
                       split(disfavoring: 2), "b", goto(label: 1),
                       label(2), "c",
                       label(1),
                       endCap(0),
                       label(0), "d",
                       labels: [10, 8, 6],
                       numCaptures: 1))
    //        performTest("a(?b|c)*",
    //                    recode("a",
    //                           cap(0),
    //                           labels: [8, 7, 5]
    //        ))
    performTest("(?a*)*",
                recode(label(0), split(disfavoring: 1), cap(0),
                       label(2), split(disfavoring: 3), "a", goto(label: 2),
                       label(3), endCap(0), goto(label: 0),
                       label(1),
                       labels: [0, 10, 3, 7], numCaptures: 1))
    performTest("(.*)*",
                recode(label(0), split(disfavoring: 1),
                       label(2), split(disfavoring: 3), .any, goto(label: 2),
                       label(3), goto(label: 0),
                       label(1),
                       labels: [0, 8, 2, 6], numCaptures: 0))
  }

  func testVMs() {
    let tests: Array<(String, pass: [String], fail: [String])> = [
      ("a|b", ["a", "b"], ["ab", "c"]),
      ("a.b", ["abb", "aab", "acb"], ["ab", "c", "abc"]),
      ("a|b?c", ["a", "c", "bc"], ["ab", "ac"]),
      ("abc*", ["abc", "ab", "abcc", "abccccc"], ["a", "c", "abca"]),
      ("abc+def", ["abcdef", "abccccccdef"], ["abc", "abdef"]),
      ("ab(cdef)*", ["ab", "abcdef", "abcdefcdefcdef"],
       ["abc", "cdef", "abcde", "abcdeff"]),
      ("ab(c|def)+", ["abc", "abdef", "abcdef", "abdefdefcdefc"],
       ["ab", "c", "abca"]),
      // Pathological (at least for HareVM and for now Tortoise too)
      //            ("(a*)*", ["a"], ["b"])
    ]

    // Singly nested capture tests
    let captureTests: Array<(String, input: String, captures: [String])> = [
      ("a(?b)c", "abc", ["b"]),
      ("a(?.)c", "axc", ["x"]),
      ("a(?b)c(?d)ef", "abcdef", ["b", "d"]),
      ("a(?b*)c(?d+)ef", "acddddef", ["", "dddd"]),
      ("a(?b*)c(?d+)ef", "abbcdef", ["bb", "d"]),
      //            ("(?a*)*", "aaaa", ["aaaa"]),
    ]

    // Nested capture tests
    let nestedCaptureTests: Array<(String, captures: [[String]])> = [
    ]
    _ = nestedCaptureTests

    func performTest(regex: String, input: String, expecting: Bool = true,
                     expectedCaptures: [[String]] = []) {
      let code = try! compile(regex)
      let lonesomeGeorge = TortoiseVM(code)
      let harvey = HareVM(code)
      func report(name: String,
                  _ output: (Bool, [[String]]),
                  _ expected: (Bool, [[String]])
      ) -> String {
        return """
                 \(name) failed
                 Regex:    \(regex)
                 Input:    \(input)
                 Expected: \(expected)
                 Saw: \(output)
                 """
      }
      let expected = (expecting, expectedCaptures)
      func run(_ vm: VirtualMachine) -> (Bool, [[String]]) {
        let result = vm.execute(input: input)
        let actualCaptures = result.1.map({ $0.asStrings(from: input) })
        return (result.0, actualCaptures)
      }

      let georgeRun = run(lonesomeGeorge)
      guard georgeRun.0 == expected.0 && georgeRun.1 == expected.1  else {
        XCTFail(report(name: "Lonesome George", georgeRun, expected))
        return
      }
      let harveyRun = run(harvey)
      guard harveyRun.0 == expected.0 && harveyRun.1 == expected.1  else {
        XCTFail(report(name: "Harvey", harveyRun, expected))
        return
      }

    }
    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(regex: regex, input: pass)
      }
      for fail in fails {
        performTest(regex: regex, input: fail, expecting: false)
      }
    }
    for (regex, input, captures) in captureTests {
      let caps = captures.map { Array($0) }
      performTest(regex: regex, input: input, expectedCaptures: caps)
    }
  }
}
