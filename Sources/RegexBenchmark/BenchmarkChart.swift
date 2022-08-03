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

#if os(macOS)

import Charts
import SwiftUI

struct BenchmarkChart: View {
  var comparisons: [BenchmarkResult.Comparison]

  var sortedComparisons: [BenchmarkResult.Comparison] {
    comparisons.sorted { a, b in
      a.latest.median.seconds/a.baseline.median.seconds <
        b.latest.median.seconds/b.baseline.median.seconds
    }
  }
  var body: some View {
    VStack(alignment: .leading) {
      Chart {
        ForEach(sortedComparisons) { comparison in
          let new = comparison.latest.median.seconds
          let old = comparison.baseline.median.seconds
          chartBody(
            name: comparison.name,
            new: new,
            old: old,
            sampleCount: comparison.latest.samples)
        }
        // Baseline
        RuleMark(y: .value("Time", 1.0))
        .foregroundStyle(.red)
        .lineStyle(.init(lineWidth: 1, dash: [2]))
        
      }.frame(idealHeight: 400)
    }
  }

  @ChartContentBuilder
  func chartBody(
    name: String,
    new: TimeInterval,
    old: TimeInterval,
    sampleCount: Int
  ) -> some ChartContent {
    // Normalized runtime
    BarMark(
      x: .value("Name", name),
      y: .value("Normalized runtime", new / old))
    
    .foregroundStyle(LinearGradient(
      colors: [.accentColor, new - old <= 0 ? .green : .yellow],
      startPoint: .bottom,
      endPoint: .top))
  }
}

struct BenchmarkResultApp: App {
  static var comparisons: [BenchmarkResult.Comparison]?

  var body: some Scene {
    WindowGroup {
      if let comparisons = Self.comparisons {
        ScrollView {
          BenchmarkChart(comparisons: comparisons)
        }
      } else {
        Text("No data")
      }
    }
  }
}

#endif
