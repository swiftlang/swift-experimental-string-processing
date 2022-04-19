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

@_implementationOnly import _RegexParser

@_spi(RegexBuilder)
public struct DSLTree {
  var root: Node
  var options: Options?

  init(_ r: Node, options: Options?) {
    self.root = r
    self.options = options
  }
}

extension DSLTree {
  @_spi(RegexBuilder)
  public indirect enum Node: _DSLTreeNode {
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
    case nonCapturingGroup(_AST.GroupKind, Node)

    // TODO: Consider splitting off grouped conditions, or have
    // our own kind

    /// Match a choice of two nodes based on a condition
    ///
    ///     (?(cond) true-branch | false-branch)
    ///
    case conditional(
      _AST.ConditionKind, Node, Node)

    case quantification(
      _AST.QuantificationAmount,
      QuantificationKind,
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
    case regexLiteral(_AST.ASTNode)

    // TODO: What should we do here?
    ///
    /// TODO: Consider splitting off expression functions, or have our own kind
    case absentFunction(_AST.AbsentFunction)

    // MARK: - Tree conversions

    /// The target of AST conversion.
    ///
    /// Keeps original AST around for rich syntactic and source information
    case convertedRegexLiteral(Node, _AST.ASTNode)

    // MARK: - Extensibility points

    /// Transform a range into a value, most often used inside captures
    case transform(CaptureTransform, Node)

    case consumer(_ConsumerInterface)

    case matcher(Any.Type, _MatcherInterface)

    // TODO: Would this just boil down to a consumer?
    case characterPredicate(_CharacterPredicateInterface)
  }
}

extension DSLTree {
  @_spi(RegexBuilder)
  public enum QuantificationKind {
    /// The default quantification kind, as set by options.
    case `default`
    /// An explicitly chosen kind, overriding any options.
    case explicit(_AST.QuantificationKind)
    /// A kind set via syntax, which can be affected by options.
    case syntax(_AST.QuantificationKind)
  }
  
  @_spi(RegexBuilder)
  public struct CustomCharacterClass {
    var members: [Member]
    var isInverted: Bool
    
    var containsAny: Bool {
      members.contains { member in
        switch member {
        case .atom(.any): return true
        case .custom(let ccc): return ccc.containsAny
        default:
          return false
        }
      }
    }
    
    public init(members: [DSLTree.CustomCharacterClass.Member], isInverted: Bool = false) {
      self.members = members
      self.isInverted = isInverted
    }
    
    public var inverted: CustomCharacterClass {
      var result = self
      result.isInverted.toggle()
      return result
    }

    @_spi(RegexBuilder)
    public enum Member {
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

  @_spi(RegexBuilder)
  public enum Atom {
    case char(Character)
    case scalar(Unicode.Scalar)
    case any

    case assertion(AST.Atom.AssertionKind)
    case backreference(AST.Reference)
    case symbolicReference(ReferenceID)

    case changeMatchingOptions(AST.MatchingOptionSequence)

    case unconverted(AST.Atom)
  }
}

// CollectionConsumer
@_spi(RegexBuilder)
public typealias _ConsumerInterface = (
  String, Range<String.Index>
) throws -> String.Index?

// Type producing consume
// TODO: better name
@_spi(RegexBuilder)
public typealias _MatcherInterface = (
  String, String.Index, Range<String.Index>
) throws -> (String.Index, Any)?

// Character-set (post grapheme segmentation)
@_spi(RegexBuilder)
public typealias _CharacterPredicateInterface = (
  (Character) -> Bool
)

/*

 TODO: Use of syntactic types, like group kinds, is a
 little suspect. We may want to figure out a model here.

 TODO: Do capturing groups need explicit numbers?

 TODO: Are storing closures better/worse than existentials?

 */

extension DSLTree.Node {
  @_spi(RegexBuilder)
  public var children: [DSLTree.Node]? {
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

    case let .absentFunction(abs):
      return abs.ast.children.map(\.dslTreeNode)
    }
  }
}

extension DSLTree.Node {
  var astNode: AST.Node? {
    switch self {
    case let .regexLiteral(literal):             return literal.ast
    case let .convertedRegexLiteral(_, literal): return literal.ast
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
      return re.ast.hasCapture
    case let .convertedRegexLiteral(n, re):
      assert(n.hasCapture == re.ast.hasCapture)
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
  @_spi(RegexBuilder)
  public func _captureStructure(
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
      assert(!kind.ast.isCapturing)
      return constructor.grouping(child, as: kind.ast)

    case let .conditional(cond, trueBranch, falseBranch):
      return constructor.condition(
        cond.ast,
        trueBranch: trueBranch,
        falseBranch: falseBranch)

    case let .quantification(amount, _, child):
      return constructor.quantifying(
        child, amount: amount.ast)

    case let .regexLiteral(re):
      // TODO: Force a re-nesting?
      return re.ast._captureStructure(&constructor)

    case let .absentFunction(abs):
      return constructor.absent(abs.ast.kind)

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
      return AnyType(t)
    case let .transform(t, _):
      return AnyType(t.resultType)
    default: return nil
    }
  }
}

extension DSLTree.Node {
  @_spi(RegexBuilder)
  public func appending(_ newNode: DSLTree.Node) -> DSLTree.Node {
    if case .concatenation(let components) = self {
      return .concatenation(components + [newNode])
    }
    return .concatenation([self, newNode])
  }

  @_spi(RegexBuilder)
  public func appendingAlternationCase(
    _ newNode: DSLTree.Node
  ) -> DSLTree.Node {
    if case .orderedChoice(let components) = self {
      return .orderedChoice(components + [newNode])
    }
    return .orderedChoice([self, newNode])
  }
}

@_spi(RegexBuilder)
public struct ReferenceID: Hashable, Equatable {
  private static var counter: Int = 0
  var base: Int

  public init() {
    base = Self.counter
    Self.counter += 1
  }
}

@_spi(RegexBuilder)
public struct CaptureTransform: Hashable, CustomStringConvertible {
  public enum Closure {
    case failable((Substring) throws -> Any?)
    case nonfailable((Substring) throws -> Any)
  }
  public let resultType: Any.Type
  public let closure: Closure

  public init(resultType: Any.Type, closure: Closure) {
    self.resultType = resultType
    self.closure = closure
  }

  public init(
    resultType: Any.Type,
    _ closure: @escaping (Substring) throws -> Any
  ) {
    self.init(resultType: resultType, closure: .nonfailable(closure))
  }

  public init(
    resultType: Any.Type,
    _ closure: @escaping (Substring) throws -> Any?
  ) {
    self.init(resultType: resultType, closure: .failable(closure))
  }

  public func callAsFunction(_ input: Substring) throws -> Any? {
    switch closure {
    case .nonfailable(let closure):
      let result = try closure(input)
      assert(type(of: result) == resultType)
      return result
    case .failable(let closure):
      guard let result = try closure(input) else {
        return nil
      }
      assert(type(of: result) == resultType)
      return result
    }
  }

  public static func == (lhs: CaptureTransform, rhs: CaptureTransform) -> Bool {
    unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
      unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  public func hash(into hasher: inout Hasher) {
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  public var description: String {
    "<transform result_type=\(resultType)>"
  }
}

// MARK: AST wrapper types
//
// These wrapper types are required because even @_spi-marked public APIs can't
// include symbols from implementation-only dependencies.
internal protocol _DSLTreeNode: _TreeNode {}

extension DSLTree {
  @_spi(RegexBuilder)
  public enum _AST {
    @_spi(RegexBuilder)
    public struct GroupKind {
      internal var ast: AST.Group.Kind
      
      @_spi(RegexBuilder) public static var atomicNonCapturing: Self {
        .init(ast: .atomicNonCapturing)
      }
      @_spi(RegexBuilder) public static var lookahead: Self {
        .init(ast: .lookahead)
      }
      @_spi(RegexBuilder) public static var negativeLookahead: Self {
        .init(ast: .negativeLookahead)
      }
    }

    @_spi(RegexBuilder)
    public struct ConditionKind {
      internal var ast: AST.Conditional.Condition.Kind
    }
    
    @_spi(RegexBuilder)
    public struct QuantificationKind {
      internal var ast: AST.Quantification.Kind
      
      @_spi(RegexBuilder) public static var eager: Self {
        .init(ast: .eager)
      }
      @_spi(RegexBuilder) public static var reluctant: Self {
        .init(ast: .reluctant)
      }
      @_spi(RegexBuilder) public static var possessive: Self {
        .init(ast: .possessive)
      }
    }
    
    @_spi(RegexBuilder)
    public struct QuantificationAmount {
      internal var ast: AST.Quantification.Amount
      
      @_spi(RegexBuilder) public static var zeroOrMore: Self {
        .init(ast: .zeroOrMore)
      }
      @_spi(RegexBuilder) public static var oneOrMore: Self {
        .init(ast: .oneOrMore)
      }
      @_spi(RegexBuilder) public static var zeroOrOne: Self {
        .init(ast: .zeroOrOne)
      }
      @_spi(RegexBuilder) public static func exactly(_ n: Int) -> Self {
        .init(ast: .exactly(.init(faking: n)))
      }
      @_spi(RegexBuilder) public static func nOrMore(_ n: Int) -> Self {
        .init(ast: .nOrMore(.init(faking: n)))
      }
      @_spi(RegexBuilder) public static func upToN(_ n: Int) -> Self {
        .init(ast: .upToN(.init(faking: n)))
      }
      @_spi(RegexBuilder) public static func range(_ lower: Int, _ upper: Int) -> Self {
        .init(ast: .range(.init(faking: lower), .init(faking: upper)))
      }
    }
    
    @_spi(RegexBuilder)
    public struct ASTNode {
      internal var ast: AST.Node
    }
    
    @_spi(RegexBuilder)
    public struct AbsentFunction {
      internal var ast: AST.AbsentFunction
    }
  }
}
