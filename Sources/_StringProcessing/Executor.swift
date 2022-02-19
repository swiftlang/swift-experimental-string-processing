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

public struct Executor {
  // TODO: consider let, for now lets us toggle tracing
  var engine: Engine<String>

  init(program: Program, enablesTracing: Bool = false) {
    self.engine = Engine(program, enableTracing: enablesTracing)
  }

  public func execute(
    input: String,
    in range: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> MatchResult? {
    guard let (endIdx, capList) = engine.consume(
      input, in: range, matchMode: mode
    ) else {
      return nil
    }
    let capStruct = engine.program.captureStructure
    do {
      let caps = try capStruct.structuralize(capList, input)
      return MatchResult(range.lowerBound..<endIdx, caps)
    } catch {
      fatalError(String(describing: error))
    }
  }
  public func execute(
    input: Substring,
    mode: MatchMode = .wholeString
  ) -> MatchResult? {
    self.execute(
      input: input.base,
      in: input.startIndex..<input.endIndex,
      mode: mode)
  }

  public func executeFlat(
    input: String,
    in range: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> (Range<String.Index>, CaptureList)? {
    engine.consume(
      input, in: range, matchMode: mode
    ).map { endIndex, capture in
      (range.lowerBound..<endIndex, capture)
    }
  }
}
