import _StringProcessing
import RegexBuilder
import Foundation

// Tests that involve heavy backtracking

extension BenchmarkRunner {
  mutating func addBacktracking() {
    let r = "^ +A"
    let s = String(repeating: " ", count: 10000)

    let basicBacktrack = Benchmark(
      name: "BasicBacktrack",
      regex: try! Regex(r),
      ty: .allMatches,
      target: s
    )

    let basicBacktrackNS = NSBenchmark(
      name: "BasicBacktrackNS",
      regex: try! NSRegularExpression(pattern: r),
      ty: .all,
      target: s
    )

    let basicBacktrackFirstMatch = Benchmark(
      name: "BasicBacktrackFirstMatch",
      regex: try! Regex(r),
      ty: .first,
      target: s
    )

    let basicBacktrackNSFirstMatch = NSBenchmark(
      name: "BasicBacktrackNSFirstMatch",
      regex: try! NSRegularExpression(pattern: r),
      ty: .first,
      target: s
    )
    
    register(basicBacktrack)
    register(basicBacktrackNS)
    register(basicBacktrackFirstMatch)
    register(basicBacktrackNSFirstMatch)
  }
}
