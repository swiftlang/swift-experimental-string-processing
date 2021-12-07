import _MatchingEngine

public struct Executor {
  let engine: Engine<String>

  public init(program: RegexProgram, enablesTracing: Bool = false) {
    self.engine = Engine(program.program, enableTracing: enablesTracing)
  }

  public func execute(
    input: String,
    in range: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> MatchResult? {
    engine.consume(
      input, in: range, matchMode: mode.loweredMatchMode
    ).map { endIndex in
      MatchResult(range.lowerBound..<endIndex, .void)
    }
  }
}

// Backward compatibility layer. To be removed when we deprecate legacy
// components.
extension Executor: VirtualMachine {
  public static let motto = "Executor"

  public init(program: RegexProgram) {
    self.init(program: program, enablesTracing: false)
  }
}

extension Regex.MatchMode {
  var loweredMatchMode: _MatchingEngine.MatchMode {
    switch self {
    case .wholeString:
      return .full
    case .partialFromFront:
      return .prefix
    }
  }
}
