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

    #if os(macOS)
    if showChart {
      print("""
        === Comparison chart =================================================================
        Press Control-C to close...
        """)
      BenchmarkResultApp.comparisons = {
        return comparisons.sorted {
          let delta0 = Float($0.latest.median.seconds - $0.baseline.median.seconds)
            / Float($0.baseline.median.seconds)
          let delta1 = Float($1.latest.median.seconds - $1.baseline.median.seconds)
            / Float($1.baseline.median.seconds)
          return delta0 > delta1
        }
      }()
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

struct BenchmarkResult: Codable {
  let compileTime: Time
  let median: Time
  let stdev: Double
  let samples: Int
}

extension BenchmarkResult {
  struct Comparison: Identifiable, CustomStringConvertible {
    var id = UUID()
    var name: String
    var baseline: BenchmarkResult
    var latest: BenchmarkResult
    var diffCompileTimes: Bool = false
    
    var diff: Time? {
      if diffCompileTimes {
        return latest.compileTime - baseline.compileTime
      }
      if Stats.tTest(baseline, latest) {
        return latest.median - baseline.median
      }
      return nil
    }
    
    var description: String {
      guard let diff = diff else {
        return "- \(name) N/A"
      }
      let oldVal: Time
      let newVal: Time
      if diffCompileTimes {
        oldVal = baseline.compileTime
        newVal = latest.compileTime
      } else {
        oldVal = baseline.median
        newVal = latest.median
      }
      let percentage = (1000 * diff.seconds / oldVal.seconds).rounded()/10
      let len = max(40 - name.count, 1)
      let nameSpacing = String(repeating: " ", count: len)
      return "- \(name)\(nameSpacing)\(newVal)\t\(oldVal)\t\(diff)\t\t\(percentage)%"
    }
    
    var asCsv: String {
      guard let diff = diff else {
        return "\(name),N/A"
      }
      let oldVal: Time
      let newVal: Time
      if diffCompileTimes {
        oldVal = baseline.compileTime
        newVal = latest.compileTime
      } else {
        oldVal = baseline.median
        newVal = latest.median
      }
      let percentage = (1000 * diff.seconds / oldVal.seconds).rounded()/10
      return "\"\(name)\",\(newVal.seconds),\(oldVal.seconds),\(diff.seconds),\(percentage)%"
    }
  }
}

struct SuiteResult {
  var results: [String: BenchmarkResult] = [:]
  
  mutating func add(name: String, result: BenchmarkResult) {
    results.updateValue(result, forKey: name)
  }
  
  /// Compares with the given SuiteResult
  func compare(with other: SuiteResult) -> [BenchmarkResult.Comparison] {
    var comparisons: [BenchmarkResult.Comparison] = []
    for item in results {
      if let otherVal = other.results[item.key] {
        comparisons.append(
          .init(name: item.key, baseline: otherVal, latest: item.value))
      }
    }
    return comparisons
  }
  
  /// Compares with the NSRegularExpression benchmarks generated by CrossBenchmark
  func compareWithNS() -> [BenchmarkResult.Comparison] {
    var comparisons: [BenchmarkResult.Comparison] = []
    for item in results {
      let key = item.key + CrossBenchmark.nsSuffix
      if let nsResult = results[key] {
        comparisons.append(
          .init(name: item.key, baseline: nsResult, latest: item.value))
      }
    }
    return comparisons
  }
  
  /// Compares the compile times
  func compareCompileTimes(
    with other: SuiteResult
  ) -> [BenchmarkResult.Comparison] {
    var comparisons: [BenchmarkResult.Comparison] = []
    for item in results {
      if let otherVal = other.results[item.key] {
        comparisons.append(
          .init(name: item.key,
                baseline: otherVal,
                latest: item.value,
                diffCompileTimes: true))
      }
    }
    return comparisons
  }
}

extension SuiteResult: Codable {
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
