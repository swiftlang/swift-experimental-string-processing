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

@testable import _StringProcessing

extension PEGCore.Instruction: InstructionProtocol {
  var operandPC: InstructionAddress? { self.pc }
}
extension PEG.VM.Code.Instruction: InstructionProtocol {
  // No chaining for us
  var operandPC: InstructionAddress? { nil }
}

extension PEGCore: TracedProcessor {
  var isAcceptState: Bool { state == .accept }

  var isFailState: Bool { state == .fail }

  var currentPosition: Input.Index { current.pos }

  var currentPC: InstructionAddress { current.pc }
}

extension PEGCore.Thread: CustomStringConvertible {
  var description: String {
    "(pc: \(pc), pos: \(pos))"
  }
}

extension PEGCore.Instruction: CustomDebugStringConvertible, CustomStringConvertible {
  var description: String {
    switch self {
    case .nop: return "<nop>"
    case .consume(let i): return "<eat \(i)>"
    case .match(let e): return "<match '\(e)'>"
    case .matchPredicate(let s): return "<match predicate \(String(describing: s))>"
    case .branch(let to): return "<branch to: \(to)>"
    case .condBranch(let condition, let to): 
      return "<cond br \(condition) to: \(to)>"
    case .call(let f): return "<call \(f)>"
    case .ret: return "<ret>"
    case .save(let restoringAt): return "<save restoringAt: \(restoringAt)>"
    case .accept: return "<accept>"
    case .fail: return "<fail>"
    case .abort: return "<abort>"
    case .comment(let s): return "/* \(s) */"
    case .clear: return "<clear>"
    case .restore: return "<restore>"
    case .push(let pc): return "<push \(pc)>"
    case .pop: return "<pop>"

    case .assert(let e, let r):
      return "<assert \(r) = \(e)>"
    case .assertPredicate(let p, let r): 
      return "<assert predicate \(r) = \(String(describing: p))>"
    case .matchHook(let p): 
      return "<match hook \(String(describing: p))>"
    case .assertHook(let p, let r): 
      return "<assert hook \(r) = \(String(describing: p))>"
    }
  }
  var debugDescription: String { description }
}

extension PEGCore: CustomStringConvertible {
  public var description: String {
    fatalError()
  }
}

