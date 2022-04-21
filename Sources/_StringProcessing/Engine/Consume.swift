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
    input: Input, bounds: Range<Input.Index>, matchMode: MatchMode
  ) -> Processor<Input> {
    Processor(
      program: program,
      input: input,
      bounds: bounds,
      matchMode: matchMode,
      isTracingEnabled: enableTracing)
  }
}

extension Processor where Input == String {
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

