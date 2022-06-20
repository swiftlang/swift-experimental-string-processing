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
    
  func makeRunner() -> BenchmarkRunner {
    var benchmark = BenchmarkRunner("RegexBench", samples)
    benchmark.addReluctantQuant()
    benchmark.addCSS()
    benchmark.addNotFound()
    benchmark.addGraphemeBreak()
    benchmark.addHangulSyllable()
    benchmark.addHTML()
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
    case (false, false): runner.run()
    }
  }
}
