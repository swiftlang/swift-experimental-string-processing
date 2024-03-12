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
    var quantifiedRange: Range<Position>?

    // FIXME: refactor, for now this field is only used for quantifier save
    //        points. We should try to separate out the concerns better.
    var isScalarSemantics: Bool

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
      return (pc, pos, stackEnd, captureEnds, intRegisters, posRegisters)
    }

    // Whether this save point is quantified, meaning it has a range of
    // possible positions to explore.
    var isQuantified: Bool {
      quantifiedRange != nil
    }

    /// Move the next range position into pos, and removing it from the range
    mutating func takePositionFromQuantifiedRange(_ input: Input) {
      assert(isQuantified)
      let range = quantifiedRange!
      pos = range.upperBound
      if range.isEmpty {
        // Becomes a normal save point
        quantifiedRange = nil
        return
      }

      // Shrink the range
      let newUpper: Position
      if isScalarSemantics {
        newUpper = input.unicodeScalars.index(before: range.upperBound)
      } else {
        newUpper = input.index(before: range.upperBound)
      }
      quantifiedRange = range.lowerBound..<newUpper
    }
  }

  func makeSavePoint(
    resumingAt pc: InstructionAddress
  ) -> SavePoint {
    SavePoint(
      pc: pc,
      pos: currentPosition,
      quantifiedRange: nil,
      isScalarSemantics: false,
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions)
  }

  func makeAddressOnlySavePoint(
    resumingAt pc: InstructionAddress
  ) -> SavePoint {
    SavePoint(
      pc: pc,
      pos: nil,
      quantifiedRange: nil,
      isScalarSemantics: false,
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions)
  }

  func makeQuantifiedSavePoint(
    _ range: Range<Position>,
    isScalarSemantics: Bool
  ) -> SavePoint {
    SavePoint(
      pc: controller.pc + 1,
      pos: nil,
      quantifiedRange: range,
      isScalarSemantics: isScalarSemantics,
      stackEnd: .init(callStack.count),
      captureEnds: storedCaptures,
      intRegisters: registers.ints,
      posRegisters: registers.positions)
  }
}


