public struct Quantifier: ASTParentEntity {
  public let amount: Amount
  public let kind: Kind

  public let sourceRange: SourceRange

  init(_ a: Amount, _ k: Kind, _ r: SourceRange) {
    self.amount = a
    self.kind = k
    self.sourceRange = r
  }
}

// TODO: sourceRange doesn't participate in equality...

extension Quantifier {
  public enum Amount: ASTValue {
    case zeroOrMore              // *
    case oneOrMore               // +
    case zeroOrOne               // ?
    case exactly(Int)            // {n}
    case nOrMore(Int)            // {n,}
    case upToN(Int)              // {,n}
    case range(ClosedRange<Int>) // {n,m}
  }

  public enum Kind: String, ASTValue {
    case greedy     = ""
    case reluctant  = "?"
    case possessive = "+"
  }
}
 
// MARK: - Convenience constructors

// TODO: This should get dropped with AST overhaul
extension Quantifier {
  public static func zeroOrMore(
    _ k: Kind
  ) -> Self {
    Self(.zeroOrMore, k, _fakeRange)
  }
  public static func oneOrMore(
    _ k: Kind
  ) -> Self {
    Self(.oneOrMore, k, _fakeRange)
  }
  public static func zeroOrOne(
    _ k: Kind
  ) -> Self {
    Self(.zeroOrOne, k, _fakeRange)
  }
  public static func exactly(
    _ k: Kind, _ i: Int
  ) -> Self {
    Self(.exactly(i), k, _fakeRange)
  }
  public static func nOrMore(
    _ k: Kind, _ i: Int
  ) -> Self {
    Self(.nOrMore(i), k, _fakeRange)
  }
  public static func upToN(
    _ k: Kind, _ i: Int
  ) -> Self {
    Self(.upToN(i), k, _fakeRange)
  }
  public static func range(
    _ k: Kind, _ r: ClosedRange<Int>
  ) -> Self {
    Self(.range(r), k, _fakeRange)
  }
}

// MARK: - Printing

extension Quantifier.Amount: _ASTPrintable {
  public func _print() -> String {
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
  public func _dump() -> String {
    switch self {
    case .zeroOrMore:      return ".zeroOrMore"
    case .oneOrMore:       return ".oneOrMore"
    case .zeroOrOne:       return ".zeroOrOne"
    case let .exactly(n):  return ".exactly(\(n))"
    case let .nOrMore(n):  return ".nOrMore(\(n))"
    case let .upToN(n):    return ".uptoN(\(n))"
    case let .range(r):
      return ".range(\(r.lowerBound),\(r.upperBound))"
    }
  }
}
extension Quantifier.Kind: _ASTPrintable {
  public func _print() -> String { rawValue }
  public func _dump() -> String {
    switch self {
    case .greedy:     return ".greedy"
    case .reluctant:  return ".reluctant"
    case .possessive: return ".possessive"
    }
  }
}

extension Quantifier: _ASTPrintable {
  public func _printNested(_ child: String) -> String {
    "<?:\(child)>\(amount._print())\(kind._print())"
  }

  public func _dumpNested(_ child: String) -> String {
    "\(amount._dump())_\(kind._dump())(\(child)"
  }
}
