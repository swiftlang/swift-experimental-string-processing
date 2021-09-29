import Util

public func compile(
  _ regex: String, options: Options = .none
) throws -> RECode {
  var currentLabel = 0
  func createLabel() -> RECode.Instruction {
    defer { currentLabel += 1}
    return .label(currentLabel)
  }
  var instructions = RECode.InstructionList()
  var numCaptures = 0
  func compileNode(_ ast: AST) {
    switch ast {
    case .empty: return
    case .character(let c):
      instructions.append(.character(c))
      return
    case .any:
      instructions.append(.any)
      return
    case .group(let child):
      compileNode(child)
      return
    case .capturingGroup(let child):
      let capId = numCaptures
      numCaptures += 1
      instructions.append(.beginCapture(capId))
      compileNode(child)
      instructions.append(.endCapture(capId))

    case .concatenation(let children):
      children.forEach { compileNode($0) }
      return

    case .many(let child):
      // a* ==> L_START, <split L_DONE>, a, goto L_START, L_DONE
      let start = createLabel()
      instructions.append(start)
      let done = createLabel()
      instructions.append(.split(disfavoring: done.label!))
      compileNode(child)
      instructions.append(.goto(label: start.label!))
      instructions.append(done)
      return

    case .zeroOrOne(let child):
      // a? ==> <split L_DONE> a, L_DONE
      let done = createLabel()
      instructions.append(.split(disfavoring: done.label!))
      compileNode(child)
      instructions.append(done)
      return

    case .oneOrMore(let child):
      // a+ ==> L_START, a, <split L_DONE>, goto L_START, L_DONE
      let start = createLabel()
      let done = createLabel()
      instructions.append(start)
      compileNode(child)
      instructions.append(.split(disfavoring: done.label!))
      instructions.append(.goto(label: start.label!))
      instructions.append(done)
      return

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
    }
  }

  let ast = try parse(regex)
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
    numCaptures: numCaptures,
    options: options)
}
