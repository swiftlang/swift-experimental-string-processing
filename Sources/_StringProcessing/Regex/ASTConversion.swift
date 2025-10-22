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

internal import _RegexParser

extension AST {
  var dslTree: DSLTree {
    return DSLTree(.limitCaptureNesting(root.dslTreeNode))
  }
}

extension AST.Node {
  func convert(into list: inout [DSLTree.Node]) throws {
    switch self {
    case .alternation(let alternation):
      list.append(.orderedChoice(Array(repeating: TEMP_FAKE_NODE, count: alternation.children.count)))
      for child in alternation.children {
        try child.convert(into: &list)
      }
    case .concatenation(let concatenation):
      let coalesced = self.coalescedChildren
      list.append(.concatenation(Array(repeating: TEMP_FAKE_NODE, count: coalesced.count)))
      for child in coalesced {
        try child.convert(into: &list)
      }
    case .group(let group):
      let child = group.child
      switch group.kind.value {
      case .capture:
        list.append(.capture(TEMP_FAKE_NODE))
        try child.convert(into: &list)
      case .namedCapture(let name):
        list.append(.capture(name: name.value, TEMP_FAKE_NODE))
        try child.convert(into: &list)
      case .balancedCapture:
        throw Unsupported("TODO: balanced captures")
      default:
        list.append(.nonCapturingGroup(.init(ast: group.kind.value), TEMP_FAKE_NODE))
        try child.convert(into: &list)
      }
    case .conditional(let conditional):
      list.append(.conditional(.init(ast: conditional.condition.kind), TEMP_FAKE_NODE, TEMP_FAKE_NODE))
      try conditional.trueBranch.convert(into: &list)
      try conditional.falseBranch.convert(into: &list)
    case .quantification(let quant):
      list.append(
        .quantification(.init(ast: quant.amount.value), .syntax(.init(ast: quant.kind.value)), TEMP_FAKE_NODE))
      try quant.child.convert(into: &list)
    case .quote(let node):
      list.append(.quotedLiteral(node.literal))
    case .trivia(let node):
      list.append(.trivia(node.contents))
    case .interpolation(_):
      throw Unsupported("TODO: interpolation")
    case .atom(let atom):
      switch atom.kind {
      case .scalarSequence(let seq):
        // The DSL doesn't have an equivalent node for scalar sequences. Splat
        // them into a concatenation of scalars.
        //        list.append(.concatenation(Array(repeating: TEMP_FAKE_NODE, count: seq.scalarValues.count)))
        list.append(.quotedLiteral(String(seq.scalarValues)))
      default:
        list.append(.atom(atom.dslTreeAtom))
      }
    case .customCharacterClass(let ccc):
      list.append(.customCharacterClass(ccc.dslTreeClass))
    case .absentFunction(let abs):
      // TODO: What should this map to?
      list.append(.absentFunction(.init(ast: abs)))
    case .empty(_):
      list.append(.empty)
    }
  }
  
  var coalescedChildren: [AST.Node] {
    // Before converting a concatenation in a tree to list form, we need to
    // flatten out any nested concatenations, and coalesce any adjacent
    // characters and scalars, forming quoted literals of their contents,
    // over which we can perform grapheme breaking.

    func flatten(_ node: AST.Node) -> [AST.Node] {
      switch node {
      case .concatenation(let concat):
        return concat.children.flatMap(flatten)
      default:
        return [node]
      }
    }
    
    func appendAtom(_ atom: AST.Atom, to str: inout String) -> Bool {
      switch atom.kind {
      case .char(let c):
        str.append(c)
        return true
      case .scalar(let s):
        str.append(Character(s.value))
        return true
      case .escaped(let c):
        guard let value = c.scalarValue else { return false }
        str.append(Character(value))
        return true
      case .scalarSequence(let seq):
        str.append(contentsOf: seq.scalarValues.lazy.map(Character.init))
        return true
        
      default:
        return false
      }
    }
    
    switch self {
    case .alternation(let v): return v.children
    case .concatenation(let v):
      let children = v.children
        .flatMap(flatten)
        .coalescing(with: "", into: { AST.Node.quote(.init($0, .fake)) }) { str, node in
          switch node {
          case .atom(let a):
            return appendAtom(a, to: &str)
          case .quote(let q):
            str += q.literal
            return true
          case .trivia:
            // Trivia can be completely ignored if we've already coalesced
            // something.
            return !str.isEmpty
          default:
            return false
          }
        }
      return children

    case .group(let group):
      return [group.child]
    case .conditional(let conditional):
      return [conditional.trueBranch, conditional.falseBranch]
    case .quantification(let quant):
      return [quant.child]
    case .quote, .trivia, .interpolation, .atom, .customCharacterClass, .absentFunction, .empty:
      return []
    }
  }
}

extension AST.Node {
  /// Converts an AST node to a `convertedRegexLiteral` node.
  var dslTreeNode: DSLTree.Node {
    // Convert the top-level node without wrapping
    func convert() throws -> DSLTree.Node {
      switch self {
      case let .alternation(v):
        let children = v.children.map(\.dslTreeNode)
        return .orderedChoice(children)

      case let .concatenation(v):
        return .concatenation(v.children.map(\.dslTreeNode))

      case let .group(v):
        let child = v.child.dslTreeNode
        switch v.kind.value {
        case .capture:
          return .capture(child)
        case .namedCapture(let name):
          return .capture(name: name.value, child)
        case .balancedCapture:
          throw Unsupported("TODO: balanced captures")
        default:
          return .nonCapturingGroup(.init(ast: v.kind.value), child)
        }

      case let .conditional(v):
        let trueBranch = v.trueBranch.dslTreeNode
        let falseBranch = v.falseBranch.dslTreeNode
        return .conditional(
          .init(ast: v.condition.kind), trueBranch, falseBranch)

      case let .quantification(v):
        let child = v.child.dslTreeNode
        return .quantification(
          .init(ast: v.amount.value), .syntax(.init(ast: v.kind.value)), child)

      case let .quote(v):
        return .quotedLiteral(v.literal)

      case let .trivia(v):
        return .trivia(v.contents)

      case .interpolation:
        throw Unsupported("TODO: interpolation")

      case let .atom(v):
        switch v.kind {
        case .scalarSequence(let seq):
          // The DSL doesn't have an equivalent node for scalar sequences. Splat
          // them into a concatenation of scalars.
          return .concatenation(seq.scalarValues.map { .atom(.scalar($0)) })
        default:
          return .atom(v.dslTreeAtom)
        }

      case let .customCharacterClass(ccc):
        return .customCharacterClass(ccc.dslTreeClass)

      case .empty(_):
        return .empty

      case let .absentFunction(abs):
        // TODO: What should this map to?
        return .absentFunction(.init(ast: abs))

      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
      }
    }

    let converted = try! convert()
    return converted
  }
}

extension AST.CustomCharacterClass {
  var dslTreeClass: DSLTree.CustomCharacterClass {
    // TODO: Not quite 1-1
    func convert(
      _ member: Member
    ) -> DSLTree.CustomCharacterClass.Member {
      switch member {
      case let .custom(ccc):
        return .custom(ccc.dslTreeClass)

      case let .range(r):
        return .range(
          r.lhs.dslTreeAtom, r.rhs.dslTreeAtom)

      case let .atom(a):
        return .atom(a.dslTreeAtom)

      case let .quote(q):
        return .quotedLiteral(q.literal)

      case let .setOperation(lhs, op, rhs):
        let lhs = DSLTree.CustomCharacterClass(
          members: lhs.map(convert),
          isInverted: false)
        let rhs = DSLTree.CustomCharacterClass(
          members: rhs.map(convert),
          isInverted: false)

        switch op.value {
        case .subtraction:
          return .subtraction(lhs, rhs)
        case .intersection:
          return .intersection(lhs, rhs)
        case .symmetricDifference:
          return .symmetricDifference(lhs, rhs)
        #if RESILIENT_LIBRARIES
        @unknown default:
          fatalError()
        #endif
        }
      case let .trivia(t):
        return .trivia(t.contents)

      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
      }
    }

    return .init(
      members: members.map(convert),
      isInverted: self.isInverted)
  }
}

extension AST.Atom.EscapedBuiltin {
  var dslAssertionKind: DSLTree.Atom.Assertion? {
    switch self {
    case .wordBoundary:                   return .wordBoundary
    case .notWordBoundary:                return .notWordBoundary
    case .startOfSubject:                 return .startOfSubject
    case .endOfSubject:                   return .endOfSubject
    case .textSegment:                    return .textSegment
    case .notTextSegment:                 return .notTextSegment
    case .endOfSubjectBeforeNewline:      return .endOfSubjectBeforeNewline
    case .firstMatchingPositionInSubject: return .firstMatchingPositionInSubject
    case .resetStartOfMatch:              return .resetStartOfMatch
    default: return nil
    }
  }
  var dslCharacterClass: DSLTree.Atom.CharacterClass? {
    switch self {
    case .decimalDigit:             return .digit
    case .notDecimalDigit:          return .notDigit
    case .horizontalWhitespace:     return .horizontalWhitespace
    case .notHorizontalWhitespace:  return .notHorizontalWhitespace
    case .newlineSequence:          return .newlineSequence
    case .notNewline:               return .notNewline
    case .whitespace:               return .whitespace
    case .notWhitespace:            return .notWhitespace
    case .verticalTab:              return .verticalWhitespace
    case .notVerticalTab:           return .notVerticalWhitespace
    case .wordCharacter:            return .word
    case .notWordCharacter:         return .notWord
    case .graphemeCluster:          return .anyGrapheme
    default: return nil
    }
  }
}

extension AST.Atom {
  var dslAssertionKind: DSLTree.Atom.Assertion? {
    switch kind {
    case .caretAnchor:    return .caretAnchor
    case .dollarAnchor:   return .dollarAnchor
    case .escaped(let b): return b.dslAssertionKind
    default: return nil
    }
  }
  var dslCharacterClass: DSLTree.Atom.CharacterClass? {
    switch kind {
    case .escaped(let b): return b.dslCharacterClass
    default: return nil
    }
  }
}

extension AST.Atom {
  var dslTreeAtom: DSLTree.Atom {
    if let kind = dslAssertionKind {
      return .assertion(kind)
    }
    
    if let cc = dslCharacterClass {
      return .characterClass(cc)
    }

    switch self.kind {
    case let .char(c):                    return .char(c)
    case let .scalar(s):                  return .scalar(s.value)
    case .dot:                            return .dot
    case let .backreference(r):           return .backreference(.init(ast: r))
    case let .changeMatchingOptions(seq): return .changeMatchingOptions(.init(ast: seq))

    case .escaped(let c):
      guard let val = c.scalarValue else {
        fatalError("Got a .escaped that was not an assertion, character class, or scalar value \(self)")
      }
      return .scalar(val)
    default: return .unconverted(.init(ast: self))
    }
  }
}
