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
struct AtomicCounter: @unchecked Sendable {
  fileprivate var _storage: _AtomicInt
  
  init(startingValue: Int = 0) {
    self._storage = .create(startingValue: startingValue)
  }
  
  /// The counter's current value.
  var value: Int {
    _storage.value
  }
  
  /// Returns the current value and increments it.
  func next() -> Int {
    _storage.next()
  }
}

fileprivate final class _AtomicInt: ManagedBuffer<Void, Int> {
  static func create(startingValue: Int) -> Self {
    return super.create(minimumCapacity: 1) { buffer in
      buffer.withUnsafeMutablePointerToElements { elements in
        elements.initialize(to: startingValue)
      }
      return ()
    } as! Self
  }
  
  var value: Int {
    withUnsafeMutablePointerToElements {
      _swift_stdlib_atomicLoadInt(object: $0)
    }
  }
  
  /// Returns the current value and increments it.
  func next() -> Int {
    withUnsafeMutablePointerToElements {
      _swift_stdlib_atomicFetchAddInt(object: $0, operand: 1)
    }
  }
}
