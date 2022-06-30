import _StringProcessing

extension BenchmarkRunner {
  mutating func addCustomCharacterClasses() {
    let basic = #"[abCDeiou'~]{4,6}"#
    let basicRange = #"[a-z]{4,6}"#
    let caseInsensitive = #"(?i)[abCDeiou'~]{4,6}"#
    let inverted = #"[^jskldfjoi]{4,6}"#
    let subtraction = #"[a-z--[ae]]{4,6}"#
    let intersection = #"[a-z&&[abcdeiou]]{4,6}"#
    let symmetricDifference = #"[a-z~~[jskldfjoi]]{4,6}"#
    
    let input = Inputs.graphemeBreakData
    
    register(Benchmark(
      name: "basicCCC",
      regex: try! Regex(basic),
      type: .allMatches,
      target: input))
    
    register(Benchmark(
      name: "basicRangeCCC",
      regex: try! Regex(basicRange),
      type: .allMatches,
      target: input))
    
    register(Benchmark(
      name: "caseInsensitiveCCC",
      regex: try! Regex(caseInsensitive),
      type: .allMatches,
      target: input))
    
    register(Benchmark(
      name: "invertedCCC",
      regex: try! Regex(inverted),
      type: .allMatches,
      target: input))
    
    register(Benchmark(
      name: "subtractionCCC",
      regex: try! Regex(subtraction),
      type: .allMatches,
      target: input))
    
    register(Benchmark(
      name: "intersectionCCC",
      regex: try! Regex(intersection),
      type: .allMatches,
      target: input))
    
    register(Benchmark(
      name: "symDiffCCC",
      regex: try! Regex(symmetricDifference),
      type: .allMatches,
      target: input))
  }
}
