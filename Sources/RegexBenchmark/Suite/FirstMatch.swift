import _StringProcessing
import Foundation

extension BenchmarkRunner {
  mutating func addFirstMatch() {
    let r = "a"
    let s = String(repeating: " ", count: 100000)
    
    // this does nothing but loop through the loop in
    // Match.swift (Regex._firstMatch) since the engine should fail right away,
    let firstMatch = Benchmark(
      name: "FirstMatch",
      regex: try! Regex(r),
      ty: .first,
      target: s
    )
    
    // a comparison with now NSRegularExpression handles this situation
    let firstMatchNS = NSBenchmark(
      name: "FirstMatchNS",
      regex: try! NSRegularExpression(pattern: r),
      ty: .first,
      target: s
    )
    
    let s2 = String(repeating: "a", count: 10000)
    
    // matches calls into firstMatch, so really they're the same
    // this also stress tests the captures
    let allMatches = Benchmark(
      name: "AllMatches",
      regex: try! Regex(r),
      ty: .allMatches,
      target: s2
    )
    
    let allMatchesNS = NSBenchmark(
      name: "AllMatchesNS",
      regex: try! NSRegularExpression(pattern: r),
      ty: .all,
      target: s2
    )
    
    register(firstMatch)
    register(firstMatchNS)
    register(allMatches)
    register(allMatchesNS)
  }
}
