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
  struct SavePoint {
    var pc: InstructionAddress
    var pos: Position?
    // Quantifiers may store a range of positions to restore to
    var rangeStart: Position?
    var rangeEnd: Position?
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
      assert(rangeIsEmpty)
      return (pc, pos, stackEnd, captureEnds, intRegisters, posRegisters)
    }
    
    var rangeIsEmpty: Bool { rangeEnd == nil }
    
    mutating func updateRange(newEnd: Input.Index) {
      if rangeStart == nil {
        rangeStart = newEnd
      }
      rangeEnd = newEnd
    }

    mutating func removeLast(_ input: Input) -> (
      pc: InstructionAddress,
      pos: Position?,
      stackEnd: CallStackAddress,
      captureEnds: [_StoredCapture],
      intRegisters: [Int],
      PositionRegister: [Input.Index]
    ) {
      assert(!rangeIsEmpty)
      let pos = rangeEnd!
      if pos == rangeStart {
        // The range is now empty
        rangeStart = nil
        rangeEnd = nil
      } else {
        rangeEnd = input.index(before: pos)
      }
      return (pc, pos, stackEnd, captureEnds, intRegisters, posRegisters)
    }
  }

  func makeSavePoint(
    _ pc: InstructionAddress,
    addressOnly: Bool = false
  ) -> SavePoint {
    SavePoint(
      pc: pc,
      pos: addressOnly ? nil : currentPosition,
      rangeStart: nil,
      rangeEnd: nil,
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions)
  }
  
  func startQuantifierSavePoint() -> SavePoint {
    // Restores to the instruction AFTER the current quantifier instruction
    SavePoint(
      pc: controller.pc + 1,
      pos: nil,
      rangeStart: nil,
      rangeEnd: nil,
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions)
  }
}


