import Util

extension Processor {
  /// Our register file
  struct Registers {
    // currently, these are static readonly
    var elements: Array<Element>

    // currently, hold output of assertions
    var bools: Array<Bool> // TODO: bitset

    // currently, these are static readonly
    var predicates: Array<(Element) -> Bool>

    // currently, these are for comments and abort messages
    var strings: Array<String>

    // unused
    var ints = Array<Int>()

    // unused
    var floats = Array<Double>()

    // unused
    //
    // Unlikely to be static, as that means input must be bound
    // at compile time
    var positions = Array<Position>()

    // unused
    var instructionAddresses = Array<InstructionAddress>()

    // unused, any application?
    var classStackAddresses = Array<CallStackAddress>()

    // unused, any application?
    var positionStackAddresses = Array<PositionStackAddress>()

    // unused, any application?
    var savePointAddresses = Array<SavePointStackAddress>()

    subscript(_ i: StringRegister) -> String {
      strings[i.rawValue]
    }
    subscript(_ i: BoolRegister) -> Bool {
      get { bools[i.rawValue] }
      set { bools[i.rawValue] = newValue }
    }
    subscript(_ i: ElementRegister) -> Element {
      elements[i.rawValue]
    }
    subscript(_ i: PredicateRegister) -> (Element) -> Bool {
      predicates[i.rawValue]
    }
  }
}

extension Processor.Registers {
  init(
    _ program: Program<Input.Element>,
    _ sentinel: Input.Index
  ) {
    let info = program.registerInfo

    self.elements = program.staticElements
    assert(elements.count == info.elements)

    self.predicates = program.staticPredicates
    assert(predicates.count == info.predicates)

    self.strings = program.staticStrings
    assert(strings.count == info.strings)

    self.bools = Array(repeating: false, count: info.bools)

    self.ints = Array(repeating: 0, count: info.ints)

    self.floats = Array(repeating: 0, count: info.floats)

    self.positions = Array(repeating: sentinel, count: info.positions)

    self.instructionAddresses = Array(repeating: 0, count: info.instructionAddresses)

    self.classStackAddresses = Array(repeating: 0, count: info.classStackAddresses)

    self.positionStackAddresses = Array(repeating: 0, count: info.positionStackAddresses)

    self.savePointAddresses = Array(repeating: 0, count: info.savePointAddresses)
  }
}

extension Program {
  struct RegisterInfo {
    var elements = 0
    var bools = 0
    var strings = 0
    var predicates = 0
    var ints = 0
    var floats = 0
    var positions = 0
    var instructionAddresses = 0
    var classStackAddresses = 0
    var positionStackAddresses = 0
    var savePointAddresses = 0
  }
}

extension Processor.Registers: CustomStringConvertible {
  var description: String {
    func formatRegisters<T>(
      _ name: String, _ regs: Array<T>
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

