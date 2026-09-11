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
    /// The current position in the instruction list.
    var pc: InstructionAddress
    
    /// The current position in the input, when this save point represents a single position.
    ///
    /// `pos` is `nil` whenever `quantifiedRange` has a value, and can also be `nil`
    /// when the save point is only for backtracking to a previous instruction address.
    var pos: Position?

    /// The current range in the input, when this save point represents a range of positions.
    var quantifiedRange: Range<Position>?

    // FIXME: refactor, for now this field is only used for quantifier save
    //        points. We should try to separate out the concerns better.
    /// Indicates whether this save point has scalar or grapheme semantics.
    var isScalarSemantics: Bool

    // These properties store indices into the mutable `Processor.Registers`
    // LoggingArray logs. On backtrack, each log is unwound down to the
    // point saved here.

    /// The length of the log of the `captures` register when this save point was created,
    /// for backtracking on failure.
    var captureLogEnd: Int
    /// The length of the log of the `ints` register when this save point was created,
    /// for backtracking on failure.
    var intLogEnd: Int
    /// The length of the log of the `positions` register when this save point was created,
    /// for backtracking on failure.
    var positionLogEnd: Int

    /// Whether this save point is quantified, meaning it has a range of
    /// possible positions to explore.
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
      captureLogEnd: registers.storedCaptures.logCount,
      intLogEnd: registers.ints.logCount,
      positionLogEnd: registers.positions.logCount)
  }

  func makeAddressOnlySavePoint(
    resumingAt pc: InstructionAddress
  ) -> SavePoint {
    SavePoint(
      pc: pc,
      pos: nil,
      quantifiedRange: nil,
      isScalarSemantics: false,
      captureLogEnd: registers.storedCaptures.logCount,
      intLogEnd: registers.ints.logCount,
      positionLogEnd: registers.positions.logCount)
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
      captureLogEnd: registers.storedCaptures.logCount,
      intLogEnd: registers.ints.logCount,
      positionLogEnd: registers.positions.logCount)
  }
}


