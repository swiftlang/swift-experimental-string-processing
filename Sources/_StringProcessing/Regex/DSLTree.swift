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

@_spi(RegexBuilder)
public struct DSLTree {
  var root: Node

  init(_ r: Node) {
    self.root = r
  }
}

extension DSLTree {
  indirect enum Node {
    /// Matches each node in order.
    ///
    ///     ... | ... | ...
    case orderedChoice([Node])

    /// Match each node in sequence.
    ///
    ///     ... ...
    case concatenation([Node])

    /// Captures the result of a subpattern.
    ///
    ///     (...), (?<name>...)
    case capture(
      name: String? = nil, reference: ReferenceID? = nil, Node,
      CaptureTransform? = nil)

    /// Matches a noncapturing subpattern.
    case nonCapturingGroup(_AST.GroupKind, Node)

    /// Marks all captures in a subpattern as ignored in strongly-typed output.
    case ignoreCapturesInTypedOutput(Node)
    case limitCaptureNesting(Node)

    // TODO: Consider splitting off grouped conditions, or have
    // our own kind

    /// Matches a choice of two nodes, based on a condition.
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

    /// Comments, non-semantic whitespace, and so on.
    // TODO: Do we want this? Could be interesting
    case trivia(String)

    // TODO: Probably some atoms, built-ins, etc.

    case empty

    case quotedLiteral(String)

    // TODO: What should we do here?
    ///
    /// TODO: Consider splitting off expression functions, or have our own kind
    case absentFunction(_AST.AbsentFunction)

    // MARK: - Extensibility points

    case consumer(_ConsumerInterface)

    case matcher(Any.Type, _MatcherInterface)

    // TODO: Would this just boil down to a consumer?
    case characterPredicate(_CharacterPredicateInterface)
  }
}

extension DSLTree {
  enum QuantificationKind {
    /// The default quantification kind, as set by options.
    case `default`
    /// An explicitly chosen kind, overriding any options.
    case explicit(_AST.QuantificationKind)
    /// A kind set via syntax, which can be affected by options.
    case syntax(_AST.QuantificationKind)
    
    var ast: AST.Quantification.Kind? {
      switch self {
      case .default: return nil
      case .explicit(let kind), .syntax(let kind):
        return kind.ast
      }
    }
  }
  
  @_spi(RegexBuilder)
  public struct CustomCharacterClass {
    var members: [Member]
    var isInverted: Bool
    
    var containsDot: Bool {
      members.contains { member in
        switch member {
        case .atom(.dot): return true
        case .custom(let ccc): return ccc.containsDot
        default:
          return false
        }
      }
    }
    
    func coalescingASCIIMembers(_ opts: MatchingOptions) -> CustomCharacterClass {
      var ascii: [Member] = []
      var nonAscii: [Member] = []
      for member in members {
        if member.asAsciiBitset(opts, false) != nil {
          ascii.append(member)
        } else {
          nonAscii.append(member)
        }
      }
      if ascii.isEmpty || nonAscii.isEmpty { return self }
      return CustomCharacterClass(members: [
        .custom(CustomCharacterClass(members: ascii)),
        .custom(CustomCharacterClass(members: nonAscii))
      ], isInverted: isInverted)
    }
    
    public init(members: [DSLTree.CustomCharacterClass.Member], isInverted: Bool = false) {
      self.members = members
      self.isInverted = isInverted
    }
    
    public static func generalCategory(_ category: Unicode.GeneralCategory) -> Self {
      let property = AST.Atom.CharacterProperty(.generalCategory(category.extendedGeneralCategory!), isInverted: false, isPOSIX: false)
      let astAtom = AST.Atom(.property(property), .fake)
      return .init(members: [.atom(.unconverted(.init(ast: astAtom)))])
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
      
      var isOnlyTrivia: Bool {
        switch self {
        case .custom(let ccc):
          return ccc.members.all(\.isOnlyTrivia)
        case .trivia:
          return true
        default:
          return false
        }
      }
    }
  }

  @_spi(RegexBuilder)
  public enum Atom {
    case char(Character)
    case scalar(Unicode.Scalar)

    /// Any character, including newlines.
    case any

    /// Any character, excluding newlines. This differs from '.', as it is not
    /// affected by single line mode.
    case anyNonNewline

    /// The DSL representation of '.' in a regex literal. This does not match
    /// newlines unless single line mode is enabled.
    case dot

    case characterClass(CharacterClass)
    case assertion(Assertion)
    case backreference(_AST.Reference)
    case symbolicReference(ReferenceID)

    case changeMatchingOptions(_AST.MatchingOptionSequence)

    case unconverted(_AST.Atom)
  }
}

extension DSLTree.Atom {
  @_spi(RegexBuilder)
  public enum Assertion: UInt64, Hashable {
    /// \A
    case startOfSubject = 0

    /// \Z
    case endOfSubjectBeforeNewline

    /// \z
    case endOfSubject

    /// \K
    case resetStartOfMatch

    /// \G
    case firstMatchingPositionInSubject

    /// \y
    case textSegment

    /// \Y
    case notTextSegment

    /// The DSL's Anchor.startOfLine, which matches the start of a line
    /// even if `anchorsMatchNewlines` is false.
    case startOfLine

    /// The DSL's Anchor.endOfLine, which matches the end of a line
    /// even if `anchorsMatchNewlines` is false.
    case endOfLine

    /// ^
    case caretAnchor

    /// $
    case dollarAnchor

    /// \b (from outside a custom character class)
    case wordBoundary

    /// \B
    case notWordBoundary
  }
  
  @_spi(RegexBuilder)
  public enum CharacterClass: Hashable {
    case digit
    case notDigit
    case horizontalWhitespace
    case notHorizontalWhitespace
    case newlineSequence
    case notNewline
    case whitespace
    case notWhitespace
    case verticalWhitespace
    case notVerticalWhitespace
    case word
    case notWord
    case anyGrapheme
    case anyUnicodeScalar
  }
}

extension DSLTree.Atom.CharacterClass {
  @_spi(RegexBuilder)
  public var inverted: DSLTree.Atom.CharacterClass? {
    switch self {
    case .anyGrapheme: return nil
    case .digit: return .notDigit
    case .notDigit: return .digit
    case .word: return .notWord
    case .notWord: return .word
    case .horizontalWhitespace: return .notHorizontalWhitespace
    case .notHorizontalWhitespace: return .horizontalWhitespace
    case .newlineSequence: return .notNewline
    case .notNewline: return .newlineSequence
    case .verticalWhitespace: return .notVerticalWhitespace
    case .notVerticalWhitespace: return .verticalWhitespace
    case .whitespace: return .notWhitespace
    case .notWhitespace: return .whitespace
    case .anyUnicodeScalar:
      fatalError("Unsupported")
    }
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
typealias _ConsumerInterface = (
  String, Range<String.Index>
) throws -> String.Index?

// Type producing consume
// TODO: better name
typealias _MatcherInterface = (
  String, String.Index, Range<String.Index>
) throws -> (String.Index, Any)?

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
  /// Indicates whether this node has at least one child node (among other
  /// associated values).
  var hasChildNodes: Bool {
    switch self {
    case .trivia, .empty, .quotedLiteral,
        .consumer, .matcher, .characterPredicate,
        .customCharacterClass, .atom:
      return false
      
    case .orderedChoice(let c), .concatenation(let c):
      return !c.isEmpty
      
    case .capture, .nonCapturingGroup,
        .quantification, .ignoreCapturesInTypedOutput, .limitCaptureNesting,
        .conditional:
      return true
      
    case .absentFunction(let abs):
      return !abs.ast.children.isEmpty
    }
  }
  
  @_spi(RegexBuilder)
  public var children: [DSLTree.Node] {
    switch self {
      
    case let .orderedChoice(v):   return v
    case let .concatenation(v):   return v
      
    case let .capture(_, _, n, _):        return [n]
    case let .nonCapturingGroup(_, n):    return [n]
    case let .quantification(_, _, n):    return [n]
    case let .ignoreCapturesInTypedOutput(n): return [n]
    case let .limitCaptureNesting(n):     return [n]
      
    case let .conditional(_, t, f): return [t,f]
      
    case .trivia, .empty, .quotedLiteral,
        .consumer, .matcher, .characterPredicate,
        .customCharacterClass, .atom:
      return []
      
    case let .absentFunction(abs):
      return abs.ast.children.map(\.dslTreeNode)
    }
  }
  
  public var coalescedChildren: [DSLTree.Node] {
    // Before converting a concatenation in a tree to list form, we need to
    // flatten out any nested concatenations, and coalesce any adjacent
    // characters and scalars, forming quoted literals of their contents,
    // over which we can perform grapheme breaking.

    func flatten(_ node: DSLTree.Node) -> [DSLTree.Node] {
      switch node {
      case .concatenation(let ch):
        return ch.flatMap(flatten)
      case .ignoreCapturesInTypedOutput(let n), .limitCaptureNesting(let n):
        return flatten(n)
      default:
        return [node]
      }
    }
    
    switch self {
    case let .orderedChoice(v):   return v
    case let .concatenation(v):
      let children = v
        .flatMap(flatten)
        .coalescing(with: "", into: DSLTree.Node.quotedLiteral) { str, node in
          switch node {
          case .atom(let a):
            guard let c = a.literalCharacterValue else { return false }
            str.append(c)
            return true
          case .quotedLiteral(let q):
            str += q
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

    case let .capture(_, _, n, _):        return [n]
    case let .nonCapturingGroup(_, n):    return [n]
    case let .quantification(_, _, n):    return [n]
    case let .ignoreCapturesInTypedOutput(n): return [n]
    case let .limitCaptureNesting(n):     return [n]

    case let .conditional(_, t, f): return [t,f]

    case .trivia, .empty, .quotedLiteral,
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
    nil
  }

  /// If this node is for a converted literal, look through it.
  var lookingThroughConvertedLiteral: Self {
    self
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
  /// Indicates whether this DSLTree contains any capture groups.
  var hasCapture: Bool {
    root.hasCapture
  }
}
extension DSLTree.Node {
  /// Indicates whether this DSLTree node contains any capture groups.
  var hasCapture: Bool {
    switch self {
    case .capture:
      return true
    default:
      return self.children.any(\.hasCapture)
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

  func appendingAlternationCase(
    _ newNode: DSLTree.Node
  ) -> DSLTree.Node {
    if case .orderedChoice(let components) = self {
      return .orderedChoice(components + [newNode])
    }
    return .orderedChoice([self, newNode])
  }
}

@_spi(RegexBuilder)
public struct ReferenceID: Hashable {
  private static var counter: Int = 0
  var base: Int

  public var _raw: Int {
    base
  }
  
  public init() {
    base = Self.counter
    Self.counter += 1
  }
  
  init(_ base: Int) {
    self.base = base
  }
}

struct CaptureTransform: Hashable, CustomStringConvertible {
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

  init<Argument, Result>(
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

  init<Argument, Result>(
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

  static func == (lhs: CaptureTransform, rhs: CaptureTransform) -> Bool {
    unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
      unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  func hash(into hasher: inout Hasher) {
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  var description: String {
    "<transform argument_type=\(argumentType) result_type=\(resultType)>"
  }
}

extension CaptureList.Builder {
  mutating func addCaptures(
    of node: DSLTree.Node, optionalNesting nesting: OptionalNesting, visibleInTypedOutput: Bool
  ) {
    switch node {
    case let .orderedChoice(children):
      for child in children {
        addCaptures(of: child, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)
      }

    case let .concatenation(children):
      for child in children {
        addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      }

    case let .capture(name, _, child, transform):
      captures.append(.init(
        name: name,
        type: transform?.resultType ?? child.wholeMatchType,
        optionalDepth: nesting.depth, visibleInTypedOutput: visibleInTypedOutput, .fake))
      addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)

    case let .nonCapturingGroup(kind, child):
      assert(!kind.ast.isCapturing)
      addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      
    case let .ignoreCapturesInTypedOutput(child):
      addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: false)

    case let .limitCaptureNesting(child):
      addCaptures(of: child, optionalNesting: nesting.disablingNesting, visibleInTypedOutput: visibleInTypedOutput)
      
    case let .conditional(cond, trueBranch, falseBranch):
      switch cond.ast {
      case .group(let g):
        addCaptures(of: .group(g), optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      default:
        break
      }

      addCaptures(of: trueBranch, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)
      addCaptures(of: falseBranch, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)

    case let .quantification(amount, _, child):
      var optNesting = nesting
      if amount.ast.bounds.atLeast == 0 {
        optNesting = optNesting.addingOptional
      }
      addCaptures(of: child, optionalNesting: optNesting, visibleInTypedOutput: visibleInTypedOutput)

    case let .absentFunction(abs):
      switch abs.ast.kind {
      case .expression(_, _, let child):
        addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      case .clearer, .repeater, .stopper:
        break
      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
      }

//    case let .convertedRegexLiteral(n, _):
//      // We disable nesting for converted AST trees, as literals do not nest
//      // captures. This includes literals nested in a DSL.
//      return addCaptures(of: n, optionalNesting: nesting.disablingNesting, visibleInTypedOutput: visibleInTypedOutput)
//
    case .matcher:
      break

    case .customCharacterClass, .atom, .trivia, .empty,
        .quotedLiteral, .consumer, .characterPredicate:
      break
    }
  }

  static func build(_ dsl: DSLTree) -> CaptureList {
    var builder = Self()
    builder.captures.append(
      .init(type: dsl.root.wholeMatchType, optionalDepth: 0, visibleInTypedOutput: true, .fake))
    builder.addCaptures(of: dsl.root, optionalNesting: .init(canNest: true), visibleInTypedOutput: true)
    return builder.captures
  }
}

extension DSLTree.Node {
  /// Returns true if the node is output-forwarding, i.e. not defining its own
  /// output but forwarding its only child's output.
  var isOutputForwarding: Bool {
    switch self {
    case .nonCapturingGroup, .ignoreCapturesInTypedOutput:
      return true
    case .orderedChoice, .concatenation, .capture,
         .conditional, .quantification, .customCharacterClass, .atom,
         .trivia, .empty, .quotedLiteral, .limitCaptureNesting,
         .consumer, .absentFunction,
         .characterPredicate, .matcher:
      return false
    }
  }

  /// Returns the output-defining node, peering through any output-forwarding
  /// nodes.
  var outputDefiningNode: Self {
    if isOutputForwarding {
      assert(children.count == 1)
      return children[0].outputDefiningNode
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

extension DSLTree.Node {
  /// Implementation for `canOnlyMatchAtStart`, which maintains the option
  /// state.
  ///
  /// For a given specific node, this method can return one of three values:
  ///
  /// - `true`: This node is guaranteed to match only at the start of a subject.
  /// - `false`: This node can match anywhere in the subject.
  /// - `nil`: This node is inconclusive about where it can match.
  ///
  /// In particular, non-required groups and option-setting groups are
  /// inconclusive about where they can match.
  private func _canOnlyMatchAtStartImpl(_ options: inout MatchingOptions) -> Bool? {
    switch self {
    // Defining cases
    case .atom(.assertion(.startOfSubject)):
      return true
    case .atom(.assertion(.caretAnchor)):
      return !options.anchorsMatchNewlines
      
    // Changing options doesn't determine `true`/`false`.
    case .atom(.changeMatchingOptions(let sequence)):
      options.apply(sequence.ast)
      return nil
      
    // Any other atom or consuming node returns `false`.
    case .atom, .customCharacterClass, .quotedLiteral:
      return false
      
    // Trivia/empty have no effect.
    case .trivia, .empty:
      return nil
      
    // In an alternation, all of its children must match only at start.
    case .orderedChoice(let children):
      return children.allSatisfy { $0._canOnlyMatchAtStartImpl(&options) == true }
      
    // In a concatenation, the first definitive child provides the answer.
    case .concatenation(let children):
      for child in children {
        if let result = child._canOnlyMatchAtStartImpl(&options) {
          return result
        }
      }
      return false

    // Groups (and other parent nodes) defer to the child.
    case .nonCapturingGroup(let kind, let child):
      // Don't let a negative lookahead affect this - need to continue to next sibling
      if kind.isNegativeLookahead {
        return nil
      }
      options.beginScope()
      defer { options.endScope() }
      if case .changeMatchingOptions(let sequence) = kind.ast {
        options.apply(sequence)
      }
      return child._canOnlyMatchAtStartImpl(&options)
    case .capture(_, _, let child, _):
      options.beginScope()
      defer { options.endScope() }
      return child._canOnlyMatchAtStartImpl(&options)
    case .ignoreCapturesInTypedOutput(let child), .limitCaptureNesting(let child):
      return child._canOnlyMatchAtStartImpl(&options)

    // A quantification that doesn't require its child to exist can still
    // allow a start-only match. (e.g. `/(foo)?^bar/`)
    case .quantification(let amount, _, let child):
      return amount.requiresAtLeastOne
        ? child._canOnlyMatchAtStartImpl(&options)
        : nil

    // For conditional nodes, both sides must require matching at start.
    case .conditional(_, let child1, let child2):
      return child1._canOnlyMatchAtStartImpl(&options) == true
        && child2._canOnlyMatchAtStartImpl(&options) == true

    // Extended behavior isn't known, so we return `false` for safety.
    case .consumer, .matcher, .characterPredicate, .absentFunction:
      return false
    }
  }
  
  /// Returns a Boolean value indicating whether the regex with this node as
  /// the root can _only_ match at the start of a subject.
  ///
  /// For example, these regexes can only match at the start of a subject:
  ///
  /// - `/^foo/`
  /// - `/(^foo|^bar)/` (both sides of the alternation start with `^`)
  ///
  /// These can match other places in a subject:
  ///
  /// - `/(^foo)?bar/` (`^` is in an optional group)
  /// - `/(^foo|bar)/` (only one side of the alternation starts with `^`)
  /// - `/(?m)^foo/` (`^` means "the start of a line" due to `(?m)`)
  internal func canOnlyMatchAtStart() -> Bool {
    var options = MatchingOptions()
    return _canOnlyMatchAtStartImpl(&options) ?? false
  }
}

// MARK: AST wrapper types
//
// These wrapper types are required because even @_spi-marked public APIs can't
// include symbols from implementation-only dependencies.

extension DSLTree {
  var captureList: CaptureList { .Builder.build(self) }

  /// Presents a wrapped version of `DSLTree.Node` that can provide an internal
  /// `_TreeNode` conformance.
  struct _Tree: _TreeNode {
    var node: DSLTree.Node
    
    init(_ node: DSLTree.Node) {
      self.node = node
    }
    
    var children: [_Tree]? {
      switch node {
        
      case let .orderedChoice(v): return v.map(_Tree.init)
      case let .concatenation(v): return v.map(_Tree.init)

      case let .capture(_, _, n, _):        return [_Tree(n)]
      case let .nonCapturingGroup(_, n):    return [_Tree(n)]
      case let .quantification(_, _, n):    return [_Tree(n)]
      case let .ignoreCapturesInTypedOutput(n): return [_Tree(n)]
      case let .limitCaptureNesting(n):
        // This is a transparent wrapper
        return _Tree(n).children

      case let .conditional(_, t, f): return [_Tree(t), _Tree(f)]

      case .trivia, .empty, .quotedLiteral,
          .consumer, .matcher, .characterPredicate,
          .customCharacterClass, .atom:
        return []

      case let .absentFunction(abs):
        return abs.ast.children.map(\.dslTreeNode).map(_Tree.init)
      }
    }
  }

  @_spi(RegexBuilder)
  public enum _AST {
    @_spi(RegexBuilder)
    public struct GroupKind {
      internal var ast: AST.Group.Kind
      
      public static var atomicNonCapturing: Self {
        .init(ast: .atomicNonCapturing)
      }
      public static var lookahead: Self {
        .init(ast: .lookahead)
      }
      public static var negativeLookahead: Self {
        .init(ast: .negativeLookahead)
      }
      
      internal var isNegativeLookahead: Bool {
        self.ast == .negativeLookahead
      }
    }

    @_spi(RegexBuilder)
    public struct ConditionKind {
      internal var ast: AST.Conditional.Condition.Kind
    }
    
    @_spi(RegexBuilder)
    public struct QuantificationKind {
      internal var ast: AST.Quantification.Kind
      
      public static var eager: Self {
        .init(ast: .eager)
      }
      public static var reluctant: Self {
        .init(ast: .reluctant)
      }
      public static var possessive: Self {
        .init(ast: .possessive)
      }
    }
    
    @_spi(RegexBuilder)
    public struct QuantificationAmount {
      internal var ast: AST.Quantification.Amount
      
      public static var zeroOrMore: Self {
        .init(ast: .zeroOrMore)
      }
      public static var oneOrMore: Self {
        .init(ast: .oneOrMore)
      }
      public static var zeroOrOne: Self {
        .init(ast: .zeroOrOne)
      }
      public static func exactly(_ n: Int) -> Self {
        .init(ast: .exactly(.init(n, at: .fake)))
      }
      public static func nOrMore(_ n: Int) -> Self {
        .init(ast: .nOrMore(.init(n, at: .fake)))
      }
      public static func upToN(_ n: Int) -> Self {
        .init(ast: .upToN(.init(n, at: .fake)))
      }
      public static func range(_ lower: Int, _ upper: Int) -> Self {
        .init(ast: .range(.init(lower, at: .fake), .init(upper, at: .fake)))
      }
      
      internal var requiresAtLeastOne: Bool {
        switch ast {
        case .zeroOrOne, .zeroOrMore, .upToN:
          return false
        case .oneOrMore:
          return true
        case .exactly(let num), .nOrMore(let num), .range(let num, _):
          return num.value.map { $0 > 0 } ?? false
        #if RESILIENT_LIBRARIES
        @unknown default:
          fatalError()
        #endif
        }
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
    
    @_spi(RegexBuilder)
    public struct Reference {
      internal var ast: AST.Reference
    }
    
    @_spi(RegexBuilder)
    public struct MatchingOptionSequence {
      internal var ast: AST.MatchingOptionSequence
    }
    
    public struct Atom {
      internal var ast: AST.Atom
    }
  }
}

extension DSLTree.Atom {
  /// Returns a Boolean indicating whether the atom represents a pattern that's
  /// matchable, e.g. a character or a scalar, not representing a change of
  /// matching options or an assertion.
  var isMatchable: Bool {
    switch self {
    case .changeMatchingOptions, .assertion:
      return false
    case .char, .scalar, .any, .anyNonNewline, .dot, .backreference,
        .symbolicReference, .unconverted, .characterClass:
      return true
    }
  }
}

extension DSLTree.Node {
  // Individual public API functions are in the generated Variadics.swift file.
  /// Generates a DSL tree node for a repeated range of the given node.
  @available(SwiftStdlib 5.7, *)
  static func repeating(
    _ range: Range<Int>,
    _ behavior: RegexRepetitionBehavior?,
    _ node: DSLTree.Node
  ) -> DSLTree.Node {
    // TODO: Throw these as errors
    precondition(range.lowerBound >= 0, "Cannot specify a negative lower bound")
    precondition(!range.isEmpty, "Cannot specify an empty range")

    let kind: DSLTree.QuantificationKind = behavior
      .map { .explicit($0.dslTreeKind) } ?? .default

    // The upper bound needs adjusting down as
    // `.quantification` expects a closed range.
    let lower = range.lowerBound
    let upperInclusive = range.upperBound - 1

    // Unbounded cases
    if range.upperBound == Int.max {
      switch lower {
      case 0: // 0...
        return .quantification(.zeroOrMore, kind, node)
      case 1: // 1...
        return .quantification(.oneOrMore, kind, node)
      default: // n...
        return .quantification(.nOrMore(lower), kind, node)
      }
    }
    if range.count == 1 {
      // ..<1 or ...0 or any range with count == 1
      // Note: `behavior` is ignored in this case
      return .quantification(.exactly(lower), .default, node)
    }
    switch lower {
    case 0: // 0..<n or 0...n or ..<n or ...n
      return .quantification(.upToN(upperInclusive), kind, node)
    default:
      return .quantification(.range(lower, upperInclusive), kind, node)
    }
  }
}
