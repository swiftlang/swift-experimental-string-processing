extension AST {
  public struct Quantification: Hashable {
    public let amount: Located<Amount>
    public let kind: Located<Kind>

    public let child: AST
    public let location: SourceLocation

    public init(
      _ amount: Located<Amount>,
      _ kind: Located<Kind>,
      _ child: AST,
      _ r: SourceLocation
    ) {
      self.amount = amount
      self.kind = kind
      self.child = child
      self.location = r
    }

    public enum Amount: Hashable {
      case zeroOrMore              // *
      case oneOrMore               // +
      case zeroOrOne               // ?
      case exactly(Located<Int>)         // {n}
      case nOrMore(Located<Int>)         // {n,}
      case upToN(Located<Int>)           // {,n}
      case range(Located<Int>, Located<Int>) // {n,m}
    }

    public enum Kind: String, Hashable {
      case eager      = ""
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
    case let .exactly(n):  return "{\(n.value)}"
    case let .nOrMore(n):  return "{\(n.value),}"
    case let .upToN(n):    return "{,\(n.value)}"
    case let .range(lower, upper):
      return "{\(lower),\(upper)}"
    }
  }
  public var _dumpBase: String {
    switch self {
    case .zeroOrMore:      return "zeroOrMore"
    case .oneOrMore:       return "oneOrMore"
    case .zeroOrOne:       return "zeroOrOne"
    case let .exactly(n):  return "exactly<\(n.value)>"
    case let .nOrMore(n):  return "nOrMore<\(n.value)>"
    case let .upToN(n):    return "uptoN<\(n.value)>"
    case let .range(lower, upper):
      return ".range<\(lower.value)...\(upper.value)>"
    }
  }
}
extension AST.Quantification.Kind: _ASTPrintable {
  public var _printBase: String { rawValue }
  public var _dumpBase: String {
    switch self {
    case .eager:      return "eager"
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

/// MARK: - Semantic API

extension AST.Quantification.Amount {
  /// Get the bounds
  public var bounds: (atLeast: Int, atMost: Int?) {
    switch self {
    case .zeroOrMore: return (0, nil)
    case .oneOrMore:  return (1, nil)
    case .zeroOrOne:  return (0, 1)

    case let .exactly(n):  return (n.value, n.value)
    case let .nOrMore(n):  return (n.value, nil)
    case let .upToN(n):    return (0, n.value)
    case let .range(n, m): return (n.value, m.value)
    }
  }
}
