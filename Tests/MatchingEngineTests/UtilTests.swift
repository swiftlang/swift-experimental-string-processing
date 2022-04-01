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
@testable import _MatchingEngine

class UtilTests: XCTestCase {
  func testTupleTypeConstruction() {
    XCTAssertTrue(TypeConstruction.tupleType(
      of: []) == Void.self)
    XCTAssertTrue(TypeConstruction.tupleType(
      of: [Int.self, Any.self]) == (Int, Any).self)
    XCTAssertTrue(
      TypeConstruction.tupleType(
        of: [[Int].self, [Int: Int].self, Void.self, Any.self])
      == ([Int], [Int: Int], Void, Any).self)
  }

  func testTypeErasedTupleConstruction() throws {
    do {
      let tupleErased = TypeConstruction.tuple(of: [1, 2, 3])
      let tuple = try XCTUnwrap(tupleErased as? (Int, Int, Int))
      XCTAssertEqual(tuple.0, 1)
      XCTAssertEqual(tuple.1, 2)
      XCTAssertEqual(tuple.2, 3)
    }

    do {
      let tupleErased = TypeConstruction.tuple(
        of: [[1, 2], [true, false], [3.0, 4.0]])
      XCTAssertTrue(type(of: tupleErased) == ([Int], [Bool], [Double]).self)
      let tuple = try XCTUnwrap(tupleErased as? ([Int], [Bool], [Double]))
      XCTAssertEqual(tuple.0, [1, 2])
      XCTAssertEqual(tuple.1, [true, false])
      XCTAssertEqual(tuple.2, [3.0, 4.0])
    }

    // Reproducer for a memory corruption bug with transformed captures.
    do {
      enum GraphemeBreakProperty: UInt32 {
        case control = 0
        case prepend = 1
      }
      let tupleErased = TypeConstruction.tuple(of: [
        "a"[...],                        // Substring
        Unicode.Scalar(0xA6F0)!,         // Unicode.Scalar
        Unicode.Scalar(0xA6F0) as Any,   // Unicode.Scalar?
        GraphemeBreakProperty.prepend    // GraphemeBreakProperty
      ])
      let tuple = try XCTUnwrap(
        tupleErased as?
          (Substring, Unicode.Scalar, Unicode.Scalar, GraphemeBreakProperty))
      XCTAssertEqual(tuple.0, "a")
      XCTAssertEqual(tuple.1, Unicode.Scalar(0xA6F0)!)
      XCTAssertEqual(tuple.2, Unicode.Scalar(0xA6F0)!)
      XCTAssertEqual(tuple.3, .prepend)
    }
  }
}
