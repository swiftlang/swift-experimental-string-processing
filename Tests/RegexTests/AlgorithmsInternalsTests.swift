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
extension AlgorithmTests {
  func testAdHoc() {
    let r = try! Regex("a|b+")

    XCTAssert("palindrome".contains(r))
    XCTAssert("botany".contains(r))
    XCTAssert("antiquing".contains(r))
    XCTAssertFalse("cdef".contains(r))

    let str = "a string with the letter b in it"
    let first = str.firstRange(of: r)
    let (expectFirst, expectLast) = (
      str.index(atOffset: 0)..<str.index(atOffset: 1),
      str.index(atOffset: 25)..<str.index(atOffset: 26))
    output(str.split(around: first!))

    XCTAssertEqual(expectFirst, first)
    XCTAssertEqual(
      [expectFirst, expectLast], Array(str.ranges(of: r)))

    XCTAssertTrue(str.starts(with: r))
    XCTAssertEqual(str.dropFirst(), str.trimmingPrefix(r))
  }
  
  func testMatchesCollection() {
    let r = try! Regex("a|b+|c*", as: Substring.self)
    
    let str = "zaabbbbbbcde"
    let matches = str._matches(of: r)
    let expected: [Substring] = [
      "", // before 'z'
      "a",
      "a",
      "bbbbbb",
      "c",
      "", // after 'c'
      "", // after 'd'
      "", // after 'e'
    ]

    // Make sure we're getting the right collection type
    let _: RegexMatchesCollection<Substring> = matches

    XCTAssertEqual(matches.map(\.output), expected)
    
    let i = matches.index(matches.startIndex, offsetBy: 3)
    XCTAssertEqual(matches[i].output, expected[3])
    let j = matches.index(i, offsetBy: 5)
    XCTAssertEqual(j, matches.endIndex)
    
    var index = matches.startIndex
    while index < matches.endIndex {
      XCTAssertEqual(
        matches[index].output,
        expected[matches.distance(from: matches.startIndex, to: index)])
      matches.formIndex(after: &index)
    }
  }
}
