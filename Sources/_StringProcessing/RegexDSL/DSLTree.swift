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
    /// Try to match each node in order
    ///
    ///     ... | ... | ...
    case orderedChoice([Node])

    /// Match each node in sequence
    ///
    ///     ... ...
    case concatenation([Node])

    /// Capture the result of a subpattern
    ///
    ///     (...), (?<name>...)
    case capture(
      name: String? = nil, reference: ReferenceID? = nil, Node)

    /// Match a (non-capturing) subpattern / group
    case nonCapturingGroup(AST.Group.Kind, Node)

    // TODO: Consider splitting off grouped conditions, or have
    // our own kind

    /// Match a choice of two nodes based on a condition
    ///
    ///     (?(cond) true-branch | false-branch)
    ///
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
    /// Keeps original AST around for rich syntactic and source information
    case convertedRegexLiteral(Node, AST.Node)

    // MARK: - Extensibility points

    /// Transform a range into a value, most often used inside captures
    case transform(CaptureTransform, Node)

    case consumer(_ConsumerInterface)

    case matcher(AnyType, _MatcherInterface)

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
    case symbolicReference(ReferenceID)

    case unconverted(AST.Atom)
  }
}

// CollectionConsumer
typealias _ConsumerInterface = (
  String, Range<String.Index>
) -> String.Index?

// Type producing consume
// TODO: better name
typealias _MatcherInterface = (
  String, String.Index, Range<String.Index>
) -> (String.Index, Any)?

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
      
    case let .orderedChoice(v):   return v
    case let .concatenation(v): return v

    case let .convertedRegexLiteral(n, _):
      // Treat this transparently
      return n.children

    case let .capture(_, _, n):           return [n]
    case let .nonCapturingGroup(_, n):    return [n]
    case let .transform(_, n):            return [n]
    case let .quantification(_, _, n):    return [n]

    case let .conditional(_, t, f): return [t,f]

    case .trivia, .empty, .quotedLiteral, .regexLiteral,
        .consumer, .matcher, .characterPredicate,
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
    case .capture:
      return true
    case let .regexLiteral(re):
      return re.hasCapture
    case let .convertedRegexLiteral(n, re):
      assert(n.hasCapture == re.hasCapture)
      return n.hasCapture

    default:
      return self.children?.any(\.hasCapture) ?? false
    }
  }
}

extension DSLTree {
  var captureStructure: CaptureStructure {
    // TODO: nesting
    var constructor = CaptureStructure.Constructor(.flatten)
    return root._captureStructure(&constructor)
  }
}
extension DSLTree.Node {
  func _captureStructure(
    _ constructor: inout CaptureStructure.Constructor
  ) -> CaptureStructure {
    switch self {
    case let .orderedChoice(children):
      return constructor.alternating(children)

    case let .concatenation(children):
      return constructor.concatenating(children)

    case let .capture(name, _, child):
      if let type = child.valueCaptureType {
        return constructor.capturing(
          name: name, child, withType: type)
      }
      return constructor.capturing(name: name, child)

    case let .nonCapturingGroup(kind, child):
      assert(!kind.isCapturing)
      return constructor.grouping(child, as: kind)

    case let .conditional(cond, trueBranch, falseBranch):
      return constructor.condition(
        cond,
        trueBranch: trueBranch,
        falseBranch: falseBranch)

    case let .quantification(amount, _, child):
      return constructor.quantifying(
        child, amount: amount)

    case let .regexLiteral(re):
      // TODO: Force a re-nesting?
      return re._captureStructure(&constructor)

    case let .absentFunction(abs):
      return constructor.absent(abs.kind)

    case let .convertedRegexLiteral(n, _):
      // TODO: Switch nesting strategy?
      return n._captureStructure(&constructor)

    case .matcher:
      return .empty

    case .transform(_, let child):
      return child._captureStructure(&constructor)

    case .customCharacterClass, .atom, .trivia, .empty,
        .quotedLiteral, .consumer, .characterPredicate:
      return .empty
    }
  }

  /// For typed capture-producing nodes, the type produced.
  var valueCaptureType: AnyType? {
    switch self {
    case let .matcher(t, _):
      return t
    case let .transform(t, _):
      return AnyType(t.resultType)
    default: return nil
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
    if case .orderedChoice(let components) = self {
      return .orderedChoice(components + [newNode])
    }
    return .orderedChoice([self, newNode])
  }
}

extension DSLTree.Node {
  /// Generates a DSLTree node for a repeated range of the given DSLTree node.
  /// Individual public API functions are in the generated Variadics.swift file.
  static func repeating(
    _ range: Range<Int>,
    _ behavior: QuantificationBehavior,
    _ node: DSLTree.Node
  ) -> DSLTree.Node {
    // TODO: Throw these as errors
    assert(range.lowerBound >= 0, "Cannot specify a negative lower bound")
    assert(!range.isEmpty, "Cannot specify an empty range")
    
    switch (range.lowerBound, range.upperBound) {
    case (0, Int.max): // 0...
      return .quantification(.zeroOrMore, behavior.astKind, node)
    case (1, Int.max): // 1...
      return .quantification(.oneOrMore, behavior.astKind, node)
    case _ where range.count == 1: // ..<1 or ...0 or any range with count == 1
      // Note: `behavior` is ignored in this case
      return .quantification(.exactly(.init(faking: range.lowerBound)), .eager, node)
    case (0, _): // 0..<n or 0...n or ..<n or ...n
      return .quantification(.upToN(.init(faking: range.upperBound)), behavior.astKind, node)
    case (_, Int.max): // n...
      return .quantification(.nOrMore(.init(faking: range.lowerBound)), behavior.astKind, node)
    default: // any other range
      return .quantification(.range(.init(faking: range.lowerBound), .init(faking: range.upperBound)), behavior.astKind, node)
    }
  }
}
