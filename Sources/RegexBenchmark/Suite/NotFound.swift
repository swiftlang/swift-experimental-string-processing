import _StringProcessing
import Foundation

extension BenchmarkRunner {
  mutating func addNotFound() {
    let input = String(repeating: " ", count: 100_000)

    let notFound = CrossBenchmark(
      baseName: "notFound", regex: "a", input: input)
    notFound.register(&self)

    let anchoredNotFound = CrossBenchmark(
      baseName: "anchoredNotFound",
      regex: "^ +a",
      input: input,
      isWhole: true)
    anchoredNotFound.register(&self)
  }
}
