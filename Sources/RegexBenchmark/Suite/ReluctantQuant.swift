import _StringProcessing
import RegexBuilder

extension BenchmarkRunner {
  mutating func addReluctantQuant() {
    let size = 100_000
    let input = String(repeating: "a", count: size)

    let reluctantQuant = CrossBenchmark(
      baseName: "ReluctantQuant",
      regex: #".*?"#,
      input: input,
      isWhole: true)
    reluctantQuant.register(&self)

    let eagarQuantWithTerminal = CrossBenchmark(
      baseName: "EagarQuantWithTerminal",
      regex: #".*;"#,
      input: input + ";",
      isWhole: true)
    eagarQuantWithTerminal.register(&self)

    let reluctantQuantWithTerminal = CrossBenchmark(
      baseName: "ReluctantQuantWithTerminal",
      regex: #".*?;"#,
      input: input + ";",
      isWhole: true)
    reluctantQuantWithTerminal.register(&self)
  }
}
