public enum MatchMode {
  case full
  case `prefix`
}

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
  let bounds: Range<Position>
  let matchMode: MatchMode
  var currentPosition: Position

  let instructions: InstructionList<Instruction>
  var controller: Controller

  var cycleCount = 0

  /// Our register file
  var registers: Registers

  // Used for back tracking
  var savePoints: [(SavePoint, stackEnd: Int)] = []

  var callStack: [InstructionAddress] = []

  var state: State = .inprogress

  var isTracingEnabled: Bool

  var start: Position { bounds.lowerBound }
  var end: Position { bounds.upperBound }
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
    program: Program<Input>,
    input: Input,
    bounds: Range<Position>,
    matchMode: MatchMode,
    isTracingEnabled: Bool
  ) {
    self.controller = Controller(pc: 0)
    self.instructions = program.instructions
    self.input = input
    self.bounds = bounds
    self.matchMode = matchMode
    self.isTracingEnabled = isTracingEnabled
    self.currentPosition = bounds.lowerBound

    self.registers = Registers(program, bounds.upperBound)

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

  mutating func advance(to nextIndex: Input.Index) {
    assert(nextIndex >= bounds.lowerBound)
    assert(nextIndex <= bounds.upperBound)
    assert(nextIndex > currentPosition)
    currentPosition = nextIndex
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

  mutating func tryAccept() {
    switch (currentPosition, matchMode) {
    // When reaching the end of the match bounds or when we are only doing a
    // prefix match, transition to accept.
    case (bounds.upperBound, _), (_, .prefix):
      state = .accept

    // When we are doing a full match but did not reach the end of the match
    // bounds, backtrack if possible.
    case (_, .full):
      signalFailure()
    }
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
        tryAccept()
        return
      }
      controller.pc = r

    case .abort:
      // TODO: throw or otherwise propagate
      doPrint(registers[operand.payload(as: StringRegister.self)])
      state = .fail

    case .accept:
      tryAccept()

    case .fail:
      signalFailure()

    case .consume:
      consume(operand.payload(as: Distance.self))
      controller.step()

    case .match:
      let reg = operand.payload(as: ElementRegister.self)
      guard let cur = load(), cur == registers[reg] else {
        signalFailure()
        return
      }
      consume(1)
      controller.step()

    case .consumeBy:
      let reg = operand.payload(as: ConsumeFunctionRegister.self)
      guard currentPosition < bounds.upperBound,
            let nextIndex = registers[reg](
              input, currentPosition..<bounds.upperBound) else {
        signalFailure()
        return
      }
      advance(to: nextIndex)
      controller.step()

    case .print:
      // TODO: Debug stream
      doPrint(registers[operand.payload(as: StringRegister.self)])

    case .assertion:
      let reg = operand.payload(as: ElementRegister.self)
      let result: Bool
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

