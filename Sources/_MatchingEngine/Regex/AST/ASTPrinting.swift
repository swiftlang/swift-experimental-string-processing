
// MARK: - Printing

/// AST entities can be pretty-printed or dumped
///
/// Alternative: just use `description` for pretty-print
/// and `debugDescription` for dump
public protocol _ASTPrintable:
  CustomStringConvertible,
  CustomDebugStringConvertible
{
  // The "base" dump out for AST nodes, like `alternation`.
  // Children printing, parens, etc., handled automatically
  var _dumpBase: String { get }

}
extension _ASTPrintable {
  public var description: String { _print() }
  public var debugDescription: String { _dump() }

  var _children: [AST]? {
    (self as? _ASTParent)?.children
  }

  // TODO: Semi-pretty printing
  var _printBase: String { _dumpBase }

  func _print() -> String {
    guard let children = _children else {
      return _printBase
    }
    let sub = children.lazy.map {
      $0._print()
    }.joined(separator: ",")
    return "\(_printBase)(\(sub))"
  }
  func _dump() -> String {
    guard let children = _children else {
      return _dumpBase
    }
    let sub = children.lazy.map {
      $0._dump()
    }.joined(separator: ",")
    return "\(_dumpBase)(\(sub))"
  }
}

extension AST: _ASTPrintable {
  public var _printBase: String {
    _associatedValue?._printBase ?? ""
  }
  public var _dumpBase: String {
    _associatedValue?._dumpBase ?? ""
  }
}


