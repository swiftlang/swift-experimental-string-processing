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
      let regex = try! Regex(compiling: regex)
      
      let actualSeq: [Range<Int>] = string[...].ranges(of: regex).map(string.offsets(of:))
      XCTAssertEqual(actualSeq, expected, file: file, line: line)

      // `IndexingIterator` tests the collection conformance
      let actualCol: [Range<Int>] = string[...].ranges(of: regex)[...].map(string.offsets(of:))
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
      let regex = try! Regex(compiling: regex)
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
      let regex = try! Regex(compiling: regex)
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

  func testAdHoc() {
    let r = try! Regex(compiling: "a|b+")

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
  
  func testSubstring() throws {
    let s = "aaa | aaaaaa | aaaaaaaaaa"
    let s1 = s.dropFirst(6)  // "aaaaaa | aaaaaaaaaa"
    let s2 = s1.dropLast(17) // "aa"
    let regex = try! Regex(compiling: "a+")

    XCTAssertEqual(s.firstMatch(of: regex)?.0, "aaa")
    XCTAssertEqual(s1.firstMatch(of: regex)?.0, "aaaaaa")
    XCTAssertEqual(s2.firstMatch(of: regex)?.0, "aa")

    XCTAssertEqual(
      s.ranges(of: regex).map(s.offsets(of:)),
      [0..<3, 6..<12, 15..<25])
    XCTAssertEqual(
      s1.ranges(of: regex).map(s.offsets(of:)),
      [6..<12, 15..<25])
    XCTAssertEqual(
      s2.ranges(of: regex).map(s.offsets(of:)),
      [6..<8])

    XCTAssertEqual(s.replacing(regex, with: ""), " |  | ")
    XCTAssertEqual(s1.replacing(regex, with: ""), " | ")
    XCTAssertEqual(s2.replacing(regex, with: ""), "")

    XCTAssertEqual(
      s.matches(of: regex).map(\.0),
      ["aaa", "aaaaaa", "aaaaaaaaaa"])
    XCTAssertEqual(
      s1.matches(of: regex).map(\.0),
      ["aaaaaa", "aaaaaaaaaa"])
    XCTAssertEqual(
      s2.matches(of: regex).map(\.0),
      ["aa"])
  }
}
