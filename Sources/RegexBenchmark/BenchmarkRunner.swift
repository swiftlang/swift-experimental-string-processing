import Foundation

struct BenchmarkRunner {
  let suiteName: String
  var suite: [any RegexBenchmark] = []
  
  let samples: Int
  var results: SuiteResult = SuiteResult()
  let quiet: Bool

  init(_ suiteName: String, _ n: Int, _ quiet: Bool) {
    self.suiteName = suiteName
    self.samples = n
    self.quiet = quiet
  }
  
  mutating func register(_ new: some RegexBenchmark) {
    suite.append(new)
  }
  
  mutating func measure(benchmark: some RegexBenchmark, samples: Int) -> BenchmarkResult {
    var times: [Time] = []
    
    // initial run to make sure the regex has been compiled
    // FIXME: this is a very poor way of estimating compile time
    // we should have some sort of interface directly with the engine to measure this
    // This also completely breaks when we rerun measure() for variant results
    let initialStart = Tick.now
    benchmark.run()
    let initialEnd = Tick.now
    let initialRunTime = initialEnd.elapsedTime(since: initialStart)
    
    // FIXME: use suspendingclock?
    for _ in 0..<samples {
      let start = Tick.now
      benchmark.run()
      let end = Tick.now
      let time = end.elapsedTime(since: start)
      times.append(time)
    }

    times.sort()
    let median = times[samples/2]
    let mean = times.reduce(0.0, {acc, next in acc + next.seconds}) / Double(times.count)
    let stdev = (times.reduce(0.0, {acc, next in acc + pow(next.seconds - mean, 2)}) / Double(times.count)).squareRoot()
    return BenchmarkResult(initialRunTime, median, stdev, samples)
  }
  
  mutating func run() {
    print("Running")
    for b in suite {
      var result = measure(benchmark: b, samples: samples)
      if result.stdev > Stats.maxAllowedStdev {
        print("Warning: Standard deviation > \(Time(Stats.maxAllowedStdev)) for \(b.name)")
        print("N = \(samples), median: \(result.median), stdev: \(Time(result.stdev))")
        print("Rerunning \(b.name)")
        result = measure(benchmark: b, samples: result.samples*2)
        print("N = \(result.samples), median: \(result.median), stdev: \(Time(result.stdev))")
        if result.stdev > Stats.maxAllowedStdev {
          fatalError("Benchmark \(b.name) is too variant")
        }
      }
      if !quiet {
        print("- \(b.name) \(result.median) (stdev: \(Time(result.stdev))) (estimated compile time: \(result.estimatedCompileTime))")
      }
      self.results.add(name: b.name, result: result)
    }
  }
    
  mutating func debug() {
    print("Debugging")
    print("========================")
    for b in suite {
      let result = measure(benchmark: b, samples: samples)
      print("- \(b.name) \(result.median) (stdev: \(Time(result.stdev)))")
      b.debug()
      print("========================")
    }
  }
}
