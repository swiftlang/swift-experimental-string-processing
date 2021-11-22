
// TODO: struct? source ranges? ASTValue? etc?
public enum CustomCharacterClass: Hashable {
  // TODO: store the start too, relevant for e.g. inversion
  indirect case setOperation([Member], SetOp, [Member])
  indirect case set([Member])

  public enum Member: Hashable {
    case custom(CustomCharacterClass)
    case range(Atom, Atom)
    case atom(Atom)
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
