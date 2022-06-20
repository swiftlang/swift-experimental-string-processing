import ArgumentParser

@main
struct Runner: ParsableCommand {
  @Argument(help: "Names of benchmarks to run")
  var specificBenchmarks: [String] = []
  
  @Option(help: "Run only once for profiling purposes")
  var profile = false
  
  @Option(help: "How many samples to collect for each benchmark")
  var samples = 20
  
  @Option(help: "Debug benchmark regexes")
  var debug = false
  
  @Option(help: "Output folder")
  var outputPath = "./results/"
  
  @Option(help: "Should the results be saved")
  var save = false
  
  @Option(help: "Compare this result with the latest saved result")
  var compare = false
    
  func makeRunner() -> BenchmarkRunner {
    var benchmark = BenchmarkRunner("RegexBench", samples, outputPath)
    benchmark.addReluctantQuant()
    benchmark.addCSS()
    benchmark.addNotFound()
    benchmark.addGraphemeBreak()
    benchmark.addHangulSyllable()
    benchmark.addHTML()
    benchmark.addEmail()
    return benchmark
  }
  
  mutating func run() throws {
    var runner = makeRunner()
    if !self.specificBenchmarks.isEmpty {
      runner.suite = runner.suite.filter { b in specificBenchmarks.contains(b.name) }
    }
    switch (profile, debug) {
    case (true, true): print("Cannot run both profile and debug")
    case (true, false): runner.profile()
    case (false, true): runner.debug()
    case (false, false):
      runner.run()
      if save {
        try runner.save()
      }
      if compare {
        try runner.compare()
      }
    }
  }
}
