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

var checkComments = true

extension Engine {
  func makeProcessor(
    input: String, bounds: Range<String.Index>, matchMode: MatchMode
  ) -> Processor {
    Processor(
      program: program,
      input: input,
      subjectBounds: bounds,
      searchBounds: bounds,
      matchMode: matchMode,
      isTracingEnabled: enableTracing,
      shouldMeasureMetrics: enableMetrics)
  }
  
  func makeFirstMatchProcessor(
    input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>
  ) -> Processor {
    Processor(
      program: program,
      input: input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      matchMode: .partialFromFront,
      isTracingEnabled: enableTracing,
      shouldMeasureMetrics: enableMetrics)
  }
}

extension Processor {
  // TODO: Should we throw here?
  mutating func consume() -> Input.Index? {
    while true {
      switch self.state {
      case .accept:
        return self.currentPosition
      case .fail:
        return nil
      case .inProgress: self.cycle()
      }
    }
  }
}

