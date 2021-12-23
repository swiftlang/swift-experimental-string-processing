extension Processor: TracedProcessor {
  var isFailState: Bool { state == .fail }
  var isAcceptState: Bool { state == .accept }

  var currentPC: InstructionAddress { controller.pc }

  public func formatSavePoints() -> String {
    if !savePoints.isEmpty {
      var result = "save points:\n"
      for point in savePoints {
        result += "  \(point.describe(in: input))\n"
      }
      return result
    }
    return ""
  }
}

extension Instruction: CustomStringConvertible {
  var description: String {
    // TODO: opcode specific rendering
    "\(opcode) \(payload)"
  }
}

extension Instruction.Payload: CustomStringConvertible {
  var description: String {
//    var result = ""
//    if hasCondition {
//      result += "\(condition) "
//    }
//    if hasPayload {
//      let payload: TypedInt<_Boo> = payload()
//      result += payload.description
//    }
//    return result

    // TODO: Without bit packing our representation, what
    // should we do? I'd say a payload cannot be printed
    // in isolation of the instruction...
    return "\(rawValue)"
  }
}

extension Processor.SavePoint {
  func describe(in input: Input) -> String {
    let posStr: String
    if let p = self.pos {
      posStr = "\(input.distance(from: input.startIndex, to: p))"
    } else {
      posStr = "<none>"
    }
    return """
      pc: \(self.pc), pos: \(posStr), stackEnd: \(stackEnd)
      """
  }
}
