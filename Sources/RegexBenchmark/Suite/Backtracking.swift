import _StringProcessing
import RegexBuilder
import Foundation

// Tests that involve heavy backtracking

extension BenchmarkRunner {
  mutating func addBacktracking() {
    register(new: basicBacktrack)
    register(new: basicBacktrackNS)
  }
}


private let r = " +A"
private let s = String(repeating: " ", count: 100)

private let basicBacktrack = Benchmark(
  name: "BasicBacktrack",
  regex: try! Regex(r),
  ty: .enumerate,
  target: s
)

private let basicBacktrackNS = NSBenchmark(
  name: "BasicBacktrackNS",
  regex: try! NSRegularExpression(pattern: r),
  ty: .all,
  target: s
)
