//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _MatchingEngine

extension Regex where Match == (Substring, DynamicCaptures) {
  public init(_ pattern: String) throws {
    self.init(ast: try parse(pattern, .traditional))
  }
}

// FIXME: Separate storage representation from types vending
// API.
public typealias DynamicCaptures = Array<StoredDynamicCapture>

// FIXME: Make this internal when we have API types or otherwise
// disentagle storage from API. In the meantime, this will have
// the storage name _and_ provide the API.
public struct StoredDynamicCapture: Hashable {
  var optionalCount = 0

  // TODO: replace with a range
  var slice: Substring?

  init(_ slice: Substring?, optionalCount: Int) {
    self.slice = slice
    self.optionalCount = optionalCount
  }
}

extension StoredDynamicCapture {
  // TODO: How should we expose optional nesting?

  public var range: Range<String.Index>? {
    guard let s = slice else {
      return nil
    }
    return s.startIndex..<s.endIndex
  }

  public var underlyingSubstring: Substring? {
    slice
  }

  public var capture: Any {
    // Ok for now because `existentialMatchComponent`
    // wont slice the input if there's no range to slice with
    //
    // FIXME: This is ugly :-/
    let input = slice ?? ""

    return constructExistentialMatchComponent(
      from: input,
      in: range,
      value: nil,
      optionalCount: optionalCount)
  }
}

extension StoredDynamicCapture {
  init(
    _ cap: StructuredCapture,
    in input: String
  ) {
    self.optionalCount = cap.optionalCount
    guard let stored = cap.storedCapture else {
      self.slice = nil
      return
    }
    assert(stored.value == nil, "Dynamic typed?")
    guard let r = stored.range else {
      fatalError("FIXME: unreachable")
    }
    self.slice = input[r]
  }
}
