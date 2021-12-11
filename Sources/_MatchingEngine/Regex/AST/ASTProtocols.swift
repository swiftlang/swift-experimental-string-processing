/*

 Common protocols for AST nodes and values. These allow us
 to do more capabilities-based programming, currently
 implemented on top of existentials.

 */



// MARK: - AST parent/child

protocol _ASTNode: _ASTPrintable {
  var sourceRange: SourceRange { get }
}
extension _ASTNode {
  var startLoc: SourceLoc { sourceRange.lowerBound }
  var endLoc: SourceLoc { sourceRange.upperBound }
}

protocol _ASTParent: _ASTNode {
  var children: [AST] { get }
}

extension AST.Concatenation: _ASTParent {}
extension AST.Alternation: _ASTParent {}

extension AST.Group: _ASTParent {
  var children: [AST] { [child] }
}
extension AST.Quantification: _ASTParent {
  var children: [AST] { [child] }
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
    _associatedValue._printBase
  }
  public var _dumpBase: String {
    _associatedValue._dumpBase
  }
}

// Useful for testing, debugging, etc.
//
// TODO: Prettier rendering, probably inverted
extension AST {

  func _postOrder() -> Array<AST> {
    var nodes = Array<AST>()
    _postOrder(into: &nodes)
    return nodes
  }
  func _postOrder(into array: inout Array<AST>) {
    children?.forEach { $0._postOrder(into: &array) }
    array.append(self)
  }

  // We render from top-to-bottom, coalescing siblings
  public func _render(in input: String) -> [String] {
    var lines = Array<String>()
    let base = String(repeating: " ", count: input.count)

    let nodes = _postOrder().filter(\.sourceRange.isReal)
    let levels = nodes.chunked {
      $0.sourceRange.upperBound <= $1.sourceRange.lowerBound
    }

    for level in levels {
      // TODO: Actually, I want to render into the bottom-most
      // string that only has spaces over this range...

      var line = base
      for node in level {
        node._renderRange(in: input, into: &line)
      }
      lines.append(line)
    }

    return lines
  }

  // Produce a textually "rendered" rane
  //
  // NOTE: `input` must be the string from which a
  // source range was derived.
  func _renderRange(
    in input: String, into output: inout String
  ) {
    guard !sourceRange.isEmpty else { return }
    let sliceCount = input[sourceRange].count
    let repl = String(repeating: "-", count: sliceCount-1) + "^"
    output.replaceSubrange(sourceRange, with: repl)
  }
}
