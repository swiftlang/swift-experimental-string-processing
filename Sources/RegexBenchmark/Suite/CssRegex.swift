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

import Foundation
import _StringProcessing

extension BenchmarkRunner {
  mutating func addCSS() {
    let r = #"--([a-zA-Z0-9_-]+)\s*:\s*(.*?);"#

    let css = CrossBenchmark(
      baseName: "Css", regex: r, input: Inputs.swiftOrgCSS)
    css.register(&self)
  }
}
