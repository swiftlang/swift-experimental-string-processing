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

// MARK: - Convenience constructors
extension AST {
  public static func zeroOrMore(
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
