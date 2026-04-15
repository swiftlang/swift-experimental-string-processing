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

extension ArraySlice<DSLTree.Node> {
  internal func skipNode(_ position: inout Int) {
    guard position < endIndex else {
      return
    }
    switch self[position] {
    case let .orderedChoice(n):
      for _ in 0..<n {
        position += 1
        skipNode(&position)
      }
      
    case let .concatenation(n):
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

extension DSLList {
  internal func skipNode(_ position: inout Int) {
    nodes[...].skipNode(&position)
  }
  
  func indexOfCoalescableAtom(startingAt position: Int, findLast: Bool = false) -> Int? {
    switch nodes[position] {
    case .concatenation(let count):
      var position = position + 1
      if findLast {
        for _ in 0..<(count - 1) {
          skipNode(&position)
          position += 1
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
  Loop:
    while i >= 0 {
      switch other.nodes[i] {
      case .concatenation(let count):
        other.nodes[i] = .concatenation(count - 1)
        break Loop
      case .limitCaptureNesting, .ignoreCapturesInTypedOutput:
        other.nodes.remove(at: i)
        i -= 1
      default:
        break Loop
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
