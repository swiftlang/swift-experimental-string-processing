import Foundation
import _StringProcessing

extension BenchmarkRunner {
  mutating func addCSS() {
    let r = #"--([a-zA-Z0-9_-]+)\s*:\s*(.*?):"#
    
    let cssRegex = Benchmark(
      name: "cssRegex",
      regex: try! Regex(r),
      ty: .allMatches,
      target: Inputs.swiftOrgCSS
    )

    let cssRegexNS = NSBenchmark(
      name: "cssRegexNS",
      regex: try! NSRegularExpression(pattern: r),
      ty: .all,
      target: Inputs.swiftOrgCSS
    )
    register(cssRegex)
    register(cssRegexNS)
  }
}
