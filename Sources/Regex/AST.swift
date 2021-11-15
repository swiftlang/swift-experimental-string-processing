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

  case quote(String)
  case character(Character)
  case unicodeScalar(UnicodeScalar)
  case characterClass(CharacterClass)
  case any
  case empty

  case trivia
}

// Note that we're not yet an ASTEntity, would need to be a struct.
// We might end up with ASTStorage which projects the nice AST type.
// Values and projected entities can still refer to positions.
// ASTStorage might end up becoming the ASTAction conformer
private struct ASTStorage {
  let ast: AST
  let sourceRange: SourceRange?
}

extension AST {
  public var isSemantic: Bool {
    switch self {
    case .trivia: return false
    default: return true
    }
  }

  func filter(_ f: (AST) -> Bool) -> AST? {
    func filt(_ children: [AST]) -> [AST] {
      children.compactMap {
        guard f($0) else { return nil }
        return $0.filter(f)
      }
    }
    switch self {
    case let .alternation(children):
      return .alternation(filt(children))

    case let .concatenation(children):
      return .concatenation(filt(children))

    case let .group(g, child):
      guard let c = child.filter(f) else { return nil }
      return .group(g, c)

    case let .groupTransform(g, child, transform):
      guard let c = child.filter(f) else { return nil }
      return .groupTransform(g, c, transform: transform)

    case let .quantification(q, child):
      guard let c = child.filter(f) else { return nil }
      return .quantification(q, c)

    case .character, .unicodeScalar, .characterClass,
        .any, .empty, .trivia, .quote:
      return f(self) ? self : nil
    }
  }

  public var strippingTrivia: AST? {
    filter(\.isSemantic)
  }
}
