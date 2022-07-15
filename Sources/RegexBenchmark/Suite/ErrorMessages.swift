import _StringProcessing

extension BenchmarkRunner {
  mutating func addErrorMessages() {
    let regex = #"(?:.*):(?:\d+):(?:\d+): (?:error|warning): (.*)"#
    let errorMsgs = CrossBenchmark(
      baseName: "CompilerMessages",
      regex: regex,
      input: Inputs.compilerOutput
    )
    errorMsgs.register(&self)
  }
}
