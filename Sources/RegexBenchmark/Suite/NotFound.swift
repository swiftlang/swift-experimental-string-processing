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

import _StringProcessing
import Foundation

extension BenchmarkRunner {
  mutating func addNotFound() {
    let input = String(repeating: " ", count: 100_000)

    let notFound = CrossBenchmark(
      baseName: "NotFound", regex: "a", input: input)
    notFound.register(&self)

    let anchoredNotFound = CrossBenchmark(
      baseName: "AnchoredNotFound",
      regex: "^ +a",
      input: input,
      includeFirst: true)
    anchoredNotFound.register(&self)
  }
}
