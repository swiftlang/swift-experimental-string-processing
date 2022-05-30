//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// THIS FILE IS PART OF A SUBSET OF https://github.com/apple/swift-atomics/

import _LazyAtomicShims

extension Int: AtomicValue {
  @frozen
  public struct AtomicRepresentation {
    public typealias Value = Int

    @usableFromInline
    var _storage: _AtomicIntStorage

    @inline(__always) @_alwaysEmitIntoClient
    public init(_ value: Value) {
      self._storage = _sa_prepare_Int(value)
    }

    @inline(__always) @_alwaysEmitIntoClient
    public func dispose() -> Value {
      return _sa_dispose_Int(_storage)
    }
  }
}

extension UnsafeMutablePointer
where Pointee == Int.AtomicRepresentation {
  @inlinable @inline(__always)
  internal var _extract: UnsafeMutablePointer<_AtomicIntStorage> {
    // `Int` is layout-compatible with its only stored property.
    return UnsafeMutableRawPointer(self)
      .assumingMemoryBound(to: _AtomicIntStorage.self)
  }
}

extension Int.AtomicRepresentation: AtomicStorage {
  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicLoad(
    at pointer: UnsafeMutablePointer<Self>
  ) -> Value {
    _sa_load_acquire_Int(pointer._extract)
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicCompareExchange(
    expected: Value,
    desired: Value,
    at pointer: UnsafeMutablePointer<Self>
  ) -> (exchanged: Bool, original: Value) {
    var expected = expected
    let exchanged: Bool
    exchanged = _sa_cmpxchg_strong_acq_rel_acquire_Int(
      pointer._extract,
      &expected, desired)
    return (exchanged, expected)
  }
}
