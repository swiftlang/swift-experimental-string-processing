/// A single instruction for the matching engine to execute
///
/// Instructions are 64-bits, consisting of an 8-bit opcode
/// and a 56-bit payload, which packs operands.
///
struct Instruction: RawRepresentable, Hashable {
  var rawValue: UInt64
  init(rawValue: UInt64){
    self.rawValue = rawValue
  }
}

extension Instruction {
  enum OpCode: UInt64 {
    case invalid = 0

    // MARK: - General Purpose

    /// Do nothing
    ///
    ///     nop(comment: String?)
    ///
    /// Operand:
    ///   - Optional string register containing a comment or reason
    ///
    case nop

    /// Decrement the value stored in a register.
    /// Returns whether the value was set to zero
    ///
    ///     decrement(_ i: IntReg) -> Bool
    ///
    /// Operands:
    ///   - Int register to decrease
    ///   - Condition register set if now zero
    ///
    case decrement

    /// Move an immediate value into a register
    ///
    ///     moveImmediate(_ i: Int, into: IntReg)
    ///
    /// Operands:
    ///   - TODO
    ///
    case moveImmediate

    // MARK: General Purpose: Control flow

    /// Branch to a new instruction
    ///
    /// Operand: instruction address to branch to
    case branch

    /// Conditionally branch
    ///
    /// Operand: packed condition register and address to branch to
    case condBranch

    /// Conditionally branch if zero, otherwise decrement
    ///
    ///     branch_cond_zero_else_decrement(_ i: IntReg, to: InstructionAddress)
    ///
    /// Operands:
    ///   - Int register to check for zero, otherwise decrease
    ///   - Instruction address to branch to, if zero
    ///
    case condBranchZeroElseDecrement

    // MARK: General Purpose: Function calls

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

    // MARK: General Purpose: Debugging instructions

    /// Print a string to the output
    ///
    /// Operand: String register
    case print



    // MARK: - Matching

    /// Advance the input position.
    ///
    /// Operand: Amount to advance by.
    case advance

    // TODO: Is the amount useful here? Is it commonly more than 1?

    /// Composite assert-advance else restore.
    ///
    /// Operand: Element register to compare against.
    case match

    /// Match against a sequence of elements
    ///
    /// Operand: Sequence register to compare against.
    case matchSequence

    /// Match against a provided element.
    ///
    /// Operand: Packed condition register to write to and element register to
    /// compare against.
    case assertion

    /// Advance the input position based on the result by calling the consume
    /// function.
    ///
    /// Operand: Consume function register to call.
    case consumeBy

    /// Custom assertion operation
    ///
    /// Operands: destination bool register, assert hook register
    static var assertHook: OpCode { fatalError() }


    // MARK: Matching: Save points

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

    /// Fused save-and-branch. 
    ///
    ///   split(to: target, saving: backtrackPoint)
    ///
    case splitSaving

    // MARK: Matching: State transitions

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

    // TODO: Fused assertions. It seems like we often want to
    // branch based on assertion fail or success.
  }
}

internal var _opcodeMask: UInt64 { 0xFF00_0000_0000_0000 }

// TODO: internal after compiler moves in
public var _payloadMask: UInt64 { ~_opcodeMask }

extension Instruction {
  var opcodeMask: UInt64 { 0xFF00_0000_0000_0000 }

  var opcode: OpCode {
    get {
      OpCode(
        rawValue: (rawValue & _opcodeMask) &>> 56
      ).unsafelyUnwrapped
    }
    set {
      assert(newValue != .invalid, "consider hoisting this")
      assert(newValue.rawValue < 256)
      self.rawValue &= ~_opcodeMask
      self.rawValue |= newValue.rawValue &<< 56
    }
  }
  var payload: Payload {
    get { Payload(rawValue: rawValue & ~opcodeMask) }
    set {
      self.rawValue &= opcodeMask
      self.rawValue |= newValue.rawValue
    }
  }

  var destructure: (opcode: OpCode, payload: Payload) {
    get { (opcode, payload) }
    set { self = Self(opcode, payload) }
  }

  init(_ opcode: OpCode, _ payload: Payload/* = Payload()*/) {
    self.init(rawValue: 0)
    self.opcode = opcode
    self.payload = payload
    // TODO: check invariants
  }
  init(_ opcode: OpCode) {
    self.init(rawValue: 0)
    self.opcode = opcode
    //self.payload = payload
    // TODO: check invariants
    // TODO: placeholder bit pattern for fill-in-later
  }
}

/*

 This is in need of more refactoring and design, the following
 are a rough listing of TODOs:

 - Save point and call stack interactions should be more formalized.
 - It's too easy to have unbalanced save/clears amongst function calls
 - Nominal type for conditions with an invert bit
 - Better bit allocation and layout for operand, instruction, etc
 - Use spare bits for better assertions
 - Check low-level compiler code gen for switches
 - Consider relative addresses instead of absolute addresses
 - Explore a predication bit
 - Explore using SIMD
 - Explore a larger opcode, so that we can have variant flags
   - E.g., opcode-local bits instead of flattening opcode space

 We'd like to eventually design:

 - A general-purpose core (future extensibility)
 - A matching-specific instruction area carved out
 - Leave a large area for future usage of run-time bytecode interpretation
 - Debate: allow for future variable-width instructions

 We'd like a testing / performance setup that lets us

 - Define new instructions in terms of old ones (testing, perf)
 - Version our instruction set in case we need future fixes

 */

// TODO: replace with instruction formatters...
extension Instruction {
  var stringRegister: StringRegister? {
    switch opcode {
    case .nop, .abort:
      return payload.optionalString
    case .print:
      return payload.string
    default: return nil
    }
  }
  var instructionAddress: InstructionAddress? {
    switch opcode {
    case .branch, .save, .saveAddress, .call:
      return payload.addr

    case .condBranch:
      return payload.pairedAddrBool.0

    default: return nil
    }
  }
  var elementRegister: ElementRegister? {
    switch opcode {
    case .match:
      return payload.element
    case .assertion:
      return payload.pairedElementBool.0
    default: return nil
    }
  }
  var consumeFunctionRegister: ConsumeFunctionRegister? {
    switch opcode {
    case .consumeBy: return payload.consumer
    default: return nil
    }
  }

}

extension Instruction: InstructionProtocol {
  var operandPC: InstructionAddress? { instructionAddress }
}


// TODO: better names for accept/fail/etc. Instruction
// conflates backtracking with signaling failure or success,
// could be clearer.
enum State {
  /// Still running
  case inProgress

  /// FAIL: halt and signal failure
  case fail

  /// ACCEPT: halt and signal success
  case accept
}
