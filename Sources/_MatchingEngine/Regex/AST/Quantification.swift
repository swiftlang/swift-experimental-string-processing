extension AST {
  public struct Quantification: Hashable {
    public let amount: Loc<Amount>
    public let kind: Loc<Kind>

    public let child: AST
    public let sourceRange: SourceRange

    public init(
      _ amount: Loc<Amount>,
      _ kind: Source.Value<Kind>,
      _ child: AST,
      _ r: SourceRange
    ) {
      self.amount = amount
      self.kind = kind
      self.child = child
      self.sourceRange = r
    }

    public enum Amount: Hashable {
      case zeroOrMore              // *
      case oneOrMore               // +
      case zeroOrOne               // ?
      case exactly(Loc<Int>)            // {n}
      case nOrMore(Loc<Int>)            // {n,}
      case upToN(Loc<Int>)              // {,n}
      case range(ClosedRange<Loc<Int>>) // {n,m}
    }

    public enum Kind: String, Hashable {
      case greedy     = ""
      case reluctant  = "?"
      case possessive = "+"
    }
  }
}


// MARK: - Printing

extension AST.Quantification.Amount: _ASTPrintable {
  public var _printBase: String {
    switch self {
    case .zeroOrMore:      return "*"
    case .oneOrMore:       return "+"
    case .zeroOrOne:       return "?"
    case let .exactly(n):  return "{\(n)}"
    case let .nOrMore(n):  return "{\(n),}"
    case let .upToN(n):    return "{,\(n)}"
    case let .range(r):
      return "{\(r.lowerBound),\(r.upperBound)}"
    }
  }
  public var _dumpBase: String {
    switch self {
    case .zeroOrMore:      return "zeroOrMore"
    case .oneOrMore:       return "oneOrMore"
    case .zeroOrOne:       return "zeroOrOne"
    case let .exactly(n):  return "exactly<\(n)>"
    case let .nOrMore(n):  return "nOrMore<\(n)>"
    case let .upToN(n):    return "uptoN<\(n)>"
    case let .range(r):
      return ".range<\(r.lowerBound)...\(r.upperBound)>"
    }
  }
}
extension AST.Quantification.Kind: _ASTPrintable {
  public var _printBase: String { rawValue }
  public var _dumpBase: String {
    switch self {
    case .greedy:     return "greedy"
    case .reluctant:  return "reluctant"
    case .possessive: return "possessive"
    }
  }
}

extension AST.Quantification: _ASTPrintable {
  public var _printBase: String {
    """
    quant_\(amount.value._printBase)\(kind.value._printBase)
    """
  }

  public var _dumpBase: String {
    """
    quant_\(amount.value._dumpBase)_\(kind.value._dumpBase)
    """
  }
}
