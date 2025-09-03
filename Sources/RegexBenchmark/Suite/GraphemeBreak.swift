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

import Foundation

extension BenchmarkRunner {
  mutating func addGraphemeBreak() {
    let input = Inputs.graphemeBreakData
    let regex = #"(?:[0-9A-F]+)(?:\.\.(?:[0-9A-F]+))?\s+;\s+(?:\w+).*"#

    let benchmark = CrossBenchmark(
      baseName: "GraphemeBreakNoCap", regex: regex, input: input)
    benchmark.register(&self)
  }

  mutating func addHangulSyllable() {
    let input = Inputs.graphemeBreakData
    let regex = #"HANGUL SYLLABLE [A-Z]+(?:\.\.HANGUL SYLLABLE [A-Z]+)?"#

    let benchmark = CrossBenchmark(
      baseName: "HangulSyllable", regex: regex, input: input, includeFirst: true)
    benchmark.register(&self)
  }
}

