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
    let median =  times[samples/2]
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
  var dateStyle: Date.FormatStyle {
    Date.FormatStyle()
      .year(.twoDigits)
      .month(.twoDigits)
      .day(.twoDigits)
      .hour(.twoDigits(amPM: .omitted))
      .minute(.twoDigits)
  }
  
  var outputFolderUrl: URL {
    let url = URL(fileURLWithPath: outputPath, isDirectory: true)
    if !FileManager.default.fileExists(atPath: url.path) {
      try! FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    }
    return url
  }
  
  public func save() throws {
    let now = startTime.formatted(dateStyle)
    let resultJsonUrl = outputFolderUrl.appendingPathComponent(now + "-result.json")
    print("Saving result to \(resultJsonUrl.path)")
    try results.save(to: resultJsonUrl)
  }

  func fetchLatestResult() throws -> (Date, SuiteResult) {
    var pastResults: [Date: SuiteResult] = [:]
    for resultFile in try FileManager.default.contentsOfDirectory(
      at: outputFolderUrl,
      includingPropertiesForKeys: nil
    ) {
      let dateString = resultFile.lastPathComponent.replacingOccurrences(
        of: "-result.json",
        with: "")
      let date = try dateStyle.parse(dateString)
      pastResults.updateValue(try SuiteResult.load(from: resultFile), forKey: date)
    }
    
    let sorted = pastResults
      .sorted(by: {(kv1,kv2) in kv1.0 > kv2.0})
    return sorted[0]
  }

  public func compare() throws {
    // It just compares by the latest result for now, we probably want a CLI
    // flag to set which result we want to compare against
    let (compareDate, compareResult) = try fetchLatestResult()
    let diff = results.compare(with: compareResult)
    let regressions = diff.filter({(_, change) in change.seconds > 0})
    let improvements = diff.filter({(_, change) in change.seconds < 0})
    
    print("Comparing against benchmark done on \(compareDate.formatted(dateStyle))")
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
        // note: is this enough time difference?
        if diff.abs() > Time.millisecond {
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
