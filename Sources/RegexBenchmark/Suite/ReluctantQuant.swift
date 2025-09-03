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
import RegexBuilder

extension BenchmarkRunner {
  mutating func addReluctantQuant() {
    let size = 100_000
    let input = String(repeating: "a", count: size)

    let reluctantQuant = CrossBenchmark(
      baseName: "ReluctantQuant",
      regex: #".*?"#,
      input: input,
      isWhole: true)
    reluctantQuant.register(&self)

    let eagarQuantWithTerminal = CrossBenchmark(
      baseName: "EagarQuantWithTerminal",
      regex: #".*;"#,
      input: input + ";",
      isWhole: true)
    eagarQuantWithTerminal.register(&self)

    let reluctantQuantWithTerminal = CrossBenchmark(
      baseName: "ReluctantQuantWithTerminal",
      regex: #".*?;"#,
      input: input + ";",
      isWhole: true)
    reluctantQuantWithTerminal.register(&self)
  }
}
