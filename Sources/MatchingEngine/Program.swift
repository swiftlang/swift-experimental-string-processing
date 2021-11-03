import Util

public struct Program<Input: Collection> where Input.Element: Equatable {
  public typealias ConsumeFunction = (Input, Range<Input.Index>) -> Input.Index?
  var instructions: InstructionList<Instruction>

  var staticElements: [Input.Element]
  var staticStrings: [String]
  var staticConsumeFunctions: [ConsumeFunction]

  var registerInfo: RegisterInfo

  var enableTracing: Bool = false
}

extension Program: CustomStringConvertible {
  public var description: String {
    var result = """
    Elements: \(staticElements)
    Strings: \(staticStrings)

    """
    if !staticConsumeFunctions.isEmpty {
      result += "Consume functions: \(staticConsumeFunctions)"
    }

    // TODO: Extract into formatting code

    for idx in instructions.indices {
      let inst = instructions[idx]
      result += "[\(idx.rawValue)] \(inst)"
      if let sp = inst.stringRegister {
        result += " // \(staticStrings[sp.rawValue])"
      }
      if let ia = inst.instructionAddress {
        result += " // \(instructions[ia])"
      }
      result += "\n"
    }
    return result
  }
}
