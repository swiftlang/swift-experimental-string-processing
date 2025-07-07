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
  mutating func addBuiltinCC() {
    let basic = CrossBenchmark(
      baseName:
        "BasicBuiltinCharacterClass",
      regex: #"\d\w"#,
      input: Inputs.graphemeBreakData)
    
    // An imprecise email matching regex using mostly builtin character classes
    let email = CrossBenchmark(
      baseName:
        "EmailBuiltinCharacterClass",
      regex: #"(?:\d|\w|\.|-|_|%|\+)+@(?:\d|\w|\.|-|_|%|\+)+"#,
      input: Inputs.validEmails)

    let words = CrossBenchmark(
      baseName: "Words",
      regex: #"\w+"#,
      input: Inputs.swiftOrgHTML)
    let numbers = CrossBenchmark(
      baseName: "Numbers",
      regex: #"\d+"#,
      input: Inputs.swiftOrgHTML)
    let lines = CrossBenchmark(
      baseName: "Lines",
      regex: #".+"#,
      input: Inputs.swiftOrgHTML)

    basic.register(&self)
    email.register(&self)
    words.register(&self)
    numbers.register(&self)
    lines.register(&self)
  }
}
