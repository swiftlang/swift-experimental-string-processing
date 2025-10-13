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

