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

struct SentinelValue: Hashable, CustomStringConvertible {
  var description: String { "<value sentinel>" }
}

extension Processor {
  /// Our register file
  struct Registers {

    // MARK: static / read-only, non-resettable

    // Verbatim elements to compare against
    var elements: [Element]

    // Verbatim bytes to compare against
    var utf8Contents: [[UInt8]]

    var bitsets: [DSLTree.CustomCharacterClass.AsciiBitset]

    var consumeFunctions: [MEProgram.ConsumeFunction]

    // Captured-value constructors
    var transformFunctions: [MEProgram.TransformFunction]

    // Value-constructing matchers
    var matcherFunctions: [MEProgram.MatcherFunction]
    
    // MARK: writeable

    var values: UndoableArray<ValueRegister, Any>

    // MARK: writeable, resettable

    var ints: UndoableArray<IntRegister, Int>

    var positions: UndoableArray<PositionRegister, Input.Index>

    var storedCaptures: UndoableArray<CaptureRegister, Processor._StoredCapture>

    var isDirty = false
    
    init(
      elements: [Element],
      utf8Contents: [[UInt8]],
      bitsets: [DSLTree.CustomCharacterClass.AsciiBitset],
      consumeFunctions: [MEProgram.ConsumeFunction],
      transformFunctions: [MEProgram.TransformFunction],
      matcherFunctions: [MEProgram.MatcherFunction],
      numInts: Int,
      numValues: Int,
      numPositions: Int,
      numCaptures: Int
    ) {
      self.elements = elements
      self.utf8Contents = utf8Contents
      self.bitsets = bitsets
      self.consumeFunctions = consumeFunctions
      self.transformFunctions = transformFunctions
      self.matcherFunctions = matcherFunctions
      self.ints = UndoableArray(repeating: 0, count: numInts)
      self.values = UndoableArray(repeating: SentinelValue(), count: numValues)
      self.positions = UndoableArray(
        repeating: Self.sentinelIndex, count: numPositions)
      self.storedCaptures = UndoableArray(
        repeating: Processor._StoredCapture(), count: numCaptures)
    }
  }
}

extension Processor {
  @inline(always)
  mutating func updateRegister(at i: IntRegister, to newValue: Int) {
    registers.ints.set(i, to: newValue, logging: !savePoints.isEmpty)
    registers.isDirty = true
  }

  @inline(always)
  mutating func updateRegister(at i: IntRegister, body: (inout Int) -> ()) {
    registers.ints.update(i, logging: !savePoints.isEmpty, body)
    registers.isDirty = true
  }

  @inline(always)
  mutating func updateRegister(at i: PositionRegister, to newValue: Input.Index) {
    registers.positions.set(i, to: newValue, logging: !savePoints.isEmpty)
    registers.isDirty = true
  }

  // NOTE: Value registers are deliberately never logged, matching the
  // behavior from before the undo log was introduced. Values are only
  // really read when consuming matches, so they don't need to be unwound.
  @inline(always)
  mutating func updateRegister(at i: ValueRegister, to newValue: Any) {
    registers.values.set(i, to: newValue, logging: false)
    registers.isDirty = true
  }

  @inline(always)
  mutating func updateRegister(at i: CaptureRegister, body: (inout _StoredCapture) -> ()) {
    registers.storedCaptures.update(i, logging: !savePoints.isEmpty, body)
    registers.isDirty = true
  }
}

extension Processor.Registers {
  typealias Input = String

  subscript(_ i: IntRegister) -> Int {
    ints[i]
  }

  subscript(_ i: ValueRegister) -> Any {
    values[i]
  }

  subscript(_ i: PositionRegister) -> Input.Index {
    positions[i]
  }

  subscript(_ i: CaptureRegister) -> Processor._StoredCapture {
    storedCaptures[i]
  }

  subscript(_ i: ElementRegister) -> Input.Element {
    elements[i.rawValue]
  }
  subscript(_ i: UTF8Register) -> [UInt8] {
    utf8Contents[i.rawValue]
  }
  subscript(
    _ i: AsciiBitsetRegister
  ) -> DSLTree.CustomCharacterClass.AsciiBitset {
    bitsets[i.rawValue]
  }
  subscript(_ i: ConsumeFunctionRegister) -> MEProgram.ConsumeFunction {
    consumeFunctions[i.rawValue]
  }
  subscript(_ i: TransformRegister) -> MEProgram.TransformFunction {
    transformFunctions[i.rawValue]
  }
  subscript(_ i: MatcherRegister) -> MEProgram.MatcherFunction {
    matcherFunctions[i.rawValue]
  }
}

extension Processor.Registers {
  static var sentinelIndex: String.Index {
    "".startIndex
  }

  mutating func reset() {
    guard isDirty else { return }
    ints.reset(to: 0)
    values.reset(to: SentinelValue())
    positions.reset(to: Processor.Registers.sentinelIndex)
    storedCaptures.reset(to: Processor._StoredCapture())
    isDirty = false
  }

  /// Discards every register's undo log, leaving the current values in place.
  ///
  /// Only valid when no save points remain, since the logged values can no
  /// longer be reached by backtracking at that point.
  @inline(__always)
  mutating func discardUndoLogs() {
    ints.discardLog()
    positions.discardLog()
    storedCaptures.discardLog()
  }
}

extension Processor.Registers: CustomStringConvertible {
  var description: String {
    func formatRegisters<T>(
      _ name: String, _ regs: [T]
    ) -> String {
      // TODO: multi-line if long
      if regs.isEmpty { return "" }

      return "\(name): \(regs)\n"
    }

    return """
      \(formatRegisters("elements", elements))\
      \(formatRegisters("ints", ints.values))\

      """
  }
}

