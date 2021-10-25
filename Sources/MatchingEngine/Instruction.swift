import Util

enum State {
  /// Still running
  case inprogress

  /// FAIL: halt and signal failure
  case fail

  /// ACCEPT: halt and signal success
  case accept
}
// TODO: better names for accept/fail/etc. Instruction
// conflates backtracking with signaling failure or success,
// could be clearer.


// TODO: Save point and call stack interactions should be more formalized.
// It's too easy to have unbalanced save/clears amongst function calls

/*

We're looking at 8-byte instructions, which allow us to really
pack in complex series of operations into fewer
fetch/decode/execute cycles.

We'll want

 A) A general-purpose RISC core
 B) A customization-hook opcode area carved out
 C) A specialized pattern-matching opcode area carved out
 D) An extensible-for-other-purposes opcode area carved out

 Where C and D can provide decompositions into A for testing,
 and even B. A and B become extension mechanisms for the future:

 Ideally, we'd avoid hot-switching between bytecode and normal
 code execution. It's likely that the RISC core will be highly
 valuable for this purpose. B will be necessary sometimes, but
 ideally we'd avoid it when possible.

 While we want some core operations to be fixed-length, there's
 not necessarily (until I'm wrong, of course) a detriment to
 allowing D to have other widths. Also, 8 bytes is a lot for A...


 */

enum OpCode: UInt64 {
  case invalid = 0

  /// Do nothing
  ///
  /// Operand: optional string register containing a comment
  case nop

  // MARK: - Control flow

  /// Branch to a new instruction
  ///
  /// Operand: instruction address to branch to
  case branch

  /// Conditionally branch
  ///
  /// Operand: packed condition register and address to branch to
  case condBranch

  // MARK: - Save points (e.g. for backtracking)

  /// Add a save point
  ///
  /// Operand: instruction address to resume from
  ///
  /// A save point is:
  ///   - a position in the input to restore
  ///   - a position in the call stack to cut off
  ///   - an instruction address to resume from
  ///
  /// TODO: Consider if separating would improve generality
  case save

  ///
  /// Add a save point that doesn't preserve input position
  ///
  /// NOTE: This is a prototype for now, but exposes
  /// flaws in our formulation of back tracking. We could
  /// instead have an instruction to update the top
  /// most saved position instead
  case saveAddress

  /// Remove the most recently saved point
  ///
  /// Precondition: There is a save point to remove
  case clear

  /// View the most recently saved point
  ///
  /// UNIMPLEMENTED
  case peek

  /// Composite peek-branch-clear else FAIL
  case restore

  // MARK: - Function call stack

  /// Push an instruction address to the stack
  ///
  /// Operand: the instruction address
  ///
  /// UNIMPLEMENTED
  case push

  /// Pop return address from call stack
  ///
  /// UNIMPLEMENTED
  case pop

  /// Composite push-next-branch instruction
  ///
  /// Operand: the function's start address
  case call

  /// Composite pop-branch instruction
  ///
  /// Operand: the instruction address
  ///
  /// NOTE: Currently, empty stack -> ACCEPT
  case ret

  // MARK: - State transitions

  // TODO: State transitions need more work. We want
  // granular core but also composite ones that will
  // interact with save points

  /// Transition into ACCEPT and halt
  case accept

  /// Signal failure (currently same as `restore`)
  case fail

  /// Halt, fail, and signal failure
  ///
  /// Operand: optional string register specifying the reason
  ///
  /// TODO: Could have an Error existential area instead
  case abort

  // MARK: - Interact with the input

  /// Advance our input position
  ///
  /// Operand: amount to advance by
  case consume

  // TODO: assert, hooks, etc

  /// Composite assert-consume else restore
  ///
  /// Operand: Element register to compare against
  case match

  /// Match an element based on whether it satisfies a predicate
  ///
  /// Operand: Predicate register to call
  case matchPredicate

  /// Match against a provided element
  ///
  /// Operand: Packed condition register to write to and element register to compare against
  case assertion

  // TODO: Fused assertions. It seems like we often want to
  // branch based on assertion fail or success.


  // MARK: - Debugging instructions

  /// Print a string to the output
  ///
  /// Operand: String register
  case print

  /// Custom consumption operation
  ///
  /// Operand: consume hook register
  static var consumeHook: OpCode { fatalError() }

  /// Custom assertion operation
  ///
  /// Operands: destination bool register, assert hook register
  static var assertHook: OpCode { fatalError() }

  // ...


}
// TODO: Instructions for interacting with the various
// registers and stack

// TODO: Nominal type for conditions, which can have an invert bit
// set

// TODO: Better bit allocation for operand. Consider having an
// address and register number concept: addresses get ~48bits while
// registers get ~16 bits currently.

// TODO: pack in a discriminator so we can assert on types

// TODO: see if switching on top or bottom byte is better

// TODO: store relative offsets for instructions, allows for
// smaller bit-width addresses and arbitrary length programs
// using jump islands

// TODO: Explore if predication bit (or full register) would
// make it more feasible to SIMD some common programs.

//
//
// Internal NOTE: Currently stored 1-biased so that we can
// provide assertions when this is accessed incorrectly.
// Likely to remove later.
//
// TODO: Consider hoisting the bias and un-bias up into Instruction
struct Operand: RawRepresentable {
  // Store conditions in high bits, rest in low bits
  var rawValue: UInt64

  init(rawValue: UInt64) {
    self.rawValue = rawValue
  }
  init<👻>(
    condition: BoolRegister? = nil,
    _ payload: TypedInt<👻>? = nil
  ) {
    self.rawValue = 0
    if let c = condition {
      assert(c < 65_536) // How do I exponentiate in Swift?...
      self.rawValue |= (c.bits&+1) &<< 48
    }
    if let p = payload { initializePayload(p) }
  }
  init() {
    // Workaround: have to invent phantom type
    let payload: TypedInt<_PositionStackAddressRegister>? = nil
    self.init(condition: nil, payload)
  }

  var payloadMask: UInt64 { _payloadMask()  }

  // Weird workaround: I want my masks to just be the literals,
  // semantically similar to if I had pasted this value into the
  // source code. Swift doesn't support generic vars, so we do
  // this
  //
  // NOTE: Is Operand's un-descriminated union similar?
  func _payloadMask<
    I: ExpressibleByIntegerLiteral
  >() -> I {
    0x0000_FFFF_FFFF_FFFF
  }

  var hasPayload: Bool { payloadBits > 0 }
  var payloadBits: UInt64 { rawValue & payloadMask }

  func payload<👻>(
    as ty: TypedInt<👻>.Type = TypedInt<👻>.self
  ) -> TypedInt<👻> {
    assert(hasPayload)
    return TypedInt(payloadBits &- 1)
  }

  mutating func initializePayload<👻>(_ value: TypedInt<👻>) {
    assert(!hasPayload)
    assert(value < _payloadMask())
    self.rawValue |= (value.bits&+1)
  }

  var hasCondition: Bool { conditionBits > 0 }
  var conditionBits: UInt64 { (rawValue & ~payloadMask) &>> 48 }

  var condition: BoolRegister {
    assert(hasCondition)
    return BoolRegister(conditionBits &- 1)
  }

}

struct Instruction: RawRepresentable {
  var rawValue: UInt64

  var opcodeMask: UInt64 { 0xFF00_0000_0000_0000 }

  var opcode: OpCode {
    get {
      OpCode(
        rawValue: (rawValue & opcodeMask) &>> 56
      ).unsafelyUnwrapped
    }
    set {
      assert(newValue != .invalid, "consider hoisting this")
      assert(newValue.rawValue < 256)
      self.rawValue &= ~opcodeMask
      self.rawValue |= newValue.rawValue &<< 56
    }
  }
  var operand: Operand {
    get { Operand(rawValue: rawValue & ~opcodeMask) }
    set {
      assert(newValue.rawValue & opcodeMask == 0)
      self.rawValue &= opcodeMask
      self.rawValue |= newValue.rawValue
    }
  }

  var destructure: (opcode: OpCode, operand: Operand) {
    get { (opcode, operand) }
    set { self = Self(opcode, operand) }
  }

  init(rawValue: UInt64){
    self.rawValue = rawValue
  }
  init(_ opcode: OpCode, _ operand: Operand = Operand()) {
    self.init(rawValue: 0)
    self.opcode = opcode
    self.operand = operand
  }
}
extension Instruction {
  static func nop(_ s: StringRegister? = nil) -> Instruction {
    Instruction(.nop, Operand(s))
  }
  static func branch(to: InstructionAddress? = nil) -> Instruction {
    Instruction(.branch, Operand(to))
  }
  static func condBranch(condition: BoolRegister? = nil, to: InstructionAddress? = nil) -> Instruction {
    Instruction(.condBranch, Operand(condition: condition, to))
  }
  static func save(resumingFrom: InstructionAddress? = nil) -> Instruction {
    Instruction(.save, Operand(resumingFrom))
  }
  static func saveAddress(resumingFrom: InstructionAddress? = nil) -> Instruction {
    Instruction(.saveAddress, Operand(resumingFrom))
  }
  static func clear() -> Instruction {
    Instruction(.clear)
  }
  static func restore() -> Instruction {
    Instruction(.restore)
  }
  static func fail() -> Instruction {
    Instruction(.fail)
  }
  static func call(start: InstructionAddress? = nil) -> Instruction {
    Instruction(.call, Operand(start))
  }
    static func ret() -> Instruction {
    Instruction(.ret, Operand())
  }
  static func abort(_ s: StringRegister? = nil) -> Instruction {
    Instruction(.abort, Operand(s))
  }
  static func accept() -> Instruction {
    Instruction(.accept)
  }
  static func consume(_ n: Distance? = nil) -> Instruction {
    Instruction(.consume, Operand(n))
  }
  static func match(_ e: ElementRegister? = nil) -> Instruction {
    Instruction(.match, Operand(e))
  }
  static func matchPredicate(_ e: PredicateRegister? = nil) -> Instruction {
    Instruction(.matchPredicate, Operand(e))
  }
  static func assertion(
    condition: BoolRegister? = nil, _ e: ElementRegister? = nil
  ) -> Instruction {
    Instruction(.assertion, Operand(condition: condition, e))
  }
  static func print(_ s: StringRegister? = nil) -> Instruction {
    Instruction(.match, Operand(s))
  }
}

extension Instruction {
  var stringRegister: StringRegister? {
    switch opcode {
    case .nop: fallthrough
    case .abort: fallthrough
    case .print:
      return operand.hasPayload ? operand.payload() : nil
    default: return nil
    }
  }
  var instructionAddress: InstructionAddress? {
    switch opcode {
    case .branch: fallthrough
    case .condBranch: fallthrough
    case .save: fallthrough
    case .saveAddress: fallthrough
    case .call:
      return operand.hasPayload ? operand.payload() : nil
    default: return nil
    }
  }
  var elementRegister: ElementRegister? {
    switch opcode {
    case .match: fallthrough
    case .assertion:
      return operand.hasPayload ? operand.payload() : nil
    default: return nil
    }
  }
  var predicateRegister: PredicateRegister? {
    switch opcode {
    case .matchPredicate: return operand.payload()
    default: return nil
    }
  }

}

extension Instruction: InstructionProtocol {
  var operandPC: InstructionAddress? { instructionAddress }
}

