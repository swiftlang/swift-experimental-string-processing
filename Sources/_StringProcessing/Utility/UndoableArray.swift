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
  /// The current value of each register slot.
  private(set) var values: [Value]

  /// The prior value of each logged mutation, most recent last.
  private var log: [(slot: Register, oldValue: Value)] = []

  init(repeating initialValue: Value, count: Int) {
    self.values = Array(repeating: initialValue, count: count)
  }

  subscript(_ i: Register) -> Value {
    values[i.rawValue]
  }

  var count: Int { values.count }

  /// The current length of the undo log.
  ///
  /// Save this value to later undo every mutation logged after it via
  /// `undo(to:)`.
  var logCount: Int { log.count }

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
    while log.count > mark {
      let entry = log.removeLast()
      values[entry.slot.rawValue] = entry.oldValue
    }
  }

  /// Resets every register slot to `initialValue` and discards the undo
  /// log.
  @inline(always)
  mutating func reset(to initialValue: Value) {
    if !log.isEmpty {
      log.removeAll(keepingCapacity: true)
    }
    for idx in values.indices {
      values[idx] = initialValue
    }
  }
}
