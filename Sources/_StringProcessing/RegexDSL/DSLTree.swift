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

import _MatchingEngine

struct DSLTree {}

extension DSLTree {
  indirect enum Node: _TreeNode {
    /// ... | ... | ...
    case alternation([Node])

    /// ... ...
    case concatenation([Node])

    /// (...)
    case group(AST.Group.Kind, Node)

    /// (?(cond) true-branch | false-branch)
    case conditional(
      AST.Conditional.Condition.Kind, Node, Node)

    case quantification(
      AST.Quantification.Amount,
      AST.Quantification.Kind,
      Node)

    case customCharacterClass(CustomCharacterClass)

    case atom(Atom)

    /// Comments, non-semantic whitespace, etc
    // TODO: Do we want this? Could be interesting
    case trivia(String)

    // TODO: Probably some atoms, built-ins, etc.

    case empty

    case stringLiteral(String)

    /// An embedded literal
    case regexLiteral(AST.Node)

    // TODO: What should we do here?
    case absentFunction(AST.AbsentFunction)

    // MARK: - Tree conversions

    /// The target of AST conversion.
    ///
    /// Keeps original AST around for rich syntatic and source information
    case convertedRegexLiteral(Node, AST.Node)

    // MARK: - Extensibility points

    /// A capturing group (TODO: is it?) with a transformation function
    case groupTransform(
      AST.Group.Kind,
      Node,
      CaptureTransform)

    case consumer(_ConsumerInterface)

    case consumerValidator(_ConsumerValidatorInterface)

    // TODO: Would this just boil down to a consumer?
    case characterPredicate(_CharacterPredicateInterface)
  }
}

extension DSLTree {
  struct CustomCharacterClass {
    var members: [Member]
    var isInverted: Bool

    enum Member {
      case atom(Atom)
      case range(Atom, Atom)
      case custom(CustomCharacterClass)

      indirect case intersection(CustomCharacterClass, CustomCharacterClass)
      indirect case subtraction(CustomCharacterClass, CustomCharacterClass)
      indirect case symmetricDifference(CustomCharacterClass, CustomCharacterClass)
    }
  }

  enum Atom {
    case char(Character)
    case scalar(Unicode.Scalar)
    case any

    case assertion(AST.Atom.AssertionKind)
    case backreference(AST.Reference)

    case unconverted(AST.Atom)
  }
}

// CollectionConsumer
typealias _ConsumerInterface = (
  String, Range<String.Index>
) -> String.Index?

// Type producing consume
typealias _ConsumerValidatorInterface = (
  String, Range<String.Index>
) -> (Any, Any.Type, String.Index)?

// Character-set (post grapheme segmentation)
typealias _CharacterPredicateInterface = (
  (Character) -> Bool
)

/*

 TODO: Use of syntactic types, like group kinds, is a
 little suspect. We may want to figure out a model here.

 TODO: Do capturing groups need explicit numbers?

 TODO: Are storing closures better/worse than existentials?

 */

extension DSLTree.Node {
  var children: [DSLTree.Node]? {
    switch self {
      
    case let .alternation(v):   return v
    case let .concatenation(v): return v

    case let .convertedRegexLiteral(n, _):
      // Treat this transparently
      return n.children

    case let .group(_, n):             return [n]
    case let .groupTransform(_, n, _): return [n]
    case let .quantification(_, _, n): return [n]

    case let .conditional(_, t, f): return [t,f]

    case .trivia, .empty, .stringLiteral, .regexLiteral,
        .consumer, .consumerValidator, .characterPredicate,
        .customCharacterClass, .atom:
      return []

    case let .absentFunction(a):
      return a.children.map(\.dslTreeNode)
    }
  }
}

extension DSLTree.Node {
  var astNode: AST.Node? {
    switch self {
    case let .regexLiteral(ast):             return ast
    case let .convertedRegexLiteral(_, ast): return ast
    default: return nil
    }
  }
}

extension AST.Node {
  /// Converts an AST node to a `convertedRegexLiteral` node.
  var dslTreeNode: DSLTree.Node {
    func wrap(_ node: DSLTree.Node) -> DSLTree.Node {
      switch node {
      case .convertedRegexLiteral:
        assertionFailure("Double wrapping?")
      default:
        break
      }
      // TODO: Should we do this for the
      // single-concatenation child too, or should?
      // we wrap _that_?
      return .convertedRegexLiteral(node, self)
    }

    // Convert the top-level node without wrapping
    func convert() -> DSLTree.Node {
      switch self {
      case let .alternation(v):
        let children = v.children.map(\.dslTreeNode)
        return .alternation(children)

      case let .concatenation(v):
        // Coalesce adjacent children who can produce a
        // string literal representation
        let astChildren = v.children
        func coalesce(
          _ idx: inout Array<AST>.Index
        ) -> String? {
          var result = ""
          while idx < astChildren.endIndex {
            let atom: AST.Atom? = astChildren[idx].as()
            guard let str = atom?.literalStringValue else {
              break
            }
            result += str
            astChildren.formIndex(after: &idx)
          }
          return result.isEmpty ? nil : result
        }

        // No need to nest single children concatenations
        if astChildren.count == 1 {
          return astChildren.first!.dslTreeNode
        }

        // Check for a single child post-coalescing
        var idx = astChildren.startIndex
        if let str = coalesce(&idx),
           idx == astChildren.endIndex
        {
          return .stringLiteral(str)
        }

        // Coalesce adjacent string children
        var curIdx = astChildren.startIndex
        var children = Array<DSLTree.Node>()
        while curIdx < astChildren.endIndex {
          if let str = coalesce(&curIdx) {
            // TODO: Track source info...
            children.append(.stringLiteral(str))
          } else {
            children.append(astChildren[curIdx].dslTreeNode)
            children.formIndex(after: &curIdx)
          }
        }
        return .concatenation(children)

      case let .group(v):
        let child = v.child.dslTreeNode
        return .group(v.kind.value, child)

      case let .conditional(v):
        let trueBranch = v.trueBranch.dslTreeNode
        let falseBranch = v.falseBranch.dslTreeNode
        return .conditional(
          v.condition.kind, trueBranch, falseBranch)

      case let .quantification(v):
        let child = v.child.dslTreeNode
        return .quantification(
          v.amount.value, v.kind.value, child)

      case let .quote(v):
        return .stringLiteral(v.literal)

      case let .trivia(v):
        return .trivia(v.contents)

      case let .atom(v):
        if let str = v.literalStringValue {
          return .stringLiteral(str)
        }
        return .atom(v.dslTreeAtom)

      case let .customCharacterClass(ccc):
        return .customCharacterClass(ccc.dslTreeClass)

      case .empty(_):
        return .empty

      case let .groupTransform(v, transform):
        let child = v.child.dslTreeNode
        return .groupTransform(
          v.kind.value, child, transform)

      case let .absentFunction(a):
        // TODO: What should this map to?
        return .absentFunction(a)
      }
    }

    return wrap(convert())
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
        // TODO: Probably should flatten instead of nest
        return .custom(.init(
          members: q.literal.map { .atom(.char($0)) },
          isInverted: false))

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
        }
      }
    }

    return .init(
      members: members.map(convert),
      isInverted: self.isInverted)
  }
}

extension AST.Atom {
  var dslTreeAtom: DSLTree.Atom {
    if let kind = assertionKind {
      return .assertion(kind)
    }

    switch self.kind {
    case let .char(c):          return .char(c)
    case let .scalar(s):        return .scalar(s)
    case .any:                  return .any
    case let .backreference(r): return .backreference(r)

    default: return .unconverted(self)
    }
  }
}

extension DSLTree.Atom {
  // Return the Character or promote a scalar to a Character
  var literalCharacterValue: Character? {
    switch self {
    case let .char(c):   return c
    case let .scalar(s): return Character(s)
    default: return nil
    }
  }
}
