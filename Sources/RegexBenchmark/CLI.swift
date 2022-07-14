import ArgumentParser

@main
struct Runner: ParsableCommand {
  @Argument(help: "Names of benchmarks to run")
  var specificBenchmarks: [String] = []

  @Option(help: "How many samples to collect for each benchmark")
  var samples = 30

  @Flag(help: "Debug benchmark regexes")
  var debug = false

  @Option(help: "The file results should be saved to")
  var save: String?

  @Option(help: "The result file to compare against")
  var compare: String?

  @Flag(help: "Quiet mode")
  var quiet = false

  mutating func run() throws {
    var runner = BenchmarkRunner.makeRunner(samples, quiet)

    // todo: regex based filter 
    if !self.specificBenchmarks.isEmpty {
      runner.suite = runner.suite.filter { b in specificBenchmarks.contains(b.name) }
    }
    if debug {
      runner.debug()
    } else {
      runner.run()
      if let compareFile = compare {
        try runner.compare(against: compareFile)
      }
      if let saveFile = save {
        try runner.save(to: saveFile)
      }
    }
  }
}
