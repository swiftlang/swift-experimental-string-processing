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

import XCTest

// We need to split this out of the test files, as it needs to be compiled
// *without* `-disable-availability-checking` to ensure the #available check is
// not compiled into a no-op.

#if os(Linux) || os(Android) || os(Windows) || os(WASI)
public func XCTExpectFailure(
  _ message: String? = nil, body: () throws -> Void
) rethrows {}
#endif

/// Guards certain tests to make sure we have a new stdlib available.
public func ensureNewStdlib(
  file: StaticString = #file, line: UInt = #line
) -> Bool {
  guard #available(SwiftStdlib 5.7, *) else {
    XCTExpectFailure { XCTFail("Unsupported stdlib", file: file, line: line) }
    return false
  }
  return true
}
