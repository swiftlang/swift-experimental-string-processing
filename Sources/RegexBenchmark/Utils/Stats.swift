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

enum Stats {}

extension Stats {
  // Maximum allowed standard deviation is 7.5% of the median runtime
  static let maxAllowedStdev = 0.15

  static func tTest(_ a: Measurement, _ b: Measurement) -> Bool {
    // Student's t-test
    // Since we should generally have similar variances across runs
    let n1 = Double(a.samples)
    let n2 = Double(b.samples)
    let sPNumerator = (n1 - 1) * pow(a.stdev, 2) + (n2 - 1) * pow(b.stdev, 2)
    let sPDenominator = n1 + n2 - 2
    let sP = (sPNumerator/sPDenominator).squareRoot()
    let tVal = (a.median.seconds - b.median.seconds) / (sP * (pow(n1, -1) + pow(n2, -1)).squareRoot())
    return abs(tVal) > 2
  }
}

extension BenchmarkResult {
  var runtimeIsTooVariant: Bool {
    runtime.stdev > Stats.maxAllowedStdev * runtime.median.seconds
  }
}
