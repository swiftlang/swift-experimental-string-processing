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

public protocol AtomicOptionalWrappable: AtomicValue {
  associatedtype AtomicOptionalRepresentation: AtomicStorage
  where AtomicOptionalRepresentation.Value == Self?
}

extension Optional: AtomicValue where Wrapped: AtomicOptionalWrappable {
  public typealias AtomicRepresentation = Wrapped.AtomicOptionalRepresentation
}
