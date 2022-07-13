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

extension Processor {
  enum SavePoint {
    case basic(BasicSavePoint)
    case quant(QuantifierSavePoint)
    
    var pc: InstructionAddress {
      switch self {
      case .basic(let sp): return sp.pc
      case .quant(let sp): return sp.pc
      }
    }
  }
  
  struct BasicSavePoint {
    var pc: InstructionAddress
    var pos: Position?

    // The end of the call stack, so we can slice it off
    // when failing inside a call.
    //
    // NOTE: Alternatively, also place return addresses on the
    // save point stack
    var stackEnd: CallStackAddress

    // FIXME: Save minimal info (e.g. stack position and
    // perhaps current start)
    var captureEnds: [_StoredCapture]

    // The int registers store values that can be relevant to
    // backtracking, such as the number of trips in a quantification.
    var intRegisters: [Int]
    // Same with position registers
    var posRegisters: [Input.Index]

    var destructure: (
      pc: InstructionAddress,
      pos: Position?,
      stackEnd: CallStackAddress,
      captureEnds: [_StoredCapture],
      intRegisters: [Int],
      PositionRegister: [Input.Index]
    ) {
      (pc, pos, stackEnd, captureEnds, intRegisters, posRegisters)
    }
  }
  
  struct QuantifierSavePoint {
    var pc: InstructionAddress
    var quantifiedPositions: [Position]
    var stackEnd: CallStackAddress
    var captureEnds: [_StoredCapture]
    var intRegisters: [Int]
    var posRegisters: [Input.Index]


    mutating func pop() -> (
      pc: InstructionAddress,
      pos: Position,
      stackEnd: CallStackAddress,
      captureEnds: [_StoredCapture],
      intRegisters: [Int],
      PositionRegister: [Input.Index]
    ) {
      (pc, quantifiedPositions.popLast()!, stackEnd, captureEnds, intRegisters, posRegisters)
    }
    
    var isEmpty: Bool { quantifiedPositions.isEmpty }
  }

  func makeSavePoint(
    _ pc: InstructionAddress,
    addressOnly: Bool = false
  ) -> SavePoint {
    .basic(BasicSavePoint(
      pc: pc,
      pos: addressOnly ? nil : currentPosition,
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions))
  }
  
  func startQuantifierSavePoint() -> QuantifierSavePoint {
    // Restores to the instruction AFTER the current quantifier instruction
    QuantifierSavePoint(
      pc: controller.pc + 1,
      quantifiedPositions: [],
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions)
  }
}


