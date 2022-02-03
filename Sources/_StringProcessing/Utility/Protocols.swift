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


// These currently only drive tracing/formatting, but could drive
// more

public protocol InstructionProtocol {
  var operandPC: InstructionAddress? { get }
}

public protocol ProcessorProtocol {
  associatedtype Input: Collection
  associatedtype Instruction: InstructionProtocol
  associatedtype SavePoint = ()
  associatedtype Registers = ()

  var cycleCount: Int { get }
  var input: Input { get }

  var currentPosition: Input.Index { get }
  var currentPC: InstructionAddress { get }

  var instructions: InstructionList<Instruction> { get }

  var isAcceptState: Bool { get }
  var isFailState: Bool { get }

  // Provide to get call stack formatting, default empty
  var callStack: Array<InstructionAddress> { get }

  // Provide to get save point formatting, default empty
  var savePoints: Array<SavePoint> { get }

  // Provide to get register formatting, default empty
  var registers: Registers { get }
}

extension ProcessorProtocol {
  public func fetch() -> Instruction {
    instructions[currentPC]
  }

  public var callStack: Array<InstructionAddress> { [] }
//  public var savePoints: Array<SavePoint> { [] }
  public var registers: Array<Registers> { [] }

}
