import _StringProcessing
import RegexBuilder

import Foundation

extension BenchmarkRunner {
  mutating func addGraphemeBreak() {
    let input = Inputs.graphemeBreakData
    let regex = #"(?:[0-9A-F]+)(?:\.\.(?:[0-9A-F]+))?\s+;\s+(?:\w+).*"#
    let type = Substring.self // (Substring, Substring, Substring?, Substring).self

    let graphemeBreakFirst = Benchmark(
      name: "GraphemeBreakNoCapFirst",
      regex: try! Regex(regex, as: type),
      ty: .first,
      target: input
    )

    let graphemeBreakAll = Benchmark(
      name: "GraphemeBreakNoCapAll",
      regex: try! Regex(regex, as: type),
      ty: .allMatches,
      target: input
    )

    let graphemeBreakFirstNS = NSBenchmark(
      name: "GraphemeBreakNoCapFirstNS",
      regex: try! NSRegularExpression(pattern: regex),
      ty: .first,
      target: input
    )

    let graphemeBreakAllNS = NSBenchmark(
      name: "GraphemeBreakNoCapAllNS",
      regex: try! NSRegularExpression(pattern: regex),
      ty: .all,
      target: input
    )

    register(graphemeBreakFirst)
    register(graphemeBreakAll)
    register(graphemeBreakFirstNS)
    register(graphemeBreakAllNS)
  }
}

