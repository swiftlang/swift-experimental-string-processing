/// A regex abstract syntax tree
public enum AST: Hashable {

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

