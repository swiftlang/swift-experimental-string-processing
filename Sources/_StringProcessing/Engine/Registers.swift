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

@_implementationOnly import _RegexParser

struct SentinelValue: Hashable, CustomStringConvertible {
  var description: String { "<value sentinel>" }
}

extension Processor {
  /// Our register file
  struct Registers {
    // currently, these are static readonly
    var elements: [Element]

    // currently, these are static readonly
    //
    // TODO: We want to be `String` instead of `[Character]`...
    var sequences: [[Element]] = []

    // currently, hold output of assertions
    var bools: [Bool] // TODO: bitset

    // currently, these are static readonly
    var consumeFunctions: [MEProgram<Input>.ConsumeFunction]

    // currently, these are static readonly
    var assertionFunctions: [MEProgram<Input>.AssertionFunction]

    // Captured-value constructors
    var transformFunctions: [MEProgram<Input>.TransformFunction]

    // Value-constructing matchers
    var matcherFunctions: [MEProgram<Input>.MatcherFunction]

    // currently, these are for comments and abort messages
    var strings: [String]

    // currently, useful for range-based quantification
    var ints: [Int]

    // unused
    var floats: [Double] = []

    // Currently, used for `movePosition` and `matchSlice`
    var positions: [Position] = []

    var values: [Any]

    // unused
    var instructionAddresses: [InstructionAddress] = []

    // unused, any application?
    var classStackAddresses: [CallStackAddress] = []

    // unused, any application?
    var positionStackAddresses: [PositionStackAddress] = []

    // unused, any application?
    var savePointAddresses: [SavePointStackAddress] = []

    subscript(_ i: StringRegister) -> String {
      strings[i.rawValue]
    }
    subscript(_ i: SequenceRegister) -> [Element] {
      sequences[i.rawValue]
    }
    subscript(_ i: IntRegister) -> Int {
      get { ints[i.rawValue] }
      set { ints[i.rawValue] = newValue }
    }
    subscript(_ i: BoolRegister) -> Bool {
      get { bools[i.rawValue] }
      set { bools[i.rawValue] = newValue }
    }
    subscript(_ i: PositionRegister) -> Position {
      get { positions[i.rawValue] }
      set { positions[i.rawValue] = newValue }
    }
    subscript(_ i: ValueRegister) -> Any {
      get { values[i.rawValue] }
      set {
        values[i.rawValue] = newValue
      }
    }
    subscript(_ i: ElementRegister) -> Element {
      elements[i.rawValue]
    }
    subscript(_ i: ConsumeFunctionRegister) -> MEProgram<Input>.ConsumeFunction {
      consumeFunctions[i.rawValue]
    }
    subscript(_ i: AssertionFunctionRegister) -> MEProgram<Input>.AssertionFunction {
      assertionFunctions[i.rawValue]
    }
    subscript(_ i: TransformRegister) -> MEProgram<Input>.TransformFunction {
      transformFunctions[i.rawValue]
    }
    subscript(_ i: MatcherRegister) -> MEProgram<Input>.MatcherFunction {
      matcherFunctions[i.rawValue]
    }
  }
}

extension Processor.Registers {
  init(
    _ program: MEProgram<Input>,
    _ sentinel: Input.Index
  ) {
    let info = program.registerInfo

    self.elements = program.staticElements
    assert(elements.count == info.elements)

    self.sequences = program.staticSequences
    assert(sequences.count == info.sequences)

    self.consumeFunctions = program.staticConsumeFunctions
    assert(consumeFunctions.count == info.consumeFunctions)

    self.assertionFunctions = program.staticAssertionFunctions
    assert(assertionFunctions.count == info.assertionFunctions)

    self.transformFunctions = program.staticTransformFunctions
    assert(transformFunctions.count == info.transformFunctions)

    self.matcherFunctions = program.staticMatcherFunctions
    assert(matcherFunctions.count == info.matcherFunctions)

    self.strings = program.staticStrings
    assert(strings.count == info.strings)

    self.bools = Array(repeating: false, count: info.bools)

    self.ints = Array(repeating: 0, count: info.ints)

    self.floats = Array(repeating: 0, count: info.floats)

    self.positions = Array(repeating: sentinel, count: info.positions)

    self.values = Array(
      repeating: SentinelValue(), count: info.values)

    self.instructionAddresses = Array(repeating: 0, count: info.instructionAddresses)

    self.classStackAddresses = Array(repeating: 0, count: info.classStackAddresses)

    self.positionStackAddresses = Array(repeating: 0, count: info.positionStackAddresses)

    self.savePointAddresses = Array(repeating: 0, count: info.savePointAddresses)
  }
}

extension MEProgram {
  struct RegisterInfo {
    var elements = 0
    var sequences = 0
    var bools = 0
    var strings = 0
    var consumeFunctions = 0
    var assertionFunctions = 0
    var transformFunctions = 0
    var matcherFunctions = 0
    var ints = 0
    var floats = 0
    var positions = 0
    var values = 0
    var instructionAddresses = 0
    var classStackAddresses = 0
    var positionStackAddresses = 0
    var savePointAddresses = 0
    var captures = 0
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
      \(formatRegisters("bools", bools))\
      \(formatRegisters("strings", strings))\
      \(formatRegisters("ints", ints))\
      \(formatRegisters("floats", floats))\
      \(formatRegisters("positions", positions))\
      \(formatRegisters("instructionAddresses", instructionAddresses))\
      \(formatRegisters("classStackAddresses", classStackAddresses))\
      \(formatRegisters("positionStackAddresses", positionStackAddresses))\
      \(formatRegisters("savePointAddresses", savePointAddresses))\

      """    
  }
}

