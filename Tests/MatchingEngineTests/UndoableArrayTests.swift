//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest

@testable import _StringProcessing

class UndoableArrayTests: XCTestCase {
  func testInitialState() {
    let a = UndoableArray<IntRegister, Int>(repeating: 0, count: 4)
    XCTAssertEqual(a.count, 4)
    XCTAssertEqual(a.logCount, 0)
    XCTAssertFalse(a.isDirty)
    for i in 0..<4 {
      XCTAssertEqual(a[IntRegister(i)], 0)
    }
  }

  func testSetWithoutLogging() {
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 4)
    a.set(IntRegister(0), to: 42, logging: false)
    a.set(IntRegister(1), to: 7, logging: false)

    XCTAssertEqual(a[IntRegister(0)], 42)
    XCTAssertEqual(a[IntRegister(1)], 7)
    XCTAssertTrue(a.isDirty)
    // No log entries were recorded, so there's nothing to undo.
    XCTAssertEqual(a.logCount, 0)
  }

  func testUpdateWithoutLogging() {
    var a = UndoableArray<IntRegister, Int>(repeating: 10, count: 2)
    a.update(IntRegister(0), logging: false) { $0 += 5 }

    XCTAssertEqual(a[IntRegister(0)], 15)
    XCTAssertEqual(a.logCount, 0)
    XCTAssertTrue(a.isDirty)
  }

  func testSetWithLoggingRecordsUndoEntry() {
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 4)
    a.set(IntRegister(0), to: 1, logging: true)
    XCTAssertEqual(a.logCount, 1)
    a.set(IntRegister(0), to: 2, logging: true)
    XCTAssertEqual(a.logCount, 2)
    XCTAssertEqual(a[IntRegister(0)], 2)
  }

  func testUpdateWithLoggingRecordsUndoEntry() {
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 4)
    a.update(IntRegister(0), logging: true) { $0 += 1 }
    XCTAssertEqual(a.logCount, 1)
    XCTAssertEqual(a[IntRegister(0)], 1)
  }

  func testUndoRevertsToMark() {
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 2)

    let mark0 = a.logCount
    a.set(IntRegister(0), to: 1, logging: true)
    let mark1 = a.logCount
    a.set(IntRegister(1), to: 2, logging: true)
    let mark2 = a.logCount
    a.set(IntRegister(0), to: 99, logging: true)

    XCTAssertEqual(a[IntRegister(0)], 99)
    XCTAssertEqual(a[IntRegister(1)], 2)

    // Undo the last mutation only.
    a.undo(to: mark2)
    XCTAssertEqual(a[IntRegister(0)], 1)
    XCTAssertEqual(a[IntRegister(1)], 2)
    XCTAssertEqual(a.logCount, mark2)

    // Undo back to after the first mutation.
    a.undo(to: mark1)
    XCTAssertEqual(a[IntRegister(0)], 1)
    XCTAssertEqual(a[IntRegister(1)], 0)
    XCTAssertEqual(a.logCount, mark1)

    // Undo everything.
    a.undo(to: mark0)
    XCTAssertEqual(a[IntRegister(0)], 0)
    XCTAssertEqual(a[IntRegister(1)], 0)
    XCTAssertEqual(a.logCount, mark0)
  }

  func testUndoToCurrentMarkIsANoOp() {
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 2)
    a.set(IntRegister(0), to: 5, logging: true)
    let mark = a.logCount
    a.undo(to: mark)
    XCTAssertEqual(a[IntRegister(0)], 5)
    XCTAssertEqual(a.logCount, mark)
  }

  func testUndoWithInterleavedUnloggedMutationsRestoresLoggedValue() {
    // A mutation made with `logging: false` after a logged mutation isn't
    // itself undoable, but undoing back past the logged mutation should
    // still restore the value it recorded.
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 1)
    let mark = a.logCount
    a.set(IntRegister(0), to: 1, logging: true)
    a.set(IntRegister(0), to: 2, logging: false)
    XCTAssertEqual(a[IntRegister(0)], 2)

    a.undo(to: mark)
    XCTAssertEqual(a[IntRegister(0)], 0)
  }

  func testUpdateBodyCanReadPriorValue() {
    var a = UndoableArray<IntRegister, Int>(repeating: 3, count: 1)
    let mark = a.logCount
    a.update(IntRegister(0), logging: true) { $0 *= 10 }
    XCTAssertEqual(a[IntRegister(0)], 30)

    a.undo(to: mark)
    XCTAssertEqual(a[IntRegister(0)], 3)
  }

  func testResetRestoresAllSlotsAndClearsLog() {
    var a = UndoableArray<IntRegister, Int>(repeating: 0, count: 3)
    a.set(IntRegister(0), to: 1, logging: true)
    a.set(IntRegister(1), to: 2, logging: true)
    a.set(IntRegister(2), to: 3, logging: false)
    XCTAssertTrue(a.isDirty)
    XCTAssertEqual(a.logCount, 2)

    a.reset(to: 0)

    for i in 0..<3 {
      XCTAssertEqual(a[IntRegister(i)], 0)
    }
    XCTAssertFalse(a.isDirty)
    XCTAssertEqual(a.logCount, 0)
  }
}
