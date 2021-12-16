
extension AST {
  public struct CustomCharacterClass: Hashable {
    public var start: Located<Start>
    public var members: [Member]

    public let location: SourceLocation

    public init(
      _ start: Located<Start>,
      _ members: [Member],
      _ sr: SourceLocation
    ) {
      self.start = start
      self.members = members
      self.location = sr
    }

    public enum Member: Hashable {
      /// A nested custom character class `[[ab][cd]]`
      case custom(CustomCharacterClass)

      /// A character range `a-z`
      case range(Atom, Atom)

      /// A single character or escape
      case atom(Atom)

      /// A binary operator applied to sets of members `abc&&def`
      case setOperation([Member], Located<SetOp>, [Member])
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
}

/// `AST.CustomCharacterClass.Start` is a mouthful
internal typealias CustomCC = AST.CustomCharacterClass

extension CustomCC {
  public var isInverted: Bool { start.value == .inverted }
}

extension CustomCC: _ASTNode {
  public var _dumpBase: String {
    "customCharacterClass(\(members))"
  }
}

extension CustomCC.Member: _ASTPrintable {
  public var _dumpBase: String {
    switch self {
    case .custom(let cc): return "\(cc)"
    case .atom(let a): return "\(a)"
    case .range(let lhs, let rhs):
      return "range \(lhs) to \(rhs)"
    case .setOperation(let lhs, let op, let rhs):
      return "op \(lhs) \(op.value) \(rhs)"
    }
  }
}
