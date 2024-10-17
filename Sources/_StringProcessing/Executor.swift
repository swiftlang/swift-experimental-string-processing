//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal import _RegexParser

/// `Executor` encapsulates the execution of the regex engine post-compilation.
/// It doesn't know anything about the `Regex` type or how to compile a regex.
@available(SwiftStdlib 5.7, *)
enum Executor<Output> {
  static func prefixMatch(
    _ program: MEProgram,
    _ input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>
  ) throws -> Regex<Output>.Match? {
    try Executor._run(
      program,
      input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      mode: .partialFromFront)
  }

  static func wholeMatch(
    _ program: MEProgram,
    _ input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>
  ) throws -> Regex<Output>.Match? {
    try Executor._run(
      program,
      input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      mode: .wholeString)
  }

  static func firstMatch(
    _ program: MEProgram,
    _ input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>
  ) throws -> Regex<Output>.Match? {
    var cpu = Processor(
      program: program,
      input: input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      matchMode: .partialFromFront)
    return try Executor._firstMatch(
      program,
      using: &cpu)
  }

  static func _firstMatch(
    _ program: MEProgram,
    using cpu: inout Processor
  ) throws -> Regex<Output>.Match? {
    let isGraphemeSemantic = program.initialOptions.semanticLevel == .graphemeCluster

    var low = cpu.searchBounds.lowerBound
    let high = cpu.searchBounds.upperBound
    while true {
      if let m = try Executor._run(program, &cpu) {
        return m
      }
      // Fast-path for start-anchored regex
      if program.canOnlyMatchAtStart {
        return nil
      }
      if low == high { return nil }
      if isGraphemeSemantic {
        cpu.input.formIndex(after: &low)
      } else {
        cpu.input.unicodeScalars.formIndex(after: &low)
      }
      guard low <= high else {
        return nil
      }
      cpu.reset(currentPosition: low, searchBounds: cpu.searchBounds)
    }
  }
}

@available(SwiftStdlib 5.7, *)
extension Executor {
  struct Matches: Sequence {
    var program: MEProgram
    var input: String
    var subjectBounds: Range<String.Index>
    var searchBounds: Range<String.Index>

    struct Iterator: IteratorProtocol {
      var program: MEProgram
      var processor: Processor
      var finished = false
    }

    func makeIterator() -> Iterator {
      Iterator(
        program: program,
        processor: Processor(
          program: program,
          input: input,
          subjectBounds: subjectBounds,
          searchBounds: searchBounds,
          matchMode: .partialFromFront))
    }
  }
}

@available(SwiftStdlib 5.7, *)
extension Executor.Matches.Iterator {
  func nextSearchIndex(
    after range: Range<String.Index>
  ) -> String.Index? {
    if !range.isEmpty {
      return range.upperBound
    }

    // If the last match was an empty match, advance by one position and
    // run again, unless at the end of `input`.
    guard range.lowerBound < processor.subjectBounds.upperBound else {
      return nil
    }

    switch program.initialOptions.semanticLevel {
    case .graphemeCluster:
      return processor.input.index(after: range.upperBound)
    case .unicodeScalar:
      return processor.input.unicodeScalars.index(after: range.upperBound)
    }
  }

  mutating func next() -> Regex<Output>.Match? {
    if finished {
      return nil
    }
    guard let match = try? Executor._firstMatch(
      program, using: &processor
    ) else {
      return nil
    }

    // If there's more input to process, advance our position
    // and search bounds. Otherwise, set to fail fast.
    if let currentPosition = nextSearchIndex(after: match.range) {
      processor.reset(
        currentPosition: currentPosition,
        searchBounds: currentPosition..<processor.searchBounds.upperBound)
    } else {
      finished = true
    }
    return match
  }
}

@available(SwiftStdlib 5.7, *)
extension Executor {
  static func _run(
    _ program: MEProgram,
    _ input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>,
    mode: MatchMode
  ) throws -> Regex<Output>.Match? {
    var cpu = Processor(
      program: program,
      input: input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      matchMode: mode)
    return try _run(program, &cpu)
  }

  static func _run(
    _ program: MEProgram,
    _ cpu: inout Processor
  ) throws -> Regex<Output>.Match? {

    let startPosition = cpu.currentPosition
    guard let endIdx = try cpu.run() else {
      return nil
    }
    let capList = MECaptureList(
      values: cpu.storedCaptures,
      referencedCaptureOffsets: program.referencedCaptureOffsets)

    let range = startPosition..<endIdx
    let caps = program.captureList.createElements(capList)

    let anyRegexOutput = AnyRegexOutput(
      input: cpu.input, elements: caps)
    return .init(anyRegexOutput: anyRegexOutput, range: range)
  }}

extension Processor {
  fileprivate mutating func run() throws -> Input.Index? {
#if PROCESSOR_MEASUREMENTS_ENABLED
    defer { if cpu.metrics.shouldMeasureMetrics { cpu.printMetrics() } }
#endif
    if self.state == .fail {
      if let e = failureReason {
        throw e
      }
      return nil
    }
    assert(isReset())
    while true {
      switch self.state {
      case .accept:
        return self.currentPosition
      case .fail:
        if let e = failureReason {
          throw e
        }
        return nil
      case .inProgress: self.cycle()
      }
    }
  }
}
