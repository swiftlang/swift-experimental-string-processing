import _StringProcessing
import Foundation

extension BenchmarkRunner {
  mutating func addFirstMatch() {
    let r = "a"
    let s = String(repeating: " ", count: 100000)
    
    let firstMatch = Benchmark(
      name: "FirstMatch",
      regex: try! Regex(r),
      ty: .first,
      target: s
    )
    let firstMatchNS = NSBenchmark(
      name: "FirstMatchNS",
      regex: try! NSRegularExpression(pattern: r),
      ty: .first,
      target: s
    )
    
    register(new: firstMatch)
    register(new: firstMatchNS)
  }
}
