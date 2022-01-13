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

func compile(
  _ ast: AST, options: REOptions = .none
) throws -> RECode {
  var currentLabel = 0
  func createLabel() -> RECode.Instruction {
    defer { currentLabel += 1}
    return .label(currentLabel)
  }
  var instructions = RECode.InstructionList()
  func compileNode(_ ast: AST) throws {

    if let cc = ast.characterClass {
      instructions.append(.characterClass(cc))
      return
    }

    switch ast {
    case .trivia, .empty: return

    case .quote(let s):
      s.literal.forEach { instructions.append(.character($0)) }
      return

    case .atom(let a):
      switch a.kind {
      case .char(let c):
        instructions.append(.character(c))
        return
      case .scalar(let u):
        instructions.append(.unicodeScalar(u))
        return
      case .any:
        instructions.append(.any)
        return
      default:
        throw unsupported("Unsupported: \(a._dumpBase)")
      }

    case .group(let g):
      switch g.kind.value {
      case .nonCapture:
        instructions.append(.beginGroup)
        try compileNode(g.child)
        instructions.append(.endGroup)
        return
      case .capture:
        instructions.append(.beginCapture)
        try compileNode(g.child)
        instructions.append(.endCapture())
        return

      default:
        throw unsupported("Unsupported group \(g.kind.value) \(g)")
      }

//    case let .groupTransform(g, transform: t) where g.kind.value == .capture:
//      instructions.append(.beginCapture)
//      try compileNode(g.child)
//      instructions.append(.endCapture(transform: t))
//      return
//
//    case .groupTransform(let g, _):
//      throw unsupported("Unsupported group \(g)")

    case .concatenation(let concat):
      let children = concat.children
      let childrenHaveCaptures = children.any(\.hasCapture)
      if childrenHaveCaptures {
        instructions.append(.beginGroup)
      }
      try children.forEach { try compileNode($0) }
      if childrenHaveCaptures {
        instructions.append(.endGroup)
      }
      return

    case .quantification(let quant):
      let child = quant.child
      switch (quant.amount.value, quant.kind.value) {
      case (.zeroOrMore, .eager):
        // a* ==> L_START, <split L_DONE>, a, goto L_START, L_DONE
        let childHasCaptures = child.hasCapture
        if childHasCaptures {
          instructions.append(.beginGroup)
        }
        let start = createLabel()
        instructions.append(start)
        let done = createLabel()
        instructions.append(.split(disfavoring: done.label!))
        try compileNode(child)
        instructions.append(.goto(label: start.label!))
        instructions.append(done)
        if childHasCaptures {
          instructions.append(.captureArray(childType: child.captureStructure.type))
          instructions.append(.endGroup)
        }
        return

      case (.zeroOrMore, .reluctant):
        // a*? ==> L_START, <split L_ELEMENT>, goto L_DONE,
        //         L_ELEMENT, a, goto L_START, L_DONE
        let childHasCaptures = child.hasCapture
        if childHasCaptures {
          instructions.append(.beginGroup)
        }
        let start = createLabel()
        let element = createLabel()
        let done = createLabel()
        instructions.append(start)
        instructions.append(.split(disfavoring: element.label!))
        instructions.append(.goto(label: done.label!))
        instructions.append(element)
        try compileNode(child)
        instructions.append(.goto(label: start.label!))
        instructions.append(done)
        if childHasCaptures {
          instructions.append(.captureArray(childType: child.captureStructure.type))
          instructions.append(.endGroup)
        }
        return

      case (.zeroOrOne, .eager):
        // a? ==> <split L_DONE> a, L_DONE
        if child.hasCapture {
          instructions.append(.beginGroup)
          let nilCase = createLabel()
          let done = createLabel()
          instructions.append(.split(disfavoring: nilCase.label!))
          try compileNode(child)
          instructions += [
            .captureSome,
            .goto(label: done.label!),
            nilCase,
            .captureNil(childType: child.captureStructure.type),
            done,
            .endGroup
          ]
        } else {
          let done = createLabel()
          instructions.append(.split(disfavoring: done.label!))
          try compileNode(child)
          instructions.append(done)
        }
        return

      case (.zeroOrOne, .reluctant):
        // a?? ==> <split L_ELEMENT>, goto L_DONE, L_ELEMENT, a, L_DONE
        if child.hasCapture {
          instructions.append(.beginGroup)
          let element = createLabel()
          let nilCase = createLabel()
          let done = createLabel()
          instructions.append(.split(disfavoring: element.label!))
          instructions.append(.goto(label: nilCase.label!))
          instructions.append(element)
          try compileNode(child)
          instructions += [
            .captureSome,
            .goto(label: done.label!),
            nilCase,
            .captureNil(childType: child.captureStructure.type),
            done,
            .endGroup
          ]
        } else {
          let element = createLabel()
          let done = createLabel()
          instructions.append(.split(disfavoring: element.label!))
          instructions.append(.goto(label: done.label!))
          instructions.append(element)
          try compileNode(child)
          instructions.append(done)
        }
        return

      case (.oneOrMore, .eager):
        // a+ ==> L_START, a, <split L_DONE>, goto L_START, L_DONE
        let childHasCaptures = child.hasCapture
        if childHasCaptures {
          instructions.append(.beginGroup)
        }
        let start = createLabel()
        let done = createLabel()
        instructions.append(start)
        try compileNode(child)
        instructions.append(.split(disfavoring: done.label!))
        instructions.append(.goto(label: start.label!))
        instructions.append(done)
        if childHasCaptures {
          instructions.append(.captureArray(childType: child.captureStructure.type))
          instructions.append(.endGroup)
        }
        return

      case (.oneOrMore, .reluctant):
        // a+? ==> L_START, a, <split L_START>
        let childHasCaptures = child.hasCapture
        if childHasCaptures {
          instructions.append(.beginGroup)
        }
        let start = createLabel()
        instructions.append(start)
        try compileNode(child)
        instructions.append(.split(disfavoring: start.label!))
        if childHasCaptures {
          instructions.append(.captureArray(childType: child.captureStructure.type))
          instructions.append(.endGroup)
        }
        return
      default:
        throw unsupported("Unsupported: \(quant._dumpBase)")
      }

    case .alternation(let alt):
      // a|b ==> <split L_B>, a, goto L_DONE, L_B, b, L_DONE
      // a|b|c ==> <split L_B>, a, goto L_DONE,
      //           L_B, <split L_C>, b, goto L_DONE, L_C, c, L_DONE
      // a|b|c|... ==> <split L_B>, a, goto L_DONE,
      //               L_B, <split L_C>, b, goto L_DONE,
      //                    L_C, <split L_...>, c, goto L_DONE, ...,
      //               L_DONE
      //
      // NOTE: Can be optimized for more efficient layout.
      //       E.g. `a` falls-through to the rest of the program and the
      //       other cases branch back.
      //
      let children = alt.children
      assert(!children.isEmpty)
      guard children.count > 1 else {
        return try compileNode(children[0])
      }

      let last = children.last!
      let middle = children.dropLast()
      let done = createLabel()
      for child in middle {
        let nextLabel = createLabel()
        instructions.append(.split(disfavoring: nextLabel.label!))
        try compileNode(child)
        instructions.append(.goto(label: done.label!))
        instructions.append(nextLabel)
      }
      try compileNode(last)
      instructions.append(done)
      return

    case .customCharacterClass:
      fatalError("unreachable")

    case .atom(let a) where a.characterClass != nil:
      fatalError("unreachable")
    }
  }

  try compileNode(ast)
  instructions.append(.accept)

  // TODO: Just remember them as we compile
  let labels: Array<InstructionAddress> = instructions.indices.compactMap {
    idx -> (LabelId, InstructionAddress)? in
    guard case .label(let id) = instructions[idx] else { return nil }
    return (id, InstructionAddress(idx))
  }.sorted {
    $0.0 < $1.0
  }.map { $0.1 }
  let splits: Array<InstructionAddress> = instructions.indices.compactMap {
    idx -> InstructionAddress? in
    if case .split(_) = instructions[idx] { return InstructionAddress(idx) }
    return nil
  }

  return RECode(
    instructions: instructions,
    labels: labels,
    splits: splits,
    options: options)
}

func compile(
  _ regex: String, options: REOptions = .none,
  _ syntax: SyntaxOptions = .traditional
) throws -> RECode {
  let ast = try parse(regex, syntax)
  return try compile(ast, options: options)
}

