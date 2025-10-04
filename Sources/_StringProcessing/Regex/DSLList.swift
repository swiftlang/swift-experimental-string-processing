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

struct DSLList {
  var nodes: [DSLTree.Node]
  
  init(_ initial: DSLTree.Node) {
    self.nodes = [initial]
  }
  
  init(_ nodes: [DSLTree.Node]) {
    self.nodes = nodes
  }
  
  init(tree: DSLTree) {
    self.nodes = Array(tree.depthFirst)
  }
}

extension DSLList {
  struct Children: Sequence {
    var nodes: [DSLTree.Node]
    var firstChildIndex: Int
    
    struct Iterator: IteratorProtocol {
      var nodes: [DSLTree.Node]
      var currentIndex: Int
      var remainingCount: Int
      
      mutating func next() -> DSLTree.Node? {
        guard remainingCount > 0 else { return nil }
        guard currentIndex < nodes.count else {
          // FIXME: assert?
          print("ERROR: index out of bounds")
          return nil
        }
        remainingCount -= 1
        var nextIndex = currentIndex
        var inc = nodes[currentIndex].directChildren + 1
        while inc > 0 {
          nextIndex += 1
          inc += nodes[nextIndex].directChildren - 1
        }

        return nodes[currentIndex]
      }
    }
    
    func makeIterator() -> Iterator {
      Iterator(nodes: nodes, currentIndex: firstChildIndex, remainingCount: nodes[firstChildIndex].directChildren)
    }
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
