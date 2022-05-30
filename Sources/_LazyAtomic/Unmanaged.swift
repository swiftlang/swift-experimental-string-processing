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

extension Unmanaged: AtomicValue {
  @frozen
  public struct AtomicRepresentation {
    public typealias Value = Unmanaged
    @usableFromInline internal typealias Storage = Int.AtomicRepresentation

    @usableFromInline
    internal let _storage: Storage

    @inline(__always) @_alwaysEmitIntoClient
    public init(_ value: Value) {
      self._storage = .init(Self._encode(value))
    }

    @inline(__always) @_alwaysEmitIntoClient
    public func dispose() -> Value {
      Self._decode(_storage.dispose())
    }
  }
}

extension Unmanaged.AtomicRepresentation {
  @_transparent @_alwaysEmitIntoClient
  @usableFromInline
  internal static func _extract(
    _ ptr: UnsafeMutablePointer<Self>
  ) -> UnsafeMutablePointer<Storage> {
    // `Self` is layout-compatible with its only stored property.
    return UnsafeMutableRawPointer(ptr)
      .assumingMemoryBound(to: Storage.self)
  }

  @_transparent @_alwaysEmitIntoClient
  internal static func _decode(_ bitPattern: Int) -> Value {
    return Unmanaged.fromOpaque(UnsafeRawPointer(bitPattern: bitPattern)!)
  }

  @_transparent @_alwaysEmitIntoClient
  internal static func _encode(_ value: Value) -> Int {
    return Int(bitPattern: value.toOpaque())
  }
}

extension Unmanaged.AtomicRepresentation: AtomicStorage {
  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicLoad(
    at pointer: UnsafeMutablePointer<Self>
  ) -> Value {
    let encoded = Storage.atomicLoad(at: _extract(pointer))
    return _decode(encoded)
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicCompareExchange(
    expected: Value,
    desired: Value,
    at pointer: UnsafeMutablePointer<Self>
  ) -> (exchanged: Bool, original: Value) {
    let (exchanged, original) = Storage.atomicCompareExchange(
      expected: _encode(expected),
      desired: _encode(desired),
      at: _extract(pointer))
    return (exchanged, _decode(original))
  }
}

extension Unmanaged: AtomicOptionalWrappable {
  @frozen
  public struct AtomicOptionalRepresentation {
    public typealias Value = Unmanaged?
    @usableFromInline internal typealias Storage = Int.AtomicRepresentation

    @usableFromInline
    internal let _storage: Storage

    @inline(__always) @_alwaysEmitIntoClient
    public init(_ value: Value) {
      self._storage = .init(Self._encode(value))
    }

    @inline(__always) @_alwaysEmitIntoClient
    public func dispose() -> Value {
      Self._decode(_storage.dispose())
    }
  }
}

extension Unmanaged.AtomicOptionalRepresentation {
  @_transparent @_alwaysEmitIntoClient
  @usableFromInline
  internal static func _extract(
    _ ptr: UnsafeMutablePointer<Self>
  ) -> UnsafeMutablePointer<Storage> {
    // `Self` is layout-compatible with its only stored property.
    return UnsafeMutableRawPointer(ptr)
      .assumingMemoryBound(to: Storage.self)
  }

  @_transparent @_alwaysEmitIntoClient
  internal static func _decode(_ bitPattern: Int) -> Value {
    guard let opaque = UnsafeRawPointer(bitPattern: bitPattern) else {
      return nil
    }
    return Unmanaged.fromOpaque(opaque)
  }

  @_transparent @_alwaysEmitIntoClient
  internal static func _encode(_ value: Value) -> Int {
    guard let value = value else { return 0 }
    return Int(bitPattern: value.toOpaque())
  }
}

extension Unmanaged.AtomicOptionalRepresentation: AtomicStorage {
  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicLoad(
    at pointer: UnsafeMutablePointer<Self>
  ) -> Value {
    let encoded = Storage.atomicLoad(at: _extract(pointer))
    return _decode(encoded)
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicCompareExchange(
    expected: Value,
    desired: Value,
    at pointer: UnsafeMutablePointer<Self>
  ) -> (exchanged: Bool, original: Value) {
    let (exchanged, original) = Storage.atomicCompareExchange(
      expected: _encode(expected),
      desired: _encode(desired),
      at: _extract(pointer))
    return (exchanged, _decode(original))
  }
}
