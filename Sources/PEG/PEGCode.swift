import MatchingEngine

extension PEG.VM {
  struct Code {
    var functions: Array<Function>

    var start: Function { functions[0] }

    // TODO: Capture metadata

    func lookup(_ f: FunctionId) -> Function {
      functions[f.rawValue]
    }
  }
}


extension PEG.VM.Code {
  enum Instruction {
    case nop

    case comment(String)

    // Advance the InIndex by a fixed amount of positions
    case consume(Int)

    // Advance the InIndex by a dynamic amount of positions
    //case advance(Register) should we have non-bool registers?

    // TODO: Matching vs asserting...

    // Match and consume
    case element(Element)
    case set((Element) -> Bool)
    case any

    // Control flow
    case branch(to: LabelId)
    case condBranch(condition: BoolRegister, to: LabelId)
    case label(LabelId) // TODO: separate out

    // Function calls
    case call(FunctionId)
    case ret

    // Backtracking (TODO: should this be explicit slots or implicit stack?)
    case save(restoringAt: LabelId)
//      case restore
    case commit(continuingAt: LabelId)

    // Capture
    case startCapture
    case endCapture

    // TODO: Consider captures an PC/SP pair, requires ability to
    // save / retrieve SPs and a commit-capture instruction.

    // Terminate
    case accept
    case fail
    case abort

  }

}

extension PEG.VM.Code {
  struct Function {
    let name: String
    var instructions: InstructionList<Instruction>

    init(name: String) {
      self.name = name
      self.instructions = [.comment(name)]
    }

    // Label location metadata
    // TODO: Array permitting uninitialized values
    var labels: Dictionary<LabelId, InstructionAddress> = [:]

    // TODO: Do we want to represent capture metadata?

    func lookup(_ p: InstructionAddress) -> Instruction { instructions[p] }
    func lookup(_ l: LabelId) -> InstructionAddress { labels[l]! }

    mutating func add(_ inst: Instruction) {
      if case .label = inst {
        assertionFailure("Compilation error: label instruction")
      }
      instructions.append(inst)
    }
    mutating func addLabel(_ id: LabelId) {
      labels[id] = InstructionAddress(instructions.count)
      instructions.append(.label(id))
    }
  }
}

extension PEG.VM.Code.Instruction: CustomStringConvertible {
  var description: String {
    switch self {
    case .nop: return "<nop>"
    case .consume(let i): return "<eat \(i)>"
    case .element(let e): return "<match '\(e)'>"
    case .set(let s): return "<predicate \(String(describing: s))>"
    case .any: return "<any>"
    case .branch(let to): return "<branch to: \(to)>"
    case .condBranch(let condition, let to): 
      return "<cond br \(condition) to: \(to)>"
    case .label(let l): return "<label \(l)>"
    case .call(let f): return "<call \(f)>"
    case .ret: return "<ret>"
    case .save(let restoringAt): return "<save restoringAt: \(restoringAt)>"
    case .commit(let continuingAt): return "<commit continuingAt: \(continuingAt)>"
    case .startCapture: return "<startCapture>"
    case .endCapture: return "<endCapture>"
    case .accept: return "<accept>"
    case .fail: return "<fail>"
    case .abort: return "<abort>"
    case .comment(let s): return "/* \(s) */"
    }
  }
}

extension PEG.VM.Code.Function: CustomStringConvertible {
  var description: String {
    instructions.indices.reduce("Instructions:\n") { result, idx in
      result + "\(instructions.formatInstruction(idx, atCurrent: false, depth: 3))\n"
    }
  }
}

extension PEG.VM.Code.Instruction {
  var label: LabelId? {
    switch self {
    case .branch(let l): return l
    case .condBranch(_, let l): return l
    case .save(let l): return l
    case .commit(let l): return l
    case .label(let l): return l
    default: return nil
    }
  }
}

extension PEG.VM.Code: CustomStringConvertible {
  var description: String {
    "\(functions)"
  }
}
