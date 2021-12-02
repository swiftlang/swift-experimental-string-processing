import Util

public func compile(
  _ ast: AST, options: REOptions = .none
) throws -> RECode {
  var currentLabel = 0
  func createLabel() -> RECode.Instruction {
    defer { currentLabel += 1}
    return .label(currentLabel)
  }
  var instructions = RECode.InstructionList()
  func compileNode(_ ast: AST) {

    if let cc = ast.characterClass {
      instructions.append(.characterClass(cc))
      return
    }

    switch ast {
    case .trivia, .empty: return

    case .quote(let s):
      s.forEach { instructions.append(.character($0)) }
      return

    case .atom(.char(let c)):
      instructions.append(.character(c))
      return

    case .atom(.scalar(let u)):
      instructions.append(.unicodeScalar(u))
      return

    case .any:
      instructions.append(.any)
      return

    case .group(.nonCapture(), let child):
      instructions.append(.beginGroup)
      compileNode(child)
      instructions.append(.endGroup)
      return

    case .group(.capture(), let child):
      instructions.append(.beginCapture)
      compileNode(child)
      instructions.append(.endCapture())
      return

    case .group(let g, _):
      fatalError("Unsupported group \(g)")

    case .groupTransform(.capture(), let child, let transform):
      instructions.append(.beginCapture)
      compileNode(child)
      instructions.append(.endCapture(transform: transform))
      return

    case .groupTransform(let g, _, _):
      fatalError("Unsupported group \(g)")

    case .concatenation(let children):
      let childrenHaveCaptures = children.any(\.hasCaptures)
      if childrenHaveCaptures {
        instructions.append(.beginGroup)
      }
      children.forEach { compileNode($0) }
      if childrenHaveCaptures {
        instructions.append(.endGroup)
      }
      return

    case .quantification(.zeroOrMore(.greedy), let child):
      // a* ==> L_START, <split L_DONE>, a, goto L_START, L_DONE
      let childHasCaptures = child.hasCaptures
      if childHasCaptures {
        instructions.append(.beginGroup)
      }
      let start = createLabel()
      instructions.append(start)
      let done = createLabel()
      instructions.append(.split(disfavoring: done.label!))
      compileNode(child)
      instructions.append(.goto(label: start.label!))
      instructions.append(done)
      if childHasCaptures {
        instructions.append(.captureArray)
        instructions.append(.endGroup)
      }
      return

    case .quantification(.zeroOrMore(.reluctant), let child):
      // a*? ==> L_START, <split L_ELEMENT>, goto L_DONE,
      //         L_ELEMENT, a, goto L_START, L_DONE
      let childHasCaptures = child.hasCaptures
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
      compileNode(child)
      instructions.append(.goto(label: start.label!))
      instructions.append(done)
      if childHasCaptures {
        instructions.append(.captureArray)
        instructions.append(.endGroup)
      }
      return

    case .quantification(.zeroOrOne(.greedy), let child):
      // a? ==> <split L_DONE> a, L_DONE
      if child.hasCaptures {
        instructions.append(.beginGroup)
        let nilCase = createLabel()
        let done = createLabel()
        instructions.append(.split(disfavoring: nilCase.label!))
        compileNode(child)
        instructions += [
          .captureSome,
          .goto(label: done.label!),
          nilCase,
          .captureNil,
          done,
          .endGroup
        ]
      } else {
        let done = createLabel()
        instructions.append(.split(disfavoring: done.label!))
        compileNode(child)
        instructions.append(done)
      }
      return

    case .quantification(.zeroOrOne(.reluctant), let child):
      // a?? ==> <split L_ELEMENT>, goto L_DONE, L_ELEMENT, a, L_DONE
      if child.hasCaptures {
        instructions.append(.beginGroup)
        let element = createLabel()
        let nilCase = createLabel()
        let done = createLabel()
        instructions.append(.split(disfavoring: element.label!))
        instructions.append(.goto(label: nilCase.label!))
        instructions.append(element)
        compileNode(child)
        instructions += [
          .captureSome,
          .goto(label: done.label!),
          nilCase,
          .captureNil,
          done,
          .endGroup
        ]
      } else {
        let element = createLabel()
        let done = createLabel()
        instructions.append(.split(disfavoring: element.label!))
        instructions.append(.goto(label: done.label!))
        instructions.append(element)
        compileNode(child)
        instructions.append(done)
      }
      return

    case .quantification(.oneOrMore(.greedy), let child):
      // a+ ==> L_START, a, <split L_DONE>, goto L_START, L_DONE
      let childHasCaptures = child.hasCaptures
      if childHasCaptures {
        instructions.append(.beginGroup)
      }
      let start = createLabel()
      let done = createLabel()
      instructions.append(start)
      compileNode(child)
      instructions.append(.split(disfavoring: done.label!))
      instructions.append(.goto(label: start.label!))
      instructions.append(done)
      if childHasCaptures {
        instructions.append(.captureArray)
        instructions.append(.endGroup)
      }
      return

    case .quantification(.oneOrMore(.reluctant), let child):
      // a+? ==> L_START, a, <split L_START>
      let childHasCaptures = child.hasCaptures
      if childHasCaptures {
        instructions.append(.beginGroup)
      }
      let start = createLabel()
      instructions.append(start)
      compileNode(child)
      instructions.append(.split(disfavoring: start.label!))
      if childHasCaptures {
        instructions.append(.captureArray)
        instructions.append(.endGroup)
      }
      return
    case .quantification(let q, _):
      fatalError("Unsupported: \(q._dump())")

    case .alternation(let children):
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
      assert(!children.isEmpty)
      guard children.count > 1 else { return compileNode(children[0]) }

      let last = children.last!
      let middle = children.dropLast()
      let done = createLabel()
      for child in middle {
        let nextLabel = createLabel()
        instructions.append(.split(disfavoring: nextLabel.label!))
        compileNode(child)
        instructions.append(.goto(label: done.label!))
        instructions.append(nextLabel)
      }
      compileNode(last)
      instructions.append(done)
      return

    case .atom: fatalError("FIXME")

    case .any, .customCharacterClass:
      fatalError("unreachable")

    case .atom(let a) where a.characterClass != nil:
      fatalError("unreachable")
    }

  }

  compileNode(ast)
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

public func compile(
  _ regex: String, options: REOptions = .none,
  _ syntax: SyntaxOptions = .traditional
) throws -> RECode {
  let ast = try parse(regex, syntax)
  return try compile(ast, options: options)
}

