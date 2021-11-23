
// TODO: source ranges? ASTValue? etc?
public struct CustomCharacterClass: Hashable {
  public var start: Start
  public var members: [Member]

  public enum Member: Hashable {
    /// A nested custom character class `[[ab][cd]]`
    case custom(CustomCharacterClass)
    /// A character range `a-z`
    case range(Atom, Atom)
    /// A single character or escape
    case atom(Atom)
    /// A binary operator applied to sets of members `abc&&def`
    case setOperation([Member], SetOp, [Member])
  }
  public enum SetOp: String, Hashable {
    case subtraction = "--"
    case intersection = "&&"
    case symmetricDifference = "~~"
  }
  public enum Start: Hashable {
    /// `[`
    case normal

    /// `[^`
    case inverted
  }
}

extension CustomCharacterClass {
  /// The model character class for this custom character class.
  var modelCharacterClass: CharacterClass {
    typealias Component = CharacterClass.CharacterSetComponent
    func getComponents(_ members: [Member]) -> [Component] {
      members.map { m in
        switch m {
        case .custom(let cc):
          return .characterClass(cc.modelCharacterClass)
        case .range(let lhs, let rhs):
          return .range(
            lhs.literalCharacterValue! ... rhs.literalCharacterValue!
          )
        case .atom(let a):
          return .characterClass(a.characterClass!)
        case .setOperation(let lhs, let op, let rhs):
          // FIXME: CharacterClass wasn't designed for set operations with
          // multiple components in each operand, we should fix that. For now,
          // just produce custom components.
          return .setOperation(
            .init(lhs: .characterClass(.custom(getComponents(lhs))), op: op,
                  rhs: .characterClass(.custom(getComponents(rhs))))
          )
        }
      }
    }
    return .custom(getComponents(members))
  }
}
