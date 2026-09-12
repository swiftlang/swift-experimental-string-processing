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

    /// What to resume the current match position at when this save point
    /// is invoked, and what (if anything) to keep around for a future
    /// pop of the same save point.
    ///
    /// A save point is in exactly one of these states at a time: a single
    /// position isn't also mid-quantified-range, and vice versa. The
    /// value most recently popped from a quantified range never needs to
    /// be stored here — `popQuantifiedPosition(_:)` returns it directly
    /// to its caller instead, so it doesn't have to coexist in storage
    /// with the (already-shrunk) remaining range.
    enum SavedPosition {
      /// A single position to resume at.
      case position(Position)
      /// A range of positions still to explore, most-recently-matched
      /// first, from a quantifier's greedy over-match, along with
      /// whether the quantifier has scalar or grapheme semantics.
      ///
      /// `isScalarSemantics` only ever matters while popping a range
      /// (see `popQuantifiedPosition(_:)`), so it travels with the range
      /// itself instead of living in its own struct-wide field that the
      /// `position`/`addressOnly` cases would otherwise carry for no
      /// reason.
      case range(Range<Position>, isScalarSemantics: Bool)
      /// No position to restore — only the instruction address matters.
      case addressOnly
    }

    var savedPosition: SavedPosition

    // These properties store indices into the mutable `Processor.Registers`
    // undo logs. On backtrack, each log is unwound down to the point saved
    // here.
    //
    // `UInt32` rather than `Int`: these are lengths of the per-register
    // undo logs, which grow by one entry per logged mutation while this
    // save point (or a newer one) is live. Overflowing 4 billion entries
    // in a single log would already require tens of gigabytes just for
    // that one log, long before this could matter in practice.

    /// The length of the log of the `captures` register when this save point was created,
    /// for backtracking on failure.
    var captureLogEnd: UInt32
    /// The length of the log of the `ints` register when this save point was created,
    /// for backtracking on failure.
    var intLogEnd: UInt32
    /// The length of the log of the `positions` register when this save point was created,
    /// for backtracking on failure.
    var positionLogEnd: UInt32

    /// The single position to resume at, for a save point that isn't
    /// quantified or address-only.
    var pos: Position? {
      if case .position(let p) = savedPosition { return p }
      return nil
    }

    /// Whether this save point is quantified, meaning it has a range of
    /// possible positions still to explore.
    var isQuantified: Bool {
      if case .range = savedPosition { return true }
      return false
    }

    /// Pops the next position to try from a quantified save point's
    /// range, returning it and updating the stored state so a future pop
    /// (if any) tries the next-most-recent position.
    ///
    /// If the range is (or becomes) empty, this save point becomes a
    /// normal, single-position save point for a final future pop.
    mutating func popQuantifiedPosition(_ input: Input) -> Position {
      guard case .range(let range, let isScalarSemantics) = savedPosition else {
        fatalError("Not a quantified save point")
      }
      let resumeAt = range.upperBound
      guard !range.isEmpty else {
        savedPosition = .position(resumeAt)
        return resumeAt
      }

      // Shrink the range
      let newUpper: Position
      if isScalarSemantics {
        newUpper = input.unicodeScalars.index(before: range.upperBound)
      } else {
        newUpper = input.index(before: range.upperBound)
      }
      savedPosition = .range(range.lowerBound..<newUpper, isScalarSemantics: isScalarSemantics)
      return resumeAt
    }
  }

  func makeSavePoint(
    resumingAt pc: InstructionAddress
  ) -> SavePoint {
    SavePoint(
      pc: pc,
      savedPosition: .position(currentPosition),
      captureLogEnd: .init(asserting: registers.storedCaptures.logCount),
      intLogEnd: .init(asserting: registers.ints.logCount),
      positionLogEnd: .init(asserting: registers.positions.logCount))
  }

  func makeAddressOnlySavePoint(
    resumingAt pc: InstructionAddress
  ) -> SavePoint {
    SavePoint(
      pc: pc,
      savedPosition: .addressOnly,
      captureLogEnd: .init(asserting: registers.storedCaptures.logCount),
      intLogEnd: .init(asserting: registers.ints.logCount),
      positionLogEnd: .init(asserting: registers.positions.logCount))
  }

  func makeQuantifiedSavePoint(
    _ range: Range<Position>,
    isScalarSemantics: Bool
  ) -> SavePoint {
    SavePoint(
      pc: controller.pc + 1,
      savedPosition: .range(range, isScalarSemantics: isScalarSemantics),
      captureLogEnd: .init(asserting: registers.storedCaptures.logCount),
      intLogEnd: .init(asserting: registers.ints.logCount),
      positionLogEnd: .init(asserting: registers.positions.logCount))
  }
}


