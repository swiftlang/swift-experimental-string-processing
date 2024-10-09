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
    return Self(optionalDepth: 0, visibleInTypedOutput: true, .fake)
  }

  static var opt: Self {
    return Self(optionalDepth: 1, visibleInTypedOutput: true, .fake)
  }

  static func named(_ name: String, opt: Int = 0) -> Self {
    return Self(name: name, optionalDepth: opt, visibleInTypedOutput: true, .fake)
  }
}
extension CaptureList {
  static func caps(count: Int) -> Self {
    Self(Array(repeating: .cap, count: count))
  }

  var withoutLocs: Self {
    var copy = self
    for idx in copy.captures.indices {
      copy.captures[idx].location = .fake
    }
    return copy
  }
}

extension AnyRegexOutput.Element {
  func formatStringCapture(input: String) -> String {
    var res = String(repeating: "some(", count: representation.optionalDepth)
    if let r = range {
      res += input[r]
    } else {
      res += "none"
    }
    res += String(repeating: ")", count: representation.optionalDepth)
    return res
  }
}

extension AnyRegexOutput {
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
    to structCap: AnyRegexOutput.Element,
    in input: String
  ) -> Bool {
    guard optionalCount == structCap.representation.optionalDepth else {
      return false
    }
    guard let r = structCap.range else {
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

func compile(_ ast: AST) -> MEProgram {
  try! Compiler(tree: ast.dslTree).emit()
}

func captureTest(
  _ regex: String,
  _ expected: CaptureList,
  _ tests: (input: String, output: [StringCapture])...,
  skipEngine: Bool = false,
  file: StaticString = #file,
  line: UInt = #line
) {
  let ast = try! parse(regex, .traditional)
  var capList = ast.captureList.withoutLocs
  // Peel off the whole match element.
  capList.captures.removeFirst()
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
  var dslCapList = ast.dslTree.captureList
  // Peel off the whole match element.
  dslCapList.captures.removeFirst()
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

    guard let result = try! Executor<AnyRegexOutput>.wholeMatch(
      compile(ast),
      input,
      subjectBounds: inputRange,
      searchBounds: inputRange
    ) else {
      XCTFail("No match", file: file, line: line)
      return
    }

    var caps = result.anyRegexOutput
    // Peel off the whole match element.
    caps._elements.removeFirst()
    guard caps.count == output.count else {
      XCTFail("""
      Mismatched capture count:
      Expected:
      \(output)
      Seen:
      \(caps.formatStringCaptures(input: input))
      """, file: file, line: line)
      continue
    }
    
    guard output.elementsEqual(caps, by: {
      $0.isEqual(to: $1, in: input)
    }) else {
      XCTFail("""
      Mismatched captures:
      Expected:
      \(output)
      Seen:
      \(caps.formatStringCaptures(input: input))
      """, file: file, line: line)
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
      [.opt, .opt, .opt],
      ("a", [.some("a"), .some("a"), .none]),
      ("b", [.some("b"), .none, .some("b")]))

    captureTest(
      "((a)|(b))*",
      [.opt, .opt, .opt],
      ("a", [.some("a"), .some("a"), .none]))

    captureTest(
      "((a)|(b))+",
      [.cap, .opt, .opt],
      ("a", ["a", .some("a"), .none]),
      ("aaa", ["a", .some("a"), .none]),
      ("b", ["b", .none, .some("b")]),
      ("bbaba", ["a", .some("a"), .some("b")]))

    captureTest(
      "(((a)|(b))*)",
      [.cap, .opt, .opt, .opt],
      ("a", ["a", .some("a"), .some("a"), .none]),
      ("aaa", ["aaa", .some("a"), .some("a"), .none]),
      ("b", ["b", .some("b"), .none, .some("b")]),
      ("bbaba", ["bbaba", .some("a"), .some("a"), .some("b")]),
      ("", ["", .none, .none, .none]))

    captureTest(
      "(((a)|(b))?)",
      [.cap, .opt, .opt, .opt],
      ("a", ["a", .some("a"), .some("a"), .none]),
      ("b", ["b", .some("b"), .none, .some("b")]),
      ("", ["", .none, .none, .none]))

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

    captureTest(
      "((((a)*)?)*)?",
      [.opt, .opt, .opt, .opt],
      ("a", [.some("a"), .some("a"), .some("a"), .some("a")]),
      ("aaa", [.some("aaa"), .some("aaa"), .some("aaa"), .some("a")]),
      ("", [.some(""), .none, .none, .none]),
      // FIXME: This spins the matching engine forever.
      skipEngine: true)

    captureTest(
      "a|(b*)",
      [.opt],
      ("a", [.none]),
      ("", [.some("")]),
      ("b", [.some("b")]),
      ("bbb", [.some("bbb")]))

    captureTest(
      "a|(b)*",
      [.opt],
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]))

    captureTest(
      "a|(b)+",
      [.opt],
      ("a", [.none]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]))

    captureTest(
      "a|(b)?",
      [.opt],
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some("b")]))

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

    captureTest(
      "a|(b|c)*",
      [.opt],
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some("b")]),
      ("bbb", [.some("b")]))

    captureTest(
      "a|(b|c)?",
      [.opt],
      ("a", [.none]),
      ("", [.none]),
      ("b", [.some("b")]),
      ("c", [.some("c")]))

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

    captureTest(
      "((a|b)*|c)*",
      [.opt, .opt],
      ("a", [.some("a"), .some("a")]),
      ("b", [.some("b"), .some("b")]),
      ("c", [.some("c"), .none]),
      ("ababc", [.some("c"), .some("b")]),
      ("acab", [.some("b"), .some("b")]),
      ("cbba", [.some("a"), .some("a")]),
      ("cbbaaa", [.some("aaa"), .some("a")]),
      ("", [.none, .none]),
      // FIXME: This spins the matching engine forever.
      skipEngine: true)

    captureTest(
      "((a|b)|c)*",
      [.opt, .opt],
      ("a", [.some("a"), .some("a")]),
      ("b", [.some("b"), .some("b")]),
      ("c", [.some("c"), .none]),
      ("ababc", [.some("c"), .some("b")]),
      ("acab", [.some("b"), .some("b")]),
      ("cbba", [.some("a"), .some("a")]),
      ("cbbaaa", [.some("a"), .some("a")]),
      ("", [.none, .none]))
  }
  
  func testTypeVerification() throws {
    let opaque1 = try Regex("abc")
    _ = try XCTUnwrap(Regex<Substring>(opaque1))
    XCTAssertNil(Regex<(Substring, Substring)>(opaque1))
    XCTAssertNil(Regex<Int>(opaque1))
    
    let opaque2 = try Regex("(abc)")
    _ = try XCTUnwrap(Regex<(Substring, Substring)>(opaque2))
    XCTAssertNil(Regex<Substring>(opaque2))
    XCTAssertNil(Regex<(Substring, Int)>(opaque2))
    
    let opaque3 = try Regex("(?<someLabel>abc)")
    _ = try XCTUnwrap(Regex<(Substring, someLabel: Substring)>(opaque3))
    XCTAssertNil(Regex<(Substring, Substring)>(opaque3))
    XCTAssertNil(Regex<Substring>(opaque3))
    
    let opaque4 = try Regex("(?<somethingHere>abc)?")
    _ = try XCTUnwrap(Regex<(Substring, somethingHere: Substring?)>(opaque4))
    XCTAssertNil(Regex<(Substring, somethignHere: Substring)>(opaque4))
    XCTAssertNil(Regex<(Substring, Substring?)>(opaque4))
    
    let opaque5 = try Regex("((a)?bc)?")
    _ = try XCTUnwrap(Regex<(Substring, Substring?, Substring?)>(opaque5))
    XCTAssertNil(Regex<(Substring, Substring?, Substring??)>(opaque5))
    XCTAssertNil(Regex<(Substring, somethingHere: Substring?, here: Substring??)>(opaque5))
  }
}


