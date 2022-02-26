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
  var optionalCount = 0

  var storedCapture: StoredCapture?

  var someCount: Int {
    storedCapture == nil ? optionalCount - 1 : optionalCount
  }
}

/// A storage form for a successful capture
struct StoredCapture {
  // TODO: drop optional when engine tracks all ranges
  var range: Range<String.Index>?

  // If strongly typed, value is set
  var value: Any? = nil
}

// TODO: Where should this live? Inside TypeConstruction?
func constructExistentialMatchComponent(
  from input: Substring,
  in range: Range<String.Index>?,
  value: Any?,
  optionalCount: Int
) -> Any {
  let someCount: Int
  var underlying: Any
  if let v = value {
    underlying = v
    someCount = optionalCount
  } else if let r = range {
    underlying = input[r]
    someCount = optionalCount
  } else {
    // Ok since we Any-box every step up the ladder
    underlying = Optional<Any>(nil) as Any
    someCount = optionalCount - 1
  }
  for _ in 0..<someCount {
    func wrap<T>(_ x: T) {
      underlying = Optional(x) as Any
    }
    _openExistential(underlying, do: wrap)
  }
  return underlying
}

extension StructuredCapture {
  func existentialMatchComponent(
    from input: Substring
  ) -> Any {
    constructExistentialMatchComponent(
      from: input,
      in: storedCapture?.range,
      value: storedCapture?.value,
      optionalCount: optionalCount)
  }

  func slice(from input: String) -> Substring? {
    guard let r = storedCapture?.range else { return nil }
    return input[r]
  }
}

extension Sequence where Element == StructuredCapture {
  // FIXME: This is a stop gap where we still slice the input
  // and traffic through existentials
  func existentialMatch(
    from input: Substring
  ) -> Any {
    var caps = Array<Any>()
    caps.append(input)
    caps.append(contentsOf: self.map {
      $0.existentialMatchComponent(from: input)
    })
    return TypeConstruction.tuple(of: caps)
  }

  func slices(from input: String) -> [Substring?] {
    self.map { $0.slice(from: input) }
  }
}


