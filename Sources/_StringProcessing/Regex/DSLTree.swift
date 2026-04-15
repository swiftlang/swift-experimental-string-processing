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
    case orderedChoice(Int)

    /// Match each node in sequence.
    ///
    ///     ... ...
    case concatenation(Int)

    /// Captures the result of a subpattern.
    ///
    ///     (...), (?<name>...)
    case capture(
      name: String? = nil, reference: ReferenceID? = nil,
      CaptureTransform? = nil)

    /// Matches a noncapturing subpattern.
    case nonCapturingGroup(_AST.GroupKind)

    /// Marks all captures in a subpattern as ignored in strongly-typed output.
    case ignoreCapturesInTypedOutput
    case limitCaptureNesting

    // TODO: Consider splitting off grouped conditions, or have
    // our own kind

    /// Matches a choice of two nodes, based on a condition.
    ///
    ///     (?(cond) true-branch | false-branch)
    ///
    case conditional(_AST.ConditionKind)

    case quantification(
      _AST.QuantificationAmount,
      QuantificationKind)

    case customCharacterClass(CustomCharacterClass)

    case atom(Atom)

    /// Comments, non-semantic whitespace, and so on.
    // TODO: Do we want this? Could be interesting
    case trivia(String)

    // TODO: Probably some atoms, built-ins, etc.

    case empty

    case quotedLiteral(String, display: String?)

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
  struct QuantificationKind {
    var quantificationKind: _AST.QuantificationKind?
    var isExplicit: Bool
    var canAutoPossessify: Bool?
    
    /// The default quantification kind, as set by options.
    static var `default`: Self {
      .init(quantificationKind: nil, isExplicit: false, canAutoPossessify: nil)
    }
    
    /// An explicitly chosen kind, overriding any options.
    static func explicit(_ kind: _AST.QuantificationKind) -> Self {
      .init(quantificationKind: kind, isExplicit: true, canAutoPossessify: nil)
    }

    /// A kind set via syntax, which can be affected by options.
    static func syntax(_ kind: _AST.QuantificationKind) -> Self {
      .init(quantificationKind: kind, isExplicit: false, canAutoPossessify: nil)
    }
    
    var ast: AST.Quantification.Kind? {
      quantificationKind?.ast
    }
    
    func applying(options: MatchingOptions) -> AST.Quantification.Kind {
      guard let kind = quantificationKind?.ast else {
        return options.defaultQuantificationKind
      }
      return if isExplicit {
        kind
      } else {
        kind.applying(options)
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

extension DSLTree.Node {
  var literalStringValue: String? {
    switch self {
    case .atom(let a):   return a.literalCharacterValue.map(String.init)
    case .quotedLiteral(let s, _): return s
    default: return nil
    }
  }

  var literalDisplayValue: String? {
    switch self {
    case .atom(let a):
      guard let c = a.literalCharacterValue else { return nil }
      return String(c)._escaped
    case .quotedLiteral(_, display: let d):
      return d
    default: return nil
    }
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
    in list: inout ArraySlice<DSLTree.Node>, optionalNesting nesting: OptionalNesting, visibleInTypedOutput: Bool
  ) {
    guard let node = list.popFirst() else { return }
    switch node {
    case let .orderedChoice(count):
      for _ in 0..<count {
        addCaptures(in: &list, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)
      }

    case let .concatenation(count):
      for _ in 0..<count {
        addCaptures(in: &list, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      }

    case let .capture(name, _, transform):
      captures.append(.init(
        name: name,
        type: transform?.resultType ?? list.wholeMatchType,
        optionalDepth: nesting.depth, visibleInTypedOutput: visibleInTypedOutput, .fake))
      addCaptures(in: &list, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)

    case let .nonCapturingGroup(kind):
      assert(!kind.ast.isCapturing)
      addCaptures(in: &list, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      
    case .ignoreCapturesInTypedOutput:
      addCaptures(in: &list, optionalNesting: nesting, visibleInTypedOutput: false)

    case .limitCaptureNesting:
      addCaptures(in: &list, optionalNesting: nesting.disablingNesting, visibleInTypedOutput: visibleInTypedOutput)
      
    case let .conditional(cond):
      switch cond.ast {
      case .group:
        addCaptures(in: &list, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      default:
        break
      }

      addCaptures(in: &list, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)
      addCaptures(in: &list, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)

    case let .quantification(amount, _):
      var optNesting = nesting
      if amount.ast.bounds.atLeast == 0 {
        optNesting = optNesting.addingOptional
      }
      addCaptures(in: &list, optionalNesting: optNesting, visibleInTypedOutput: visibleInTypedOutput)

    case let .absentFunction(abs):
      switch abs.ast.kind {
      case .expression(_, _, _):
        addCaptures(in: &list, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      case .clearer, .repeater, .stopper:
        break
      #if RESILIENT_LIBRARIES
      @unknown default:
        fatalError()
      #endif
      }

    case .matcher:
      break

    case .customCharacterClass, .atom, .trivia, .empty,
        .quotedLiteral, .consumer, .characterPredicate:
      break
    }
  }

  static func build(_ dsl: DSLList) -> CaptureList {
    var builder = Self()
    builder.captures.append(
      .init(type: dsl.wholeMatchType, optionalDepth: 0, visibleInTypedOutput: true, .fake))
    var nodes = dsl.nodes[...]
    builder.addCaptures(in: &nodes, optionalNesting: .init(canNest: true), visibleInTypedOutput: true)
    return builder.captures
  }
}

extension DSLList {
  /// Returns the type of the whole match, i.e. `.0` element type of the output.
  var wholeMatchType: Any.Type {
    nodes.wholeMatchType
  }
}

extension Sequence<DSLTree.Node> {
  var wholeMatchType: Any.Type {
  Loop:
    for node in self {
      switch node {
      case .nonCapturingGroup, .ignoreCapturesInTypedOutput:
        continue Loop
      case .matcher(let type, _):
        return type
      default:
        break Loop
      }
    }
    return Substring.self
  }
}

// MARK: Required first and last atoms

private func _requiredAtomImpl(_ list: inout ArraySlice<DSLTree.Node>) -> DSLTree.Atom?? {
  guard let node = list.popFirst() else {
    return nil
  }
  switch node {
  case .atom(let atom):
    return switch atom {
    case .changeMatchingOptions:
      nil
    default:
      atom
    }

  // In a concatenation, the first definitive child provides the answer.
  case .concatenation(let count):
    for _ in 0..<count {
      if let result = _requiredAtomImpl(&list) {
        return result
      }
    }
    return nil

  // For a quoted literal, we can look at the first char
  // TODO: matching semantics???
  case .quotedLiteral(let str, _):
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

  // Groups (and other parent nodes) defer to the child.
  case .nonCapturingGroup, .capture,
      .ignoreCapturesInTypedOutput,
      .limitCaptureNesting:
    return _requiredAtomImpl(&list)

  // A quantification that doesn't require its child to exist can still
  // allow a start-only match. (e.g. `/(foo)?^bar/`)
  case .quantification(let amount, _):
    return amount.requiresAtLeastOne
      ? _requiredAtomImpl(&list)
      : .some(nil)

  // Extended behavior isn't known, so we return `false` for safety.
  case .consumer, .matcher, .characterPredicate, .absentFunction:
    return .some(nil)
  }
}

internal func requiredFirstAtom(_ list: inout ArraySlice<DSLTree.Node>) -> DSLTree.Atom? {
  _requiredAtomImpl(&list) ?? nil
}

// MARK: AST wrapper types
//
// These wrapper types are required because even @_spi-marked public APIs can't
// include symbols from implementation-only dependencies.

extension DSLTree {
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
      
      internal var isChangeMatchingOptions: Bool {
        if case .changeMatchingOptions = ast {
          return true
        } else {
          return false
        }
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
    _ behavior: RegexRepetitionBehavior?
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
        return .quantification(.zeroOrMore, kind)
      case 1: // 1...
        return .quantification(.oneOrMore, kind)
      default: // n...
        return .quantification(.nOrMore(lower), kind)
      }
    }
    if range.count == 1 {
      // ..<1 or ...0 or any range with count == 1
      // Note: `behavior` is ignored in this case
      return .quantification(.exactly(lower), .default)
    }
    switch lower {
    case 0: // 0..<n or 0...n or ..<n or ...n
      return .quantification(.upToN(upperInclusive), kind)
    default:
      return .quantification(.range(lower, upperInclusive), kind)
    }
  }
}
