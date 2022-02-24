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

extension Engine where Input == String {
  func consume(
    _ input: Input
  ) -> (Input.Index, CaptureList)? {
    consume(input, in: input.startIndex ..< input.endIndex)
  }

  func consume(
    _ input: Input,
    in range: Range<Input.Index>,
    matchMode: MatchMode = .partialFromFront
  ) -> (Input.Index, CaptureList)? {
    if enableTracing {
      print("Consume: \(input)")
    }

    var cpu = makeProcessor(input: input, bounds: range, matchMode: matchMode)
    let result: Input.Index? = {
      while true {
        switch cpu.state {
        case .accept:
          return cpu.currentPosition
        case .fail:
          return nil
        case .inProgress: cpu.cycle()
        }
      }
    }()

    if enableTracing {
      if let idx = result {
        print("Result: \(input[..<idx]) | \(input[idx...])")
      } else {
        print("Result: nil")
      }
    }
    guard let result = result else { return nil }

    let capList = cpu.storedCaptures
    return (result, CaptureList(
      values: capList, referencedCaptureOffsets: program.referencedCaptureOffsets))
  }
}

