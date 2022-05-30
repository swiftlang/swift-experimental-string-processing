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

public protocol AtomicValue {
  associatedtype AtomicRepresentation: AtomicStorage
  where AtomicRepresentation.Value == Self
}

public protocol AtomicStorage {
  associatedtype Value

  init(_ value: __owned Value)

  __consuming func dispose() -> Value

  @_semantics("atomics.requires_constant_orderings")
  static func atomicLoad(
    at pointer: UnsafeMutablePointer<Self>
  ) -> Value

  @_semantics("atomics.requires_constant_orderings")
  static func atomicCompareExchange(
    expected: Value,
    desired: __owned Value,
    at pointer: UnsafeMutablePointer<Self>
  ) -> (exchanged: Bool, original: Value)
}
