
import XCTest
@testable import _StringProcessing
import _MatchingEngine

extension Capture: ExpressibleByStringLiteral {
  fileprivate init(_ s: String) {
    self = .atom(s[...])
  }
  public init(stringLiteral: String) {
    self.init(stringLiteral)
  }
}

// TODO: Move `flatCaptureTest`s over here too...

private func isEqual(_ lhs: Capture, _ rhs: Capture) -> Bool {
  switch (lhs, rhs) {
  case let (.atom(a), .atom(b)):
    // FIXME: Needed because "a" != "a"[...] existentially
    let lhsStr = String(describing: a)
    let rhsStr = String(describing: b)

    // :-(
    return lhsStr == rhsStr

  case let (.tuple(a), .tuple(b)):
    return zip(a, b).map(isEqual).all({$0})
  case let (.some(a), .some(b)):
    return isEqual(a, b)
  case let (.none(a), .none(b)):
    return a == b
  case let (.array(a, tA), .array(b, tB)):
    let contentsCompare = zip(a, b).map(isEqual).all({$0})
    return contentsCompare && tA == tB

  default: return false
  }
}

func compile(_ ast: AST) -> Executor {
  let tree = ast.dslTree
  let prog = try! Compiler(tree: tree).emit()
  let executor = Executor(program: prog)
  return executor
}

func captureTest(
  _ regex: String,
  _ expected: CaptureStructure,
  _ tests: (input: String, output: Capture)...,
  skipEngine: Bool = false,
  file: StaticString = #file,
  line: UInt = #line
) {

  let ast = try! parse(regex, .traditional)
  let capStructure = ast.captureStructure
  guard capStructure == expected else {
    XCTFail("""
        Expected:
        \(expected)
        Actual:
        \(capStructure)
        """,
        file: file,
        line: line)
    return
  }

  // Ensure DSLTree preserves literal captures
  let dslCapStructure = ast.dslTree.captureStructure
  guard dslCapStructure == capStructure else {
    XCTFail("""
      DSLTree did not preserve structure:
      AST:
      \(capStructure)
      DSLTree:
      \(dslCapStructure)
      """,
      file: file,
      line: line)
    return
  }

  let executor = compile(ast)
  if skipEngine {
    return
  }

  for (input, output) in tests {
    let inputRange = input.startIndex..<input.endIndex
    let (_, capFlat) = executor.executeFlat(
      input: input, in: inputRange, mode: .wholeString
    )!

    let cap = try! capStructure.structuralize(capFlat, input)

    guard isEqual(cap, output) else {
      XCTFail("""
          regex: \(regex), input: "\(input)"
          Structure:
          \(capStructure)
          Capture list:
          \(capFlat.latestUntyped(from: input))
          Expected:
          \(output)
          Actual:
          \(cap)
          """,
              file: file,
              line: line)
      continue
    }
  }
}

extension RegexTests {

  func testLiteralStructuredCaptures() throws {
    func some(_ c: Capture) -> Capture {
      .some(c)
    }

    func array(_ cs: Capture...) -> Capture {
      .array(cs, childType: Substring.self)
    }
    func someArray(_ cs: Capture...) -> Capture {
      .some(.array(cs, childType: Substring.self))
    }

    func tuple(_ ss: Capture...) -> Capture {
      .tuple(ss)
    }

    var none: Capture {
      .none(childType: Substring.self)
    }
    var noArray: Capture {
      .none(childType: [Substring].self)
    }
    var noOpt: Capture {
      .none(childType: Substring?.self)
    }

    captureTest(
      "abc",
      .empty,
      ("abc", .void))

    captureTest(
      "a(b)c",
      .atom(),
      ("abc", "b"))

    captureTest(
      "a(b*)c",
      .atom(),
      ("abc", "b"),
      ("ac", ""),
      ("abbc", "bb"))

    captureTest(
      "a(b)*c",
      .optional(.atom()),
      ("abc", some("b")),
      ("ac", none),
      ("abbc", some("b")))

    captureTest(
      "a(b)+c",
      .atom(),
      ("abc", "b"),
      ("abbc", "b"))

    captureTest(
      "a(b)?c",
      .optional(.atom()),
      ("ac", none),
      ("abc", some("b")))

    captureTest(
      "(a)(b)(c)",
      .tuple([.atom(),.atom(),.atom()]),
      ("abc", tuple("a", "b", "c")))

    captureTest(
      "a|(b)",
      .optional(.atom()),
      ("a", none),
      ("b", some("b")))

    captureTest(
      "(a)|(b)",
      .tuple(.optional(.atom()), .optional(.atom())),
      ("a", tuple(some("a"), none)),
      ("b", tuple(none, some("b"))))

    captureTest(
      "((a)|(b))",
      .tuple(.atom(), .optional(.atom()), .optional(.atom())),
      ("a", tuple("a", some("a"), none)),
      ("b", tuple("b", none, some("b"))))

    captureTest(
      "((a)|(b))?",
      .tuple(
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.atom()))),
      ("a", tuple(some("a"), some("a"), none)),
      ("b", tuple(some("b"), none, some("b"))))

    captureTest(
      "((a)|(b))*",
      .tuple(
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.atom()))),
      ("a", tuple(some("a"), some(some("a")), none)),
      skipEngine: true)

    captureTest(
      "((a)|(b))+",
      .tuple(
        .atom(),
        .optional(.atom()),
        .optional(.atom())),
      // TODO: test cases
      skipEngine: true)

    captureTest(
      "(((a)|(b))*)",
      .tuple(
        .atom(),
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.atom()))),
      // TODO: test cases
      skipEngine: true)


    captureTest(
      "(((a)|(b))?)",
      .tuple(
        .atom(),
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.atom()))),
      // TODO: test cases
      skipEngine: true)

    captureTest(
      "(a)",
      .atom(),
      ("a", "a"))

    captureTest(
      "((a))",
      .tuple([.atom(), .atom()]),
      ("a", tuple("a", "a")))

    captureTest(
      "(((a)))",
      .tuple([.atom(), .atom(), .atom()]),
      ("a", tuple("a", "a", "a")))


    // broke
    captureTest(
      "((((a)*)?)*)?",
      .tuple([
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.optional(.atom()))),
        .optional(.optional(.optional(.optional(.atom())))),
      ]),
      // TODO: test cases
      skipEngine: true)


    captureTest(
      "a|(b*)",
      .optional(.atom()),
      ("a", none),
      ("", some("")),
      ("b", some("b")),
      ("bbb", some("bbb")))

    captureTest(
      "a|(b)*",
      .optional(.optional(.atom())),
      ("a", none),
      ("", someArray()),
      ("b", someArray("b")),
      ("bbb", someArray("b", "b", "b")),
      skipEngine: true)

    captureTest(
      "a|(b)+",
      .optional(.atom()),
      ("a", noArray),
      ("b", someArray("b")),
      ("bbb", someArray("b", "b", "b")),
      skipEngine: true)

    captureTest(
      "a|(b)?",
      .optional(.optional(.atom())),
      ("a", noOpt),
      ("", noOpt),
      ("b", .some(some("b"))),
      skipEngine: true)

    captureTest(
      "a|(b|c)",
      .optional(.atom()),
      ("a", none),
      ("b", some("b")),
      ("c", some("c")))

    captureTest(
      "a|(b*|c)",
      .optional(.atom()),
      ("a", none),
      ("b", some("b")),
      ("c", some("c")))

    captureTest(
      "a|(b|c)*",
      .optional(.optional(.atom())),
      ("a", noArray),
      ("", noArray),
      ("b", someArray("b")),
      ("bbb", someArray("b", "b", "b")),
      skipEngine: true)

    captureTest(
      "a|(b|c)?",
      .optional(.optional(.atom())),
      ("a", noOpt),
      ("", noOpt),
      ("b", .some(some("b"))),
      ("c", .some(some("c"))),
      skipEngine: true)


    captureTest(
      "a(b(c))",
      .tuple(.atom(), .atom()),
      ("abc", tuple("bc", "c")))

    captureTest(
      "a(b(c*))",
      .tuple(.atom(), .atom()),
      ("ab", tuple("b", "")),
      ("abc", tuple("bc", "c")),
      ("abcc", tuple("bcc", "cc")))

    captureTest(
      "a(b(c)*)",
      .tuple(.atom(), .optional(.atom())),
      ("ab", tuple("b", none)),
      ("abc", tuple("bc", some("c"))),
      ("abcc", tuple("bcc", some("c"))))

    captureTest(
      "a(b(c)?)",
      .tuple(.atom(), .optional(.atom())),
      ("ab", tuple("b", none)),
      ("abc", tuple("bc", some("c"))))


    captureTest(
      "a(b(c))*",
      .tuple(.optional(.atom()), .optional(.atom())),
      ("a", tuple(none, none)),
      ("abc", tuple(some("bc"), some("c"))),
      ("abcbc", tuple(some("bc"), some("c"))))

    captureTest(
      "a(b(c))?",
      .tuple(.optional(.atom()), .optional(.atom())),
      ("a", tuple(none, none)),
      ("abc", tuple(some("bc"), some("c"))))

//    TODO: "((a|b)*|c)*"
//    TODO: "((a|b)|c)*"
  }

}


