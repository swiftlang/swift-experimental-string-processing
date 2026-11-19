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
  var hasChildren: Bool {
    (nodes.first?.directChildren ?? 0) > 0
  }
  
  var captureList: CaptureList {
    .Builder.build(self)
  }
  
  init(_ initial: DSLTree.Node) {
    self.nodes = [initial]
  }
  
  init(_ nodes: [DSLTree.Node]) {
    self.nodes = nodes
  }
  
  init(ast: AST) {
    self.nodes = [.limitCaptureNesting]
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
      return c
      
    case .capture, .nonCapturingGroup,
        .quantification, .ignoreCapturesInTypedOutput,
        .limitCaptureNesting:
      return 1
      
    case .conditional:
      return 2
      
    case .absentFunction:
      return 0
    }
  }
}

// MARK: Walking the flat node list
//
// A `DSLList` stores a tree in preorder: each node is followed by the subtrees
// of its children, with the number of children given by `directChildren`.
// Methods that walk the list with an `Int` cursor must all follow the same
// contract: on return, the cursor is just past the initial position's entire
// subtree, no matter what path the walk took. This way a caller can keep
// reading siblings without additional bookkeeping.

extension ArraySlice<DSLTree.Node> {
  /// Returns the index just past the subtree rooted at the node at `position`.
  internal func indexAfterNode(at position: Int) -> Int {
    precondition(
      UInt(truncatingIfNeeded: position) <= endIndex,
      "Can't find index after out-of-bounds node")
    var index = position
    // The number of subtrees still to be read, starting with the one rooted
    // at `position`. Each node replaces itself with its children.
    var pending = 1
    while pending > 0 && index < endIndex {
      pending += self[index].directChildren - 1
      index += 1
    }
    return index
  }

  /// Removes the first node and its entire subtree.
  ///
  /// This is the consuming counterpart of `indexAfterNode(at:)`, for walkers
  /// that read the list by dropping nodes from the front.
  internal mutating func dropFirstSubtree() {
    self = self[indexAfterNode(at: startIndex)...]
  }
}

extension DSLList {
  /// Returns the index just past the subtree rooted at the node at `position`.
  internal func indexAfterNode(at position: Int) -> Int {
    nodes[...].indexAfterNode(at: position)
  }

  func indexOfCoalescableAtom(startingAt position: Int, findLast: Bool = false) -> Int? {
    switch nodes[position] {
    case .concatenation(let count):
      var position = position + 1
      if findLast {
        for _ in (0..<count).dropLast() {
          position = indexAfterNode(at: position)
        }
      }
      return indexOfCoalescableAtom(startingAt: position, findLast: findLast)
    case .ignoreCapturesInTypedOutput, .limitCaptureNesting:
      return indexOfCoalescableAtom(startingAt: position + 1, findLast: findLast)
    case .atom(let atom):
      if atom.literalCharacterValue != nil {
        return position
      }
    case .quotedLiteral:
      return position
    default:
      break
    }
    return nil
  }
    
  mutating func coalesce(withFirstAtomIn other: inout DSLList) {
    // Find the last coalescable node in the LHS and the first in the RHS
    guard let prefixIndex = indexOfCoalescableAtom(startingAt: 0, findLast: true),
          let postfixIndex = other.indexOfCoalescableAtom(startingAt: 0),
          let prefixValue = nodes[prefixIndex].literalStringValue,
          let postfixValue = other.nodes[postfixIndex].literalStringValue
    else { return }

    // Merge display strings, falling back to the escaped value for either
    // side if its display is not available.
    let prefixDisplay = nodes[prefixIndex].literalDisplayValue ?? prefixValue._escaped
    let postfixDisplay = other.nodes[postfixIndex].literalDisplayValue ?? postfixValue._escaped
    let mergedDisplay = prefixDisplay + postfixDisplay

    // Replace the prefix node with a coalesced version of the two
    nodes[prefixIndex] = .quotedLiteral(prefixValue + postfixValue, display: mergedDisplay)
    
    // Remove the postfix node and fix up any parent concatenations
    other.nodes.remove(at: postfixIndex)
    var i = postfixIndex - 1

    while i >= 0 {
      switch other.nodes[i] {
      case .concatenation(let count):
        // Omit a concatenation entirely if it would have zero children.
        if count == 1 {
          other.nodes[i] = .empty
        } else {
          other.nodes[i] = .concatenation(count - 1)
        }
        // No more fixing up to do
        return
      case .limitCaptureNesting, .ignoreCapturesInTypedOutput:
        other.nodes.remove(at: i)
        i -= 1
      default:
        return
      }
    }
  }
}

extension DSLList {
  internal func getNamedCaptures() -> [String] {
    var result: [String] = []
    for node in nodes {
      if case .capture(let name?, _, _) = node, !result.contains(name) {
        result.append(name)
      }
    }
    return result
  }
}
