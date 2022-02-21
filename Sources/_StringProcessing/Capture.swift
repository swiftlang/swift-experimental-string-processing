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

/// A structured capture
struct StructuredCapture {
  /// The `.optional` height of the result
  var numOptionals = 0

  var storedCapture: StoredCapture?

  var numSomes: Int {
    storedCapture == nil ? numOptionals - 1 : numOptionals
  }
}

/// A storage form for a successful capture
struct StoredCapture {
  // TODO: drop optional when engine tracks all ranges
  var range: Range<String.Index>?

  // If strongly typed, value is set
  var value: Any? = nil
}

extension StructuredCapture {
  func extractExistentialMatchComponent(
    from input: Substring
  ) -> Any {
    var underlying: Any
    if let cap = self.storedCapture {
      underlying = cap.value ?? input[cap.range!]
    } else {
      // Ok since we Any-box every step up the ladder
      underlying = Optional<Any>(nil) as Any
    }
    for _ in 0..<numSomes {
      underlying = Optional(underlying) as Any
    }
    return underlying
  }
}

extension Sequence where Element == StructuredCapture {
  // FIXME: This is a stop gap where we still slice the input
  // and traffic through existentials
  func extractExistentialMatch(
    from input: Substring
  ) -> Any {
    var caps = Array<Any>()
    caps.append(input)
    caps.append(contentsOf: self.map {
      $0.extractExistentialMatchComponent(from: input)
    })
    return TypeConstruction.tuple(of: caps)
  }
}

