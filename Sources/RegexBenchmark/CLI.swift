import ArgumentParser

@main
struct Runner: ParsableCommand {
  @Argument(help: "Patterns for benchmarks to run")
  var specificBenchmarks: [String] = []

  @Option(help: "How many samples to collect for each benchmark")
  var samples = 30

  @Flag(help: "Debug benchmark regexes")
  var debug = false
  
  @Option(help: "Load results from this file instead of rerunning")
  var load: String?

  @Option(help: "The file results should be saved to")
  var save: String?

  @Option(help: "The result file to compare against")
  var compare: String?

  @Option(help: "Compare compile times with the given results file")
  var compareCompileTime: String?
  
  @Flag(help: "Show comparison chart")
  var showChart: Bool = false
  
  @Flag(help: "Compare with NSRegularExpression")
  var compareWithNS: Bool = false
  
  @Option(help: "Save comparison results as csv")
  var saveComparison: String?

  @Flag(help: "Quiet mode")
  var quiet = false

  @Flag(help: "Exclude running NSRegex benchmarks")
  var excludeNs = false

  mutating func run() throws {
    var runner = BenchmarkRunner.makeRunner(samples, quiet)
    
    if !self.specificBenchmarks.isEmpty {
      runner.suite = runner.suite.filter { b in
        specificBenchmarks.contains { pattern in
          try! Regex(pattern).firstMatch(in: b.name) != nil
        }
      }
    }
    if debug {
      runner.debug()
      return
    }
    
    if let loadFile = load {
      try runner.load(from: loadFile)
    } else {
      if excludeNs {
        runner.suite = runner.suite.filter { b in !b.name.contains("NS") }
      }
      runner.run()
    }
    if let saveFile = save {
      try runner.save(to: saveFile)
    }
    if saveComparison != nil && compareWithNS && compare != nil {
      print("Unable to save both comparison results, specify only one compare operation")
      return
    }
    if compareWithNS {
      try runner.compareWithNS(showChart: showChart, saveTo: saveComparison)
    }
    if let compareFile = compare {
      try runner.compare(
        against: compareFile,
        showChart: showChart,
        saveTo: saveComparison)
    }
    if let compareFile = compareCompileTime {
      try runner.compareCompileTimes(against: compareFile, showChart: showChart)
    }
  }
}
