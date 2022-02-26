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

import _MatchingEngine

struct Executor {
  // TODO: consider let, for now lets us toggle tracing
  var engine: Engine<String>

  init(program: Program, enablesTracing: Bool = false) {
    self.engine = Engine(program, enableTracing: enablesTracing)
  }

  func match<Match>(
    _ input: String,
    in inputRange: Range<String.Index>,
    _ mode: MatchMode
  ) throws -> RegexMatch<Match>? {
    guard let (endIdx, capList) = engine.consume(
      input, in: inputRange, matchMode: mode
    ) else {
      return nil
    }
    let capStruct = engine.program.captureStructure
    let range = inputRange.lowerBound..<endIdx
    let caps = try capStruct.structuralize(
        capList, input)

    return RegexMatch(
      input: input,
      range: range,
      rawCaptures: caps,
      referencedCaptureOffsets: capList.referencedCaptureOffsets)
  }

  func dynamicMatch(
    _ input: String,
    in inputRange: Range<String.Index>,
    _ mode: MatchMode
  ) throws -> RegexMatch<(Substring, DynamicCaptures)>? {
    try match(input, in: inputRange, mode)
  }
}
