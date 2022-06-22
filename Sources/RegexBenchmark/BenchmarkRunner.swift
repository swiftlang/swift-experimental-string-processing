import Foundation

public struct BenchmarkRunner {
  let suiteName: String
  var suite: [any RegexBenchmark] = []
  
  let samples: Int
  var results: SuiteResult = SuiteResult()
  
  // Outputting
  let startTime = Date()
  let outputPath: String
  
  public init(_ suiteName: String, _ n: Int, _ outputPath: String) {
    self.suiteName = suiteName
    self.samples = n
    self.outputPath = outputPath
  }
  
  public mutating func register(_ new: some RegexBenchmark) {
    suite.append(new)
  }
  
  mutating func measure(benchmark: some RegexBenchmark) -> Time {
    var times: [Time] = []
    
    // initial run to make sure the regex has been compiled
    // todo: measure compile times, or at least how much this first run
    //       differs from the later ones
    benchmark.run()
    
    // fixme: use suspendingclock?
    for _ in 0..<samples {
      let start = Tick.now
      benchmark.run()
      let end = Tick.now
      let time = end.elapsedTime(since: start)
      times.append(time)
    }
    // todo: compute stdev and warn if it's too large
    
    // return median time
    times.sort()
    let median = times[samples/2]
    self.results.add(name: benchmark.name, time: median)
    return median
  }
  
  public mutating func run() {
    print("Running")
    for b in suite {
      print("- \(b.name) \(measure(benchmark: b))")
    }
  }
  
  public func profile() {
    print("Starting")
    for b in suite {
      print("- \(b.name)")
      b.run()
      print("- done")
    }
  }
  
  public mutating func debug() {
    print("Debugging")
    print("========================")
    for b in suite {
      print("- \(b.name) \(measure(benchmark: b))")
      b.debug()
      print("========================")
    }
  }
}

extension BenchmarkRunner {
  
#if _runtime(_ObjC)
  var dateStyle: Date.ISO8601FormatStyle { Date.ISO8601FormatStyle() }

  func format(_ date: Date) -> String {
    return dateStyle.format(date)
  }
#else
  func format(_ date: Date) -> String {
    return date.description
  }
#endif
  
  var outputFolderUrl: URL {
    let url = URL(fileURLWithPath: outputPath, isDirectory: true)
    if !FileManager.default.fileExists(atPath: url.path) {
      try! FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    }
    return url
  }
  
  public func save() throws {
    let now = format(startTime)
    let resultJsonUrl = outputFolderUrl.appendingPathComponent(now + "-result.json")
    print("Saving result to \(resultJsonUrl.path)")
    try results.save(to: resultJsonUrl)
  }
  
  func fetchLatestResult() throws -> (String, SuiteResult) {
#if _runtime(_ObjC)
    var pastResults: [Date: (String, SuiteResult)] = [:]
    for resultFile in try FileManager.default.contentsOfDirectory(
      at: outputFolderUrl,
      includingPropertiesForKeys: nil
    ) {
      do {
        let dateString = resultFile.lastPathComponent.replacingOccurrences(
          of: "-result.json",
          with: "")
        let date = try dateStyle.parse(dateString)
        let result = try SuiteResult.load(from: resultFile)
        pastResults.updateValue((resultFile.lastPathComponent, result), forKey: date)
      } catch {
        print("Warning: Found invalid result file \(resultFile.lastPathComponent) in results directory, skipping")
      }
    }

    let sorted = pastResults
      .sorted(by: {(kv1,kv2) in kv1.0 > kv2.0})
    return sorted[0].1
#else
    // corelibs-foundation lacks Date.FormatStyle entirely, so we don't have
    // any way of parsing the dates. So use the filename sorting to pick out the
    // latest one... this sucks
    let items = try FileManager.default.contentsOfDirectory(
      at: outputFolderUrl,
      includingPropertiesForKeys: nil
    )
    let resultFile = items[items.count - 1]
    let pastResult = try SuiteResult.load(from: resultFile)
    return (resultFile.lastPathComponent, pastResult)
#endif
  }

  public func compare(against: String?) throws {
    let compareFile: String
    let compareResult: SuiteResult
    
    if let compareFilePath = against {
      let compareFileURL = URL(fileURLWithPath: compareFilePath)
      compareResult = try SuiteResult.load(from: compareFileURL)
      compareFile = compareFileURL.lastPathComponent
    } else {
      (compareFile, compareResult) = try fetchLatestResult()
    }
    
    let diff = results.compare(with: compareResult)
    let regressions = diff.filter({(_, change) in change.seconds > 0})
    let improvements = diff.filter({(_, change) in change.seconds < 0})
    
    print("Comparing against benchmark result file \(compareFile)")
    print("=== Regressions ====================================================")
    for item in regressions {
      let oldVal = compareResult.results[item.key]!
      let newVal = results.results[item.key]!
      let percentage = item.value.seconds / oldVal.seconds
      print("- \(item.key)\t\t\(newVal)\t\(oldVal)\t\(item.value)\t\((percentage * 100).rounded())%")
    }
    print("=== Improvements ====================================================")
    for item in improvements {
      let oldVal = compareResult.results[item.key]!
      let newVal = results.results[item.key]!
      let percentage = item.value.seconds / oldVal.seconds
      print("- \(item.key)\t\t\(newVal)\t\(oldVal)\t\(item.value)\t\((percentage * 100).rounded())%")
    }
  }
}

struct SuiteResult {
  var results: [String: Time] = [:]
  
  public mutating func add(name: String, time: Time) {
    results.updateValue(time, forKey: name)
  }
  
  public func compare(with other: SuiteResult) -> [String: Time] {
    var output: [String: Time] = [:]
    for item in results {
      if let otherVal = other.results[item.key] {
        let diff = item.value - otherVal
        if abs(100 * diff.seconds / otherVal.seconds) > 0.5 {
          output.updateValue(diff, forKey: item.key)
        }
      }
    }
    return output
  }
}

extension SuiteResult: Codable {
  public func save(to url: URL) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(self)
    try data.write(to: url, options: .atomic)
  }
  
  public static func load(from url: URL) throws -> SuiteResult {
    let decoder = JSONDecoder()
    let data = try Data(contentsOf: url)
    return try decoder.decode(SuiteResult.self, from: data)
  }
}
