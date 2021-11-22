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

  case trivia // TODO: track comments

  case atom(Atom)

  // FIXME: This doesn't belong in the AST. It could be a model
  // type produced from an AST node.
  case characterClass(CharacterClass)

  case customCharacterClass(
    CustomCharacterClass.Start, CustomCharacterClass)
}

extension AST {
  static var any: AST {
    .atom(.any)
  }
}

extension AST {
  /// If this has a character class representation, whether built-in or custom, return it.
  ///
  /// TODO: Not sure if this the right model type, but I suspect we'll want to produce
  /// something like this on demand
  var characterClass: CharacterClass? {
    switch self {
    case .customCharacterClass:
      fatalError("TODO")
    case let .atom(a): return a.characterClass

    // TODO: remove
    case let .characterClass(c): return c

    default: return nil
    }
  }
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

    case .customCharacterClass: fatalError("TODO")

    case let .group(g, child):
      guard let c = child.filter(f) else { return nil }
      return .group(g, c)

    case let .groupTransform(g, child, transform):
      guard let c = child.filter(f) else { return nil }
      return .groupTransform(g, c, transform: transform)

    case let .quantification(q, child):
      guard let c = child.filter(f) else { return nil }
      return .quantification(q, c)

    case .characterClass, .any, .trivia, .quote, .atom:
      return f(self) ? self : nil
    }
  }

  public var strippingTrivia: AST? {
    filter(\.isSemantic)
  }
}
