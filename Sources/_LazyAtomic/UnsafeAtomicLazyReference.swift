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

@frozen
public struct UnsafeAtomicLazyReference<Instance: AnyObject> {
  public typealias Value = Instance?

  @usableFromInline
  internal typealias _Rep = Unmanaged<Instance>.AtomicOptionalRepresentation

  @usableFromInline
  internal let _ptr: UnsafeMutablePointer<_Rep>

  @_transparent // Debug performance
  public init(@_nonEphemeral at pointer: UnsafeMutablePointer<Storage>) {
    // `Storage` is layout-compatible with its only stored property.
    _ptr = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: _Rep.self)
  }
}

#if compiler(>=5.5) && canImport(_Concurrency)
extension UnsafeAtomicLazyReference: @unchecked Sendable
where Instance: Sendable {}
#endif

extension UnsafeAtomicLazyReference {
  @frozen
  public struct Storage {
    @usableFromInline
    internal var _storage: _Rep

    @inlinable @inline(__always)
    public init() {
      _storage = _Rep(nil)
    }

    @inlinable @inline(__always)
    @discardableResult
    public mutating func dispose() -> Value {
      defer { _storage = _Rep(nil) }
      return _storage.dispose()?.takeRetainedValue()
    }
  }
}

extension UnsafeAtomicLazyReference {
  @inlinable
  public static func create() -> Self {
    let ptr = UnsafeMutablePointer<Storage>.allocate(capacity: 1)
    ptr.initialize(to: Storage())
    return Self(at: ptr)
  }

  @discardableResult
  @inlinable
  public func destroy() -> Value {
    // `Storage` is layout-compatible with its only stored property.
    let address = UnsafeMutableRawPointer(_ptr)
      .assumingMemoryBound(to: Storage.self)
    defer { address.deallocate() }
    return address.pointee.dispose()
  }
}

extension UnsafeAtomicLazyReference {
  public func storeIfNilThenLoad(_ desired: __owned Instance) -> Instance {
    let desiredUnmanaged = Unmanaged.passRetained(desired)
    let (exchanged, current) = _Rep.atomicCompareExchange(
            expected: nil,
            desired: desiredUnmanaged,
            at: _ptr)
    if !exchanged {
      // The reference has already been initialized. Balance the retain that
      // we performed on `desired`.
      desiredUnmanaged.release()
      return current!.takeUnretainedValue()
    }
    return desiredUnmanaged.takeUnretainedValue()
  }

  public func load() -> Instance? {
    let value = _Rep.atomicLoad(at: _ptr)
    return value?.takeUnretainedValue()
  }
}
