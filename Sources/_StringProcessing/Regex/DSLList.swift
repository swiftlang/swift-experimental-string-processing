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
  private func skipNode(_ position: inout Int) {
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

  private func _requiredAtomImpl(_ position: inout Int) -> DSLTree.Atom?? {
    guard position < nodes.count else {
      return nil
    }
    
    switch nodes[position] {
    case .atom(let atom):
      return switch atom {
      case .changeMatchingOptions:
        nil
      default:
        atom
      }

    // In a concatenation, the first definitive child provides the answer,
    // and then we need to skip past (in some cases at least) the remaining
    // concatenation elements.
    case .concatenation(let children):
      var result: DSLTree.Atom?? = nil
      var i = 0
      while i < children.count {
        i += 1
        position += 1
        if let r = _requiredAtomImpl(&position) {
          result = r
          break
        }
      }
      
      for _ in i..<children.count {
        position += 1
        skipNode(&position)
      }
      return result

    // For a quoted literal, we can look at the first char
    // TODO: matching semantics???
    case .quotedLiteral(let str):
      return str.first.map(DSLTree.Atom.char)
    
    // TODO: custom character classes could/should participate here somehow
    case .customCharacterClass:
      return .some(nil)
      
    // Trivia/empty have no effect.
    case .trivia, .empty:
      return nil
      
    // For alternation and conditional, no required first (this could change
    // if we identify the _same_ required first atom across all possibilities).
    case .orderedChoice, .conditional:
      return .some(nil)

    // A negative lookahead rules out the existence of a safe required
    // character.
    case .nonCapturingGroup(let kind, _) where kind.isNegativeLookahead:
      return .some(nil)
      
    // Other groups (and other parent nodes) defer to the child.
    case .nonCapturingGroup, .capture,
        .ignoreCapturesInTypedOutput,
        .limitCaptureNesting:
      position += 1
      return _requiredAtomImpl(&position)

    // A quantification that doesn't require its child to exist can still
    // allow a start-only match. (e.g. `/(foo)?^bar/`)
    case .quantification(let amount, _, _):
      if amount.requiresAtLeastOne {
        position += 1
        return _requiredAtomImpl(&position)
      } else {
        return .some(nil)
      }

    // Extended behavior isn't known, so we return `false` for safety.
    case .consumer, .matcher, .characterPredicate, .absentFunction:
      return .some(nil)
    }
  }

  internal func requiredFirstAtom() -> DSLTree.Atom? {
    var position = 0
    return _requiredAtomImpl(&position) ?? nil
  }

  internal mutating func autoPossessifyNextQuantification(_ position: inout Int) -> (Int, DSLTree.Atom)? {
    guard position < nodes.count else {
      return nil
    }
    
    switch nodes[position] {
    case .quantification(let amount, _, _):
      let quantPosition = position
      position += 1
      
      // Do a search within this quantification's contents
      // FIXME: How to handle an inner quantification surfacing here?
      var innerPosition = position
      _ = autoPossessifyNextQuantification(&innerPosition)
      
      switch _requiredAtomImpl(&position) {
      case .some(let atom?):
        return (quantPosition, atom)
      case .none, .some(.none):
        return nil
      }
      
    case .concatenation(let children):
      // If we find a valid quantification among this concatenation's components,
      // we must look for a required atom in the sibling. If a definitive result
      // is not found, pop up the recursion stack to find a sibling at a higher
      // level.
      var foundQuantification: (Int, DSLTree.Atom)? = nil
      var foundNextAtom: DSLTree.Atom? = nil
      var i = 0
      position += 1
      while i < children.count {
        i += 1
        if let result = autoPossessifyNextQuantification(&position) {
          foundQuantification = result
          break
        }
      }
      
      while i < children.count {
        i += 1
        position += 1
        if let result = _requiredAtomImpl(&position) {
          foundNextAtom = result
          break
        }
      }

      for _ in i..<children.count {
        position += 1
        skipNode(&position)
      }
      
      guard let (quantIndex, firstAtom) = foundQuantification,
            let nextAtom = foundNextAtom
      else { return foundQuantification }
      
      // We found a quantifier with a required first atom and a required
      // following atom. If the second is excluded by the first, we can
      // safely convert the quantifier to possessive.
      
      if firstAtom.excludes(nextAtom),
          case .quantification(let amount, _, let node) = nodes[quantIndex]
      {
        nodes[quantIndex] = .quantification(amount, .explicit(.possessive), node)
      }
      
      return nil
      
    // For alternations, we need to explore / auto-possessify in the different
    // branches, but quantifications inside an alternation don't
    // auto-possessify with following matching elements outside of the
    // alternation (for now, at least).
    case .orderedChoice(let children):
      position += 1
      for _ in 0..<children.count {
        _ = autoPossessifyNextQuantification(&position)
      }
    
    // Same as alternations, just with n = 2
    case .conditional:
      position += 1
      for _ in 0..<2 {
        _ = autoPossessifyNextQuantification(&position)
      }

    // Groups (and other parent nodes) defer to the child.
    default:
      // All multi-child nodes are handled above, just handle 0 and 1 here.
      let childCount = nodes[position].directChildren
      position += 1

      assert(childCount <= 1)
      if childCount == 1 {
        return autoPossessifyNextQuantification(&position)
      }
    }
    return nil
  }
  
  internal mutating func autoPossessify() {
    var index = 0
    while index < self.nodes.count {
      _ = autoPossessifyNextQuantification(&index)
    }
  }
}

extension DSLTree.Atom {
  func excludes(_ other: Self) -> Bool {
    switch (self, other) {
    case (.char(let a), .char(let b)):
      return a != b
    case (.scalar(let a), .scalar(let b)):
      return a != b
    case (.characterClass(let a), .characterClass(let b)):
      return a.excludes(b)
    // FIXME: Need to track matching options so we can know if this actually matches
    case (.characterClass(let a), .char(let b)), (.char(let b), .characterClass(let a)):
      let s = "\(b)"
      return a.asRuntimeModel(MatchingOptions()).matches(in: s, at: s.startIndex, limitedBy: s.endIndex) == nil
    case (.characterClass(let a), .scalar(let b)), (.scalar(let b), .characterClass(let a)):
      let s = "\(b)"
      return a.asRuntimeModel(MatchingOptions()).matches(in: s, at: s.startIndex, limitedBy: s.endIndex) == nil

    default:
      return false
    }
  }
}

extension DSLTree.Atom.CharacterClass {
  func excludes(_ other: Self) -> Bool {
    if other == .anyGrapheme || other == .anyUnicodeScalar {
      return false
    }
    
    return switch self {
    case .anyGrapheme, .anyUnicodeScalar:
      false
      
    case .digit:
      switch other {
      case .whitespace, .horizontalWhitespace, .verticalWhitespace, .newlineSequence,
          .notWord, .notDigit: true
      default: false
      }
    case .notDigit:
      other == .digit
      
    case .horizontalWhitespace:
      switch other {
      case .word, .digit, .verticalWhitespace, .newlineSequence,
          .notWhitespace, .notHorizontalWhitespace: true
      default: false
      }
    case .notHorizontalWhitespace:
      other == .horizontalWhitespace
      
    case .newlineSequence:
      switch other {
      case .word, .digit, .horizontalWhitespace, .notNewline: true
      default: false
      }
    case .notNewline:
      other == .newlineSequence
      
    case .whitespace:
      switch other {
      case .word, .digit, .notWhitespace: true
      default: false
      }
    case .notWhitespace:
      other == .whitespace
      
    case .verticalWhitespace:
      switch other {
      case .word, .digit, .notWhitespace, .notVerticalWhitespace: true
      default: false
      }
    case .notVerticalWhitespace:
      other == .verticalWhitespace
      
    case .word:
      switch other {
      case .whitespace, .horizontalWhitespace, .verticalWhitespace, .newlineSequence,
          .notWord: true
      default: false
      }
    case .notWord:
      other == .word
    }
  }
}
