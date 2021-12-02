import MatchingEngine

public struct RegexProgram {
  typealias Program = MatchingEngine.Program<String>
  var program: Program
}

public class Compiler {
  public let ast: AST
  public let matchLevel: CharacterClass.MatchLevel
  public let options: REOptions
  private var builder = RegexProgram.Program.Builder()

  public init(
    ast: AST,
    matchLevel: CharacterClass.MatchLevel = .graphemeCluster,
    options: REOptions = []
  ) {
    self.ast = ast
    self.matchLevel = matchLevel
    self.options = options
  }

  public __consuming func emit() -> RegexProgram {
    emit(ast)
    builder.buildAccept()
    return RegexProgram(program: builder.assemble())
  }

  func emit(_ node: AST) {
    switch node {
    // Any: .
    //     consume 1
    case .any where matchLevel == .graphemeCluster:
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
    case .alternation(let components):
      let done = builder.makeAddress()
      for component in components.dropLast() {
        let next = builder.makeAddress()
        builder.buildSave(next)
        emit(component)
        builder.buildBranch(to: done)
        builder.label(next)
      }
      emit(components.last!)
      builder.label(done)

    case .groupTransform(_, let component, _):
      emit(component)

    case .atom(.char(let ch)):
      builder.buildMatch(ch)

    case .atom(.scalar(let scalar)):
      builder.buildConsume { input, bounds in
        input.unicodeScalars[bounds.lowerBound] == scalar
          ? input.unicodeScalars.index(after: bounds.lowerBound)
          : nil
      }

    case .concatenation(let components):
      for component in components {
        emit(component)
      }

    case .trivia, .empty:
      break

    case .group(_, let component):
      emit(component)

    case .quantification(let quantifier, let component):
      emitQuantification(quantifier, component)

    case .atom, .quote, .customCharacterClass:
      fatalError("FIXME")
    }


  }

  func emitQuantification(_ quantifier: Quantifier, _ component: AST) {
    switch (quantifier.amount, quantifier.kind, component) {
    // Lazy zero or more: *?
    //   start:
    //     save element
    //     branch after
    //   element:
    //     <code for component>
    //     branch start
    //   after:
    case (.zeroOrMore, .reluctant, let component):
      let start = builder.makeAddress()
      let element = builder.makeAddress()
      let after = builder.makeAddress()
      builder.label(start)
      builder.buildSave(element)
      builder.buildBranch(to: after)
      builder.label(element)
      emit(component)
      builder.buildBranch(to: start)
      builder.label(after)

    // Lazy one or more: +?
    //   element:
    //     <code for component>
    //     save element
    //   after:
    case (.oneOrMore, .reluctant, let component):
      let element = builder.makeAddress()
      let after = builder.makeAddress()
      builder.label(element)
      emit(component)
      builder.buildSave(element)
      builder.label(after)

    // Lazy zero or one: ??
    //     save element
    //     branch after
    //   element:
    //     <code for component>
    //   after:
    case (.zeroOrOne, .reluctant, let component):
      let element = builder.makeAddress()
      let after = builder.makeAddress()
      builder.buildSave(element)
      builder.buildBranch(to: after)
      builder.label(element)
      emit(component)
      builder.label(after)

    // Zero or more: *
    //   start:
    //     save end
    //     <code for component>
    //     branch start
    //   end:
    case (.zeroOrMore, .greedy, let component):
      let end = builder.makeAddress()
      let start = builder.makeAddress()
      builder.label(start)
      builder.buildSave(end)
      emit(component)
      builder.buildBranch(to: start)
      builder.label(end)

    // One or more: +
    //   element:
    //     <code for component>
    //     save end
    //     branch element
    //   end:
    case (.oneOrMore, .greedy, let component):
      let element = builder.makeAddress()
      let end = builder.makeAddress()
      builder.label(element)
      emit(component)
      builder.buildSave(end)
      builder.buildBranch(to: element)
      builder.label(end)

    // Zero or one: ?
    //     save end
    //     <code for component>
    //   end:
    case (.zeroOrOne, .greedy, let component):
      let end = builder.makeAddress()
      builder.buildSave(end)
      emit(component)
      builder.label(end)

    case (.exactly(_), _, _),
         (.nOrMore(_), _, _),
         (.upToN(_), _, _),
         (.range(_), _, _),
         (_, .possessive, _):
      fatalError("Not yet supported")
    }
  }
}

