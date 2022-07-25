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

@_implementationOnly import _RegexParser

extension Compiler {
  struct ByteCodeGen {
    var options: MatchingOptions
    var builder = MEProgram.Builder()
    /// A Boolean indicating whether the first matchable atom has been emitted.
    /// This is used to determine whether to apply initial options.
    var hasEmittedFirstMatchableAtom = false

    private let compileOptions: CompileOptions
    fileprivate var optimizationsEnabled: Bool { !compileOptions.contains(.disableOptimizations) }

    init(
      options: MatchingOptions,
      compileOptions: CompileOptions,
      captureList: CaptureList
    ) {
      self.options = options
      self.compileOptions = compileOptions
      self.builder.captureList = captureList
    }
  }
}

extension Compiler.ByteCodeGen {
  mutating func emitRoot(_ root: DSLTree.Node) throws -> MEProgram {
    // The whole match (`.0` element of output) is equivalent to an implicit
    // capture over the entire regex.
    try emitNode(.capture(name: nil, reference: nil, root))
    builder.buildAccept()
    return try builder.assemble()
  }
}

fileprivate extension Compiler.ByteCodeGen {
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
      emitDot()

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
      builder.buildUnresolvedReference(id: id)

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
    guard options.semanticLevel == .graphemeCluster else {
      for char in s {
        for scalar in char.unicodeScalars {
          emitMatchScalar(scalar)
        }
      }
      return
    }

    // Fast path for eliding boundary checks for an all ascii quoted literal
    if optimizationsEnabled && s.allSatisfy(\.isASCII) {
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
      builder.buildBackreference(.init(i))
    case .named(let name):
      try builder.buildNamedReference(name)
    case .relative:
      throw Unsupported("Backreference kind: \(ref)")
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
      // TODO: builder.buildAdvanceUnicodeScalar(1)
      builder.buildConsume { input, bounds in
        input.unicodeScalars.index(after: bounds.lowerBound)
      }
    }
  }

  mutating func emitAnyNonNewline() {
    switch options.semanticLevel {
    case .graphemeCluster:
      builder.buildConsume { input, bounds in
        input[bounds.lowerBound].isNewline
        ? nil
        : input.index(after: bounds.lowerBound)
      }
    case .unicodeScalar:
      builder.buildConsume { input, bounds in
        input[bounds.lowerBound].isNewline
        ? nil
        : input.unicodeScalars.index(after: bounds.lowerBound)
      }
    }
  }

  mutating func emitDot() {
    if options.dotMatchesNewline {
      emitAny()
    } else {
      emitAnyNonNewline()
    }
  }

  mutating func emitAlternation(
    _ children: [DSLTree.Node]
  ) throws {
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
    for component in children.dropLast() {
      let next = builder.makeAddress()
      builder.buildSave(next)
      try emitNode(component)
      builder.buildBranch(to: done)
      builder.label(next)
    }
    try emitNode(children.last!)
    builder.label(done)
  }

  mutating func emitConcatenationComponent(
    _ node: DSLTree.Node
  ) throws {
    // TODO: Should we do anything special since we can
    // be glueing sub-grapheme components together?
    try emitNode(node)
  }

  mutating func emitLookaround(
    _ kind: (forwards: Bool, positive: Bool),
    _ child: DSLTree.Node
  ) throws {
    guard kind.forwards else {
      throw Unsupported("backwards assertions")
    }

    let positive = kind.positive
    /*
      save(restoringAt: success)
      save(restoringAt: intercept)
      <sub-pattern>    // failure restores at intercept
      clearThrough(intercept) // remove intercept and any leftovers from <sub-pattern>
      <if negative>:
        clearSavePoint // remove success
      fail             // positive->success, negative propagates
    intercept:
      <if positive>:
        clearSavePoint // remove success
      fail             // positive propagates, negative->success
    success:
      ...
    */

    let intercept = builder.makeAddress()
    let success = builder.makeAddress()

    builder.buildSave(success)
    builder.buildSave(intercept)
    try emitNode(child)
    builder.buildClearThrough(intercept)
    if !positive {
      builder.buildClear()
    }
    builder.buildFail()

    builder.label(intercept)
    if positive {
      builder.buildClear()
    }
    builder.buildFail()

    builder.label(success)
  }

  mutating func emitAtomicNoncapturingGroup(
    _ child: DSLTree.Node
  ) throws {
    /*
      save(continuingAt: success)
      save(restoringAt: intercept)
      <sub-pattern>    // failure restores at intercept
      clearThrough(intercept) // remove intercept and any leftovers from <sub-pattern>
      fail             // ->success
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
    builder.buildFail()

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
    let updatedKind: AST.Quantification.Kind
    switch kind {
    case .explicit(let kind):
      updatedKind = kind.ast
    case .syntax(let kind):
      updatedKind = kind.ast.applying(options)
    case .default:
      updatedKind = options.defaultQuantificationKind
    }

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

    let extraTrips: Int?
    if let h = high {
      extraTrips = h - low
    } else {
      extraTrips = nil
    }
    let minTrips = low
    assert((extraTrips ?? 1) >= 0)

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
        <if can't guarantee forward progress && extraTrips = nil>:
          mov currentPosition %pos
        evaluate the subexpression
        <if can't guarantee forward progress && extraTrips = nil>:
          if %pos is currentPosition:
            goto exit
        goto min-trip-count control block

      exit-policy control block:
        if %extraTrips is zero:
          goto exit
        else:
          decrement %extraTrips and fallthrough

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

    // Specialization based on `extraTrips` for 0 or unbounded
    _ = """
      exit-policy control block:
        <if extraTrips == 0>:
          goto exit
        <if extraTrips == .unbounded>:
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

    let extraTripsReg: IntRegister?
    if (extraTrips ?? 0) > 0 {
      extraTripsReg = builder.makeIntRegister(
        initialValue: extraTrips!)
    } else {
      extraTripsReg = nil
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
      extraTrips == nil

    if emitPositionChecking {
      startPosition = builder.makePositionRegister()
      builder.buildMoveCurrentPosition(into: startPosition!)
    } else {
      startPosition = nil
    }
    try emitNode(child)
    if emitPositionChecking {
      // in all quantifier cases, no matter what minTrips or extraTrips is,
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
    //   condBranch(to: exit, ifZeroElseDecrement: %extraTrips)
    //   <eager: split(to: loop, saving: exit)>
    //   <possesive:
    //     clearSavePoint
    //     split(to: loop, saving: exit)>
    //   <reluctant: save(restoringAt: loop)
    builder.label(exitPolicy)
    switch extraTrips {
    case nil: break
    case 0:   builder.buildBranch(to: exit)
    default:
      assert(extraTripsReg != nil, "logic inconsistency")
      builder.buildCondBranch(
        to: exit, ifZeroElseDecrement: extraTripsReg!)
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
    }

    builder.label(exit)
  }
  
  mutating func emitCharacterInCCC(_ c: Character)  {
    let isCaseInsensitive = options.isCaseInsensitive
    switch options.semanticLevel {
    case .graphemeCluster:
      emitCharacter(c)
    case .unicodeScalar:
      let consumers = c.unicodeScalars.map { s in consumeScalar {
        isCaseInsensitive
          ? $0.properties.lowercaseMapping == s.properties.lowercaseMapping
          : $0 == s
      }}
      let consumer: MEProgram.ConsumeFunction = { input, bounds in
        for fn in consumers {
          if let idx = fn(input, bounds) {
            return idx
          }
        }
        return nil
      }
      builder.buildConsume(by: consumer)
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
    case .range, .quotedLiteral:
      let consumer = try member.generateConsumer(options)
      builder.buildConsume(by: consumer)
    case .trivia:
      return
    // store current position r0
    // lhs
    // store current position r1
    // restore to r0 position
    // rhs
    // cond branch if same position as r1 to end
    // .invalid
    // end: ...
    case let .intersection(lhs, rhs):
      let r0 = builder.makePositionRegister()
      let r1 = builder.makePositionRegister()
      let end = builder.makeAddress()
      
      builder.buildMoveCurrentPosition(into: r0)
      try emitCustomCharacterClass(lhs)
      builder.buildMoveCurrentPosition(into: r1)
      
      builder.buildRestorePosition(from: r0)
      try emitCustomCharacterClass(rhs)
      
      builder.buildCondBranch(to: end, ifSamePositionAs: r1)
      builder.buildFatalError()
      builder.label(end)
      
    // store current position
    // lhs
    // save to end
    // restore current position
    // rhs
    // clear, fail (since both succeeded)
    // end: ...
    case let .subtraction(lhs, rhs):
      let r = builder.makePositionRegister()
      let end = builder.makeAddress()
      builder.buildMoveCurrentPosition(into: r)
      try emitCustomCharacterClass(lhs)
      builder.buildSave(end)
      builder.buildRestorePosition(from: r)
      try emitCustomCharacterClass(rhs)
      builder.buildClear()
      builder.buildFail()
      builder.label(end)
      
    // lily fixme: this duplicates the code emission from rhs
    // do we care? we could track the success/fail in registers
    // and then emit a bunch of conditional branches to fail/success?
      
    // store current position
    // save to lhsFail
    // lhs
    // save to rhsFail
    // restore current position
    // rhs
    // both succeeded, clear both and fail
    // rhsFail: clear, goto end
    // lhsFail:
    // restore current position
    // rhs
    // end: ...
    case let .symmetricDifference(lhs, rhs):
      let r = builder.makePositionRegister()
      let lhsFail = builder.makeAddress()
      let rhsFail = builder.makeAddress()
      let end = builder.makeAddress()
      
      builder.buildMoveCurrentPosition(into: r)
      builder.buildSave(lhsFail) // saves lhsFail
      try emitCustomCharacterClass(lhs)
      builder.buildSave(rhsFail) // saves rhsFail
      
      builder.buildRestorePosition(from: r)
      try emitCustomCharacterClass(rhs)
      // Both succeeded, fail
      builder.buildClear() // clears save(to: rhsFail)
      builder.buildClear() // clears save(to: lhsFail)
      builder.buildFail()
    
      // rhsFail
      builder.label(rhsFail)
      builder.buildClear() // clears save(to: lhsFail)
      builder.buildBranch(to: end)

      // lhsFail
      builder.label(lhsFail)
      builder.buildRestorePosition(from: r)
      try emitCustomCharacterClass(rhs)
      
      // end
      builder.label(end)
    }
  }

  mutating func emitCustomCharacterClass(
    _ ccc: DSLTree.CustomCharacterClass
  ) throws {
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
      updatedCCC = ccc.coalesedASCIIMembers(options)
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
        // TODO: builder.buildAdvanceUnicodeScalar(1)
        builder.buildConsume { input, bounds in
          input.unicodeScalars.index(after: bounds.lowerBound)
        }
      }
      return
    }
    // non inverted CCC
    // Custom character class: p0 | p1 | ... | pn
    // Very similar to alternation, but we don't keep backtracking save points
    //     save next_p1
    //     <code for p0>
    //     clear
    //     branch done
    //   next_p1:
    //     save next_p2
    //     <code for p1>
    //     clear
    //     branch done
    //   next_p2:
    //     save next_p...
    //     <code for p2>
    //     clear
    //     branch done
    //   ...
    //   next_pn:
    //     <code for pn>
    //   done:
    let done = builder.makeAddress()
    for member in filteredMembers.dropLast() {
      let next = builder.makeAddress()
      builder.buildSave(next)
      try emitCCCMember(member)
      builder.buildClear()
      builder.buildBranch(to: done)
      builder.label(next)
    }
    try emitCCCMember(filteredMembers.last!)
    builder.label(done)
  }

  @discardableResult
  mutating func emitNode(_ node: DSLTree.Node) throws -> ValueRegister? {
    switch node {
      
    case let .orderedChoice(children):
      try emitAlternation(children)

    case let .concatenation(children):
      for child in children {
        try emitConcatenationComponent(child)
      }

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

    case .conditional:
      throw Unsupported("Conditionals")

    case let .quantification(amt, kind, child):
      try emitQuantification(amt.ast, kind, child)

    case let .customCharacterClass(ccc):
      if ccc.containsDot {
        if !ccc.isInverted {
          emitDot()
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

    case let .convertedRegexLiteral(n, _):
      return try emitNode(n)

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
      default: return true
      }
    case .trivia, .empty:
      return false
    case .quotedLiteral(let string):
      return !string.isEmpty
    case .convertedRegexLiteral(let node, _):
      return node.guaranteesForwardProgress
    case .consumer, .matcher:
      // Allow zero width consumers and matchers
     return false
    case .customCharacterClass(let ccc):
      return ccc.guaranteesForwardProgress
    case .quantification(let amount, _, let child):
      let (atLeast, _) = amount.ast.bounds
      return atLeast ?? 0 > 0 && child.guaranteesForwardProgress
    default: return false
    }
  }
}

extension DSLTree.CustomCharacterClass {
  /// We allow trivia into CustomCharacterClass, which could result in a CCC that matches nothing
  /// ie (?x)[ ]
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
