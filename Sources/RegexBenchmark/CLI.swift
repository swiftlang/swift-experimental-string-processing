import ArgumentParser

@main
struct Runner: ParsableCommand {
  @Argument(help: "Names of benchmarks to run")
  var specificBenchmarks: [String] = []
  
  @Flag(help: "Run only once for profiling purposes")
  var profile = false
  
  @Option(help: "How many samples to collect for each benchmark")
  var samples = 20
  
  @Flag(help: "Debug benchmark regexes")
  var debug = false
  
  @Option(help: "Output folder")
  var outputPath = "./results/"
  
  @Flag(help: "Should the results be saved")
  var save = false
  
  @Flag(help: "Compare this result with the latest saved result")
  var compare = false
      
  mutating func run() throws {
    var runner = BenchmarkRunner.makeRunner(samples, outputPath)
    
    // todo: regex based filter 
    if !self.specificBenchmarks.isEmpty {
      runner.suite = runner.suite.filter { b in specificBenchmarks.contains(b.name) }
    }
    switch (profile, debug) {
    case (true, true): print("Cannot run both profile and debug")
    case (true, false): runner.profile()
    case (false, true): runner.debug()
    case (false, false):
      runner.run()
      if compare {
        try runner.compare()
      }
      if save {
        try runner.save()
      }
    }
  }
}
