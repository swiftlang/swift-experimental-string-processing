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

public struct _DSLTree {
  var root: _Node

  init(_ r: _Node) {
    self.root = r
  }
}

extension _DSLTree {
  public indirect enum _Node {
    /// Matches each node in order.
    ///
    ///     ... | ... | ...
    case orderedChoice([_Node])

    /// Match each node in sequence.
    ///
    ///     ... ...
    case concatenation([_Node])

    /// Captures the result of a subpattern.
    ///
    ///     (...), (?<name>...)
    case capture(
      name: String? = nil, reference: _ReferenceID? = nil, _Node,
      _CaptureTransform? = nil)

    /// Matches a noncapturing subpattern.
    case nonCapturingGroup(_AST._GroupKind, _Node)

    // TODO: Consider splitting off grouped conditions, or have
    // our own kind

    /// Matches a choice of two nodes, based on a condition.
    ///
    ///     (?(cond) true-branch | false-branch)
    ///
    case conditional(
      _AST._ConditionKind, _Node, _Node)

    case quantification(
      _AST._QuantificationAmount,
      _QuantificationKind,
      _Node)

    case customCharacterClass(_CustomCharacterClass)

    case atom(_Atom)

    /// Comments, non-semantic whitespace, and so on.
    // TODO: Do we want this? Could be interesting
    case trivia(String)

    // TODO: Probably some atoms, built-ins, etc.

    case empty

    case quotedLiteral(String)

    /// An embedded literal.
    case regexLiteral(_AST._ASTNode)

    // TODO: What should we do here?
    ///
    /// TODO: Consider splitting off expression functions, or have our own kind
    case absentFunction(_AST._AbsentFunction)

    // MARK: - Tree conversions

    /// The target of AST conversion.
    ///
    /// Keeps original AST around for rich syntactic and source information
    case convertedRegexLiteral(_Node, _AST._ASTNode)

    // MARK: - Extensibility points

    case consumer(_ConsumerInterface)

    case matcher(Any.Type, _MatcherInterface)

    // TODO: Would this just boil down to a consumer?
    case characterPredicate(_CharacterPredicateInterface)
  }
}

extension _DSLTree {
  public enum _QuantificationKind {
    /// The default quantification kind, as set by options.
    case `default`
    /// An explicitly chosen kind, overriding any options.
    case explicit(_AST._QuantificationKind)
    /// A kind set via syntax, which can be affected by options.
    case syntax(_AST._QuantificationKind)
    
    var ast: AST.Quantification.Kind? {
      switch self {
      case .default: return nil
      case .explicit(let kind), .syntax(let kind):
        return kind.ast
      }
    }
  }
  
  public struct _CustomCharacterClass {
    var members: [_Member]
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
    
    public init(_members: [_DSLTree._CustomCharacterClass._Member], isInverted: Bool = false) {
      self.members = _members
      self.isInverted = isInverted
    }
    
    public static func _generalCategory(_ category: Unicode.GeneralCategory) -> Self {
      let property = AST.Atom.CharacterProperty(.generalCategory(category.extendedGeneralCategory!), isInverted: false, isPOSIX: false)
      let astAtom = AST.Atom(.property(property), .fake)
      return .init(_members: [.atom(.unconverted(.init(ast: astAtom)))])
    }
    
    public var _inverted: _CustomCharacterClass {
      var result = self
      result.isInverted.toggle()
      return result
    }

    public enum _Member {
      case atom(_Atom)
      case range(_Atom, _Atom)
      case custom(_CustomCharacterClass)

      case quotedLiteral(String)

      case trivia(String)

      indirect case intersection(_CustomCharacterClass, _CustomCharacterClass)
      indirect case subtraction(_CustomCharacterClass, _CustomCharacterClass)
      indirect case symmetricDifference(_CustomCharacterClass, _CustomCharacterClass)
    }
  }

  public enum _Atom {
    case char(Character)
    case scalar(Unicode.Scalar)
    case any

    case assertion(_AST._AssertionKind)
    case backreference(_AST._Reference)
    case symbolicReference(_ReferenceID)

    case changeMatchingOptions(_AST._MatchingOptionSequence)

    case unconverted(_AST._Atom)
  }
}

extension Unicode.GeneralCategory {
  var extendedGeneralCategory: Unicode.ExtendedGeneralCategory? {
    switch self {
    case .uppercaseLetter: return .uppercaseLetter
    case .lowercaseLetter: return .lowercaseLetter
    case .titlecaseLetter: return .titlecaseLetter
    case .modifierLetter: return .modifierLetter
    case .otherLetter: return .otherLetter
    case .nonspacingMark: return .nonspacingMark
    case .spacingMark: return .spacingMark
    case .enclosingMark: return .enclosingMark
    case .decimalNumber: return .decimalNumber
    case .letterNumber: return .letterNumber
    case .otherNumber: return .otherNumber
    case .connectorPunctuation: return .connectorPunctuation
    case .dashPunctuation: return .dashPunctuation
    case .openPunctuation: return .openPunctuation
    case .closePunctuation: return .closePunctuation
    case .initialPunctuation: return .initialPunctuation
    case .finalPunctuation: return .finalPunctuation
    case .otherPunctuation: return .otherPunctuation
    case .mathSymbol: return .mathSymbol
    case .currencySymbol: return .currencySymbol
    case .modifierSymbol: return .modifierSymbol
    case .otherSymbol: return .otherSymbol
    case .spaceSeparator: return .spaceSeparator
    case .lineSeparator: return .lineSeparator
    case .paragraphSeparator: return .paragraphSeparator
    case .control: return .control
    case .format: return .format
    case .surrogate: return .surrogate
    case .privateUse: return .privateUse
    case .unassigned: return .unassigned
    @unknown default: return nil
    }
  }
}

// CollectionConsumer
public typealias _ConsumerInterface = (
  String, Range<String.Index>
) throws -> String.Index?

// Type producing consume
// TODO: better name
public typealias _MatcherInterface = (
  String, String.Index, Range<String.Index>
) throws -> (String.Index, Any)?

// Character-set (post grapheme segmentation)
public typealias _CharacterPredicateInterface = (
  (Character) -> Bool
)

/*

 TODO: Use of syntactic types, like group kinds, is a
 little suspect. We may want to figure out a model here.

 TODO: Do capturing groups need explicit numbers?

 TODO: Are storing closures better/worse than existentials?

 */

extension _DSLTree._Node {
  public var _children: [_DSLTree._Node] {
    switch self {
      
    case let .orderedChoice(v):   return v
    case let .concatenation(v): return v

    case let .convertedRegexLiteral(n, _):
      // Treat this transparently
      return n._children

    case let .capture(_, _, n, _):        return [n]
    case let .nonCapturingGroup(_, n):    return [n]
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

extension _DSLTree._Node {
  var astNode: AST.Node? {
    switch self {
    case let .regexLiteral(literal):             return literal.ast
    case let .convertedRegexLiteral(_, literal): return literal.ast
    default: return nil
    }
  }
}

extension _DSLTree._Atom {
  // Return the Character or promote a scalar to a Character
  var literalCharacterValue: Character? {
    switch self {
    case let .char(c):   return c
    case let .scalar(s): return Character(s)
    default: return nil
    }
  }
}

extension _DSLTree {
  struct Options {
    // TBD
  }
}

extension _DSLTree {
  var ast: AST? {
    guard let root = root.astNode else {
      return nil
    }
    // TODO: Options mapping
    return AST(root, globalOptions: nil)
  }
}

extension _DSLTree {
  var hasCapture: Bool {
    root.hasCapture
  }
}
extension _DSLTree._Node {
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
      return self._children.any(\.hasCapture)
    }
  }
}

extension _DSLTree._Node {
  public func _appending(_ newNode: _DSLTree._Node) -> _DSLTree._Node {
    if case .concatenation(let components) = self {
      return .concatenation(components + [newNode])
    }
    return .concatenation([self, newNode])
  }

  public func _appendingAlternationCase(
    _ newNode: _DSLTree._Node
  ) -> _DSLTree._Node {
    if case .orderedChoice(let components) = self {
      return .orderedChoice(components + [newNode])
    }
    return .orderedChoice([self, newNode])
  }
}

public struct _ReferenceID: Hashable {
  private static var counter: Int = 0
  var base: Int

  public init() {
    base = Self.counter
    Self.counter += 1
  }
}

public struct _CaptureTransform: Hashable, CustomStringConvertible {
  enum Closure {
    /// A failable transform.
    case failable((Any) throws -> Any?)
    /// Specialized case of `failable` for performance.
    case substringFailable((Substring) throws -> Any?)
    /// A non-failable transform.
    case nonfailable((Any) throws -> Any)
    /// Specialized case of `failable` for performance.
    case substringNonfailable((Substring) throws -> Any?)
  }
  let argumentType: Any.Type
  let resultType: Any.Type
  let closure: Closure

  init(argumentType: Any.Type, resultType: Any.Type, closure: Closure) {
    self.argumentType = argumentType
    self.resultType = resultType
    self.closure = closure
  }

  public init<Argument, Result>(
    _ userSpecifiedTransform: @escaping (Argument) throws -> Result
  ) {
    let closure: Closure
    if let substringTransform = userSpecifiedTransform
      as? (Substring) throws -> Result {
      closure = .substringNonfailable(substringTransform)
    } else {
      closure = .nonfailable {
        try userSpecifiedTransform($0 as! Argument) as Any
      }
    }
    self.init(
      argumentType: Argument.self,
      resultType: Result.self,
      closure: closure)
  }

  public init<Argument, Result>(
    _ userSpecifiedTransform: @escaping (Argument) throws -> Result?
  ) {
    let closure: Closure
    if let substringTransform = userSpecifiedTransform
      as? (Substring) throws -> Result? {
      closure = .substringFailable(substringTransform)
    } else {
      closure = .failable {
        try userSpecifiedTransform($0 as! Argument) as Any?
      }
    }
    self.init(
      argumentType: Argument.self,
      resultType: Result.self,
      closure: closure)
  }

  func callAsFunction(_ input: Any) throws -> Any? {
    switch closure {
    case .nonfailable(let transform):
      let result = try transform(input)
      assert(type(of: result) == resultType)
      return result
    case .substringNonfailable(let transform):
      let result = try transform(input as! Substring)
      assert(type(of: result) == resultType)
      return result
    case .failable(let transform):
      guard let result = try transform(input) else {
        return nil
      }
      assert(type(of: result) == resultType)
      return result
    case .substringFailable(let transform):
      guard let result = try transform(input as! Substring) else {
        return nil
      }
      assert(type(of: result) == resultType)
      return result
    }
  }

  func callAsFunction(_ input: Substring) throws -> Any? {
    switch closure {
    case .substringFailable(let transform):
      return try transform(input)
    case .substringNonfailable(let transform):
      return try transform(input)
    case .failable(let transform):
      return try transform(input)
    case .nonfailable(let transform):
      return try transform(input)
    }
  }

  public static func == (lhs: _CaptureTransform, rhs: _CaptureTransform) -> Bool {
    unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
      unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  public func hash(into hasher: inout Hasher) {
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  public var description: String {
    "<transform argument_type=\(argumentType) result_type=\(resultType)>"
  }
}

// MARK: AST wrapper types
//
// These wrapper types are required because even @_spi-marked public APIs can't
// include symbols from implementation-only dependencies.

extension _DSLTree._Node {
  func _addCaptures(
    to list: inout CaptureList,
    optionalNesting nesting: Int
  ) {
    let addOptional = nesting+1
    switch self {
    case let .orderedChoice(children):
      for child in children {
        child._addCaptures(to: &list, optionalNesting: addOptional)
      }

    case let .concatenation(children):
      for child in children {
        child._addCaptures(to: &list, optionalNesting: nesting)
      }

    case let .capture(name, _, child, transform):
      list.append(.init(
        name: name,
        type: transform?.resultType ?? child.wholeMatchType,
        optionalDepth: nesting, .fake))
      child._addCaptures(to: &list, optionalNesting: nesting)

    case let .nonCapturingGroup(kind, child):
      assert(!kind.ast.isCapturing)
      child._addCaptures(to: &list, optionalNesting: nesting)

    case let .conditional(cond, trueBranch, falseBranch):
      switch cond.ast {
      case .group(let g):
        AST.Node.group(g)._addCaptures(to: &list, optionalNesting: nesting)
      default:
        break
      }

      trueBranch._addCaptures(to: &list, optionalNesting: addOptional)
      falseBranch._addCaptures(to: &list, optionalNesting: addOptional)


    case let .quantification(amount, _, child):
      var optNesting = nesting
      if amount.ast.bounds.atLeast == 0 {
        optNesting += 1
      }
      child._addCaptures(to: &list, optionalNesting: optNesting)

    case let .regexLiteral(re):
      return re.ast._addCaptures(to: &list, optionalNesting: nesting)

    case let .absentFunction(abs):
      switch abs.ast.kind {
      case .expression(_, _, let child):
        child._addCaptures(to: &list, optionalNesting: nesting)
      case .clearer, .repeater, .stopper:
        break
      }

    case let .convertedRegexLiteral(n, _):
      return n._addCaptures(to: &list, optionalNesting: nesting)

    case .matcher:
      break

    case .customCharacterClass, .atom, .trivia, .empty,
        .quotedLiteral, .consumer, .characterPredicate:
      break
    }
  }

  /// Returns true if the node is output-forwarding, i.e. not defining its own
  /// output but forwarding its only child's output.
  var isOutputForwarding: Bool {
    switch self {
    case .nonCapturingGroup:
      return true
    case .orderedChoice, .concatenation, .capture,
         .conditional, .quantification, .customCharacterClass, .atom,
         .trivia, .empty, .quotedLiteral, .regexLiteral, .absentFunction,
         .convertedRegexLiteral, .consumer,
         .characterPredicate, .matcher:
      return false
    }
  }

  /// Returns the output-defining node, peering through any output-forwarding
  /// nodes.
  var outputDefiningNode: Self {
    if isOutputForwarding {
      assert(_children.count == 1)
      return _children[0].outputDefiningNode
    }
    return self
  }

  /// Returns the type of the whole match, i.e. `.0` element type of the output.
  var wholeMatchType: Any.Type {
    if case .matcher(let type, _) = outputDefiningNode {
      return type
    }
    return Substring.self
  }
}

extension _DSLTree {
  var captureList: CaptureList {
    var list = CaptureList()
    list.append(.init(type: root.wholeMatchType, optionalDepth: 0, .fake))
    root._addCaptures(to: &list, optionalNesting: 0)
    return list
  }

  /// Presents a wrapped version of `DSLTree.Node` that can provide an internal
  /// `_TreeNode` conformance.
  struct _Tree: _TreeNode {
    var node: _DSLTree._Node
    
    init(_ node: _DSLTree._Node) {
      self.node = node
    }
    
    var children: [_Tree]? {
      switch node {
        
      case let .orderedChoice(v): return v.map(_Tree.init)
      case let .concatenation(v): return v.map(_Tree.init)

      case let .convertedRegexLiteral(n, _):
        // Treat this transparently
        return _Tree(n).children

      case let .capture(_, _, n, _):        return [_Tree(n)]
      case let .nonCapturingGroup(_, n):    return [_Tree(n)]
      case let .quantification(_, _, n):    return [_Tree(n)]

      case let .conditional(_, t, f): return [_Tree(t), _Tree(f)]

      case .trivia, .empty, .quotedLiteral, .regexLiteral,
          .consumer, .matcher, .characterPredicate,
          .customCharacterClass, .atom:
        return []

      case let .absentFunction(abs):
        return abs.ast.children.map(\.dslTreeNode).map(_Tree.init)
      }
    }
  }

  public enum _AST {
    public struct _GroupKind {
      internal var ast: AST.Group.Kind
      
      public static var _atomicNonCapturing: Self {
        .init(ast: .atomicNonCapturing)
      }
      public static var _lookahead: Self {
        .init(ast: .lookahead)
      }
      public static var _negativeLookahead: Self {
        .init(ast: .negativeLookahead)
      }
    }

    public struct _ConditionKind {
      internal var ast: AST.Conditional.Condition.Kind
    }
    
    public struct _QuantificationKind {
      internal var ast: AST.Quantification.Kind
      
      public static var _eager: Self {
        .init(ast: .eager)
      }
      public static var _reluctant: Self {
        .init(ast: .reluctant)
      }
      public static var _possessive: Self {
        .init(ast: .possessive)
      }
    }
    
    public struct _QuantificationAmount {
      internal var ast: AST.Quantification.Amount
      
      public static var _zeroOrMore: Self {
        .init(ast: .zeroOrMore)
      }
      public static var _oneOrMore: Self {
        .init(ast: .oneOrMore)
      }
      public static var _zeroOrOne: Self {
        .init(ast: .zeroOrOne)
      }
      public static func _exactly(_ n: Int) -> Self {
        .init(ast: .exactly(.init(faking: n)))
      }
      public static func _nOrMore(_ n: Int) -> Self {
        .init(ast: .nOrMore(.init(faking: n)))
      }
      public static func _upToN(_ n: Int) -> Self {
        .init(ast: .upToN(.init(faking: n)))
      }
      public static func _range(_ lower: Int, _ upper: Int) -> Self {
        .init(ast: .range(.init(faking: lower), .init(faking: upper)))
      }
    }
    
    public struct _ASTNode {
      internal var ast: AST.Node
    }
    
    public struct _AbsentFunction {
      internal var ast: AST.AbsentFunction
    }
    
    public struct _AssertionKind {
      internal var ast: AST.Atom.AssertionKind
      
      public static func _startOfSubject(_ inverted: Bool = false) -> Self {
        .init(ast: .startOfSubject)
      }
      public static func _endOfSubjectBeforeNewline(_ inverted: Bool = false) -> Self {
        .init(ast: .endOfSubjectBeforeNewline)
      }
      public static func _endOfSubject(_ inverted: Bool = false) -> Self {
        .init(ast: .endOfSubject)
      }
      public static func _firstMatchingPositionInSubject(_ inverted: Bool = false) -> Self {
        .init(ast: .firstMatchingPositionInSubject)
      }
      public static func _textSegmentBoundary(_ inverted: Bool = false) -> Self {
        inverted
          ? .init(ast: .notTextSegment)
          : .init(ast: .textSegment)
      }
      public static func _startOfLine(_ inverted: Bool = false) -> Self {
        .init(ast: .startOfLine)
      }
      public static func _endOfLine(_ inverted: Bool = false) -> Self {
        .init(ast: .endOfLine)
      }
      public static func _wordBoundary(_ inverted: Bool = false) -> Self {
        inverted
          ? .init(ast: .notWordBoundary)
          : .init(ast: .wordBoundary)
      }
    }
    
    public struct _Reference {
      internal var ast: AST.Reference
    }
    
    public struct _MatchingOptionSequence {
      internal var ast: AST.MatchingOptionSequence
    }
    
    public struct _Atom {
      internal var ast: AST.Atom
    }
  }
}

extension _DSLTree._Atom {
  /// Returns a Boolean indicating whether the atom represents a pattern that's
  /// matchable, e.g. a character or a scalar, not representing a change of
  /// matching options or an assertion.
  var isMatchable: Bool {
    switch self {
    case .changeMatchingOptions, .assertion:
      return false
    case .char, .scalar, .any, .backreference, .symbolicReference, .unconverted:
      return true
    }
  }
}
