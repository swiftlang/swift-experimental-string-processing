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

struct MEProgram {
  typealias Input = String

  typealias ConsumeFunction = (Input, Range<Input.Index>) -> Input.Index?
  typealias TransformFunction =
    (Input, Processor._StoredCapture) throws -> Any?
  typealias MatcherFunction =
    (Input, Input.Index, Range<Input.Index>) throws -> (Input.Index, Any)?

  var instructions: InstructionList<Instruction>
  var wholeMatchValueRegister: ValueRegister?

  var enableTracing: Bool
  var enableMetrics: Bool
  
  let captureList: CaptureList
  let referencedCaptureOffsets: [ReferenceID: Int]
  
  var initialOptions: MatchingOptions
  var canOnlyMatchAtStart: Bool

  // We store the initial register state in the program, so that
  // processors can be spun up quicker (useful for running same regex
  // over many, many smaller inputs).
  var registers: Processor.Registers
  var storedCaptures: [Processor._StoredCapture]

}

extension MEProgram: CustomStringConvertible {
  var description: String {
    // TODO: Re-instate better pretty-printing functionality

    var result = """

    """
    // TODO: Extract into formatting code

    for idx in instructions.indices {
      let inst = instructions[idx]
      result += "[\(idx.rawValue)] \(inst)"
      if let ia = inst.instructionAddress {
        result += " // \(instructions[ia])"
      }
      result += "\n"
    }
    return result
  }
}
