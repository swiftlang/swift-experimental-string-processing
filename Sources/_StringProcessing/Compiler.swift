import _MatchingEngine

struct RegexProgram {
  typealias Program = _MatchingEngine.Program<String>
  var program: Program
}

class Compiler {
  let ast: AST
  let matchLevel: CharacterClass.MatchLevel
  let options: REOptions
  private var builder = RegexProgram.Program.Builder()

  init(
    ast: AST,
    matchLevel: CharacterClass.MatchLevel = .graphemeCluster,
    options: REOptions = []
  ) {
    self.ast = ast
    self.matchLevel = matchLevel
    self.options = options
  }

  __consuming func emit() -> RegexProgram {
    emit(ast)
    builder.buildAccept()
    return RegexProgram(program: builder.assemble())
  }

  func emit(_ node: AST) {
    switch node {
    // Any: .
    //     consume 1
    case .atom(let a) where a.kind == .any && matchLevel == .graphemeCluster:
      builder.buildConsume(1)

    case let n where n.characterClass != nil:
      let cc = n.characterClass!.withMatchLevel(matchLevel)
      builder.buildConsume { input, bounds in
        cc.matches(in: input, at: bounds.lowerBound)
      }

    // Alternation: p0 | p1 | ... | pn
    //     save next_p1
    //     <code for p0>
    //     branch done
    //   next_p1:
    //     save next_p2
    //     <code for p1>
    //     branch done
    //   next_p2:
    //     save next_p...
    //     <code for p2>
    //     branch done
    //   ...
    //   next_pn:
    //     <code for pn>
    //   done:
    case .alternation(let alt):
      let done = builder.makeAddress()
      for component in alt.children.dropLast() {
        let next = builder.makeAddress()
        builder.buildSave(next)
        emit(component)
        builder.buildBranch(to: done)
        builder.label(next)
      }
      emit(alt.children.last!)
      builder.label(done)

    // FIXME: Wait, how does this work?
    case .groupTransform(let g, _):
      emit(g.child)

    case .atom(let a):
      switch a.kind {
      case .char(let ch):
        builder.buildMatch(ch)
      case .scalar(let scalar):
        builder.buildConsume { input, bounds in
          input.unicodeScalars[bounds.lowerBound] == scalar
          ? input.unicodeScalars.index(after: bounds.lowerBound)
          : nil
        }
      default:
        fatalError("Unsupported: \(a._dumpBase)")
      }

    case .concatenation(let concat):
      concat.children.forEach(emit)

    case .trivia, .empty:
      break

    // FIXME: This can't be right...
    case .group(let g):
      emit(g.child)

    case .quantification(let quant):
      emitQuantification(quant)

    case .quote, .customCharacterClass:
      fatalError("FIXME")
    }
  }

  func emitQuantification(_ quant: AST.Quantification) {
    let child = quant.child
    switch (quant.amount.value, quant.kind.value) {
    // Lazy zero or more: *?
    //   start:
    //     save element
    //     branch after
    //   element:
    //     <code for component>
    //     branch start
    //   after:
    case (.zeroOrMore, .reluctant):
      let start = builder.makeAddress()
      let element = builder.makeAddress()
      let after = builder.makeAddress()
      builder.label(start)
      builder.buildSave(element)
      builder.buildBranch(to: after)
      builder.label(element)
      emit(child)
      builder.buildBranch(to: start)
      builder.label(after)

    // Lazy one or more: +?
    //   element:
    //     <code for component>
    //     save element
    //   after:
    case (.oneOrMore, .reluctant):
      let element = builder.makeAddress()
      let after = builder.makeAddress()
      builder.label(element)
      emit(child)
      builder.buildSave(element)
      builder.label(after)

    // Lazy zero or one: ??
    //     save element
    //     branch after
    //   element:
    //     <code for component>
    //   after:
    case (.zeroOrOne, .reluctant):
      let element = builder.makeAddress()
      let after = builder.makeAddress()
      builder.buildSave(element)
      builder.buildBranch(to: after)
      builder.label(element)
      emit(child)
      builder.label(after)

    // Zero or more: *
    //   start:
    //     save end
    //     <code for component>
    //     branch start
    //   end:
    case (.zeroOrMore, .greedy):
      let end = builder.makeAddress()
      let start = builder.makeAddress()
      builder.label(start)
      builder.buildSave(end)
      emit(child)
      builder.buildBranch(to: start)
      builder.label(end)

    // One or more: +
    //   element:
    //     <code for component>
    //     save end
    //     branch element
    //   end:
    case (.oneOrMore, .greedy):
      let element = builder.makeAddress()
      let end = builder.makeAddress()
      builder.label(element)
      emit(child)
      builder.buildSave(end)
      builder.buildBranch(to: element)
      builder.label(end)

    // Zero or one: ?
    //     save end
    //     <code for component>
    //   end:
    case (.zeroOrOne, .greedy):
      let end = builder.makeAddress()
      builder.buildSave(end)
      emit(child)
      builder.label(end)

    case (.exactly, _),
         (.nOrMore, _),
         (.upToN, _),
         (.range, _),
         (_, .possessive):
      fatalError("Not yet supported")
    }
  }
}

public func _compileRegex(
  _ regex: String, _ syntax: SyntaxOptions = .traditional
) -> Executor {
  let ast = try! parse(regex, .traditional)
  let program = Compiler(ast: ast).emit()
  return Executor(program: program)
}

