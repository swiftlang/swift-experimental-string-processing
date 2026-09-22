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

/// A thread-safe integer counter.
///
/// This is built on `_swift_stdlib_atomicFetchAddInt`, an underscored
/// public entry point that the standard library has exported since ABI
/// stability.
final class AtomicCounter: @unchecked Sendable {
  /// The counter's storage, on the heap to provide a stable address.
  private let storage: UnsafeMutablePointer<Int>

  init(startingAt value: Int = 0) {
    storage = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    storage.initialize(to: value)
  }

  deinit {
    storage.deallocate()
  }

  /// The current value.
  var value: Int {
    _swift_stdlib_atomicLoadInt(object: storage)
  }

  /// Returns the current value and increments it.
  func next() -> Int {
    _swift_stdlib_atomicFetchAddInt(object: storage, operand: 1)
  }
}
