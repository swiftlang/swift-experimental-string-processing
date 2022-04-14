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
@testable import _StringProcessing

class RegexAPITests: XCTestCase {
  func testDynamicConstruction() throws {
    do {
      let regex = try Regex(compiling: "aabcc.")
      let line = "aabccd"
      let match = try XCTUnwrap(line.wholeMatch(of: regex))
      XCTAssertEqual(match.0, line[...])
      let output = match.output
      XCTAssertEqual(output[0].substring, line[...])
    }
    do {
      let regex = try Regex(
        compiling: #"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#)
      let line = """
        A6F0..A6F1    ; Extend # Mn   [2] BAMUM COMBINING MARK KOQNDON..BAMUM \
        COMBINING MARK TUKWENTIS
        """
      let match = try XCTUnwrap(line.wholeMatch(of: regex))
      XCTAssertEqual(match.0, line[...])
      let output = match.output
      XCTAssertEqual(output[0].substring, line[...])
      XCTAssertTrue(output[1].substring == "A6F0")
      XCTAssertTrue(output[2].substring == "A6F1")
      XCTAssertTrue(output[3].substring == "Extend")
      let typedOutput = try XCTUnwrap(output.as(
        (Substring, Substring, Substring?, Substring).self))
      XCTAssertEqual(typedOutput.0, line[...])
      XCTAssertTrue(typedOutput.1 == "A6F0")
      XCTAssertTrue(typedOutput.2 == "A6F1")
      XCTAssertTrue(typedOutput.3 == "Extend")
    }
  }

  func testPrimaryAssociatedType() throws {
    let originalRegex = try Regex(compiling: "aabcc.")
    let regex = originalRegex as any RegexComponent<AnyRegexOutput>
    let line = "aabccd"
    let match = try XCTUnwrap(line.wholeMatch(of: regex))
    XCTAssertEqual(match.0, line[...])
    let output = match.output
    XCTAssertEqual(output[0].substring, line[...])
  }
}
