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

@testable import _StringProcessing
import XCTest

// TODO: Protocol-powered testing
class AlgorithmTests: XCTestCase {

}

var enablePrinting = false
func output<T>(_ s: @autoclosure () -> T) {
  if enablePrinting {
    print(s())
  }
}

class RegexConsumerTests: XCTestCase {
  func testRanges() {
    func expectRanges(
      _ string: String,
      _ regex: String,
      _ expected: [Range<Int>],
      file: StaticString = #file, line: UInt = #line
    ) {
      let regex = try! Regex(regex)
      
      let actualSeq: [Range<Int>] = string[...].ranges(of: regex).map {
        let start = string.offset(ofIndex: $0.lowerBound)
        let end = string.offset(ofIndex: $0.upperBound)
        return start..<end
      }
      XCTAssertEqual(actualSeq, expected, file: file, line: line)

      // `IndexingIterator` tests the collection conformance
      let actualCol: [Range<Int>] = string[...].ranges(of: regex)[...].map {
        let start = string.offset(ofIndex: $0.lowerBound)
        let end = string.offset(ofIndex: $0.upperBound)
        return start..<end
      }
      XCTAssertEqual(actualCol, expected, file: file, line: line)
    }

    expectRanges("", "", [0..<0])
    expectRanges("", "x", [])
    expectRanges("", "x+", [])
    expectRanges("", "x*", [0..<0])
    expectRanges("abc", "", [0..<0, 1..<1, 2..<2, 3..<3])
    expectRanges("abc", "x", [])
    expectRanges("abc", "x+", [])
    expectRanges("abc", "x*", [0..<0, 1..<1, 2..<2, 3..<3])
    expectRanges("abc", "a", [0..<1])
    expectRanges("abc", "a*", [0..<1, 1..<1, 2..<2, 3..<3])
    expectRanges("abc", "a+", [0..<1])
    expectRanges("abc", "a|b", [0..<1, 1..<2])
    expectRanges("abc", "a|b+", [0..<1, 1..<2])
    expectRanges("abc", "a|b*", [0..<1, 1..<2, 2..<2, 3..<3])
    expectRanges("abc", "(a|b)+", [0..<2])
    expectRanges("abc", "(a|b)*", [0..<2, 2..<2, 3..<3])
    expectRanges("abc", "(b|c)+", [1..<3])
    expectRanges("abc", "(b|c)*", [0..<0, 1..<3, 3..<3])
  }

  func testSplit() {
    func expectSplit(
      _ string: String,
      _ regex: String,
      _ expected: [Substring],
      file: StaticString = #file, line: UInt = #line
    ) {
      let regex = try! Regex(regex)
      let actual = Array(string.split(by: regex))
      XCTAssertEqual(actual, expected, file: file, line: line)
    }

    expectSplit("", "", ["", ""])
    expectSplit("", "x", [""])
    expectSplit("a", "", ["", "a", ""])
    expectSplit("a", "x", ["a"])
    expectSplit("a", "a", ["", ""])
  }
  
  func testReplace() {
    func expectReplace(
      _ string: String,
      _ regex: String,
      _ replacement: String,
      _ expected: String,
      file: StaticString = #file, line: UInt = #line
    ) {
      let regex = try! Regex(regex)
      let actual = string.replacing(regex, with: replacement)
      XCTAssertEqual(actual, expected, file: file, line: line)
    }
    
    expectReplace("", "", "X", "X")
    expectReplace("", "x", "X", "")
    expectReplace("", "x*", "X", "X")
    expectReplace("a", "", "X", "XaX")
    expectReplace("a", "x", "X", "a")
    expectReplace("a", "a", "X", "X")
    expectReplace("a", "a+", "X", "X")
    expectReplace("a", "a*", "X", "XX")
    expectReplace("aab", "a", "X", "XXb")
    expectReplace("aab", "a+", "X", "Xb")
    expectReplace("aab", "a*", "X", "XXbX")
  }
  
  func testMatches() {
    let regex = capture(oneOrMore(.digit)) { 2 * Int($0)! }
    let str = "foo 160 bar 99 baz"
    XCTAssertEqual(str.matches(of: regex).map(\.result.1), [320, 198])
  }
  
  func testMatchReplace() {
    func replaceTest<R: RegexComponent>(
      _ regex: R,
      input: String,
      result: String,
      _ replace: (_MatchResult<RegexConsumer<R, Substring>>) -> String,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      XCTAssertEqual(input.replacing(regex, with: replace), result)
    }
    
    let int = capture(oneOrMore(.digit)) { Int($0)! }
    
    replaceTest(
      int,
      input: "foo 160 bar 99 baz",
      result: "foo 240 bar 143 baz",
      { match in String(match.result.1, radix: 8) })
    
    replaceTest(
      Regex { int; "+"; int },
      input: "9+16, 0+3, 5+5, 99+1",
      result: "25, 3, 10, 100",
      { match in "\(match.result.1 + match.result.2)" })

    // TODO: Need to support capture history
    // replaceTest(
    //   oneOrMore { int; "," },
    //   input: "3,5,8,0, 1,0,2,-5,x8,8,",
    //   result: "16 3-5x16",
    //   { match in "\(match.result.1.reduce(0, +))" })
    
    replaceTest(
      Regex { int; "x"; int; optionally { "x"; int } },
      input: "2x3 5x4x3 6x0 1x2x3x4",
      result: "6 60 0 6x4",
      { match in "\(match.result.1 * match.result.2 * (match.result.3 ?? 1))" })
  }

  func testAdHoc() {
    let r = try! Regex("a|b+")

    XCTAssert("palindrome".contains(r))
    XCTAssert("botany".contains(r))
    XCTAssert("antiquing".contains(r))
    XCTAssertFalse("cdef".contains(r))

    let str = "a string with the letter b in it"
    let first = str.firstRange(of: r)
    let last = str.lastRange(of: r)
    let (expectFirst, expectLast) = (
      str.index(atOffset: 0)..<str.index(atOffset: 1),
      str.index(atOffset: 25)..<str.index(atOffset: 26))
    output(str.split(around: first!))
    output(str.split(around: last!))

    XCTAssertEqual(expectFirst, first)
    XCTAssertEqual(expectLast, last)

    XCTAssertEqual(
      [expectFirst, expectLast], Array(str.ranges(of: r)))

    XCTAssertTrue(str.starts(with: r))
    XCTAssertFalse(str.ends(with: r))

    XCTAssertEqual(str.dropFirst(), str.trimmingPrefix(r))
    XCTAssertEqual("x", "axb".trimming(r))
    XCTAssertEqual("x", "axbb".trimming(r))
  }
}
