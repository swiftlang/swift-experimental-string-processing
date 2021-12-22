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
  var savePoints: [SavePoint] = []

  var callStack: [InstructionAddress] = []

  var state: State = .inProgress

  var isTracingEnabled: Bool

  var start: Position { bounds.lowerBound }
  var end: Position { bounds.upperBound }
}


extension Processor {
  typealias Position = Input.Index

  // TODO: What all do we want to save? Configurable?
  // TODO: Do we need to save any registers?
  // TODO: Is this the right place to do function stack unwinding?
  struct SavePoint {
    var pc: InstructionAddress
    var pos: Position?
    var stackEnd: Int

    var destructure: (
      pc: InstructionAddress,
      pos: Position?,
      stackEnd: Int
    ) {
      (pc, pos, stackEnd)
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
  //
  // Returns whether the advance succeeded. On failure, our
  // save point was restored
  mutating func consume(_ n: Distance) -> Bool {
    // Want Collection to provide this behavior...
    if input.distance(from: currentPosition, to: end) < n.rawValue {
      signalFailure()
      return false
    }
    currentPosition = input.index(currentPosition, offsetBy: n.rawValue)
    return true
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
  func load(count: Int) -> Input.SubSequence? {
    let slice = input[currentPosition...].prefix(count)
    guard slice.count == count else { return nil }
    return slice
  }

  mutating func match(_ e: Element) {
    guard let cur = load(), cur == e else {
      signalFailure()
      return
    }
    if consume(1) {
      controller.step()
    }
  }
  mutating func matchSeq<C: Collection>(
    _ seq: C
  ) where C.Element == Input.Element {
    let count = seq.count

    guard let inputSlice = load(count: count),
          seq.elementsEqual(inputSlice)
    else {
      signalFailure()
      return
    }
    guard consume(.init(count)) else {
      fatalError("unreachable")
    }
    controller.step()
  }

  mutating func signalFailure() {
    guard let (pc, pos, stackEnd) = savePoints.popLast()?.destructure
    else {
      state = .fail
      return
    }
    assert(stackEnd <= callStack.count)
    controller.pc = pc
    currentPosition = pos ?? currentPosition
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
    assert(state == .inProgress)
    if cycleCount == 0 { trace() }
    defer {
      cycleCount += 1
      trace()
      _checkInvariants()
    }
    let (opcode, payload) = fetch().destructure

    switch opcode {
    case .invalid:
      fatalError("Invalid program")
    case .nop:
      if checkComments,
         let s = payload.optionalString
      {
        doPrint(registers[s])
      }
      controller.step()

    case .decrement:
      let (bool, int) = payload.pairedBoolInt
      let newValue = registers[int] - 1
      registers[bool] = newValue == 0
      registers[int] = newValue
      controller.step()

    case .moveImmediate:
      let (imm, reg) = payload.pairedImmediateInt
      // TODO: Consider UInt64 regs, which may subsume Bool
      let int = Int(bitPattern: UInt(truncatingIfNeeded: imm))
      assert(int == imm)

      registers[reg] = int
      controller.step()

    case .movePosition:
      let reg = payload.position
      registers[reg] = currentPosition
      controller.step()

    case .branch:
      controller.pc = payload.addr

    case .condBranch:
      let (addr, cond) = payload.pairedAddrBool
      if registers[cond] {
        controller.pc = addr
      } else {
        controller.step()
      }

    case .condBranchZeroElseDecrement:
      let (addr, int) = payload.pairedAddrInt
      if registers[int] == 0 {
        controller.pc = addr
      } else {
        registers[int] -= 1
        controller.step()
      }

    case .save:
      savePoints.append(SavePoint(
        pc: payload.addr,
        pos: currentPosition,
        stackEnd: callStack.count))
      controller.step()

    case .saveAddress:
      savePoints.append(SavePoint(
        pc: payload.addr,
        pos: nil,
        stackEnd: callStack.count))
      controller.step()

    case .splitSaving:
      let (nextPC, saveAddr) = payload.pairedAddrAddr
      savePoints.append(SavePoint(
        pc: saveAddr,
        pos: currentPosition,
        stackEnd: callStack.count))
      controller.pc = nextPC

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
      controller.pc = payload.addr

    case .ret:
      // TODO: Should empty stack mean success?
      guard let r = callStack.popLast() else {
        tryAccept()
        return
      }
      controller.pc = r

    case .abort:
      // TODO: throw or otherwise propagate
      if let s = payload.optionalString {
        doPrint(registers[s])
      }
      state = .fail

    case .accept:
      tryAccept()

    case .fail:
      signalFailure()

    case .advance:
      if consume(payload.distance) {
        controller.step()
      }

    case .match:
      let reg = payload.element
      match(registers[reg])

    case .matchSequence:
      let reg = payload.sequence
      let seq = registers[reg]
      matchSeq(seq)

    case .matchSlice:
      let (lower, upper) = payload.pairedPosPos
      let range = registers[lower]..<registers[upper]
      let slice = input[range]
      matchSeq(slice)

    case .consumeBy:
      let reg = payload.consumer
      guard currentPosition < bounds.upperBound,
            let nextIndex = registers[reg](
              input, currentPosition..<bounds.upperBound)
      else {
        signalFailure()
        return
      }
      advance(to: nextIndex)
      controller.step()

    case .print:
      // TODO: Debug stream
      doPrint(registers[payload.string])

    case .assertion:
      let (element, cond) =
        payload.pairedElementBool
      let result: Bool
      if let cur = load(), cur == registers[element] {
        result = true
      } else {
        result = false
      }
      registers[cond] = result
      controller.step()
    }
  }
}
