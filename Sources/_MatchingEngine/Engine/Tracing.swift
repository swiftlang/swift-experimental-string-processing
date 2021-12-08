extension Processor: TracedProcessor {
  var isFailState: Bool { state == .fail }
  var isAcceptState: Bool { state == .accept }

  var currentPC: InstructionAddress { controller.pc }
}

extension Instruction: CustomStringConvertible {
  var description: String {
    "\(opcode) \(operand)"
  }
}

extension Operand: CustomStringConvertible {
  var description: String {
    var result = ""
    if hasCondition {
      result += "\(condition) "
    }
    if hasPayload {
      let payload: TypedInt<_Boo> = payload()
      result += payload.description
    }
    return result
  }
}

extension Processor.SavePoint: CustomStringConvertible {
  var description: String {
    String(describing: self.destructure)
  }
}
