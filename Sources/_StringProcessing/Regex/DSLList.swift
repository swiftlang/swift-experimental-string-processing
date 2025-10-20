//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal import _RegexParser

struct DSLList {
  var nodes: [DSLTree.Node]
  
  // experimental
  var hasCapture: Bool = false
  var hasChildren: Bool = false
  var captureList: CaptureList {
    .Builder.build(self)
  }
  
  init(_ initial: DSLTree.Node) {
    self.nodes = [initial]
  }
  
  init(_ nodes: [DSLTree.Node]) {
    self.nodes = nodes
  }
  
  init(tree: DSLTree) {
    self.nodes = Array(tree.depthFirst)
  }
  
  init(ast: AST) {
    self.nodes = []
    try! ast.root.convert(into: &nodes)
  }
  
  var first: DSLTree.Node {
    nodes.first ?? .empty
  }
}

extension DSLList {
  mutating func append(_ node: DSLTree.Node) {
    nodes.append(node)
  }
  
  mutating func append(contentsOf other: some Sequence<DSLTree.Node>) {
    nodes.append(contentsOf: other)
  }
  
  mutating func prepend(_ node: DSLTree.Node) {
    nodes.insert(node, at: 0)
  }
  
  mutating func prepend(contentsOf other: some Collection<DSLTree.Node>) {
    nodes.insert(contentsOf: other, at: 0)
  }
}

extension DSLTree.Node {
  var directChildren: Int {
    switch self {
    case .trivia, .empty, .quotedLiteral,
        .consumer, .matcher, .characterPredicate,
        .customCharacterClass, .atom:
      return 0
      
    case .orderedChoice(let c), .concatenation(let c):
      return c.count
      
    case .capture, .nonCapturingGroup,
        .quantification, .ignoreCapturesInTypedOutput,
        .limitCaptureNesting, .conditional:
      return 1
      
    case .absentFunction:
      return 0
    }
  }
}

extension DSLTree {
  struct DepthFirst: Sequence, IteratorProtocol {
    typealias Element = DSLTree.Node
    private var stack: [Frame]
    private let getChildren: (Element) -> [Element]

    private struct Frame {
      let node: Element
      let children: [Element]
      var nextIndex: Int = 0
    }

    fileprivate init(
      root: Element,
      getChildren: @escaping (Element) -> [Element]
    ) {
      self.getChildren = getChildren
      self.stack = [Frame(node: root, children: getChildren(root))]
    }

    mutating func next() -> Element? {
      guard let top = stack.popLast() else { return nil }
      // Push children in reverse so leftmost comes out first.
      for child in top.children.reversed() {
        stack.append(Frame(node: child, children: getChildren(child)))
      }
      
      // Since we coalesce the children before adding them to the stack,
      // we need an exact matching number of children in the list's
      // concatenation node, so that it can provide the correct component
      // count. This will go away/change when .concatenation only stores
      // a count.
      return switch top.node {
      case .concatenation:
        .concatenation(top.node.coalescedChildren)
      default:
        top.node
      }
    }
  }
  
  var depthFirst: DepthFirst {
    DepthFirst(root: root, getChildren: {
      $0.coalescedChildren
    })
  }
}

extension DSLList {
  internal func skipNode(_ position: inout Int) {
    guard position < nodes.count else {
      return
    }
    switch nodes[position] {
    case let .orderedChoice(children):
      let n = children.count
      for _ in 0..<n {
        position += 1
        skipNode(&position)
      }
      
    case let .concatenation(children):
      let n = children.count
      for _ in 0..<n {
        position += 1
        skipNode(&position)
      }
      
    case .capture, .nonCapturingGroup, .ignoreCapturesInTypedOutput,
        .limitCaptureNesting, .quantification:
      position += 1
      skipNode(&position)
      
    case .customCharacterClass, .atom, .quotedLiteral, .matcher, .conditional,
        .absentFunction, .consumer, .characterPredicate, .trivia, .empty:
      break
    }
  }
}
