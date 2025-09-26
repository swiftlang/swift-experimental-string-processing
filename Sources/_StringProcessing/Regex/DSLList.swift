//
//  DSLList.swift
//  swift-experimental-string-processing
//
//  Created by Nate Cook on 9/25/25.
//

struct DSLList {
  var nodes: [DSLTree.Node]
  
  init(_ initial: DSLTree.Node) {
    self.nodes = [initial]
  }
  
  init(_ nodes: [DSLTree.Node]) {
    self.nodes = nodes
  }
  
  init(root: DSLTree.Node) {
    self.nodes = Array(root)
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

extension DSLTree.Node: Sequence {
  struct Iterator: Sequence, IteratorProtocol {
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
      return top.node
    }
  }
  
  func makeIterator() -> Iterator {
    Iterator(root: self, getChildren: { $0.children })
  }
}
