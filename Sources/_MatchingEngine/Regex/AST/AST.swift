/// A regex abstract syntax tree
public enum AST: ASTValue/*, ASTAction*/ {
  public typealias Product = Self

  /// ... | ... | ...
  indirect case alternation([AST])

  /// ... ...
  indirect case concatenation([AST])

  /// (...)
  indirect case group(Group, AST)

  indirect case quantification(Quantifier, AST)

  case quote(String)

  case trivia // TODO: track comments

  case atom(Atom)

  case customCharacterClass(CustomCharacterClass)

  case empty


  // FIXME: Move off the regex literal AST
  indirect case groupTransform(
    Group, AST, transform: CaptureTransform)
}

extension AST {
  public static var any: AST {
    .atom(.any)
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
    func filt(_ cc: CustomCharacterClass) -> CustomCharacterClass {
      CustomCharacterClass(cc.start, filt(cc.members))
    }
    typealias CCCMember = CustomCharacterClass.Member
    func filt(_ children: [CCCMember]) -> [CCCMember] {
      children.compactMap {
        switch $0 {
        case let .custom(cc):
          return .custom(filt(cc))
        case .range(let lhs, let rhs):
          guard let filtLHS = f(.atom(lhs)) ? lhs : nil else { return nil }
          guard let filtRHS = f(.atom(rhs)) ? rhs : nil else { return nil }
          return .range(filtLHS, filtRHS)
        case let .atom(atom):
          return f(.atom(atom)) ? .atom(atom) : nil
        case let .setOperation(lhsMembers, op, rhsMembers):
          return .setOperation(filt(lhsMembers), op, filt(rhsMembers))
        }
      }
    }
    switch self {
    case let .alternation(children):
      return .alternation(filt(children))

    case let .concatenation(children):
      return .concatenation(filt(children))

    case let .customCharacterClass(cc):
      return .customCharacterClass(filt(cc))

    case let .group(g, child):
      guard let c = child.filter(f) else { return nil }
      return .group(g, c)

    case let .groupTransform(g, child, transform):
      guard let c = child.filter(f) else { return nil }
      return .groupTransform(g, c, transform: transform)

    case let .quantification(q, child):
      guard let c = child.filter(f) else { return nil }
      return .quantification(q, c)

    case .any, .trivia, .quote, .atom, .empty:
      return f(self) ? self : nil
    }
  }

  public var strippingTrivia: AST? {
    filter(\.isSemantic)
  }
}

// FIXME: Probably remove this from the AST

public struct CaptureTransform: Equatable, Hashable, CustomStringConvertible {
  public let closure: (Substring) -> Any

  public init(_ closure: @escaping (Substring) -> Any) {
    self.closure = closure
  }

  public func callAsFunction(_ input: Substring) -> Any {
    closure(input)
  }

  public static func == (lhs: CaptureTransform, rhs: CaptureTransform) -> Bool {
    unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
      unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  public func hash(into hasher: inout Hasher) {
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  public var description: String {
    "<transform>"
  }
}

