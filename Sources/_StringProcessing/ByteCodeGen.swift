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

@_spi(_Unicode)
import Swift

internal import _RegexParser

extension Compiler {
  struct ByteCodeGen {
    var options: MatchingOptions
    var builder = MEProgram.Builder()
    /// A Boolean indicating whether the first matchable atom has been emitted.
    /// This is used to determine whether to apply initial options.
    var hasEmittedFirstMatchableAtom = false

    private let compileOptions: _CompileOptions
    internal var optimizationsEnabled: Bool {
      !compileOptions.contains(.disableOptimizations)
    }

    init(
      options: MatchingOptions,
      compileOptions: _CompileOptions,
      captureList: CaptureList
    ) {
      self.options = options
      self.compileOptions = compileOptions
      self.builder.captureList = captureList
      self.builder.enableTracing = compileOptions.contains(.enableTracing)
      self.builder.enableMetrics = compileOptions.contains(.enableMetrics)
    }
  }
}

extension Compiler.ByteCodeGen {
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
    // If the whole regex is a matcher, then the whole-match value
    // is the constructed value. Denote that the current value
    // register is the processor's value output.
    switch root {
    case .matcher:
      builder.denoteCurrentValueIsWholeMatchValue()
    default:
      break
    }

    try emitNode(root)

    builder.canOnlyMatchAtStart = root.canOnlyMatchAtStart()
    builder.buildAccept()
    return try builder.assemble()
  }
}

extension Compiler.ByteCodeGen {
  mutating func emitAtom(_ a: DSLTree.Atom) throws {
    defer {
      if a.isMatchable {
        hasEmittedFirstMatchableAtom = true
      }
    }
    switch a {
    case .any:
      emitAny()

    case .anyNonNewline:
      emitAnyNonNewline()

    case .dot:
      try emitDot()

    case let .char(c):
      emitCharacter(c)

    case let .scalar(s):
      if options.semanticLevel == .graphemeCluster {
        emitCharacter(Character(s))
      } else {
        emitMatchScalar(s)
      }

    case let .characterClass(cc):
      emitCharacterClass(cc)

    case let .assertion(kind):
      try emitAssertion(kind)

    case let .backreference(ref):
      try emitBackreference(ref.ast)

    case let .symbolicReference(id):
      builder.buildUnresolvedReference(
        id: id, isScalarMode: options.semanticLevel == .unicodeScalar)

    case let .changeMatchingOptions(optionSequence):
      if !hasEmittedFirstMatchableAtom {
        builder.initialOptions.apply(optionSequence.ast)
      }
      options.apply(optionSequence.ast)

    case let .unconverted(astAtom):
      if let consumer = try astAtom.ast.generateConsumer(options) {
        builder.buildConsume(by: consumer)
      } else {
        throw Unsupported("\(astAtom.ast._patternBase)")
      }
    }
  }

  mutating func emitQuotedLiteral(_ s: String) {
    // ASCII is normalization-invariant, so is the safe subset for
    // us to optimize
    if optimizationsEnabled,
       !options.usesCanonicalEquivalence || s.utf8.allSatisfy(\._isASCII),
       !s.isEmpty
    {

      // TODO: Make an optimizations configuration struct, where
      // we can enable/disable specific optimizations and change
      // thresholds
      let longThreshold = 5

      // Longer content will be matched against UTF-8 in contiguous
      // memory
      //
      // TODO: case-insensitive variant (just add/subtract from
      // ASCII value)
      if s.utf8.count >= longThreshold, !options.isCaseInsensitive {
        let boundaryCheck = options.semanticLevel == .graphemeCluster
        builder.buildMatchUTF8(Array(s.utf8), boundaryCheck: boundaryCheck)
        return
      }
    }

    guard options.semanticLevel == .graphemeCluster else {
      for char in s {
        for scalar in char.unicodeScalars {
          emitMatchScalar(scalar)
        }
      }
      return
    }

    // Fast path for eliding boundary checks for an all ascii quoted literal
    if optimizationsEnabled && s.allSatisfy(\.isASCII) && !s.isEmpty {
      let lastIdx = s.unicodeScalars.indices.last!
      for idx in s.unicodeScalars.indices {
        let boundaryCheck = idx == lastIdx
        let scalar = s.unicodeScalars[idx]
        if options.isCaseInsensitive && scalar.properties.isCased {
          builder.buildMatchScalarCaseInsensitive(scalar, boundaryCheck: boundaryCheck)
        } else {
          builder.buildMatchScalar(scalar, boundaryCheck: boundaryCheck)
        }
      }
      return
    }

    for c in s { emitCharacter(c) }
  }

  mutating func emitBackreference(
    _ ref: AST.Reference
  ) throws {
    if ref.recursesWholePattern {
      // TODO: A recursive call isn't a backreference, but
      // we could in theory match the whole match so far...
      throw Unsupported("Backreference kind: \(ref)")
    }

    switch ref.kind {
    case .absolute(let n):
      guard let i = n.value else {
        throw Unreachable("Expected a value")
      }
      let cap = builder.captureRegister(forBackreference: i)
      builder.buildBackreference(
        cap, isScalarMode: options.semanticLevel == .unicodeScalar)
    case .named(let name):
      try builder.buildNamedReference(
        name, isScalarMode: options.semanticLevel == .unicodeScalar)
    case .relative:
      throw Unsupported("Backreference kind: \(ref)")
    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }
  }

  mutating func emitAssertion(
    _ kind: DSLTree.Atom.Assertion
  ) throws {
    if kind == .resetStartOfMatch {
      throw Unsupported(#"\K (reset/keep assertion)"#)
    }
    builder.buildAssert(
      by: kind,
      options.anchorsMatchNewlines,
      options.usesSimpleUnicodeBoundaries,
      options.usesASCIIWord,
      options.semanticLevel)
  }

  mutating func emitCharacterClass(_ cc: DSLTree.Atom.CharacterClass) {
    builder.buildMatchBuiltin(model: cc.asRuntimeModel(options))
  }

  mutating func emitMatchScalar(_ s: UnicodeScalar) {
    assert(options.semanticLevel == .unicodeScalar)
    if options.isCaseInsensitive && s.properties.isCased {
      builder.buildMatchScalarCaseInsensitive(s, boundaryCheck: false)
    } else {
      builder.buildMatchScalar(s, boundaryCheck: false)
    }
  }
  
  mutating func emitCharacter(_ c: Character) {
    // Unicode scalar mode matches the specific scalars that comprise a character
    if options.semanticLevel == .unicodeScalar {
      for scalar in c.unicodeScalars {
        emitMatchScalar(scalar)
      }
      return
    }
    
    if options.isCaseInsensitive && c.isCased {
      if optimizationsEnabled && c.isASCII {
        // c.isCased ensures that c is not CR-LF,
        // so we know that c is a single scalar
        assert(c.unicodeScalars.count == 1)
        builder.buildMatchScalarCaseInsensitive(
          c.unicodeScalars.last!,
          boundaryCheck: true)
      } else {
        builder.buildMatch(c, isCaseInsensitive: true)
      }
      return
    }
    
    if optimizationsEnabled && c.isASCII {
      let lastIdx = c.unicodeScalars.indices.last!
      for idx in c.unicodeScalars.indices {
        builder.buildMatchScalar(c.unicodeScalars[idx], boundaryCheck: idx == lastIdx)
      }
      return
    }
      
    builder.buildMatch(c, isCaseInsensitive: false)
  }

  mutating func emitAny() {
    switch options.semanticLevel {
    case .graphemeCluster:
      builder.buildAdvance(1)
    case .unicodeScalar:
      builder.buildAdvanceUnicodeScalar(1)
    }
  }

  mutating func emitAnyNonNewline() {
    switch options.semanticLevel {
    case .graphemeCluster:
      builder.buildConsumeNonNewline()
    case .unicodeScalar:
      builder.buildConsumeScalarNonNewline()
    }
  }

  mutating func emitDot() throws {
    if options.dotMatchesNewline {
      if options.usesNSRECompatibleDot {
        try emitAlternation([
          .atom(.characterClass(.newlineSequence)),
          .atom(.anyNonNewline)])
      } else {
        emitAny()
      }
    } else {
      emitAnyNonNewline()
    }
  }

  mutating func emitAlternationGen<C: BidirectionalCollection>(
    _ elements: C,
    withBacktracking: Bool,
    _ body: (inout Compiler.ByteCodeGen, C.Element) throws -> Void
  ) rethrows {
    // Alternation: p0 | p1 | ... | pn
    //     save next_p1
    //     <code for p0>
    //     branch done
    //   next_p1:
    //     save next_p2
    //     <code for p1>
    //     branch done
    //   next_p2:
    //     save next_p...
    //     <code for p2>
    //     branch done
    //   ...
    //   next_pn:
    //     <code for pn>
    //   done:
    let done = builder.makeAddress()
    for element in elements.dropLast() {
      let next = builder.makeAddress()
      builder.buildSave(next)
      try body(&self, element)
      if !withBacktracking {
        builder.buildClear()
      }
      builder.buildBranch(to: done)
      builder.label(next)
    }
    try body(&self, elements.last!)
    builder.label(done)
  }
  
  mutating func emitAlternation(
    _ children: [DSLTree.Node]
  ) throws {
    try emitAlternationGen(children, withBacktracking: true) {
      try $0.emitNode($1)
    }
  }

  mutating func emitConcatenationComponent(
    _ node: DSLTree.Node
  ) throws {
    // TODO: Should we do anything special since we can
    // be glueing sub-grapheme components together?
    try emitNode(node)
  }

  mutating func emitPositiveLookahead(_ child: DSLTree.Node) throws {
    /*
      save(restoringAt: success)
      save(restoringAt: intercept)
      <sub-pattern>    // failure restores at intercept
      clearThrough(intercept)       // remove intercept and any leftovers from <sub-pattern>
     fail(preservingCaptures: true) // ->success
    intercept:
      clearSavePoint   // remove success
      fail             // propagate failure
    success:
      ...
    */
    let intercept = builder.makeAddress()
    let success = builder.makeAddress()

    builder.buildSave(success)
    builder.buildSave(intercept)
    try emitNode(child)
    builder.buildClearThrough(intercept)
    builder.buildFail(preservingCaptures: true) // Lookahead succeeds here

    builder.label(intercept)
    builder.buildClear()
    builder.buildFail()

    builder.label(success)
  }
  
  mutating func emitNegativeLookahead(_ child: DSLTree.Node) throws {
    /*
      save(restoringAt: success)
      save(restoringAt: intercept)
      <sub-pattern>    // failure restores at intercept
      clearThrough(intercept) // remove intercept and any leftovers from <sub-pattern>
      clearSavePoint   // remove success
      fail             // propagate failure
    intercept:
      fail             // ->success
    success:
      ...
    */
    let intercept = builder.makeAddress()
    let success = builder.makeAddress()

    builder.buildSave(success)
    builder.buildSave(intercept)
    try emitNode(child)
    builder.buildClearThrough(intercept)
    builder.buildClear()
    builder.buildFail()

    builder.label(intercept)
    builder.buildFail()

    builder.label(success)
  }
  
  mutating func emitLookaround(
    _ kind: (forwards: Bool, positive: Bool),
    _ child: DSLTree.Node
  ) throws {
    guard kind.forwards else {
      throw Unsupported("backwards assertions")
    }
    if kind.positive {
      try emitPositiveLookahead(child)
    } else {
      try emitNegativeLookahead(child)
    }
  }

  mutating func emitAtomicNoncapturingGroup(
    _ child: DSLTree.Node
  ) throws {
    /*
      save(continuingAt: success)
      save(restoringAt: intercept)
      <sub-pattern>    // failure restores at intercept
      clearThrough(intercept)        // remove intercept and any leftovers from <sub-pattern>
      fail(preservingCaptures: true) // ->success
    intercept:
      clearSavePoint   // remove success
      fail             // propagate failure
    success:
      ...
    */

    let intercept = builder.makeAddress()
    let success = builder.makeAddress()

    builder.buildSaveAddress(success)
    builder.buildSave(intercept)
    try emitNode(child)
    builder.buildClearThrough(intercept)
    builder.buildFail(preservingCaptures: true) // Atomic group succeeds here

    builder.label(intercept)
    builder.buildClear()
    builder.buildFail()

    builder.label(success)
  }

  mutating func emitMatcher(
    _ matcher: @escaping _MatcherInterface
  ) -> ValueRegister {

    // TODO: Consider emitting consumer interface if
    // not captured. This may mean we should store
    // an existential instead of a closure...

    let matcher = builder.makeMatcherFunction { input, start, range in
      try matcher(input, start, range)
    }

    let valReg = builder.makeValueRegister()
    builder.buildMatcher(matcher, into: valReg)
    return valReg
  }

  mutating func emitNoncapturingGroup(
    _ kind: AST.Group.Kind,
    _ child: DSLTree.Node
  ) throws {
    assert(!kind.isCapturing)

    options.beginScope()
    defer { options.endScope() }

    if let lookaround = kind.lookaroundKind {
      try emitLookaround(lookaround, child)
      return
    }

    switch kind {
    case .lookahead, .negativeLookahead,
        .lookbehind, .negativeLookbehind:
      throw Unreachable("TODO: reason")

    case .capture, .namedCapture, .balancedCapture:
      throw Unreachable("These should produce a capture node")

    case .changeMatchingOptions(let optionSequence):
      if !hasEmittedFirstMatchableAtom {
        builder.initialOptions.apply(optionSequence)
      }
      options.apply(optionSequence)
      try emitNode(child)
      
    case .atomicNonCapturing:
      try emitAtomicNoncapturingGroup(child)

    default:
      // FIXME: Other kinds...
      try emitNode(child)
    }
  }

  mutating func emitQuantification(
    _ amount: AST.Quantification.Amount,
    _ kind: DSLTree.QuantificationKind,
    _ child: DSLTree.Node
  ) throws {
    let updatedKind = kind.applying(options: options)

    let (low, high) = amount.bounds
    guard let low = low else {
      throw Unreachable("Must have a lower bound")
    }
    switch (low, high) {
    case (_, 0):
      // TODO: Should error out earlier, maybe DSL and parser
      // has validation logic?
      return
    case let (n, m?) where n > m:
      // TODO: Should error out earlier, maybe DSL and parser
      // has validation logic?
      return

    case let (n, m) where m == nil || n <= m!:
      // Ok
      break
    default:
      throw Unreachable("TODO: reason")
    }

    // Compiler and/or parser should enforce these invariants
    // before we are called
    assert(high != 0)
    assert((0...(high ?? Int.max)).contains(low))

    let maxExtraTrips: Int?
    if let h = high {
      maxExtraTrips = h - low
    } else {
      maxExtraTrips = nil
    }
    let minTrips = low
    assert((maxExtraTrips ?? 1) >= 0)

    if tryEmitFastQuant(child, updatedKind, minTrips, maxExtraTrips) {
      return
    }

    // The below is a general algorithm for bounded and unbounded
    // quantification. It can be specialized when the min
    // is 0 or 1, or when extra trips is 1 or unbounded.
    //
    // Stuff inside `<` and `>` are decided at compile time,
    // while run-time values stored in registers start with a `%`
    _ = """
      min-trip-count control block:
        if %minTrips is zero:
          goto exit-policy control block
        else:
          decrement %minTrips and fallthrough

      loop-body:
        <if can't guarantee forward progress && maxExtraTrips = nil>:
          mov currentPosition %pos
        evaluate the subexpression
        <if can't guarantee forward progress && maxExtraTrips = nil>:
          if %pos is currentPosition:
            goto exit
        goto min-trip-count control block

      exit-policy control block:
        if %maxExtraTrips is zero:
          goto exit
        else:
          decrement %maxExtraTrips and fallthrough

        <if eager>:
          save exit and goto loop-body
        <if possessive>:
          ratchet and goto loop
        <if reluctant>:
          save loop-body and fallthrough (i.e. goto exit)

      exit
        ... the rest of the program ...
    """

    // Specialization based on `minTrips` for 0 or 1:
    _ = """
      min-trip-count control block:
        <if minTrips == 0>:
          goto exit-policy
        <if minTrips == 1>:
          /* fallthrough */

      loop-body:
        evaluate the subexpression
        <if minTrips <= 1>
          /* fallthrough */
    """

    // Specialization based on `maxExtraTrips` for 0 or unbounded
    _ = """
      exit-policy control block:
        <if maxExtraTrips == 0>:
          goto exit
        <if maxExtraTrips == .unbounded>:
          /* fallthrough */
    """

    /*
      NOTE: These specializations don't emit the optimal
      code layout (e.g. fallthrough vs goto), but that's better
      done later (not prematurely) and certainly better
      done by an optimizing compiler.

      NOTE: We're intentionally emitting essentially the same
      algorithm for all quantifications for now, for better
      testing and surfacing difficult bugs. We can specialize
      for other things, like `.*`, later.

      When it comes time for optimizing, we can also look into
      quantification instructions (e.g. reduce save-point traffic)
    */

    let minTripsControl = builder.makeAddress()
    let loopBody = builder.makeAddress()
    let exitPolicy = builder.makeAddress()
    let exit = builder.makeAddress()

    // We'll need registers if we're (non-trivially) bounded
    let minTripsReg: IntRegister?
    if minTrips > 1 {
      minTripsReg = builder.makeIntRegister(
        initialValue: minTrips)
    } else {
      minTripsReg = nil
    }

    let maxExtraTripsReg: IntRegister?
    if (maxExtraTrips ?? 0) > 0 {
      maxExtraTripsReg = builder.makeIntRegister(
        initialValue: maxExtraTrips!)
    } else {
      maxExtraTripsReg = nil
    }

    // Set up a dummy save point for possessive to update
    if updatedKind == .possessive {
      builder.pushEmptySavePoint()
    }

    // min-trip-count:
    //   condBranch(to: exitPolicy, ifZeroElseDecrement: %min)
    builder.label(minTripsControl)
    switch minTrips {
    case 0: builder.buildBranch(to: exitPolicy)
    case 1: break
    default:
      assert(minTripsReg != nil, "logic inconsistency")
      builder.buildCondBranch(
        to: exitPolicy, ifZeroElseDecrement: minTripsReg!)
    }

    // FIXME: Possessive needs a "dummy" save point to ratchet

    // loop:
    //   <subexpression>
    //   branch min-trip-count
    builder.label(loopBody)

    // if we aren't sure if the child node will have forward progress and
    // we have an unbounded quantification
    let startPosition: PositionRegister?
    let emitPositionChecking =
      (!optimizationsEnabled || !child.guaranteesForwardProgress) &&
      maxExtraTrips == nil

    if emitPositionChecking {
      startPosition = builder.makePositionRegister()
      builder.buildMoveCurrentPosition(into: startPosition!)
    } else {
      startPosition = nil
    }
    try emitNode(child)
    if emitPositionChecking {
      // in all quantifier cases, no matter what minTrips or maxExtraTrips is,
      // if we have a successful non-advancing match, branch to exit because it
      // can match an arbitrary number of times
      builder.buildCondBranch(to: exit, ifSamePositionAs: startPosition!)
    }

    if minTrips <= 1 {
      // fallthrough
    } else {
      builder.buildBranch(to: minTripsControl)
    }

    // exit-policy:
    //   condBranch(to: exit, ifZeroElseDecrement: %maxExtraTrips)
    //   <eager: split(to: loop, saving: exit)>
    //   <possesive:
    //     clearSavePoint
    //     split(to: loop, saving: exit)>
    //   <reluctant: save(restoringAt: loop)
    builder.label(exitPolicy)
    switch maxExtraTrips {
    case nil: break
    case 0:   builder.buildBranch(to: exit)
    default:
      assert(maxExtraTripsReg != nil, "logic inconsistency")
      builder.buildCondBranch(
        to: exit, ifZeroElseDecrement: maxExtraTripsReg!)
    }

    switch updatedKind {
    case .eager:
      builder.buildSplit(to: loopBody, saving: exit)
    case .possessive:
      builder.buildClear()
      builder.buildSplit(to: loopBody, saving: exit)
    case .reluctant:
      builder.buildSave(loopBody)
      // FIXME: Is this re-entrant? That is would nested
      // quantification break if trying to restore to a prior
      // iteration because the register got overwritten?
      //
    #if RESILIENT_LIBRARIES
    @unknown default:
      fatalError()
    #endif
    }

    builder.label(exit)
  }

  /// Specialized quantification instruction for repetition of certain nodes in grapheme semantic mode
  /// Allowed nodes are:
  /// - single ascii scalar .char
  /// - ascii .customCharacterClass
  /// - single grapheme consumgin built in character classes
  /// - .any, .anyNonNewline, .dot
  mutating func tryEmitFastQuant(
    _ child: DSLTree.Node,
    _ kind: AST.Quantification.Kind,
    _ minTrips: Int,
    _ maxExtraTrips: Int?
  ) -> Bool {
    let isScalarSemantics = options.semanticLevel == .unicodeScalar
    guard optimizationsEnabled
            && minTrips <= QuantifyPayload.maxStorableTrips
            && maxExtraTrips ?? 0 <= QuantifyPayload.maxStorableTrips
            && kind != .reluctant else {
      return false
    }
    switch child {
    case .customCharacterClass(let ccc):
      // ascii only custom character class
      guard let bitset = ccc.asAsciiBitset(options) else {
        return false
      }
      builder.buildQuantify(bitset: bitset, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics)

    case .atom(let atom):
      switch atom {
      case .char(let c):
        if options.isCaseInsensitive && c.isCased {
          // Cased character with case-insensitive matching; match only as an ASCII bitset
          guard let bitset = DSLTree.CustomCharacterClass(members: [.atom(atom)]).asAsciiBitset(options) else {
            return false
          }
          builder.buildQuantify(bitset: bitset, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics)
        } else {
          // Uncased character OR case-sensitive matching; match as a single scalar ascii value character
          guard let val = c._singleScalarAsciiValue else {
            return false
          }
          builder.buildQuantify(asciiChar: val, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics)
        }

      case .any:
        builder.buildQuantifyAny(
          matchesNewlines: true, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics)
      case .anyNonNewline:
        builder.buildQuantifyAny(
          matchesNewlines: false, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics)
      case .dot:
        builder.buildQuantifyAny(
          matchesNewlines: options.dotMatchesNewline, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics)

      case .characterClass(let cc):
        // Custom character class that consumes a single grapheme
        let model = cc.asRuntimeModel(options)
        builder.buildQuantify(
          model: model,
          kind,
          minTrips,
          maxExtraTrips,
          isScalarSemantics: isScalarSemantics)
      default:
        return false
      }
    case .limitCaptureNesting(let node):
      return tryEmitFastQuant(node, kind, minTrips, maxExtraTrips)
    case .nonCapturingGroup(let groupKind, let node):
      // .nonCapture nonCapturingGroups are ignored during compilation
      guard groupKind.ast == .nonCapture else {
        return false
      }
      return tryEmitFastQuant(node, kind, minTrips, maxExtraTrips)
    default:
      return false
    }
    return true
  }

  /// Coalesce any adjacent scalar members in a custom character class together.
  /// This is required in order to produce correct grapheme matching behavior.
  func coalescingCustomCharacterClassMembers(
    _ members: [DSLTree.CustomCharacterClass.Member]
  ) -> [DSLTree.CustomCharacterClass.Member] {
    struct Accumulator {
      /// A series of range operands. For example, in `[ab-cde-fg]`, this will
      /// contain the strings `["ab", "cde", "fg"]`. From there, the resulting
      /// ranges will be created.
      private var rangeOperands: [String] = [""]

      /// The current range operand.
      private var current: String {
        _read { yield rangeOperands[rangeOperands.count - 1] }
        _modify { yield &rangeOperands[rangeOperands.count - 1] }
      }

      /// Try to accumulate a character class member, returning `true` if
      /// successful, `false` otherwise.
      mutating func tryAccumulate(
        _ member: DSLTree.CustomCharacterClass.Member
      ) -> Bool {
        switch member {
        case .atom(let a):
          guard let c = a.literalCharacterValue else { return false }
          current.append(c)
          return true
        case .quotedLiteral(let str):
          current += str
          return true
        case let .range(lhs, rhs):
          guard let lhs = lhs.literalCharacterValue,
                let rhs = rhs.literalCharacterValue
          else { return false }
          current.append(lhs)
          rangeOperands.append(String(rhs))
          return true
        case .trivia:
          // Trivia can be completely ignored if we've already coalesced
          // something.
          return !current.isEmpty
        default:
          return false
        }
      }

      func finish() -> [DSLTree.CustomCharacterClass.Member] {
        if rangeOperands.count == 1 {
          // If we didn't have any additional range operands, this isn't a
          // range, we can just form a standard quoted literal.
          return [.quotedLiteral(current)]
        }
        var members = [DSLTree.CustomCharacterClass.Member]()

        // We have other range operands, splice them together. For N operands
        // we have N - 1 ranges.
        for (i, lhs) in rangeOperands.dropLast().enumerated() {
          let rhs = rangeOperands[i + 1]

          // If this is the first operand we only need to drop the last
          // character for its quoted members, otherwise this is both an LHS
          // and RHS of a range, and as such needs both sides trimmed.
          let leading = i == 0 ? lhs.dropLast() : lhs.dropFirst().dropLast()
          if !leading.isEmpty {
            members.append(.quotedLiteral(String(leading)))
          }
          members.append(.range(.char(lhs.last!), .char(rhs.first!)))
        }
        // We've handled everything except the quoted portion of the last
        // operand, add it now.
        let trailing = rangeOperands.last!.dropFirst()
        if !trailing.isEmpty {
          members.append(.quotedLiteral(String(trailing)))
        }
        return members
      }
    }
    return members
      .map { m -> DSLTree.CustomCharacterClass.Member in
        // First we need to recursively coalsce any child character classes.
        switch m {
        case .custom(let ccc):
          return .custom(coalescingCustomCharacterClass(ccc))
        case .intersection(let lhs, let rhs):
          return .intersection(
            coalescingCustomCharacterClass(lhs),
            coalescingCustomCharacterClass(rhs))
        case .subtraction(let lhs, let rhs):
          return .subtraction(
            coalescingCustomCharacterClass(lhs),
            coalescingCustomCharacterClass(rhs))
        case .symmetricDifference(let lhs, let rhs):
          return .symmetricDifference(
            coalescingCustomCharacterClass(lhs),
            coalescingCustomCharacterClass(rhs))
        case .atom, .range, .quotedLiteral, .trivia:
          return m
        }
      }
      .coalescing(with: Accumulator(), into: { $0.finish() }) { accum, member in
        accum.tryAccumulate(member)
      }
  }

  /// Flatten quoted strings into sequences of atoms, so that the standard
  /// CCC codegen will handle them.
  func flatteningCustomCharacterClassMembers(
    _ members: [DSLTree.CustomCharacterClass.Member]
  ) -> [DSLTree.CustomCharacterClass.Member] {
    var characters: Set<Character> = []
    var scalars: Set<UnicodeScalar> = []
    var result: [DSLTree.CustomCharacterClass.Member] = []
    for member in members {
      switch member {
      case .atom(let atom):
        switch atom {
        case let .char(char):
          if characters.insert(char).inserted {
            result.append(member)
          }
        case let .scalar(scalar):
          if scalars.insert(scalar).inserted {
            result.append(member)
          }
        default:
          result.append(member)
        }
      case let .quotedLiteral(str):
        for char in str {
          if characters.insert(char).inserted {
            result.append(.atom(.char(char)))
          }
        }
      default:
        result.append(member)
      }
    }
    return result
  }
  
  func coalescingCustomCharacterClass(
    _ ccc: DSLTree.CustomCharacterClass
  ) -> DSLTree.CustomCharacterClass {
    // This only needs to be done in grapheme semantic mode. In scalar semantic
    // mode, we don't want to coalesce any scalars into a grapheme. This
    // means that e.g `[e\u{301}-\u{302}]` remains a range between U+301 and
    // U+302.
    let members = options.semanticLevel == .graphemeCluster
      ? coalescingCustomCharacterClassMembers(ccc.members)
      : ccc.members
    return .init(
      members: flatteningCustomCharacterClassMembers(members),
      isInverted: ccc.isInverted)
  }

  mutating func emitCharacterInCCC(_ c: Character)  {
    switch options.semanticLevel {
    case .graphemeCluster:
      emitCharacter(c)
    case .unicodeScalar:
      // When in scalar mode, act like an alternation of the individual scalars
      // that comprise a character.
      emitAlternationGen(c.unicodeScalars, withBacktracking: false) {
        $0.emitMatchScalar($1)
      }
    }
  }
  
  mutating func emitCCCMember(
    _ member: DSLTree.CustomCharacterClass.Member
  ) throws {
    switch member {
    case .atom(let atom):
      switch atom {
      case .char(let c):
        emitCharacterInCCC(c)
      case .scalar(let s):
        emitCharacterInCCC(Character(s))
      default:
        try emitAtom(atom)
      }
    case .custom(let ccc):
      try emitCustomCharacterClass(ccc)
    case .quotedLiteral:
      fatalError("Removed in 'flatteningCustomCharacterClassMembers'")
    case .range:
      let consumer = try member.generateConsumer(options)
      builder.buildConsume(by: consumer)
    case .trivia:
      return
      
    // TODO: Can we decide when it's better to try `rhs` first?
    // Intersection is trivial, since failure on either side propagates:
    // - store current position
    // - lhs
    // - restore current position
    // - rhs
    case let .intersection(lhs, rhs):
      let r = builder.makePositionRegister()
      builder.buildMoveCurrentPosition(into: r)
      try emitCustomCharacterClass(lhs)
      builder.buildRestorePosition(from: r)
      try emitCustomCharacterClass(rhs)
      
    // TODO: Can we decide when it's better to try `rhs` first?
    // For subtraction, failure in `lhs` propagates, while failure in `rhs` is
    // swallowed/reversed:
    // - store current position
    // - lhs
    // - save to end
    // - restore current position
    // - rhs
    // - clear, fail (since both succeeded)
    // - end: ...
    case let .subtraction(lhs, rhs):
      let r = builder.makePositionRegister()
      let end = builder.makeAddress()
      builder.buildMoveCurrentPosition(into: r)
      try emitCustomCharacterClass(lhs)   // no match here = failure, propagates
      builder.buildSave(end)
      builder.buildRestorePosition(from: r)
      try emitCustomCharacterClass(rhs)   // no match here = success, resumes at 'end'
      builder.buildClear()                // clears 'end'
      builder.buildFail()                 // this failure propagates outward
      builder.label(end)
    
    // Symmetric difference always requires executing both `rhs` and `lhs`.
    // Execute each, ignoring failure and storing the resulting position in a
    // register. If those results are equal, fail. If they're different, use
    // the position that is different from the starting position:
    // - store current position as r0
    // - save to lhsFail
    // - lhs
    // - clear lhsFail (and continue)
    // - lhsFail: save position as r1
    //
    // - restore current position
    // - save to rhsFail
    // - rhs
    // - clear rhsFail (and continue)
    // - rhsFail: save position as r2
    //
    // - restore to resulting position from lhs (r1)
    // - if equal to r2, goto fail (both sides had same result)
    // - if equal to r0, goto advance (lhs failed)
    // - goto end
    // - advance: restore to resulting position from rhs (r2)
    // - goto end
    // - fail: fail
    // - end: ...
    case let .symmetricDifference(lhs, rhs):
      let r0 = builder.makePositionRegister()
      let r1 = builder.makePositionRegister()
      let r2 = builder.makePositionRegister()
      let lhsFail = builder.makeAddress()
      let rhsFail = builder.makeAddress()
      let advance = builder.makeAddress()
      let fail = builder.makeAddress()
      let end = builder.makeAddress()

      builder.buildMoveCurrentPosition(into: r0)
      builder.buildSave(lhsFail)
      try emitCustomCharacterClass(lhs)
      builder.buildClear()
      builder.label(lhsFail)
      builder.buildMoveCurrentPosition(into: r1)
      
      builder.buildRestorePosition(from: r0)
      builder.buildSave(rhsFail)
      try emitCustomCharacterClass(rhs)
      builder.buildClear()
      builder.label(rhsFail)
      builder.buildMoveCurrentPosition(into: r2)
      
      // If r1 == r2, then fail
      builder.buildRestorePosition(from: r1)
      builder.buildCondBranch(to: fail, ifSamePositionAs: r2)
      
      // If r1 == r0, then move to r2 before ending
      builder.buildCondBranch(to: advance, ifSamePositionAs: r0)
      builder.buildBranch(to: end)
      builder.label(advance)
      builder.buildRestorePosition(from: r2)
      builder.buildBranch(to: end)

      builder.label(fail)
      builder.buildFail()
      builder.label(end)      
    }
  }
  
  mutating func emitCustomCharacterClass(
    _ ccc: DSLTree.CustomCharacterClass
  ) throws {
    // Before emitting a custom character class in grapheme semantic mode, we
    // need to coalesce together any adjacent characters and scalars, over which
    // we can perform grapheme breaking. This includes e.g range bounds for
    // `[e\u{301}-\u{302}]`.
    let ccc = coalescingCustomCharacterClass(ccc)
    if let asciiBitset = ccc.asAsciiBitset(options),
        optimizationsEnabled {
      if options.semanticLevel == .unicodeScalar {
        builder.buildScalarMatchAsciiBitset(asciiBitset)
      } else {
        builder.buildMatchAsciiBitset(asciiBitset)
      }
      return
    }

    let updatedCCC: DSLTree.CustomCharacterClass
    if optimizationsEnabled {
      updatedCCC = ccc.coalescingASCIIMembers(options)
    } else {
      updatedCCC = ccc
    }
    let filteredMembers = updatedCCC.members.filter({!$0.isOnlyTrivia})
    
    if updatedCCC.isInverted {
      // inverted
      // custom character class: p0 | p1 | ... | pn
      // Try each member to make sure they all fail
      //     save next_p1
      //     <code for p0>
      //     clear, fail
      //   next_p1:
      //     save next_p2
      //     <code for p1>
      //     clear fail
      //   next_p2:
      //     save next_p...
      //     <code for p2>
      //     clear fail
      //   ...
      //   next_pn:
      //     save done
      //     <code for pn>
      //     clear fail
      //   done:
      //     step forward by 1
      let done = builder.makeAddress()
      for member in filteredMembers.dropLast() {
        let next = builder.makeAddress()
        builder.buildSave(next)
        try emitCCCMember(member)
        builder.buildClear()
        builder.buildFail()
        builder.label(next)
      }
      builder.buildSave(done)
      try emitCCCMember(filteredMembers.last!)
      builder.buildClear()
      builder.buildFail()
      builder.label(done)
      
      // Consume a single unit for the inverted ccc
      switch options.semanticLevel {
      case .graphemeCluster:
        builder.buildAdvance(1)
      case .unicodeScalar:
        builder.buildAdvanceUnicodeScalar(1)
      }
      return
    }
    // non inverted CCC
    // Custom character class: p0 | p1 | ... | pn
    // Very similar to alternation, but we don't keep backtracking save points
    try emitAlternationGen(filteredMembers, withBacktracking: false) {
      try $0.emitCCCMember($1)
    }
  }

  mutating func emitConcatenation(_ children: [DSLTree.Node]) throws {
    // Before emitting a concatenation, we need to flatten out any nested
    // concatenations, and coalesce any adjacent characters and scalars, forming
    // quoted literals of their contents, over which we can perform grapheme
    // breaking.
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
    let children = children
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
    for child in children {
      try emitConcatenationComponent(child)
    }
  }

  @discardableResult
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
    switch node {
      
    case let .orderedChoice(children):
      try emitAlternation(children)

    case let .concatenation(children):
      try emitConcatenation(children)

    case let .capture(name, refId, child, transform):
      options.beginScope()
      defer { options.endScope() }

      let cap = builder.makeCapture(id: refId, name: name)
      builder.buildBeginCapture(cap)
      let value = try emitNode(child)
      builder.buildEndCapture(cap)
      // If the child node produced a custom capture value, e.g. the result of
      // a matcher, this should override the captured substring.
      if let value {
        builder.buildMove(value, into: cap)
      }
      // If there's a capture transform, apply it now.
      if let transform = transform {
        let fn = builder.makeTransformFunction { input, cap in
          // If it's a substring capture with no custom value, apply the
          // transform directly to the substring to avoid existential traffic.
          //
          // FIXME: separate out this code path. This is fragile,
          // slow, and these are clearly different constructs
          if let range = cap.range, cap.value == nil {
            return try transform(input[range])
          }

          let value = constructExistentialOutputComponent(
             from: input,
             component: cap.deconstructed,
             optionalCount: 0)
          return try transform(value)
        }
        builder.buildTransformCapture(cap, fn)
      }

    case let .nonCapturingGroup(kind, child):
      try emitNoncapturingGroup(kind.ast, child)

    case let .ignoreCapturesInTypedOutput(child):
      try emitNode(child)
      
    case let .limitCaptureNesting(child):
      return try emitNode(child)
      
    case .conditional:
      throw Unsupported("Conditionals")

    case let .quantification(amt, kind, child):
      try emitQuantification(amt.ast, kind, child)

    case let .customCharacterClass(ccc):
      if ccc.containsDot {
        if !ccc.isInverted {
          try emitDot()
        } else {
          throw Unsupported("Inverted any")
        }
      } else {
        try emitCustomCharacterClass(ccc)
      }

    case let .atom(a):
      try emitAtom(a)

    case let .quotedLiteral(s):
      emitQuotedLiteral(s)

    case .absentFunction:
      throw Unsupported("absent function")
    case .consumer:
      throw Unsupported("consumer")

    case let .matcher(_, f):
      return emitMatcher(f)

    case .characterPredicate:
      throw Unsupported("character predicates")

    case .trivia, .empty:
      return nil
    }
    return nil
  }
}

extension DSLTree.Node {
  /// A Boolean value indicating whether this node advances the match position
  /// on a successful match.
  ///
  /// For example, an alternation like `(a|b|c)` always advances the position
  /// by a character, but `(a|b|)` has an empty branch, which matches without
  /// advancing.
  var guaranteesForwardProgress: Bool {
    switch self {
    case .orderedChoice(let children):
      return children.allSatisfy { $0.guaranteesForwardProgress }
    case .concatenation(let children):
      return children.contains(where: { $0.guaranteesForwardProgress })
    case .capture(_, _, let node, _):
      return node.guaranteesForwardProgress
    case .nonCapturingGroup(let kind, let child):
      switch kind.ast {
      case .lookahead, .negativeLookahead, .lookbehind, .negativeLookbehind:
        return false
      default: return child.guaranteesForwardProgress
      }
    case .atom(let atom):
      switch atom {
      case .changeMatchingOptions, .assertion: return false
      // Captures may be nil so backreferences may be zero length matches
      case .backreference: return false
      default: return true
      }
    case .trivia, .empty:
      return false
    case .quotedLiteral(let string):
      return !string.isEmpty
    case .consumer, .matcher:
      // Allow zero width consumers and matchers
     return false
    case .customCharacterClass(let ccc):
      return ccc.guaranteesForwardProgress
    case .quantification(let amount, _, let child):
      let (atLeast, _) = amount.ast.bounds
      return atLeast ?? 0 > 0 && child.guaranteesForwardProgress
    case .limitCaptureNesting(let node), .ignoreCapturesInTypedOutput(let node):
      return node.guaranteesForwardProgress
    default: return false
    }
  }
}

extension DSLTree.CustomCharacterClass {
  /// We allow trivia into CustomCharacterClass, which could result in a CCC
  /// that matches nothing, ie `(?x)[ ]`.
  var guaranteesForwardProgress: Bool {
    for m in members {
      switch m {
      case .trivia:
        continue
      case let .intersection(lhs, rhs):
        return lhs.guaranteesForwardProgress && rhs.guaranteesForwardProgress
      case let .subtraction(lhs, _):
        return lhs.guaranteesForwardProgress
      case let .symmetricDifference(lhs, rhs):
        return lhs.guaranteesForwardProgress && rhs.guaranteesForwardProgress
      default:
        return true
      }
    }
    return false
  }
}
