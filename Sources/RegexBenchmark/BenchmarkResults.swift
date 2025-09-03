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

extension BenchmarkRunner {
  /// Attempts to save the results to the given path
  func save(to savePath: String) throws {
    let url = URL(fileURLWithPath: savePath, isDirectory: false)
    let parent = url.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: parent.path) {
      try! FileManager.default.createDirectory(
        atPath: parent.path,
        withIntermediateDirectories: true)
    }
    print("Saving result to \(url.path)")
    try results.save(to: url)
  }
  
  /// Attempts to load the results from the given save file
  mutating func load(from savePath: String) throws {
    let url = URL(fileURLWithPath: savePath)
    let result = try SuiteResult.load(from: url)
    self.results = result
    print("Loaded results from \(url.path)")
  }

  /// Attempts to save results in a CSV format to the given path
  func saveCSV(to savePath: String) throws {
    let url = URL(fileURLWithPath: savePath, isDirectory: false)
    let parent = url.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: parent.path) {
      try! FileManager.default.createDirectory(
        atPath: parent.path,
        withIntermediateDirectories: true)
    }
    print("Saving result as CSV to \(url.path)")
    try results.saveCSV(to: url)

  }

  /// Compare this runner's results against the results stored in the given file path
  func compare(
    against compareFilePath: String,
    showChart: Bool,
    saveTo: String?
  ) throws {
    let compareFileURL = URL(fileURLWithPath: compareFilePath)
    let compareResult = try SuiteResult.load(from: compareFileURL)
    let compareFile = compareFileURL.lastPathComponent

    let comparisons = results
      .compare(with: compareResult)
      .filter({!$0.name.contains("_NS")})
      .filter({$0.diff != nil})
    displayComparisons(
      comparisons,
      showChart,
      against: "saved benchmark result " + compareFile)
    if let saveFile = saveTo {
      try saveComparisons(comparisons, path: saveFile)
    }
  }
  
  // Compile times are often very short (5-20µs) so results are likely to be
  // very affected by background tasks. This is primarily for making sure
  // there aren't any catastrophic changes in compile times
  func compareCompileTimes(
    against compareFilePath: String,
    showChart: Bool
  ) throws {
    let compareFileURL = URL(fileURLWithPath: compareFilePath)
    let compareResult = try SuiteResult.load(from: compareFileURL)
    let compareFile = compareFileURL.lastPathComponent

    let compileTimeComparisons = results
      .compareCompileTimes(with: compareResult)
      .filter({!$0.name.contains("_NS")})
      .filter({$0.diff != nil})
    print("Comparing estimated compile times")
    displayComparisons(
      compileTimeComparisons,
      false,
      against: "saved benchmark result " + compareFile)
  }
  
  /// Compares Swift Regex benchmark results against NSRegularExpression
  func compareWithNS(showChart: Bool, saveTo: String?) throws {
    let comparisons = results.compareWithNS().filter({$0.diff != nil})
    displayComparisons(
      comparisons,
      showChart,
      against: "NSRegularExpression (via CrossBenchmark)")
    if let saveFile = saveTo {
      try saveComparisons(comparisons, path: saveFile)
    }
  }
  
  func displayComparisons(
    _ comparisons: [BenchmarkResult.Comparison],
    _ showChart: Bool,
    against: String
  ) {
    let regressions = comparisons.filter({$0.diff!.seconds > 0})
      .sorted(by: {(a,b) in a.diff!.seconds > b.diff!.seconds})
    let improvements = comparisons.filter({$0.diff!.seconds < 0})
      .sorted(by: {(a,b) in a.diff!.seconds < b.diff!.seconds})
    
    print("Comparing against \(against)")
    print("=== Regressions ======================================================================")
    for item in regressions {
      print(item)
    }
    
    print("=== Improvements =====================================================================")
    for item in improvements {
      print(item)
    }

    #if os(macOS) && canImport(Charts)
    if showChart {
      print("""
        === Comparison chart =================================================================
        Press Control-C to close...
        """)
      BenchmarkResultApp.comparisons = comparisons
      BenchmarkResultApp.main()
    }
    #endif
  }
  
  func saveComparisons(
    _ comparisons: [BenchmarkResult.Comparison],
    path: String
  ) throws {
    let url = URL(fileURLWithPath: path, isDirectory: false)
    let parent = url.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: parent.path) {
      try! FileManager.default.createDirectory(
        atPath: parent.path,
        withIntermediateDirectories: true)
    }
    
    var contents = "name,latest,baseline,diff,percentage\n"
    for comparison in comparisons {
      contents += comparison.asCsv + "\n"
    }
    print("Saving comparisons as .csv to \(path)")
    try contents.write(to: url, atomically: true, encoding: String.Encoding.utf8)
  }
}

struct Measurement: Codable, CustomStringConvertible {
  let median: Time
  let stdev: Double
  let samples: Int
  
  init(results: [Time]) {
    let sorted = results.sorted()
    self.samples = sorted.count
    self.median = sorted[samples/2]
    let sum = results.reduce(0.0) {acc, next in acc + next.seconds}
    let mean = sum / Double(samples)
    let squareDiffs = results.reduce(0.0) { acc, next in
      acc + pow(next.seconds - mean, 2)
    }
    self.stdev = (squareDiffs / Double(samples)).squareRoot()
  }
  
  var description: String {
    return "\(median) (stdev: \(Time(stdev)), N = \(samples))"
  }

  var asCSV: String {
    """
    \(median.asCSVSeconds), \(stdev), \(samples)
    """
  }
}

struct BenchmarkResult: Codable, CustomStringConvertible {
  let runtime: Measurement
  let compileTime: Measurement?
  let parseTime: Measurement?
  
  var description: String {
    var base = "  > run time: \(runtime.description)"
    if let compileTime = compileTime {
      base += "\n  > compile time: \(compileTime)"
    }
    if let parseTime = parseTime {
      base += "\n  > parse time: \(parseTime)"
    }
    return base
  }

  var asCSV: String {
    let na = "N/A, N/A, N/A"
    return """
    \(runtime.asCSV), \(compileTime?.asCSV ?? na), \(parseTime?.asCSV ?? na)
    """
  }
}

extension BenchmarkResult {
  struct Comparison: Identifiable, CustomStringConvertible {
    var id = UUID()
    var name: String
    var baseline: Measurement
    var latest: Measurement
    
    var latestTime: Time { latest.median }
    var baselineTime: Time { baseline.median }
    var diff: Time? {
      if Stats.tTest(baseline, latest) {
        return latestTime - baselineTime
      }
      return nil
    }
    var normalizedDiff: Double {
      latestTime.seconds/baselineTime.seconds
    }
    
    var description: String {
      guard let diff = diff else {
        return "- \(name) N/A"
      }
      let percentage = (1000 * diff.seconds / baselineTime.seconds).rounded()/10
      let len = max(40 - name.count, 1)
      let nameSpacing = String(repeating: " ", count: len)
      return "- \(name)\(nameSpacing)\(latestTime)\t\(baselineTime)\t\(diff)\t\t\(percentage)%"
    }
    
    var asCsv: String {
      guard let diff = diff else {
        return "\(name),N/A"
      }
      let percentage = (1000 * diff.seconds / baselineTime.seconds).rounded()/10
      return "\"\(name)\",\(latestTime.seconds),\(baselineTime.seconds),\(diff.seconds),\(percentage)%"
    }
  }
}

struct SuiteResult {
  var results: [String: BenchmarkResult] = [:]
  
  mutating func add(name: String, result: BenchmarkResult) {
    results.updateValue(result, forKey: name)
  }
  
  func compare(with other: SuiteResult) -> [BenchmarkResult.Comparison] {
    var comparisons: [BenchmarkResult.Comparison] = []
    for latest in results {
      if let otherVal = other.results[latest.key] {
        comparisons.append(
          .init(name: latest.key,
                baseline: otherVal.runtime, latest: latest.value.runtime))
      }
    }
    return comparisons
  }
  
  /// Compares with the NSRegularExpression benchmarks generated by CrossBenchmark
  func compareWithNS() -> [BenchmarkResult.Comparison] {
    var comparisons: [BenchmarkResult.Comparison] = []
    for latest in results {
      let key = latest.key + CrossBenchmark.nsSuffix
      if let nsResult = results[key] {
        comparisons.append(
          .init(name: latest.key,
                baseline: nsResult.runtime, latest: latest.value.runtime))
      }
    }
    return comparisons
  }
  
  func compareCompileTimes(
    with other: SuiteResult
  ) -> [BenchmarkResult.Comparison] {
    var comparisons: [BenchmarkResult.Comparison] = []
    for latest in results {
      if let baseline = other.results[latest.key],
         let baselineTime = baseline.compileTime,
         let latestTime = latest.value.compileTime {
        comparisons.append(
          .init(name: latest.key,
                baseline: baselineTime,
                latest: latestTime))
      }
    }
    return comparisons
  }
}

extension SuiteResult: Codable {
  func saveCSV(to url: URL) throws {
    var output: [(name: String, result: BenchmarkResult)] = []
    for key in results.keys {
      output.append((key, results[key]!))
    }
    output.sort {
      $0.name < $1.name
    }
    var contents = """
    name,\
    runtime_median, runTime_stddev, runTime_samples,\
    compileTime_median, compileTime_stddev, compileTime_samples,\
    parseTime_median, parseTime_stddev, parseTime_samples\n
    """
    for (name, result) in output {
      contents.append("\(name), \(result.asCSV))\n")
    }
    print("Saving result as .csv to \(url.path())")
    try contents.write(to: url, atomically: true, encoding: String.Encoding.utf8)
  }

  func save(to url: URL) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(self)
    try data.write(to: url, options: .atomic)
  }
  
  static func load(from url: URL) throws -> SuiteResult {
    let decoder = JSONDecoder()
    let data = try Data(contentsOf: url)
    return try decoder.decode(SuiteResult.self, from: data)
  }
}
