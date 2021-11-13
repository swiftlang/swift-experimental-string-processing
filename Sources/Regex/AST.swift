/// A regex abstract syntax tree
public enum AST: ASTValue {

  /// ... | ... | ...
  indirect case alternation([AST])

  /// ... ...
  indirect case concatenation([AST])

  /// (...)
  indirect case group(Group, AST)

  /// Group with a registered transform
  indirect case groupTransform(
    Group, AST, transform: CaptureTransform)

  indirect case quantification(Quantifier, AST)

  case character(Character)
  case unicodeScalar(UnicodeScalar)
  case characterClass(CharacterClass)
  case any
  case empty
}

// Note that we're not yet an ASTEntity, would need to be a struct.
// We might end up with ASTStorage which projects the nice AST type.
// Values and projected entities can still refer to positions.

// TODO: plumb source ranges through everything

// MARK: - Convenience constructors
extension AST {
  public static func zeroOrMore(
    _ kind: Quantifier.Kind, _ a: AST
  ) -> AST {
    .quantification(.zeroOrMore(kind), a)
  }
  public static func oneOrMore(
    _ kind: Quantifier.Kind, _ a: AST
  ) -> AST {
    .quantification(.oneOrMore(kind), a)
  }
  public static func zeroOrOne(
    _ kind: Quantifier.Kind, _ a: AST
  ) -> AST {
    .quantification(.zeroOrOne(kind), a)
  }
}
