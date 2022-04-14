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
import _StringProcessing
@testable import RegexBuilder

class RegexConsumerTests: XCTestCase {
  // FIXME: enable this test when we update the return type of `matches(of:)`
  // when SE-0346 is available
  //  func testMatches() {
  //    let regex = Capture(OneOrMore(.digit)) { 2 * Int($0)! }
  //    let str = "foo 160 bar 99 baz"
  //    XCTAssertEqual(str.matches(of: regex).map(\.result.1), [320, 198])
  //  }
  
  func testMatchReplace() {
    func replaceTest<R: RegexComponent>(
      _ regex: R,
      input: String,
      result: String,
      _ replace: (Regex<R.RegexOutput>.Match) -> String,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      XCTAssertEqual(input.replacing(regex, with: replace), result)
    }
    
    let int = Capture(OneOrMore(.digit)) { Int($0)! }
    
    replaceTest(
      int,
      input: "foo 160 bar 99 baz",
      result: "foo 240 bar 143 baz",
      { match in String(match.output.1, radix: 8) })
    
    replaceTest(
      Regex { int; "+"; int },
      input: "9+16, 0+3, 5+5, 99+1",
      result: "25, 3, 10, 100",
      { match in "\(match.output.1 + match.output.2)" })

    // TODO: Need to support capture history
    // replaceTest(
    //   OneOrMore { int; "," },
    //   input: "3,5,8,0, 1,0,2,-5,x8,8,",
    //   result: "16 3-5x16",
    //   { match in "\(match.result.1.reduce(0, +))" })
    
    replaceTest(
      Regex { int; "x"; int; Optionally { "x"; int } },
      input: "2x3 5x4x3 6x0 1x2x3x4",
      result: "6 60 0 6x4",
      { match in "\(match.output.1 * match.output.2 * (match.output.3 ?? 1))" })
  }
}
