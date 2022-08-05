@_spi(RegexBenchmark) import _StringProcessing
import Foundation

protocol RegexBenchmark {
  var name: String { get }
  mutating func compile()
  func run()
  func debug()
}

struct Benchmark: RegexBenchmark {
  let name: String
  var regex: Regex<AnyRegexOutput>
  let type: MatchType
  let target: String

  enum MatchType {
    case whole
    case first
    case allMatches
  }
  
  mutating func compile() {
    let _ = regex._forceAction(.recompile)
  }
  
  mutating func enableTracing() {
    let _ = regex._forceAction(.addOptions(.enableTracing))
  }
  mutating func enableMetrics() {
    let _ = regex._forceAction(.addOptions([.enableMetrics, .disableOptimizations]))
  }
  
  func run() {
    switch type {
    case .whole: blackHole(target.wholeMatch(of: regex))
    case .allMatches: blackHole(target.matches(of: regex))
    case .first: blackHole(target.firstMatch(of: regex))
    }
  }
}

struct NSBenchmark: RegexBenchmark {
  let name: String
  let regex: NSRegularExpression
  let type: NSMatchType
  let target: String
  
  var range: NSRange {
    NSRange(target.startIndex..<target.endIndex, in: target)
  }

  enum NSMatchType {
    case allMatches
    case first
  }
  
  // Not measured for NSRegularExpression
  mutating func compile() {}
  
  func run() {
    switch type {
    case .allMatches: blackHole(regex.matches(in: target, range: range))
    case .first: blackHole(regex.firstMatch(in: target, range: range))
    }
  }
}

/// A benchmark running a regex on strings in input set
struct InputListBenchmark: RegexBenchmark {
  let name: String
  var regex: Regex<AnyRegexOutput>
  let targets: [String]
  
  mutating func compile() {
    blackHole(regex._forceAction(.recompile))
  }
  mutating func enableTracing() {
    let _ = regex._forceAction(.addOptions(.enableTracing))
  }
  mutating func enableMetrics() {
    let _ = regex._forceAction(.addOptions(.enableMetrics))
  }

  func run() {
    for target in targets {
      blackHole(target.wholeMatch(of: regex))
    }
  }
}

struct InputListNSBenchmark: RegexBenchmark {
  let name: String
  let regex: NSRegularExpression
  let targets: [String]
  
  init(name: String, regex: String, targets: [String]) {
    self.name = name
    self.regex = try! NSRegularExpression(pattern: "^" + regex + "$")
    self.targets = targets
  }
  
  func range(in target: String) -> NSRange {
    NSRange(target.startIndex..<target.endIndex, in: target)
  }
  
  mutating func compile() {}

  func run() {
    for target in targets {
      let range = range(in: target)
      blackHole(regex.firstMatch(in: target, range: range))
    }
  }
}

/// A benchmark meant to be ran across multiple engines
struct CrossBenchmark {
  /// Suffix added onto NSRegularExpression benchmarks
  static let nsSuffix = "_NS"
  
  /// The base name of the benchmark
  var baseName: String

  /// The string to compile in differnet engines
  var regex: String

  /// The text to search
  var input: String

  // TODO: var output, for validation

  /// Whether this is whole string matching or a searching benchmark
  ///
  /// TODO: Probably better ot have a whole-line vs search anywhere, maybe
  /// accomodate multi-line matching, etc.
  var isWhole: Bool = false
  
  /// Whether or not to do firstMatch as well or just allMatches
  var includeFirst: Bool = false

  func register(_ runner: inout BenchmarkRunner) {
    let swiftRegex = try! Regex(regex)
    let nsRegex: NSRegularExpression
    if isWhole {
      nsRegex = try! NSRegularExpression(pattern: "^" + regex + "$")
    } else {
      nsRegex = try! NSRegularExpression(pattern: regex)
    }

    if isWhole {
      runner.register(
        Benchmark(
          name: baseName + "Whole",
          regex: swiftRegex,
          type: .whole,
          target: input))
      runner.register(
        NSBenchmark(
          name: baseName + "Whole" + CrossBenchmark.nsSuffix,
          regex: nsRegex,
          type: .first,
          target: input))
    } else {
      runner.register(
        Benchmark(
          name: baseName + "All",
          regex: swiftRegex,
          type: .allMatches,
          target: input))
      runner.register(
        NSBenchmark(
          name: baseName + "All" + CrossBenchmark.nsSuffix,
          regex: nsRegex,
          type: .allMatches,
          target: input))
      if includeFirst || runner.includeFirstOverride {
        runner.register(
          Benchmark(
            name: baseName + "First",
            regex: swiftRegex,
            type: .first,
            target: input))
        runner.register(
          NSBenchmark(
            name: baseName + "First" + CrossBenchmark.nsSuffix,
            regex: nsRegex,
            type: .first,
            target: input))
      }
    }
  }
}

/// A benchmark running a regex on strings in input list, run across multiple engines
struct CrossInputListBenchmark {
  /// The base name of the benchmark
  var baseName: String

  /// The string to compile in differnet engines
  var regex: String

  /// The list of strings to search
  var inputs: [String]
  
  func register(_ runner: inout BenchmarkRunner) {
    let swiftRegex = try! Regex(regex)
    runner.register(InputListBenchmark(
      name: baseName,
      regex: swiftRegex,
      targets: inputs
    ))
    runner.register(InputListNSBenchmark(
      name: baseName + "NS",
      regex: regex,
      targets: inputs
    ))
  }
}

// TODO: Capture-containing benchmarks

// nom nom nom, consume the argument
@inline(never)
func blackHole<T>(_ x: T) {
}
