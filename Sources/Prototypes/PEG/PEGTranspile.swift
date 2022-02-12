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
import _StringProcessing

extension PEG.VM where Input == String {
  typealias MEProg = MEProgram<String>
  func transpile() throws -> MEProg {
    typealias Builder = MEProg.Builder
    var builder = MEProg.Builder()

    // Address token info
    //
    // TODO: Could builder provide a generalized mapping table?
    typealias TokenEntry =
      (Builder.AddressToken, use: InstructionAddress, target: InstructionAddress)
    var addressTokens = Array<TokenEntry>()
    for idx in instructions.indices {
      if let address = instructions[idx].pc {
        addressTokens.append(
          (builder.makeAddress(), use: idx, target: address))
      }
    }
    var nextTokenIdx = addressTokens.startIndex
    func nextToken() -> Builder.AddressToken {
      defer { addressTokens.formIndex(after: &nextTokenIdx) }
      return addressTokens[nextTokenIdx].0
    }

    for idx in instructions.indices {
      defer {
        // TODO: Linear is probably fine...
        for (tok, _, _) in addressTokens.lazy.filter({
          $0.target == idx
        }) {
          builder.resolve(tok)
        }
      }

      switch instructions[idx] {
      case .nop:
        builder.buildNop()
      case .comment(let s):
        builder.buildNop(s)
      case .consume(let n):
        builder.buildAdvance(Distance(n))
      case .branch(_):
        builder.buildBranch(to: nextToken())
      case .condBranch(let condition, _):
        // TODO: Need to map our registers over...
        _ = condition
        fatalError()//builder.buildCondBranch(condition, to: nextToken())
      case .save(_):
        builder.buildSave(nextToken())
      case .clear:
        builder.buildClear()
      case .restore:
        builder.buildRestore()
      case .push(_):
        fatalError()
      case .pop:
        fatalError()
      case .call(_):
        builder.buildCall(nextToken())
      case .ret:
        builder.buildRet()

      case .assert(_,_):
        fatalError()//builder.buildAssert(e, r)

      case .assertPredicate(_, _):
        fatalError()//builder.buildAssertPredicate(p, r)

      case .match(let e):
        builder.buildMatch(e)

      case .matchPredicate(let p):
        builder.buildConsume { input, bounds in
          p(input[bounds.lowerBound])
            ? input.index(after: bounds.lowerBound)
            : nil
        }

      case .matchHook(_):
        fatalError()//builder.buildMatchHook(h)

      case .assertHook(_, _):
        fatalError()//builder.buildAssertHook(h, r)

      case .accept:
        builder.buildAccept()

      case .fail:
        builder.buildFail()

      case .abort(let s):
        builder.buildAbort(s)
      }
    }

    return try builder.assemble()
  }
}

extension PEG.Program where Element == Character {
  public func transpile(
  ) throws -> Engine<String> {
    try Engine(compile(for: String.self).vm.transpile())
  }
}
