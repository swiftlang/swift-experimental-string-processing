import _StringProcessing
import RegexBuilder

extension BenchmarkRunner {
  mutating func addReluctantQuant() {
    let size = 500000
    let s = String(repeating: "a", count: size)
    
    let reluctantQuant = Benchmark(
      name: "ReluctantQuant",
      regex: Regex {
          OneOrMore(.any, .reluctant)
      },
      ty: .whole,
      target: s
    )

    let eagarQuantWithTerminal = Benchmark(
      name: "EagarQuantWithTerminal",
      regex: Regex {
          OneOrMore(.any, .eager)
          ";"
      },
      ty: .whole,
      target: s + ";"
    )

    let reluctantQuantWithTerminal = Benchmark(
      name: "ReluctantQuantWithTerminal",
      regex: Regex {
          OneOrMore(.any, .reluctant)
          ";"
      },
      ty: .whole,
      target: s + ";"
    )
    
    register(reluctantQuant)
    register(reluctantQuantWithTerminal)
    register(eagarQuantWithTerminal)
  }
}
