import ArgumentParser

@main
struct Runner: ParsableCommand {
  @Argument(help: "Names of benchmarks to run")
  var specificBenchmarks: [String] = []
  
  @Option(help: "Run only once for profiling purposes")
  var profile = false
  
  @Option(help: "How many samples to collect for each benchmark")
  var samples = 20
    
  func makeRunner() -> BenchmarkRunner {
    var benchmark = BenchmarkRunner("RegexBench", samples)
    benchmark.addReluctantQuant()
    benchmark.addCSS()
    benchmark.addNotFound()
    benchmark.addGraphemeBreak()
    return benchmark
  }
  mutating func run() throws {
    var runner = makeRunner()
    if !self.specificBenchmarks.isEmpty {
      runner.suite = runner.suite.filter { b in specificBenchmarks.contains(b.name) }
    }
    if profile {
      runner.profile()
    } else {
      runner.run()
    }
  }
}
