import _StringProcessing

extension BenchmarkRunner {
  mutating func addURLWithWordBoundaries() {
    let urlRegex = #"https?://([-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6})\b[-a-zA-Z0-9()@:%_+.~#?&=]*"#
    let url = CrossBenchmark(
      baseName: "URLWithWordBoundaries",
      regex: urlRegex,
      input: Inputs.url,
      alsoRunSimpleWordBoundaries: true
    )
    url.register(&self)
  }
}

