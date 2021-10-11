import Util

public struct Program<Element> where Element: Equatable {
  var instructions: InstructionList<Instruction>

  var staticElements: Array<Element>
  var staticStrings: Array<String>
  var staticPredicates: Array<(Element) -> Bool>

  var registerInfo: RegisterInfo

  var enableTracing: Bool = false
}

extension Program: CustomStringConvertible {
  public var description: String {
    var result = """
    Elements: \(staticElements)
    Strings: \(staticStrings)

    """
    if !staticPredicates.isEmpty {
      result += "Predicates: \(staticPredicates)"
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
