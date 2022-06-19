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
}

