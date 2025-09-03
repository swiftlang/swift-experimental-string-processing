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
}

