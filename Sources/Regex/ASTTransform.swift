extension AST {
  public func withMatchLevel(_ level: CharacterClass.MatchLevel) -> AST {
    func recurse(_ child: AST) -> AST {
      child.withMatchLevel(level)
    }
    switch self {
    case .alternation(let components):
      return .alternation(components.map(recurse))
    case .concatenation(let components):
      return .concatenation(components.map(recurse))
    case .group(let group, let component):
      return .group(group, recurse(component))
    case .groupTransform(let group, let component, let transform):
      return .groupTransform(group, recurse(component), transform: transform)
    case .quantification(let quantifier, let component):
      return .quantification(quantifier, recurse(component))
    case .atom(.char(let c)):
      return .atom(.char(c))
    case .atom(.scalar(let u)):
      return .atom(.scalar(u))
    case .characterClass(var cc):
      cc.matchLevel = level
      return .characterClass(cc)

    case .any, .trivia, .quote: return self

    // FIXME: Do we need to do anything here? Match level is
    // fundamental to the interpretation of atoms, but not
    // their representation.
    case .atom: return self

    case .customCharacterClass:
      fatalError("TODO")
    }
  }
}

