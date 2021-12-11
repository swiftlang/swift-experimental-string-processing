
extension AST {
  public struct CustomCharacterClass: Hashable {
    public var start: Loc<Start>
    public var members: [Member]

    public let sourceRange: SourceRange

    public init(
      _ start: Loc<Start>,
      _ members: [Member],
      _ sr: SourceRange
    ) {
      self.start = start
      self.members = members
      self.sourceRange = sr
    }

    // FIXME: track source ranges
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
}

/// `AST.CustomCharacterClass.Start` is a mouthful
internal typealias CustomCC = AST.CustomCharacterClass

extension CustomCC {
  public var isInverted: Bool { start.value == .inverted }
}

extension CustomCC: _ASTNode {
  public var _dumpBase: String {
    // FIXME: print out members...
    "customCharacterClass"
  }
}

