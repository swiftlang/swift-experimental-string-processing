/// A regex abstract syntax tree
public enum AST: Hashable {

  /// ... | ... | ...
  indirect case alternation([AST])

  /// ... ...
  indirect case concatenation([AST])

  /// (?:...)
  indirect case group(AST)

  /// (...)
  indirect case capturingGroup(
    AST, transform: CaptureTransform? = nil)

  indirect case quantification(Quantifier, AST)

  case character(Character)
  case unicodeScalar(UnicodeScalar)
  case characterClass(CharacterClass)
  case any
  case empty
}

extension AST: CustomStringConvertible {
  public var description: String {
    switch self {
    case .alternation(let rest): return ".alt(\(rest))"
    case .concatenation(let rest): return ".concat(\(rest))"
    case .group(let rest): return ".group(\(rest))"
    case .capturingGroup(let rest, let transform):
      return """
          .capturingGroup(\(rest), transform: \(transform.map(String.init(describing:)) ?? "nil")
          """
    case .quantification(let q, let rest):
      return "\(q._dump())(\(rest))"

    case .character(let c): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return u.halfWidthCornerQuoted
    case .characterClass(let cc): return ".characterClass(\(cc))"
    case .any: return ".any"
    case .empty: return "".halfWidthCornerQuoted
    }
  }
}

// MARK: - Printing

/// AST entities can be pretty-printed or dumped
///
/// Alternative: just use `description` for pretty-print
/// and `debugDescription` for dump
public protocol _ASTPrintable:
  CustomStringConvertible,
  CustomDebugStringConvertible
{
  func _print() -> String
  func _dump() -> String
}
extension _ASTPrintable {
  public var description: String { _print() }
  public var debugDescription: String { _dump() }
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

// TODO: Do we want an AST builder or something? Is this distinct
// from an AST builder?
//
// Or, should these be top-level cases?
extension AST {
  public static func many(
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
