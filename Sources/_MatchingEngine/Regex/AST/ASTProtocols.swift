//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

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
  var children: [AST.Node] { get }
}

extension AST.Concatenation: _ASTParent {}
extension AST.Alternation: _ASTParent {}

extension AST.Group: _ASTParent {
  var children: [AST.Node] { [child] }
}
extension AST.Quantification: _ASTParent {
  var children: [AST.Node] { [child] }
}
extension AST.AbsentFunction: _ASTParent {
  var children: [AST.Node] {
    switch kind {
    case .repeater(let a), .stopper(let a): return [a]
    case .expression(let a, _, let c):      return [a, c]
    case .clearer:                          return []
    }
  }
}
