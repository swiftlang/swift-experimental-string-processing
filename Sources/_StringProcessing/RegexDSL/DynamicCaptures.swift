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

public struct DynamicCapture: Hashable {
  var numOptionals = 0

  // TODO: replace with a range
  var slice: Substring?

  init(_ slice: Substring?, numOptionals: Int) {
    self.slice = slice
    self.numOptionals = numOptionals
  }
}

extension DynamicCapture {
  init(
    _ cap: StructuredCapture,
    in input: String
  ) {
    self.numOptionals = cap.numOptionals
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

// TODO: Probably worth a separate type
public typealias DynamicCaptures = Array<DynamicCapture>

