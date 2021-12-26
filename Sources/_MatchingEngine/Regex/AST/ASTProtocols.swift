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
