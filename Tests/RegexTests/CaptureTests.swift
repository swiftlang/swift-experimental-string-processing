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

import XCTest
@testable @_spi(RegexBuilder) import _StringProcessing
import _MatchingEngine

extension StructuredCapture {
  func formatStringCapture(input: String) -> String {
    var res = String(repeating: "some(", count: someCount)
    if let r = self.storedCapture?.range {
      res += input[r]
    } else {
      res += "none"
    }
    res += String(repeating: ")", count: someCount)
    return res
  }
}

extension Sequence where Element == StructuredCapture {
  func formatStringCaptures(input: String) -> String {
    var res = "["
    res += self.map {
      $0.formatStringCapture(input: input)
    }.joined(separator: ", ")
    res += "]"
    return res
  }
}

struct StringCapture {
  var contents: String?
  var optionalCount: Int

  var someCount: Int {
    contents == nil ? optionalCount - 1 : optionalCount
  }

  static var none: Self {
    self.init(contents: nil, optionalCount: 1)
  }
  static func some(_ s: Self) -> Self {
    self.init(
      contents: s.contents, optionalCount: s.optionalCount+1)
  }
}

extension StringCapture: ExpressibleByStringLiteral {
  init(stringLiteral: String) {
    self.contents = stringLiteral
    self.optionalCount = 0
  }
}

extension StringCapture: CustomStringConvertible {
  var description: String {
    var res = String(repeating: "some(", count: someCount)
    if let s = self.contents {
      res += s
    } else {
      res += "none"
    }
    res += String(repeating: ")", count: someCount)
    return res
  }
}

extension StringCapture {
  func isEqual(
    to structCap: StructuredCapture,
    in input: String
  ) -> Bool {
    guard optionalCount == structCap.optionalCount else {
      return false
    }
    guard let r = structCap.storedCapture?.range else {
      return contents == nil
    }
    guard let s = contents else {
      return false
    }
    return input[r] == s
  }
}

// NOTE: These tests are not tests of type-construction logic
// (e.g. making sure we actually have the right number of
// Optional wrappers), because we test equivalence a little
// before that step.


// TODO: Move `flatCaptureTest`s over here too...

func compile(_ ast: AST) -> Executor {
  let tree = ast.dslTree
  let prog = try! Compiler(tree: tree).emit()
  let executor = Executor(program: prog)
  return executor
}

func captureTest(
  _ regex: String,
  _ expected: CaptureStructure,
  _ tests: (input: String, output: [StringCapture])...,
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

    guard let result = try! executor.dynamicMatch(
      input, in: inputRange, .wholeString
    ) else {
      XCTFail("No match")
      return
    }

    let caps = result.rawCaptures
    guard caps.count == output.count else {
      XCTFail("""
      Mismatch capture count:
      Expected:
      \(output)
      Seen:
      \(caps.formatStringCaptures(input: input))
      """)
      continue
    }

    guard output.elementsEqual(caps, by: {
      $0.isEqual(to: $1, in: input)
    }) else {
      XCTFail("""
      Mismatch capture count:
      Expected:
      \(output)
      Seen:
      \(caps.formatStringCaptures(input: input))
      """)
      continue
    }
  }
}

extension RegexTests {

  func testLiteralStructuredCaptures() throws {
    captureTest(
      "abc",
      .empty,
      ("abc", []))

    captureTest(
      "a(b)c",
      .atom(),
      ("abc", ["b"]))

    captureTest(
      "a(b*)c",
      .atom(),
      ("abc", ["b"]),
      ("ac", [""]),
      ("abbc", ["bb"]))

    captureTest(
      "a(b)*c",
      .optional(.atom()),
      ("abc", [.some("b")]),
      ("ac", [.none]),
      ("abbc", [.some("b")]))

    captureTest(
      "a(b)+c",
      .atom(),
      ("abc", ["b"]),
      ("abbc", ["b"]))

    captureTest(
      "a(b)?c",
      .optional(.atom()),
      ("ac", [.none]),
      ("abc", [.some("b")]))

    captureTest(
      "(a)(b)(c)",
      .tuple([.atom(),.atom(),.atom()]),
      ("abc", ["a", "b", "c"]))

    captureTest(
      "a|(b)",
      .optional(.atom()),
      ("a", [.none]),
      ("b", [.some("b")]))

    captureTest(
      "(a)|(b)",
      .tuple(.optional(.atom()), .optional(.atom())),
      ("a", [.some("a"), .none]),
      ("b", [.none, .some("b")]))

    captureTest(
      "((a)|(b))",
      .tuple(.atom(), .optional(.atom()), .optional(.atom())),
      ("a", ["a", .some("a"), .none]),
      ("b", ["b", .none, .some("b")]))

    captureTest(
      "((a)|(b))?",
      .tuple(
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.atom()))),
      ("a", [.some("a"), .some(.some("a")), .some(.none)]),
      ("b", [.some("b"), .some(.none), .some(.some("b"))]))

    captureTest(
      "((a)|(b))*",
      .tuple(
        .optional(.atom()),
        .optional(.optional(.atom())),
        .optional(.optional(.atom()))),
      ("a", [.some("a"), .some(.some("a")), .some(.none)]),
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
      ("a", ["a"]))

    captureTest(
      "((a))",
      .tuple([.atom(), .atom()]),
      ("a", ["a", "a"]))

    captureTest(
      "(((a)))",
      .tuple([.atom(), .atom(), .atom()]),
      ("a", ["a", "a", "a"]))


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
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("bbb")]))

    captureTest(
      "a|(b)*",
      .optional(.optional(.atom())),
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]),
      skipEngine: true)

    captureTest(
      "a|(b)+",
      .optional(.atom()),
      ("a", [.none]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]),
      skipEngine: true)

    captureTest(
      "a|(b)?",
      .optional(.optional(.atom())),
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some(.some("b"))]),
      skipEngine: true)

    captureTest(
      "a|(b|c)",
      .optional(.atom()),
      ("a", [.none]),
      ("b", [.some("b")]),
      ("c", [.some("c")]))

    captureTest(
      "a|(b*|c)",
      .optional(.atom()),
      ("a", [.none]),
      ("b", [.some("b")]),
      ("c", [.some("c")]))

    captureTest(
      "a|(b|c)*",
      .optional(.optional(.atom())),
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]),
      skipEngine: true)

    captureTest(
      "a|(b|c)?",
      .optional(.optional(.atom())),
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some(.some("b"))]),
      ("c", [.some(.some("c"))]),
      skipEngine: true)


    captureTest(
      "a(b(c))",
      .tuple(.atom(), .atom()),
      ("abc", ["bc", "c"]))

    captureTest(
      "a(b(c*))",
      .tuple(.atom(), .atom()),
      ("ab", ["b", ""]),
      ("abc", ["bc", "c"]),
      ("abcc", ["bcc", "cc"]))

    captureTest(
      "a(b(c)*)",
      .tuple(.atom(), .optional(.atom())),
      ("ab", ["b", .none]),
      ("abc", ["bc", .some("c")]),
      ("abcc", ["bcc", .some("c")]))

    captureTest(
      "a(b(c)?)",
      .tuple(.atom(), .optional(.atom())),
      ("ab", ["b", .none]),
      ("abc", ["bc", .some("c")]))


    captureTest(
      "a(b(c))*",
      .tuple(.optional(.atom()), .optional(.atom())),
      ("a", [.none, .none]),
      ("abc", [.some("bc"), .some("c")]),
      ("abcbc", [.some("bc"), .some("c")]))

    captureTest(
      "a(b(c))?",
      .tuple(.optional(.atom()), .optional(.atom())),
      ("a", [.none, .none]),
      ("abc", [.some("bc"), .some("c")]))

//    TODO: "((a|b)*|c)*"
//    TODO: "((a|b)|c)*"

  }

}


