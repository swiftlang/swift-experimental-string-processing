public struct Quantifier: Hashable {
  public var amount: Amount
  public var kind: Kind

  public init(_ a: Amount, _ k: Kind) {
    self.amount = a
    self.kind = k
  }
}

extension Quantifier {
  public enum Amount: Hashable {
    case zeroOrMore   // *
    case oneOrMore    // +
    case zeroOrOne    // ?
    case exactly(Int) // {n}
    case nOrMore(Int) // {n,}
    case upToN(Int)   // {,n}
    case range(       // {n,m}
      atLeast: Int, atMost: Int)
  }

  public enum Kind: Hashable {
    case greedy     //
    case reluctant  // ?
    case possessive // +
  }
}

// MARK: - Convenience constructors
extension Quantifier {
  public static func zeroOrMore(_ k: Kind) -> Self {
    Self(.zeroOrMore, k)
  }
  public static func oneOrMore(_ k: Kind) -> Self {
    Self(.oneOrMore, k)
  }
  public static func zeroOrOne(_ k: Kind) -> Self {
    Self(.zeroOrOne, k)
  }
  public static func exactly(_ k: Kind, _ i: Int) -> Self {
    Self(.exactly(i), k)
  }
  public static func nOrMore(_ k: Kind, _ i: Int) -> Self {
    Self(.nOrMore(i), k)
  }
  public static func upToN(_ k: Kind, _ i: Int) -> Self {
    Self(.upToN(i), k)
  }
  public static func range(
    _ k: Kind, atLeast: Int, atMost: Int
  ) -> Self {
    Self(.range(atLeast: atLeast, atMost: atMost), k)
  }
}

extension Quantifier.Amount: _ASTPrintable {
  public func _print() -> String {
    switch self {
    case .zeroOrMore: return "*"
    case .oneOrMore:  return "+"
    case .zeroOrOne:  return "?"
    case let .exactly(n):  return "{\(n)}"
    case let .nOrMore(n):  return "{\(n),}"
    case let .upToN(n):    return "{,\(n)}"
    case let .range(n, m): return "{\(n),\(m)}"
    }
  }
  public func _dump() -> String {
    switch self {
    case .zeroOrMore: return ".zeroOrMore"
    case .oneOrMore:  return ".oneOrMore"
    case .zeroOrOne:  return ".zeroOrOne"
    case let .exactly(n):  return ".exactly(\(n))"
    case let .nOrMore(n):  return ".nOrMore(\(n))"
    case let .upToN(n):    return ".uptoN(\(n))"
    case let .range(n, m): return ".range(\(n),\(m))"
    }

  }
}
extension Quantifier.Kind: _ASTPrintable {
  public func _print() -> String {
    switch self {
    case .greedy: return ""
    case .reluctant:  return "?"
    case .possessive:  return "+"
    }
  }
  public func _dump() -> String {
    switch self {
    case .greedy: return ".greedy"
    case .reluctant:  return ".reluctant"
    case .possessive:  return ".possessive"
    }
  }
}

extension Quantifier: _ASTPrintable {
  public func _print() -> String {
    "\(amount._print())\(kind._print())"
  }

  public func _dump() -> String {
    "\(amount._dump())\(kind._dump())"
  }
}
