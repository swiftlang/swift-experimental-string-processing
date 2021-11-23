
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
