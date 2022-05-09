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
@testable import _RegexParser


extension CaptureList.Capture {
  static var cap: Self {
    return Self(optionalDepth: 0)
  }

  static var opt: Self {
    return Self(optionalDepth: 1)
  }
  static var opt_opt: Self {
    return Self(optionalDepth: 2)
  }
  static var opt_opt_opt: Self {
    return Self(optionalDepth: 3)
  }
  static var opt_opt_opt_opt: Self {
    return Self(optionalDepth: 4)
  }
  static var opt_opt_opt_opt_opt: Self {
    return Self(optionalDepth: 5)
  }
  static var opt_opt_opt_opt_opt_opt: Self {
    return Self(optionalDepth: 6)
  }

  static func named(_ name: String, opt: Int = 0) -> Self {
    return Self(name: name, optionalDepth: opt)
  }
}
extension CaptureList {
  static func caps(count: Int) -> Self {
    Self(Array(repeating: .cap, count: count))
  }
}

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
  _ expected: CaptureList,
  _ tests: (input: String, output: [StringCapture])...,
  skipEngine: Bool = false,
  file: StaticString = #file,
  line: UInt = #line
) {
  let ast = try! parse(regex, .semantic, .traditional)
  let capList = ast.root._captureList
  guard capList == expected else {
    XCTFail("""
      Expected:
      \(expected)
      Actual:
      \(capList)
      """,
      file: file,
      line: line)
    return
  }

  // Ensure DSLTree preserves literal captures
  let dslCapList = ast.dslTree.root._captureList
  guard dslCapList == capList else {
    XCTFail("""
      DSLTree did not preserve structure:
      AST:
      \(capList)
      DSLTree:
      \(dslCapList)
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
      [],
      ("abc", []))

    captureTest(
      "a(b)c",
      [.cap],
      ("abc", ["b"]))

    captureTest(
      "a(b*)c",
      [.cap],
      ("abc", ["b"]),
      ("ac", [""]),
      ("abbc", ["bb"]))

    captureTest(
      "a(b)*c",
      [.opt],
      ("abc", [.some("b")]),
      ("ac", [.none]),
      ("abbc", [.some("b")]))

    captureTest(
      "a(b)+c",
      [.cap],
      ("abc", ["b"]),
      ("abbc", ["b"]))

    captureTest(
      "a(b)?c",
      [.opt],
      ("ac", [.none]),
      ("abc", [.some("b")]))

    captureTest(
      "(a)(b)(c)",
      [.cap, .cap, .cap],
      ("abc", ["a", "b", "c"]))

    captureTest(
      "a|(b)",
      [.opt],
      ("a", [.none]),
      ("b", [.some("b")]))

    captureTest(
      "(a)|(b)",
      [.opt, .opt],
      ("a", [.some("a"), .none]),
      ("b", [.none, .some("b")]))

    captureTest(
      "((a)|(b))",
      [.cap, .opt, .opt],
      ("a", ["a", .some("a"), .none]),
      ("b", ["b", .none, .some("b")]))

    captureTest(
      "((a)|(b))?",
      [.opt, .opt_opt, .opt_opt],
      ("a", [.some("a"), .some(.some("a")), .some(.none)]),
      ("b", [.some("b"), .some(.none), .some(.some("b"))]))

    // FIXME
    captureTest(
      "((a)|(b))*",
      [.opt, .opt_opt, .opt_opt],
      ("a", [.some("a"), .some(.some("a")), .some(.none)]),
      skipEngine: true)

    // FIXME
    captureTest(
      "((a)|(b))+",
      [.cap, .opt, .opt],
      // TODO: test cases
      skipEngine: true)

    // FIXME
    captureTest(
      "(((a)|(b))*)",
      [.cap, .opt, .opt_opt, .opt_opt],
      // TODO: test cases
      skipEngine: true)

    // FIXME
    captureTest(
      "(((a)|(b))?)",
      [.cap, .opt, .opt_opt, .opt_opt],
      // TODO: test cases
      skipEngine: true)

    captureTest(
      "(a)",
      [.cap],
      ("a", ["a"]))

    captureTest(
      "((a))",
      [.cap, .cap],
      ("a", ["a", "a"]))

    captureTest(
      "(((a)))",
      [.cap, .cap, .cap],
      ("a", ["a", "a", "a"]))

    // FIXME
    captureTest(
      "((((a)*)?)*)?",
      [.opt, .opt_opt, .opt_opt_opt, .opt_opt_opt_opt],
      // TODO: test cases
      skipEngine: true)

    captureTest(
      "a|(b*)",
      [.opt],
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("bbb")]))

    // FIXME
    captureTest(
      "a|(b)*",
      [.opt_opt],
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]),
      skipEngine: true)

    // FIXME
    captureTest(
      "a|(b)+",
      [.opt],
      ("a", [.none]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]),
      skipEngine: true)

    // FIXME
    captureTest(
      "a|(b)?",
      [.opt_opt],
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some(.some("b"))]),
      skipEngine: true)

    captureTest(
      "a|(b|c)",
      [.opt],
      ("a", [.none]),
      ("b", [.some("b")]),
      ("c", [.some("c")]))

    captureTest(
      "a|(b*|c)",
      [.opt],
      ("a", [.none]),
      ("b", [.some("b")]),
      ("c", [.some("c")]))

    // FIXME
    captureTest(
      "a|(b|c)*",
      [.opt_opt],
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]),
      skipEngine: true)

    // FIXME
    captureTest(
      "a|(b|c)?",
      [.opt_opt],
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some(.some("b"))]),
      ("c", [.some(.some("c"))]),
      skipEngine: true)

    captureTest(
      "a(b(c))",
      [.cap, .cap],
      ("abc", ["bc", "c"]))

    captureTest(
      "a(b(c*))",
      [.cap, .cap],
      ("ab", ["b", ""]),
      ("abc", ["bc", "c"]),
      ("abcc", ["bcc", "cc"]))

    captureTest(
      "a(b(c)*)",
      [.cap, .opt],
      ("ab", ["b", .none]),
      ("abc", ["bc", .some("c")]),
      ("abcc", ["bcc", .some("c")]))

    captureTest(
      "a(b(c)?)",
      [.cap, .opt],
      ("ab", ["b", .none]),
      ("abc", ["bc", .some("c")]))

    captureTest(
      "a(b(c))*",
      [.opt, .opt],
      ("a", [.none, .none]),
      ("abc", [.some("bc"), .some("c")]),
      ("abcbc", [.some("bc"), .some("c")]))

    captureTest(
      "a(b(c))?",
      [.opt, .opt],
      ("a", [.none, .none]),
      ("abc", [.some("bc"), .some("c")]))

    //    TODO: "((a|b)*|c)*"
    //    TODO: "((a|b)|c)*"

  }

}


