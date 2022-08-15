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

#if os(macOS) && canImport(Charts)

import Charts
import SwiftUI

struct BenchmarkChart: View {
  var comparisons: [BenchmarkResult.Comparison]

  // Sort by normalized difference
  var sortedComparisons: [BenchmarkResult.Comparison] {
    comparisons.sorted { a, b in
      a.normalizedDiff < b.normalizedDiff
    }
  }
  var body: some View {
    VStack(alignment: .leading) {
      Chart {
        ForEach(sortedComparisons) { comparison in
          // Normalized runtime
          BarMark(
            x: .value("Name", comparison.name),
            y: .value("Normalized runtime", comparison.normalizedDiff))
          .foregroundStyle(LinearGradient(
            colors: [.accentColor, comparison.diff?.seconds ?? 0 <= 0 ? .green : .yellow],
            startPoint: .bottom,
            endPoint: .top))
        }
        // Baseline
        RuleMark(y: .value("Time", 1.0))
        .foregroundStyle(.red)
        .lineStyle(.init(lineWidth: 1, dash: [2]))
        .annotation(position: .top, alignment: .leading) {
          Text("Baseline").foregroundStyle(.red)
        }
        
      }
      .frame(idealWidth: 800, idealHeight: 800)
      .chartYScale(domain: 0...2.0)
      .chartYAxis {
        AxisMarks(values: .stride(by: 0.1))
      }
      .chartXAxis {
        AxisMarks { value in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(value.as(String.self)!, orientation: .vertical)
        }
      }
    }
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
