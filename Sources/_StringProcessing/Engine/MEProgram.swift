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
  /// Transforms a capture's range, and the custom matcher value for the
  /// capture if there is one.
  typealias TransformFunction =
    (Input, Range<Input.Index>?, Any?) throws -> Any?
  typealias MatcherFunction =
    (Input, Input.Index, Range<Input.Index>) throws -> (Input.Index, Any)?

  var instructions: InstructionList<Instruction>
  var wholeMatchValueRegister: ValueRegister?

  var enableTracing: Bool
  var enableMetrics: Bool
  
  let captureList: CaptureList
  let referencedCaptureOffsets: [ReferenceID: Int]

  /// The registers of non-failable capture transforms, by capture index.
  /// Failable transforms run while matching, and aren't included.
  let captureTransforms: [Int: TransformRegister]
  
  var initialOptions: MatchingOptions
  var canOnlyMatchAtStart: Bool

  // We store the initial register state in the program, so that
  // processors can be spun up quicker (useful for running same regex
  // over many, many smaller inputs).
  var registers: Processor.Registers
}

extension MEProgram: CustomStringConvertible {
  var description: String {
    // TODO: Re-instate better pretty-printing functionality

    var result = """
    Capture list: \(captureList)
    Instructions: \(instructions.count)
    Register counts:
      ints: \(registers.ints.count)
      positions: \(registers.positions.count)
      values: \(registers.values.count)
      elements: \(registers.elements.count)
      bitsets: \(registers.bitsets.count)
      consumeFunctions: \(registers.consumeFunctions.count)
      transformFunctions: \(registers.transformFunctions.count)
      matcherFunctions: \(registers.matcherFunctions.count)
    canOnlyMatchAtStart: \(canOnlyMatchAtStart)

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
