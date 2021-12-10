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
  func compileNode(_ ast: AST) {

    if let cc = ast.characterClass {
      instructions.append(.characterClass(cc))
      return
    }

    switch ast {
    case .trivia, .empty: return

    case .quote(let s):
      s.literal.forEach { instructions.append(.character($0)) }
      return

    case .atom(.char(let c)):
      instructions.append(.character(c))
      return

    case .atom(.scalar(let u)):
      instructions.append(.unicodeScalar(u))
      return

    case .atom(.any):
      instructions.append(.any)
      return

    case .group(let g):
      switch g.kind.value {
      case .nonCapture:
        instructions.append(.beginGroup)
        compileNode(g.child)
        instructions.append(.endGroup)
        return
      case .capture:
        instructions.append(.beginCapture)
        compileNode(g.child)
        instructions.append(.endCapture())
        return

      default:
        fatalError("Unsupported group \(g.kind.value) \(g)")
      }

    case let .groupTransform(g, transform: t) where g.kind.value == .capture:
      instructions.append(.beginCapture)
      compileNode(g.child)
      instructions.append(.endCapture(transform: t))
      return

    case .groupTransform(let g, _):
      fatalError("Unsupported group \(g)")

    case .concatenation(let concat):
      let children = concat.children
      let childrenHaveCaptures = children.any(\.hasCapture)
      if childrenHaveCaptures {
        instructions.append(.beginGroup)
      }
      children.forEach { compileNode($0) }
      if childrenHaveCaptures {
        instructions.append(.endGroup)
      }
      return


    case .quantification(let quant):
      let child = quant.child
      switch (quant.amount.value, quant.kind.value) {
      case (.zeroOrMore, .greedy):
        // a* ==> L_START, <split L_DONE>, a, goto L_START, L_DONE
        let childHasCaptures = child.hasCapture
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
        compileNode(child)
        instructions.append(.goto(label: start.label!))
        instructions.append(done)
        if childHasCaptures {
          instructions.append(.captureArray)
          instructions.append(.endGroup)
        }
        return

      case (.zeroOrOne, .greedy):
        // a? ==> <split L_DONE> a, L_DONE
        if child.hasCapture {
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

      case (.oneOrMore, .greedy):
        // a+ ==> L_START, a, <split L_DONE>, goto L_START, L_DONE
        let childHasCaptures = child.hasCapture
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

      case (.oneOrMore, .reluctant):
        // a+? ==> L_START, a, <split L_START>
        let childHasCaptures = child.hasCapture
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
      default:
        fatalError("Unsupported: \(quant)")
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

    case .customCharacterClass:
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

func compile(
  _ regex: String, options: REOptions = .none,
  _ syntax: SyntaxOptions = .traditional
) throws -> RECode {
  let ast = try parse(regex, syntax)
  return try compile(ast, options: options)
}

