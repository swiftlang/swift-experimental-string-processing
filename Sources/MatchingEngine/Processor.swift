import Util

/// A concrete CU. Somehow will run the concrete logic and
/// feed stuff back to generic code
struct Controller {
  var pc: InstructionAddress

  mutating func step() {
    pc.rawValue += 1
  }
}

struct Processor<
  Input: Collection
> where Input.Element: Equatable { // maybe Hashable?
  typealias Element = Input.Element

  let input: Input
  let range: Range<Position>
  var currentPosition: Position

  let instructions: InstructionList<Instruction>
  var controller: Controller

  var cycleCount = 0

  /// Our register file
  var registers: Registers

  // Used for back tracking
  var savePoints = Array<(SavePoint, stackEnd: Int)>()

  var callStack = Array<InstructionAddress>()

  var state: State = .inprogress

  var enableTracing: Bool

  var start: Position { range.lowerBound }
  var end: Position { range.upperBound }
}


extension Processor {
  typealias Position = Input.Index

  // TODO: What all do we want to save? Configurable?
  struct SavePoint {
    var pc: InstructionAddress
    var pos: Position?

    var destructure: (pc: InstructionAddress, pos: Position?) {
      (pc, pos)
    }
  }
}

extension Processor {
  init(
    _ program: Program<Input.Element>,
    _ input: Input,
    in r: Range<Position>,
    enableTracing: Bool
  ) {
    self.controller = Controller(pc: 0)
    self.instructions = program.instructions
    self.input = input
    self.range = r
    self.enableTracing = enableTracing
    self.currentPosition = r.lowerBound

    self.registers = Registers(program, r.upperBound)

    _checkInvariants()
  }

  func _checkInvariants() {
    assert(end <= input.endIndex)
    assert(start >= input.startIndex)
    assert(currentPosition >= start)
    assert(currentPosition <= end)
  }
}

extension Processor {
  // Advance in our input
  mutating func consume(_ n: Distance) {
    // Want Collection to provide this behavior...
    if input.distance(from: currentPosition, to: end) < n.rawValue {
      signalFailure()
      return
    }
    currentPosition = input.index(currentPosition, offsetBy: n.rawValue)
  }

  func doPrint(_ s: String) {
    var enablePrinting: Bool { false }
    if enablePrinting {
      print(s)
    }
  }

  func load() -> Element? {
    currentPosition < end ? input[currentPosition] : nil
  }

  mutating func signalFailure() {
    guard let (thread, stackEnd) = savePoints.popLast() else {
      state = .fail
      return
    }
    assert(stackEnd <= callStack.count)
    controller.pc = thread.pc
    currentPosition = thread.pos ?? currentPosition
    callStack.removeLast(callStack.count - stackEnd)
  }

  mutating func cycle() {
    _checkInvariants()
    assert(state == .inprogress)
    if cycleCount == 0 { trace() }
    defer {
      cycleCount += 1
      trace()
      _checkInvariants()
    }
    let (opcode, operand) = fetch().destructure
    switch opcode {
    case .invalid:
      fatalError("Invalid program")
    case .nop:
      if checkComments, operand.hasPayload {
        doPrint(registers[operand.payload(as: StringRegister.self)])
      }
      controller.step()

    case .branch:
      controller.pc = operand.payload()

    case .condBranch:
      if registers[operand.condition] {
        controller.pc = operand.payload()
      } else {
        controller.step()
      }

    case .save:
      savePoints.append(
        (SavePoint(pc: operand.payload(), pos: currentPosition), callStack.count))
      controller.step()

    case .saveAddress:
      savePoints.append(
        (SavePoint(pc: operand.payload(), pos: nil), callStack.count))
      controller.step()

    case .clear:
      if let _ = savePoints.popLast() {
        controller.step()
      } else {
        fatalError("TODO: What should we do here?")
      }

    case .peek:
      fatalError()

    case .restore:
      signalFailure()

    case .push:
      fatalError()

    case .pop:
      fatalError()

    case .call:
      controller.step()
      callStack.append(controller.pc)
      controller.pc = operand.payload()

    case .ret:
      // TODO: Should empty stack mean success?
      guard let r = callStack.popLast() else {
        state = .accept
        return
      }
      controller.pc = r

    case .abort:
      // TODO: throw or otherwise propagate
      doPrint(registers[operand.payload(as: StringRegister.self)])
      state = .fail
      return

    case .accept:
      state = .accept
      return

    case .fail:
      signalFailure()

    case .consume:
      consume(operand.payload(as: Distance.self))
      controller.step()

    case .match:
      let reg = operand.payload(as: ElementRegister.self)
      guard let cur = load(), cur ==  registers[reg] else {
        signalFailure()
        return
      }
      consume(1)
      controller.step()

    case .matchPredicate:
      let reg = operand.payload(as: PredicateRegister.self)
      guard let cur = load(), registers[reg](cur) else {
        signalFailure()
        return
      }
      consume(1)
      controller.step()

    case .print:
      // TODO: Debug stream
      doPrint(registers[operand.payload(as: StringRegister.self)])

    case .assertion:
      let reg = operand.payload(as: ElementRegister.self)
      var result: Bool
      if let cur = load(), cur == registers[reg] {
        result = true
      } else {
        result = false
      }
      registers[operand.condition] = result
      controller.step()
    }
  }
}

