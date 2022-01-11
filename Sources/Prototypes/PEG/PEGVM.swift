//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _MatchingEngine

extension PEG {

  // NOTE: We could have a collection-agnostic object code that we compile
  // (provided no custom collection hooks are needed) to, and bind later.
  // For now, we bind Input with the VM

  public struct VM<Input: Collection> where Input.Element == Element {
    typealias Core = PEGCore<Input>
    typealias Instruction = Core.Instruction

    var instructions: InstructionList<Instruction>
    var enableTracing: Bool = false
  }
}

extension PEG.VM {
  struct Loader {
    var functionLocations = Dictionary<FunctionId, InstructionAddress>()

    // Need second pass to link functions and adjust branches
    var functionFixups = Array<(InstructionAddress, FunctionId)>()

   // var labelLocations = Dictionary<Code.Label, PC>()
  }

  static func load(_ code: Code) -> Self {
    //
    // Lower, layout, link, and load
    //

    // Layout (currently in `code` order)
    var loweredInstructions = Array<Core.Instruction>()

    // We will need to do a second pass to adjust function
    // references
    var functionLocations = Dictionary<FunctionId, InstructionAddress>()
    var functionFixups = Array<(InstructionAddress, FunctionId)>()

    func add(_ inst: Instruction) {
      loweredInstructions.append(inst)
    }
    func addFunctionFixup(
      _ inst: Instruction, _ f: FunctionId
    ) {
      defer { add(inst) }
      functionFixups.append((nextPC, f))
    }
    var nextPC: InstructionAddress { InstructionAddress(loweredInstructions.count) }
    let invalidLoc = InstructionAddress(-1)

    for funIdx in code.functions.indices {
      functionLocations[FunctionId(funIdx)] = nextPC
      let fun = code.functions[funIdx]

      // We will need to do a second pass to adjust label
      // references
      var labelFixups = Array<(InstructionAddress, LabelId)>()
      var labelLocations = Dictionary<LabelId, InstructionAddress>()
      func addLabelFixup(_ inst: Instruction, _ l: LabelId) {
        defer { add(inst) }
        labelFixups.append((nextPC, l))
      }

      for inst in fun.instructions {
        switch inst {
        case .label(let l):
          labelLocations[l] = nextPC

        case .nop:
          continue

        case .comment(let s):
          if emitComments { add(.comment(s)) }

        case .consume(let n):
          add(.consume(n))
        case .element(let e):
          add(.match(e))
        case .set(let p):
          add(.matchPredicate(p))
        case .any:
          add(.any)

        // Lower labels
        case .branch(let l):
          addLabelFixup(.branch(to: invalidLoc), l)
        case .condBranch(let cond, let l):
          addLabelFixup(
            .condBranch(condition: cond, to: invalidLoc), l)
        case .save(let l):
          addLabelFixup(.save(invalidLoc), l)
        case .commit(let l):
          add(.clear)
          addLabelFixup(.branch(to: invalidLoc), l)

        // Link calls
        case .call(let f):
          addFunctionFixup(.call(invalidLoc), f)

        case .ret:
          add(.ret)
        case .startCapture:
          fatalError()
        case .endCapture:
          fatalError()

        // TODO:
        case .accept:
          add(.accept)
        case .fail:
          add(.fail)
        case .abort:
          add(.abort(reason: "ABORT!"))
        }
      }

      // Fixup labels
      for (pc, l) in labelFixups {
        loweredInstructions[
          pc.rawValue
        ].setPC(labelLocations[l]!)
      }
    }
    // Fixup functions
    for (pc, f) in functionFixups {
      loweredInstructions[
        pc.rawValue
      ].setPC(functionLocations[f]!)
    }

    return Self(instructions: InstructionList(loweredInstructions))
  }
}

extension PEG.VM: CustomStringConvertible {
  public var description: String {
    instructions.indices.reduce("Instructions:\n") { result, idx in
      result + "\(instructions.formatInstruction(idx, atCurrent: false, depth: 3))\n"
    }
  }
}

