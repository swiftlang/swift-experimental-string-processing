//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

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

