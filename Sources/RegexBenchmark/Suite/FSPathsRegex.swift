import _StringProcessing


extension BenchmarkRunner {
  mutating func addFSPathsRegex() {
    let fsPathsRegex =
    #"^\./First/Second/(Prefix)?Third/.*\.extension/.*(OptionLeft|OptionRight)$"#
    let paths = CrossInputListBenchmark(
      baseName: "FSPathsRegex",
      regex: fsPathsRegex,
      inputs: Inputs.fsPathsList
    )
    paths.register(&self)
  }
}

