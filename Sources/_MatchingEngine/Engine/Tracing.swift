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
