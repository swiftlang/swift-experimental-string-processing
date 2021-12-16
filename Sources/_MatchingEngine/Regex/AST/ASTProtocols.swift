/*

 Common protocols for AST nodes and values. These allow us
 to do more capabilities-based programming, currently
 implemented on top of existentials.

 */

// MARK: - AST parent/child

protocol _ASTNode: _ASTPrintable {
  var location: SourceLocation { get }
}
extension _ASTNode {
  var startPosition: Source.Position { location.start }
  var endPosition: Source.Position { location.end }
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
    if let children = (self as? _ASTParent)?.children {
      return children
    }
    if let children = (self as? AST)?.children {
      return children
    }
    return nil
  }

  func _print() -> String {
    // TODO: prettier printing
    _dump()
  }
  func _dump() -> String {
    guard let children = _children else {
      return _dumpBase
    }
    let sub = children.lazy.compactMap {
      // Exclude trivia for now, as we don't want it to appear when performing
      // comparisons of dumped output in tests.
      // TODO: We should eventually have some way of filtering out trivia for
      // tests, so that it can appear in regular dumps.
      if $0.isTrivia { return nil }
      return $0._dump()
    }.joined(separator: ",")
    return "\(_dumpBase)(\(sub))"
  }
}

extension AST: _ASTPrintable {
  public var _dumpBase: String {
    _associatedValue._dumpBase
  }
}

// MARK: - Rendering

// Useful for testing, debugging, etc.
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
    let base = String(repeating: " ", count: input.count)
    var lines = [base]

    // TODO: drop the filtering when fake-ness is taken out of
    // this module
    let nodes = _postOrder().filter(\.location.isReal)

    nodes.forEach { node in
      let loc = node.location
      let count = input[loc.range].count
      for idx in lines.indices {
        if lines[idx][loc.range].all(\.isWhitespace) {
          node._renderRange(count: count, into: &lines[idx])
          return
        }
      }
      var nextLine = base
      node._renderRange(count: count, into: &nextLine)
      lines.append(nextLine)
    }

    return lines.first!.all(\.isWhitespace) ? [] : lines
  }

  // Produce a textually "rendered" rane
  //
  // NOTE: `input` must be the string from which a
  // source range was derived.
  func _renderRange(
    count: Int, into output: inout String
  ) {
    guard count > 0 else { return }
    let repl = String(repeating: "-", count: count-1) + "^"
    output.replaceSubrange(location.range, with: repl)
  }
}
