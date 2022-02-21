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
typealias Program = MEProgram<String>

public struct MatchResult {
  public var range: Range<String.Index>
  var captures: [StructuredCapture]

  var destructure: (
    matched: Range<String.Index>,
    captures: [StructuredCapture]
  ) {
    (range, captures)
  }

  init(
    _ matched: Range<String.Index>,
    _ captures: [StructuredCapture]
  ) {
    self.range = matched
    self.captures = captures
  }
}
