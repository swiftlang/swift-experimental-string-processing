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

  init(_ r: Node) {
    self.root = r
  }
}

extension DSLTree {
  @_spi(RegexBuilder)
  public indirect enum Node {
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
      name: String? = nil, reference: ReferenceID? = nil, Node)

    /// Matches a noncapturing subpattern.
    case nonCapturingGroup(_AST.GroupKind, Node)

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

    /// An embedded literal.
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
    
    public static func generalCategory(_ category: Unicode.GeneralCategory) -> Self {
      let property = AST.Atom.CharacterProperty(.generalCategory(category.extendedGeneralCategory!), isInverted: false, isPOSIX: false)
      let astAtom = AST.Atom(.property(property), .fake)
      return .init(members: [.atom(.unconverted(.init(ast: astAtom)))])
    }

    public static func binaryProperty(
      _ property: KeyPath<UnicodeScalar.Properties, Bool>,
      value: Bool
    ) -> Self {
      let binProp: Unicode.BinaryProperty
      switch property {
      case \.isAlphabetic: binProp = .alphabetic
      case \.isASCIIHexDigit: binProp = .asciiHexDigit
      case \.isBidiControl: binProp = .bidiControl
      case \.isBidiMirrored: binProp = .bidiMirrored
      case \.isCased: binProp = .cased
//      case \.compositionExclusion: binProp = .compositionExclusion
      case \.isCaseIgnorable: binProp = .caseIgnorable
      case \.changesWhenCaseFolded: binProp = .changesWhenCasefolded
      case \.changesWhenCaseMapped: binProp = .changesWhenCasemapped
      case \.changesWhenNFKCCaseFolded: binProp = .changesWhenNFKCCasefolded
      case \.changesWhenLowercased: binProp = .changesWhenLowercased
      case \.changesWhenTitlecased: binProp = .changesWhenTitlecased
      case \.changesWhenUppercased: binProp = .changesWhenUppercased
      case \.isDash: binProp = .dash
      case \.isDefaultIgnorableCodePoint: binProp = .defaultIgnorableCodePoint
      case \.isDeprecated: binProp = .deprecated
      case \.isDiacritic: binProp = .diacratic
      case \.isExtender: binProp = .extender
//      case \.extendedPictographic: binProp = .extendedPictographic
      case \.isFullCompositionExclusion: binProp = .fullCompositionExclusion
      case \.isGraphemeBase: binProp = .graphemeBase
      case \.isGraphemeExtend: binProp = .graphemeExtended
//      case \.graphemeLink: binProp = .graphemeLink
      case \.isHexDigit: binProp = .hexDigit
//      case \.hyphen: binProp = .hyphen
      case \.isIDContinue: binProp = .idContinue
      case \.isIdeographic: binProp = .ideographic
      case \.isIDStart: binProp = .idStart
      case \.isIDSBinaryOperator: binProp = .idsBinaryOperator
      case \.isIDSTrinaryOperator: binProp = .idsTrinaryOperator
      case \.isJoinControl: binProp = .joinControl
      case \.isLogicalOrderException: binProp = .logicalOrderException
      case \.isLowercase: binProp = .lowercase
      case \.isMath: binProp = .math
      case \.isNoncharacterCodePoint: binProp = .noncharacterCodePoint
//      case \.otherAlphabetic: binProp = .otherAlphabetic
//      case \.otherDefaultIgnorableCodePoint: binProp = .otherDefaultIgnorableCodePoint
//      case \.otherGraphemeExtended: binProp = .otherGraphemeExtended
//      case \.otherIDContinue: binProp = .otherIDContinue
//      case \.otherIDStart: binProp = .otherIDStart
//      case \.otherLowercase: binProp = .otherLowercase
//      case \.otherMath: binProp = .otherMath
//      case \.otherUppercase: binProp = .otherUppercase
      case \.isPatternSyntax: binProp = .patternSyntax
      case \.isPatternWhitespace: binProp = .patternWhitespace
//      case \.prependedConcatenationMark: binProp = .prependedConcatenationMark
      case \.isQuotationMark: binProp = .quotationMark
      case \.isRadical: binProp = .radical
//      case \.regionalIndicator: binProp = .regionalIndicator
      case \.isSoftDotted: binProp = .softDotted
      case \.isSentenceTerminal: binProp = .sentenceTerminal
      case \.isTerminalPunctuation: binProp = .terminalPunctuation
      case \.isUnifiedIdeograph: binProp = .unifiedIdiograph
      case \.isUppercase: binProp = .uppercase
      case \.isVariationSelector: binProp = .variationSelector
      case \.isWhitespace: binProp = .whitespace
      case \.isXIDContinue: binProp = .xidContinue
      case \.isXIDStart: binProp = .xidStart
//      case \.expandsOnNFC: binProp = .expandsOnNFC
//      case \.expandsOnNFD: binProp = .expandsOnNFD
//      case \.expandsOnNFKC: binProp = .expandsOnNFKC
//      case \.expandsOnNFKD: binProp = .expandsOnNFKD
      default:
        if #available(macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1, *) {
          // FIXME: Other platforms
          switch property {
          case \.isEmojiModifierBase: binProp = .emojiModifierBase
    //      case \.emojiComponent: binProp = .emojiComponent
          case \.isEmojiModifier: binProp = .emojiModifier
          case \.isEmoji: binProp = .emoji
          case \.isEmojiPresentation: binProp = .emojiPresentation
          default:
            fatalError()
          }
        } else {
          fatalError()
        }
      }
      
      let atomProperty = AST.Atom.CharacterProperty(.binary(binProp, value: value), isInverted: false, isPOSIX: false)
      let astAtom = AST.Atom(.property(atomProperty), .fake)
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
    }
  }

  @_spi(RegexBuilder)
  public enum Atom {
    case char(Character)
    case scalar(Unicode.Scalar)
    case any

    case assertion(_AST.AssertionKind)
    case backreference(_AST.Reference)
    case symbolicReference(ReferenceID)

    case changeMatchingOptions(_AST.MatchingOptionSequence)

    case unconverted(_AST.Atom)
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

extension DSLTree.Node {
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

extension DSLTree.Node {
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

    case let .capture(name, _, child):
      list.append(.init(
        name: name,
        type: child.valueCaptureType?.base,
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

    case .transform(_, let child):
      child._addCaptures(to: &list, optionalNesting: nesting)

    case .customCharacterClass, .atom, .trivia, .empty,
        .quotedLiteral, .consumer, .characterPredicate:
      break
    }
  }

  var _captureList: CaptureList {
    var list = CaptureList()
    self._addCaptures(to: &list, optionalNesting: 0)
    return list
  }
}

extension DSLTree {
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

      case let .convertedRegexLiteral(n, _):
        // Treat this transparently
        return _Tree(n).children

      case let .capture(_, _, n):           return [_Tree(n)]
      case let .nonCapturingGroup(_, n):    return [_Tree(n)]
      case let .transform(_, n):            return [_Tree(n)]
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
        .init(ast: .exactly(.init(faking: n)))
      }
      public static func nOrMore(_ n: Int) -> Self {
        .init(ast: .nOrMore(.init(faking: n)))
      }
      public static func upToN(_ n: Int) -> Self {
        .init(ast: .upToN(.init(faking: n)))
      }
      public static func range(_ lower: Int, _ upper: Int) -> Self {
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
    
    @_spi(RegexBuilder)
    public struct AssertionKind {
      internal var ast: AST.Atom.AssertionKind
      
      public static func startOfSubject(_ inverted: Bool = false) -> Self {
        .init(ast: .startOfSubject)
      }
      public static func endOfSubjectBeforeNewline(_ inverted: Bool = false) -> Self {
        .init(ast: .endOfSubjectBeforeNewline)
      }
      public static func endOfSubject(_ inverted: Bool = false) -> Self {
        .init(ast: .endOfSubject)
      }
      public static func firstMatchingPositionInSubject(_ inverted: Bool = false) -> Self {
        .init(ast: .firstMatchingPositionInSubject)
      }
      public static func textSegmentBoundary(_ inverted: Bool = false) -> Self {
        inverted
          ? .init(ast: .notTextSegment)
          : .init(ast: .textSegment)
      }
      public static func startOfLine(_ inverted: Bool = false) -> Self {
        .init(ast: .startOfLine)
      }
      public static func endOfLine(_ inverted: Bool = false) -> Self {
        .init(ast: .endOfLine)
      }
      public static func wordBoundary(_ inverted: Bool = false) -> Self {
        inverted
          ? .init(ast: .notWordBoundary)
          : .init(ast: .wordBoundary)
      }
    }
    
    @_spi(RegexBuilder)
    public struct Reference {
      internal var ast: AST.Reference
    }
    
    @_spi(RegexBuilder)
    public struct MatchingOptionSequence {
      internal var ast: AST.MatchingOptionSequence
    }
    
    @_spi(RegexBuilder)
    public struct Atom {
      internal var ast: AST.Atom
    }
  }
}
