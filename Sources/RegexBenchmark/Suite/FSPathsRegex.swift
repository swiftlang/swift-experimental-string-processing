import _StringProcessing


extension BenchmarkRunner {
  mutating func addFSPathsRegex() {
    let fsPathsRegex =
    #"^\./First/Second/(Prefix)?Third/.*\.extension/.*(OptionLeft|OptionRight)$"#

    CrossInputListBenchmark(
      baseName: "FSPathsRegex",
      regex: fsPathsRegex,
      inputs: Inputs.fsPathsList
    ).register(&self)

    CrossInputListBenchmark(
      baseName: "FSPathsRegexNotFound",
      regex: fsPathsRegex,
      inputs: Inputs.fsPathsNotFoundList
    ).register(&self)

    CrossInputListBenchmark(
      baseName: "FSPathsRegexFound",
      regex: fsPathsRegex,
      inputs: Inputs.fsPathsFoundList
    ).register(&self)

  }
}

