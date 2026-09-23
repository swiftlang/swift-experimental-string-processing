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

/// A fixed-length array type that records a log of prior values as they change,
/// so that a range of recent mutations can be undone later.
///
/// Logging is opt-in per mutation (via the `logging` parameter), since the
/// processor only needs to log while backtracking save points are live.
struct UndoableArray<Register: RawRepresentable, Value> where Register.RawValue == Int {
  private typealias Entry = (slot: Register, oldValue: Value)

  /// The current value of each register slot.
  private(set) var values: [Value]

  /// The prior value of each logged mutation, most recent last.
  private var log: [Entry] = []

  /// The current length of the undo log.
  ///
  /// Save this value to later undo every mutation logged after it via
  /// `undo(to:)`.
  var logCount: Int { log.count }

  init(repeating initialValue: Value, count: Int) {
    self.values = Array(repeating: initialValue, count: count)
  }

  subscript(_ i: Register) -> Value {
    values[i.rawValue]
  }

  var count: Int { values.count }

  /// Sets the value of `i`'s register slot, recording its previous value
  /// in the undo log when `logging` is true.
  @inline(always)
  mutating func set(_ i: Register, to newValue: Value, logging: Bool) {
    if logging {
      log.append((i, values[i.rawValue]))
    }
    values[i.rawValue] = newValue
  }

  /// Mutates the value of `i`'s register slot in place, recording its
  /// previous value in the undo log when `logging` is true.
  @inline(always)
  mutating func update(
    _ i: Register, logging: Bool, _ body: (inout Value) -> Void
  ) {
    if logging {
      log.append((i, values[i.rawValue]))
    }
    body(&values[i.rawValue])
  }

  /// Reverts register slots to the values they held when the undo log
  /// contained `mark` entries, replaying the log in reverse.
  @inline(always)
  mutating func undo(to mark: Int) {
    // Only inline this early exit check, so we aren't inflating the backtracking
    // caller unnecessarily.
    if logCount == mark { return }
    _undo(to: mark)
  }

  @inline(never)
  private mutating func _undo(to mark: Int) {
    assert(mark < logCount)
    // Restore values from the log in reverse order.
    let end = logCount
    log.withUnsafeBufferPointer { log in
      values.withUnsafeMutableBufferPointer { values in
        var i = end
        while i > mark {
          i -= 1
          values[log[i].slot.rawValue] = log[i].oldValue
        }
      }
    }
    // Truncate the log; old values are overwritten as needed.
    log.removeLast(log.count - mark)
  }

  /// Discards the undo log without applying it, leaving every register slot
  /// at its current value.
  ///
  /// Only valid when no save point refers to the log any longer, i.e. when
  /// there is nothing left that could backtrack.
  @inline(__always)
  mutating func discardLog() {
    if !log.isEmpty {
      log.removeAll(keepingCapacity: true)
    }
  }

  /// Resets every register slot to `initialValue` and discards the undo
  /// log.
  @inline(always)
  mutating func reset(to initialValue: Value) {
    discardLog()
    values.withUnsafeMutableBufferPointer { values in
      for idx in values.indices {
        values[idx] = initialValue
      }
    }
  }
}
