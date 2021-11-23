
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

public protocol _ASTPrintableNested: _ASTPrintable {
  func _printNested(_ child: String) -> String
  func _dumpNested(_ child: String) -> String
}
extension _ASTPrintableNested {
  public func _print() -> String { _printNested("") }
  public func _dump() -> String { _dumpNested("") }
}

// MARK: - AST's conformance

extension AST {
  public func _print() -> String {
    // TODO: printable version?
    _dump()
  }

  public func _dump() -> String {
    switch self {
    case let .alternation(rest): return ".alt(\(rest))"
    case let .concatenation(rest): return ".concat(\(rest))"
    case let .group(g, rest):
      return g._dumpNested(rest._dump())
    case let .groupTransform(g, rest, transform):
      return g._dumpNested("""
        \(rest._dump()), transform: \(
          String(describing: transform)))
        """)
    case let .quantification(q, rest):
      return q._dumpNested(rest._dump())

    case .atom(.char(let c)):    return c.halfWidthCornerQuoted
    case .atom(.scalar(let u)):  return u.halfWidthCornerQuoted
    case .characterClass(let cc): return ".characterClass(\(cc))"
    case .any: return ".any"
//    case .empty: return "".halfWidthCornerQuoted
    case .quote(let s): return s.halfWidthCornerQuoted

    case .atom(let a): return a._dump()

    case .trivia, .empty: return ""
    case .customCharacterClass: fatalError("FIXME")
    }
  }
}
