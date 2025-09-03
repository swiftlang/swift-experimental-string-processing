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
  mutating func addLiteralSearch() {
    let searchNotFound = CrossBenchmark(baseName: "LiteralSearchNotFound", regex: "magic_string_to_search_for", input: Inputs.graphemeBreakData)
    let search = CrossBenchmark(baseName: "LiteralSearch", regex: "HANGUL CHOSEONG TIKEUT-MIEUM..HANGUL CHOSEONG SSANGYEORINHIEUH", input: Inputs.graphemeBreakData)
    searchNotFound.register(&self)
    search.register(&self)
  }
}
