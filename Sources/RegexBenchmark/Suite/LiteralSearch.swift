import _StringProcessing

extension BenchmarkRunner {
  mutating func addLiteralSearch() {
    let searchNotFound = CrossBenchmark(baseName: "LiteralSearchNotFound", regex: "magic_string_to_search_for", input: Inputs.graphemeBreakData)
    let search = CrossBenchmark(baseName: "LiteralSearch", regex: "aatcgaagcagtcttctaacacccttagaaaagcaaacactattgaatactgccgccgca", input: Inputs.graphemeBreakData)
    searchNotFound.register(&self)
    search.register(&self)
  }
}
