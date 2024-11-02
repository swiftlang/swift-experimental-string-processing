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

  // Benchmark from forums user @sspringer
  // https://github.com/stefanspringer1/SwiftRegexBenchmarks/tree/main
  mutating func addCommunityBenchmark_sspringerURL() {
    let urlRegex = #"https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?"#
    let rawData = """
        URLs:
        http://www.google.com
        https://www.google.com
        http://google.com
        https://google.com
        http://www.google.com/
        https://www.google.com/
        http://google.com/
        https://google.com/
        http://www.google.com/index.html
        https://www.google.com/index.html
        http://google.com/index.html
        https://google.com/index.html
        """
    let data = String(repeating: rawData, count: 100)
    let url = CrossBenchmark(
      baseName: "Community_sspringerURL",
      regex: urlRegex,
      input: data
    )
    url.register(&self)
  }
}
