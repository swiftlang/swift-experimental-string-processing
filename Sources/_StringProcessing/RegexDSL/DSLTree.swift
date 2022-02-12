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

struct DSLTree {
  var root: Node
  var options: Options?

  init(_ r: Node, options: Options?) {
    self.root = r
    self.options = options
  }
}

extension DSLTree {
  indirect enum Node: _TreeNode {
    /// ... | ... | ...
    case alternation([Node])

    /// ... ...
    case concatenation([Node])

    /// (...)
    case group(AST.Group.Kind, Node)

    /// (?(cond) true-branch | false-branch)
    ///
    /// TODO: Consider splitting off grouped conditions, or have our own kind
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

    case quotedLiteral(String)

    /// An embedded literal
    case regexLiteral(AST.Node)

    // TODO: What should we do here?
    ///
    /// TODO: Consider splitting off expression functions, or have our own kind
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

      case quotedLiteral(String)

      case trivia(String)

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

    case .trivia, .empty, .quotedLiteral, .regexLiteral,
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

extension DSLTree {
  struct Options {
    // TBD
  }
}

extension DSLTree {
  var ast: AST? {
    guard let root = root.astNode else {
      return nil
    }
    // TODO: Options mapping
    return AST(root, globalOptions: nil)
  }
}

extension DSLTree {
  var hasCapture: Bool {
    root.hasCapture
  }
}
extension DSLTree.Node {
  var hasCapture: Bool {
    switch self {
    case let .group(k, _) where k.isCapturing,
         let .groupTransform(k, _, _) where k.isCapturing:
      return true
    case let .convertedRegexLiteral(n, re):
      assert(n.hasCapture == re.hasCapture)
      return n.hasCapture
    case let .regexLiteral(re):
      return re.hasCapture
    default:
      break
    }
    return self.children?.any(\.hasCapture) ?? false
  }
}

extension DSLTree {
  var captureStructure: CaptureStructure {
    root.captureStructure
  }
}
extension DSLTree.Node {
  var captureStructure: CaptureStructure {
    switch self {
    case let .alternation(children):
      return CaptureStructure(alternating: children)

    case let .concatenation(children):
      return CaptureStructure(concatenating: children)

    case let .group(kind, child):
      return CaptureStructure(grouping: child, as: kind)

    case let .groupTransform(kind, child, transform):
      return CaptureStructure(
        grouping: child, as: kind, withTransform: transform)

    case let .conditional(cond, trueBranch, falseBranch):
      return CaptureStructure(
        condition: cond,
        trueBranch: trueBranch,
        falseBranch: falseBranch)

    case let .quantification(amount, _, child):
      return CaptureStructure(
        quantifying: child, amount: amount)

    case let .regexLiteral(re):
      return re.captureStructure

    case let .absentFunction(abs):
      return CaptureStructure(absent: abs.kind)

    case let .convertedRegexLiteral(n, _):
      return n.captureStructure

    case .consumerValidator:
      // FIXME: This is where we make a capture!
      return .empty

    case .customCharacterClass, .atom, .trivia, .empty,
        .quotedLiteral, .consumer, .characterPredicate:
      return .empty
    }
  }
}

extension DSLTree.Node {
  func appending(_ newNode: DSLTree.Node) -> DSLTree.Node {
    if case .concatenation(let components) = self {
      return .concatenation(components + [newNode])
    }
    return .concatenation([self, newNode])
  }

  func appendingAlternationCase(_ newNode: DSLTree.Node) -> DSLTree.Node {
    if case .alternation(let components) = self {
      return .alternation(components + [newNode])
    }
    return .alternation([self, newNode])
  }
}
