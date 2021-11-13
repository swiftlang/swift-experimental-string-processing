/// A regex abstract syntax tree
public enum AST: ASTValue, ASTAction {
  public typealias Product = Self

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
// ASTStorage might end up becoming the ASTAction conformer
private struct ASTStorage {
  let ast: AST
  let sourceRange: SourceRange?
}
