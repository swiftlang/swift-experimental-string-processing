import _MatchingEngine
let emitComments = true

struct PEGCore<
  Input: Collection
> where Input.Element: Comparable & Hashable {
  let instructions: InstructionList<Instruction>
  let input: Input

  var current: Thread

  // Used for back tracking
  var savePoints = Array<SavePoint>()

  var registers = Array<Bool>()

  var callStack = Array<InstructionAddress>()

  var state: State = .processing

  var isTracingEnabled: Bool
  var cycleCount = 0
}

extension PEGCore {
  public typealias SavePoint = (Thread, stackEnd: Int)

  typealias VM = PEG<Input.Element>.VM<Input>

  typealias Element = Input.Element
  typealias Position = Input.Index

  typealias Capture = (Position, InstructionAddress)

  enum Instruction {
    // NOPs
    case nop
    case comment(String)

    // Advance our input position
    case consume(Int)

    // Control flow
    case branch(to: InstructionAddress)
    case condBranch(condition: BoolRegister, to: InstructionAddress)

    // Save a position (e.g. for backtracking)
    case save(InstructionAddress)

    // Clear the top-most saved position (e.g. on success)
    case clear

    // Restore the top-most saved position
    case restore

    // Interact with the call stack
    case push(InstructionAddress)
    case pop//(Register)

    case call(InstructionAddress) // composite push-next and branch
    case ret // composite pop-and-branch

    // TODO: Should pop assign to register, or current pc, or what?

    // TODO: Interact with capture info

    //
    // Non-primitive operations
    //

    // Return whether the current input element satisfies
    case assert(Element, BoolRegister)
    case assertPredicate((Element) -> Bool, BoolRegister)

    // Match and consume
    case match(Element)
    case matchPredicate((Element) -> Bool)

    // Extension hooks
    case matchHook((Input, Position) -> Position?)
    case assertHook((Input, Position) -> Bool, BoolRegister)

    case accept
    case fail

    case abort(reason: String) // Like fail, but clear everything
    // TODO:

    //
    // Aliases
    //

    // Alias for consume(1)
    static var any: Instruction { .consume(1) }

  }
}

extension PEGCore {
  struct Thread {
    var pc: InstructionAddress
    var pos: Position
    // TODO: save registers?
    // TODO: save call stack position?
    // TODO: save capture position?
  }

  init(
    _ instructions: InstructionList<Instruction>,
    _ input: Input,
    enableTracing: Bool = false
  ) {
    self.instructions = instructions
    self.input = input
    self.current =
      Thread(pc: InstructionAddress(rawValue: 0), pos: input.startIndex)
    self.isTracingEnabled = enableTracing
  }

  mutating func advance(instructions: Int = 1, positions: Int = 0) {
    current.pc.rawValue += instructions
    current.pos = input.index(current.pos, offsetBy: positions)
  }
}

extension PEGCore {
  func load(_ pos: Position) -> Element? {
    pos < input.endIndex ? input[pos] : nil
  }
  func load() -> Element? { load(current.pos) }

  func read(_ r: BoolRegister) -> Bool { registers[r.rawValue] }

  mutating func write(_ r: BoolRegister, _ value: Bool) {
    registers[r.rawValue] = value
  }

  func hasInput(atLeast: Int = 1) -> Bool {
    var idx = current.pos
    for _ in 0..<atLeast {
      guard idx < input.endIndex else {
        return false
      }
      input.formIndex(after: &idx)
    }
    return true
  }
}

// Instructions as API
extension PEGCore {
  mutating func nop() {
    advance()
  }

  mutating func comment(_ s: String) {
    nop()
  }

  mutating func consume(_ n: Int) {
    advance(instructions: 1, positions: n)
  }

  mutating func branch(to: InstructionAddress) {
    current.pc = to
  }

  mutating func condBranch(_ condition: BoolRegister, to: InstructionAddress) {
    if registers[condition.rawValue] {
      branch(to: to)
    } else {
      advance()
    }
  }

  mutating func save(_ pc: InstructionAddress, _ pos: Position) {
    savePoints.append(
      (Thread(pc: pc, pos: pos), callStack.count))
    advance()
  }
  mutating func save(_ pc: InstructionAddress) {
    save(pc, current.pos)
  }

  mutating func clear() {
    _ = savePoints.popLast()!
    advance()
  }

  // Restore a saved InstructionAddress, transition to `.fail` state if empty
  mutating func restore() {
    guard let (last, stackEnd) = savePoints.popLast() else {
      state = .fail
      return
    }
    current = last
    callStack.removeLast(callStack.count - stackEnd)
  }

  mutating func push(_ pc: InstructionAddress) {
    callStack.append(pc)
    advance()
  }

  // TODO: Or should this assign to a register?
  mutating func pop() -> InstructionAddress? {
    callStack.popLast()
    // advance()?
  }

  mutating func ret() {
    // Should empty stack mean success?

    // TODO: Assert that all newly added suspension points
    // have been cleared
    if let pc = pop() {
      branch(to: pc)
      return
    }
    state = .accept
  }

  mutating func call(_ pc: InstructionAddress) {
    push(current.pc+1)
    branch(to: pc)
  }

  mutating func assert(_ e: Element, _ out: BoolRegister) {
    write(out, e == load())
    advance()
  }

  mutating func assertPredicate(
    _ p: (Element) -> Bool, _ out: BoolRegister
  ) {
    defer { advance() }
    guard let e = load() else {
      write(out, false)
      return
    }
    write(out, p(e))
  }

  mutating func match(_ e: Element) {
    guard e == load() else {
      restore()
      return
    }
    advance(instructions: 1, positions: 1)
  }

  mutating func matchPredicate(_ p: (Element) -> Bool) {
    guard let e = load(), p(e) else {
      restore()
      return
    }
    advance(instructions: 1, positions: 1)
  }

  mutating func matchHook(
    _ hook: (Input, Position) -> Input.Index?
  ) {
    guard let newPos = hook(input, current.pos) else {
      restore()
      return
    }
    self.current.pos = newPos
    advance()
  }

  mutating func assertHook(
    _ hook: (Input, Position) -> Bool, _ output: BoolRegister
  ) {
    write(output, hook(input, current.pos))
    advance()
  }

  mutating func accept() {
      state = .accept
  }

  mutating func fail() {
     if savePoints.isEmpty {
      state = .fail
      return
     }
     restore()
  }

  mutating func abort(reason: String) {
    // TODO: backtrace, etc.
    print(reason)
    state = .fail
  }
}

extension PEGCore {
  enum State {
    case processing
    case accept
    case fail
  }

  // Fetch, decode, execute
  mutating func cycle() {
    guard state == .processing else { return }
    defer { cycleCount += 1 }
    trace()

    switch fetch() {
    case .nop:
      self.nop()
    case .comment(let s):
      self.comment(s)
    case .consume(let n):
      self.consume(n)

    case .branch(let to):
      self.branch(to: to)
      // branches

    case .condBranch(let condition, let to):
      self.condBranch(condition, to: to)
      // branches

    case .save(let pc):
      self.save(pc)
    case .clear:
      self.clear()
    case .restore:
      self.restore() // branches

    case .push(let pc):
      self.push(pc)
    case .pop:
      guard let pc = self.pop() else {
        fatalError("figure out what to do here")
      }
      _ = pc
      self.advance()
    case .call(let pc):
      self.call(pc) // branches
    case .ret:
      self.ret() // branches

    case .assert(let e, let r):
      self.assert(e, r)

    case .assertPredicate(let p, let r):
      self.assertPredicate(p, r)

    case .match(let e):
      self.match(e)

    case .matchPredicate(let p):
      self.matchPredicate(p)

    case .matchHook(let h):
      self.matchHook(h)

    case .assertHook(let h, let r):
      self.assertHook(h, r)

    case .accept:
      self.accept()

    case .fail:
      self.fail() // branches

    case .abort(let s):
      self.abort(reason: s)
    }
  }
}

// TODO: Trace Core

extension PEGCore.Instruction {
  var pc: InstructionAddress? {
    switch self {
    case .branch(let pc): return pc
    case .condBranch(_, let pc): return pc
    case .save(let pc): return pc
    case .push(let pc): return pc
    case .call(let pc): return pc
    default: return nil
    }
  }
  mutating func setPC(_ pc: InstructionAddress) {
    guard let inv = self.pc else {
      fatalError("Invalid instruction")
    }
    guard inv == InstructionAddress(-1) else {
      fatalError("Overwriting prior InstructionAddress")
    }
    switch self {
    case .branch(_): self = .branch(to: pc)
    case .condBranch(let cond, _):
      self = .condBranch(condition: cond, to: pc)
    case .save(_): self = .save(pc)
    case .push(_): self = .push(pc)
    case .call(_): self = .call(pc)
    default: fatalError("Unreachable")
    }
  }
}



