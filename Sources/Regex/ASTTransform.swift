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
    case .character(let c):
      return .character(c)
    case .unicodeScalar(let u):
      return .unicodeScalar(u)
    case .characterClass(var cc):
      cc.matchLevel = level
      return .characterClass(cc)
    case .any:
      return .any
    case .empty:
      return .empty
    case .trivia:
      return .trivia
    }
  }
}

