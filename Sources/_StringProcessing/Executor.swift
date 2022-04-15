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

import _RegexParser

struct Executor {
  // TODO: consider let, for now lets us toggle tracing
  var engine: Engine<String>

  init(program: Program, enablesTracing: Bool = false) {
    self.engine = Engine(program, enableTracing: enablesTracing)
  }

  @available(SwiftStdlib 5.7, *)
  func match<Output>(
    _ input: String,
    in inputRange: Range<String.Index>,
    _ mode: MatchMode
  ) throws -> Regex<Output>.Match? {
    var cpu = engine.makeProcessor(
      input: input, bounds: inputRange, matchMode: mode)

    guard let endIdx = cpu.consume() else {
      if let e = cpu.failureReason {
        throw e
      }
      return nil
    }

    let capList = CaptureList(
      values: cpu.storedCaptures,
      referencedCaptureOffsets: engine.program.referencedCaptureOffsets)

    let capStruct = engine.program.captureStructure
    let range = inputRange.lowerBound..<endIdx
    let caps = try capStruct.structuralize(
        capList, input)

    // FIXME: This is a workaround for not tracking (or
    // specially compiling) whole-match values.
    let value: Any?
    if Output.self != Substring.self,
       Output.self != AnyRegexOutput.self,
       caps.isEmpty
    {
      value = cpu.registers.values.first
      assert(value != nil, "hmm, what would this mean?")
    } else {
      value = nil
    }

    return .init(
      input: input,
      range: range,
      rawCaptures: caps,
      referencedCaptureOffsets: capList.referencedCaptureOffsets,
      value: value)
  }

  @available(SwiftStdlib 5.7, *)
  func dynamicMatch(
    _ input: String,
    in inputRange: Range<String.Index>,
    _ mode: MatchMode
  ) throws -> Regex<AnyRegexOutput>.Match? {
    try match(input, in: inputRange, mode)
  }
}
