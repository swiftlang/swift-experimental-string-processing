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

@_implementationOnly import _RegexParser

struct Executor {
  // TODO: consider let, for now lets us toggle tracing
  var engine: Engine<String>

  init(program: Program, enablesTracing: Bool = false) {
    self.engine = Engine(program, enableTracing: enablesTracing)
  }

  @available(SwiftStdlib 5.7, *)
  func match<Output>(
    _ input: String,
    in subjectBounds: Range<String.Index>,
    _ mode: MatchMode
  ) throws -> Regex<Output>.Match? {
    var cpu = engine.makeProcessor(
      input: input, bounds: subjectBounds, matchMode: mode)

    guard let endIdx = cpu.consume() else {
      if let e = cpu.failureReason {
        throw e
      }
      return nil
    }

    let capList = MECaptureList(
      values: cpu.storedCaptures,
      referencedCaptureOffsets: engine.program.referencedCaptureOffsets)

    let range = subjectBounds.lowerBound..<endIdx
    let caps = engine.program.captureList.createElements(capList)

    let anyRegexOutput = AnyRegexOutput(input: input, elements: caps)
    return .init(anyRegexOutput: anyRegexOutput, range: range)
  }

  @available(SwiftStdlib 5.7, *)
  func dynamicMatch(
    _ input: String,
    in subjectBounds: Range<String.Index>,
    _ mode: MatchMode
  ) throws -> Regex<AnyRegexOutput>.Match? {
    try match(input, in: subjectBounds, mode)
  }
}
