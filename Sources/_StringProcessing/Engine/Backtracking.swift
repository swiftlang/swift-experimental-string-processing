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

    // FIXME: refactor, for now this field is only used for quantifier save
    //        points. We should try to separate out the concerns better.
    var isScalarSemantics: Bool

    // The end of the call stack, so we can slice it off
    // when failing inside a call.
    //
    // NOTE: Alternatively, also place return addresses on the
    // save point stack
    var stackEnd: CallStackAddress

    var savedStateIndex: Array.Index

    var destructure: (
      pc: InstructionAddress,
      pos: Position?,
      stackEnd: CallStackAddress,
      savedStateIndex: Array.Index
    ) {
      return (pc, pos, stackEnd, savedStateIndex)
    }

    var rangeIsEmpty: Bool { rangeEnd == nil }

    mutating func updateRange(newEnd: Input.Index) {
      if rangeStart == nil {
        rangeStart = newEnd
      }
      rangeEnd = newEnd
    }

    /// Move the next range position into pos, and removing it from the range
    mutating func takePositionFromRange(_ input: Input) {
      assert(!rangeIsEmpty)
      pos = rangeEnd!
      shrinkRange(input)
    }

    /// Shrink the range of the save point by one index, essentially dropping the last index
    mutating func shrinkRange(_ input: Input) {
      assert(!rangeIsEmpty)
      if rangeEnd == rangeStart {
        // The range is now empty
        rangeStart = nil
        rangeEnd = nil
      } else {
        if isScalarSemantics {
          input.unicodeScalars.formIndex(before: &rangeEnd!)
        } else {
          input.formIndex(before: &rangeEnd!)
        }
      }
    }
  }

  mutating func makeSavePoint(
    _ pc: InstructionAddress,
    addressOnly: Bool = false
  ) -> SavePoint {
    // TODO: Only push back if there's been a change in state
    savedState.append(.init(
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions))

    return SavePoint(
      pc: pc,
      pos: addressOnly ? nil : currentPosition,
      rangeStart: nil,
      rangeEnd: nil,
      isScalarSemantics: false, // FIXME: refactor away
      stackEnd: .init(callStack.count),
      savedStateIndex: savedState.index(before: savedState.endIndex))
  }
  
  mutating func startQuantifierSavePoint(
    isScalarSemantics: Bool
  ) -> SavePoint {
    // TODO: Only push back if there's been a change in state
    savedState.append(.init(
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions))

    // Restores to the instruction AFTER the current quantifier instruction
    return SavePoint(
      pc: controller.pc + 1,
      pos: nil,
      rangeStart: nil,
      rangeEnd: nil,
      isScalarSemantics: isScalarSemantics,
      stackEnd: .init(callStack.count),
      savedStateIndex: savedState.index(before: savedState.endIndex))
  }
}


