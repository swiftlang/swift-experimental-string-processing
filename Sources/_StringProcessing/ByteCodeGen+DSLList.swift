//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal import _RegexParser

extension Compiler.ByteCodeGen {
  mutating func emitRoot(_ root: inout DSLList) throws -> MEProgram {
    // If the whole regex is a matcher, then the whole-match value
    // is the constructed value. Denote that the current value
    // register is the processor's value output.
    switch root.nodes.first {
    case .matcher:
      builder.denoteCurrentValueIsWholeMatchValue()
    default:
      break
    }
    
    if optimizationsEnabled {
      root.autoPossessify()
    }
    
    var list = root.nodes[...]
    try emitNode(&list)

    builder.canOnlyMatchAtStart = canOnlyMatchAtStart(in: root)
    builder.buildAccept()
    return try builder.assemble()
  }
}

fileprivate extension Compiler.ByteCodeGen {
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
  private mutating func _canOnlyMatchAtStartImpl(
    _ list: inout ArraySlice<DSLTree.Node>
  ) -> Bool? {
    guard let node = list.popFirst() else { return false }
    switch node {
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
      for _ in 0..<children.count {
        guard _canOnlyMatchAtStartImpl(&list) == true else {
          return false
        }
      }
      return true
      
    case .concatenation(let children):
      // In a concatenation, the first definitive child provides the answer.
      var i = 0
      var found = false
      while i < children.count {
        i += 1
        if let result = _canOnlyMatchAtStartImpl(&list) {
          found = result
          break
        }
      }
      // Once a definitive answer has been found, skip the rest of the nodes
      // in the concatenation.
      while i < children.count {
        i += 1
        try? skipNode(&list, preservingCaptures: false)
      }
      return found

    // Groups (and other parent nodes) defer to the child.
    case .nonCapturingGroup(let kind, _):
      // Don't let a negative lookahead affect this - need to continue to next sibling
      if kind.isNegativeLookahead {
        try? skipNode(&list, preservingCaptures: false)
        return nil
      }
      options.beginScope()
      defer { options.endScope() }
      if case .changeMatchingOptions(let sequence) = kind.ast {
        options.apply(sequence)
      }
      return _canOnlyMatchAtStartImpl(&list)
    case .capture:
      options.beginScope()
      defer { options.endScope() }
      return _canOnlyMatchAtStartImpl(&list)
    case .ignoreCapturesInTypedOutput, .limitCaptureNesting:
      return _canOnlyMatchAtStartImpl(&list)

    // A quantification that doesn't require its child to exist can still
    // allow a start-only match. (e.g. `/(foo)?^bar/`)
    case .quantification(let amount, _, _):
      if amount.requiresAtLeastOne {
        return _canOnlyMatchAtStartImpl(&list)
      } else {
        try? skipNode(&list, preservingCaptures: false)
        return nil
      }

    // For conditional nodes, both sides must require matching at start.
    case .conditional:
      return _canOnlyMatchAtStartImpl(&list) == true
        && _canOnlyMatchAtStartImpl(&list) == true

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
  mutating func canOnlyMatchAtStart(in list: DSLList) -> Bool {
    let currentOptions = options
    options = MatchingOptions()
    defer { options = currentOptions }
    
    var list = list.nodes[...]
    return _canOnlyMatchAtStartImpl(&list) ?? false
  }

  mutating func emitAlternationGen<T>(
    _ elements: inout ArraySlice<T>,
    alternationCount: Int,
    withBacktracking: Bool,
    _ body: (inout Compiler.ByteCodeGen, inout ArraySlice<T>) throws -> Void
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
    for _ in 1..<alternationCount {
      let next = builder.makeAddress()
      builder.buildSave(next)
      try body(&self, &elements)
      if !withBacktracking {
        builder.buildClear()
      }
      builder.buildBranch(to: done)
      builder.label(next)
    }
    try body(&self, &elements)
    builder.label(done)
  }
  
  mutating func emitAlternation(
    _ list: inout ArraySlice<DSLTree.Node>,
    alternationCount count: Int
  ) throws {
    try emitAlternationGen(&list, alternationCount: count, withBacktracking: true) {
      try $0.emitNode(&$1)
    }
  }

  mutating func emitPositiveLookahead(_ list: inout ArraySlice<DSLTree.Node>) throws {
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
    try emitNode(&list)
    builder.buildClearThrough(intercept)
    builder.buildFail(preservingCaptures: true) // Lookahead succeeds here

    builder.label(intercept)
    builder.buildClear()
    builder.buildFail()

    builder.label(success)
  }
  
  mutating func emitNegativeLookahead(_ list: inout ArraySlice<DSLTree.Node>) throws {
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
    try emitNode(&list)
    builder.buildClearThrough(intercept)
    builder.buildClear()
    builder.buildFail()

    builder.label(intercept)
    builder.buildFail()

    builder.label(success)
  }
  
  mutating func emitLookaround(
    _ kind: (forwards: Bool, positive: Bool),
    _ list: inout ArraySlice<DSLTree.Node>
  ) throws {
    guard kind.forwards else {
      throw Unsupported("backwards assertions")
    }
    if kind.positive {
      try emitPositiveLookahead(&list)
    } else {
      try emitNegativeLookahead(&list)
    }
  }

  mutating func emitAtomicNoncapturingGroup(
    _ list: inout ArraySlice<DSLTree.Node>
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
    try emitNode(&list)
    builder.buildClearThrough(intercept)
    builder.buildFail(preservingCaptures: true) // Atomic group succeeds here

    builder.label(intercept)
    builder.buildClear()
    builder.buildFail()

    builder.label(success)
  }

  mutating func emitNoncapturingGroup(
    _ kind: AST.Group.Kind,
    _ list: inout ArraySlice<DSLTree.Node>
  ) throws {
    assert(!kind.isCapturing)

    options.beginScope()
    defer { options.endScope() }

    if let lookaround = kind.lookaroundKind {
      try emitLookaround(lookaround, &list)
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
      try emitNode(&list)
      
    case .atomicNonCapturing:
      try emitAtomicNoncapturingGroup(&list)

    default:
      // FIXME: Other kinds...
      try emitNode(&list)
    }
  }

  func _guaranteesForwardProgressImpl(_ list: ArraySlice<DSLTree.Node>, position: inout Int) -> Bool {
    guard position < list.endIndex else { return false }
    let node = list[position]
    position += 1
    switch node {
    case .orderedChoice(let children):
      return (0..<children.count).allSatisfy { _ in
        _guaranteesForwardProgressImpl(list, position: &position)
      }
    case .concatenation(let children):
      return (0..<children.count).contains { _ in
        _guaranteesForwardProgressImpl(list, position: &position)
      }
    case .capture(_, _, _, _):
      return _guaranteesForwardProgressImpl(list, position: &position)
    case .nonCapturingGroup(let kind, _):
      switch kind.ast {
      case .lookahead, .negativeLookahead, .lookbehind, .negativeLookbehind:
        return false
      default:
        return _guaranteesForwardProgressImpl(list, position: &position)
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
    case .quantification(let amount, _, _):
      let (atLeast, _) = amount.ast.bounds
      guard let atLeast, atLeast > 0 else { return false }
      return _guaranteesForwardProgressImpl(list, position: &position)
    case .limitCaptureNesting, .ignoreCapturesInTypedOutput:
      return _guaranteesForwardProgressImpl(list, position: &position)
    default: return false
    }
  }
  
  func guaranteesForwardProgress(_ list: ArraySlice<DSLTree.Node>) -> Bool {
    var pos = list.startIndex
    return _guaranteesForwardProgressImpl(list, position: &pos)
  }
  
  mutating func emitQuantification(
    _ amount: AST.Quantification.Amount,
    _ kind: DSLTree.QuantificationKind,
    _ list: inout ArraySlice<DSLTree.Node>
  ) throws {
    let updatedKind = kind.applying(options: options)

    let (low, high) = amount.bounds
    guard let low = low else {
      throw Unreachable("Must have a lower bound")
    }
    switch (low, high) {
    case (_, 0):
      try skipNode(&list)
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

    var tmp = list
    if tryEmitFastQuant(&tmp, updatedKind, minTrips, maxExtraTrips) {
      list = tmp
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
    // FIXME: forward progress check?!
    let emitPositionChecking =
      (!optimizationsEnabled || !guaranteesForwardProgress(list))
        && maxExtraTrips == nil

    if emitPositionChecking {
      startPosition = builder.makePositionRegister()
      builder.buildMoveCurrentPosition(into: startPosition!)
    } else {
      startPosition = nil
    }
    try emitNode(&list)
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
    _ list: inout ArraySlice<DSLTree.Node>,
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
    guard let child = list.popFirst() else { return false }
    
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
      if tryEmitFastQuant(&list, kind, minTrips, maxExtraTrips) {
        return true
      } else {
        return false
      }
    case .nonCapturingGroup(let groupKind, let node):
      // .nonCapture nonCapturingGroups are ignored during compilation
      guard groupKind.ast == .nonCapture else {
        return false
      }
      if tryEmitFastQuant(&list, kind, minTrips, maxExtraTrips) {
        return true
      } else {
        return false
      }
    default:
      return false
    }
    return true
  }
  
  mutating func emitConcatenation(
    _ list: inout ArraySlice<DSLTree.Node>,
    componentCount: Int
  ) throws {
    // Unlike the tree-based bytecode generator, in a DSLList concatenations
    // have already been flattened.
    for _ in 0..<componentCount {
      try emitNode(&list)
    }
  }

  @discardableResult
  mutating func emitNode(_ list: inout ArraySlice<DSLTree.Node>) throws -> ValueRegister? {
    guard let node = list.popFirst() else { return nil }
    switch node {
      
    case let .orderedChoice(children):
      let n = children.count
      try emitAlternation(&list, alternationCount: n)
      
    case let .concatenation(children):
      let n = children.count
      try emitConcatenation(&list, componentCount: n)
      
    case let .capture(name, refId, _, transform):
      options.beginScope()
      defer { options.endScope() }
      
      let cap = builder.makeCapture(id: refId, name: name)
      builder.buildBeginCapture(cap)
      let value = try emitNode(&list)
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
      
    case let .nonCapturingGroup(kind, _):
      try emitNoncapturingGroup(kind.ast, &list)
      
    case let .ignoreCapturesInTypedOutput(_):
      try emitNode(&list)
      
    case let .limitCaptureNesting(_):
      return try emitNode(&list)
      
    case .conditional:
      throw Unsupported("Conditionals")
      
    case let .quantification(amt, kind, _):
      try emitQuantification(amt.ast, kind, &list)
      
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

// MARK: Skip node

extension Compiler.ByteCodeGen {
  mutating func skipNode(
    _ list: inout ArraySlice<DSLTree.Node>,
    preservingCaptures: Bool = true
  ) throws {
    guard let node = list.popFirst() else { return }
    switch node {
    case let .orderedChoice(children):
      let n = children.count
      for _ in 0..<n {
        try skipNode(&list, preservingCaptures: preservingCaptures)
      }
      
    case let .concatenation(children):
      let n = children.count
      for _ in 0..<n {
        try skipNode(&list, preservingCaptures: preservingCaptures)
      }

    case let .capture(name, refId, _, transform):
      options.beginScope()
      defer { options.endScope() }
      
      if preservingCaptures {
        let cap = builder.makeCapture(id: refId, name: name)
        builder.buildBeginCapture(cap)
        try skipNode(&list, preservingCaptures: preservingCaptures)
        builder.buildEndCapture(cap)
      } else {
        try skipNode(&list, preservingCaptures: preservingCaptures)
      }
      
    case let .nonCapturingGroup(kind, _):
      try skipNode(&list, preservingCaptures: preservingCaptures)

    case .ignoreCapturesInTypedOutput:
      try skipNode(&list, preservingCaptures: preservingCaptures)
      
    case .limitCaptureNesting:
      try skipNode(&list, preservingCaptures: preservingCaptures)

    case let .quantification(amt, kind, _):
      try skipNode(&list, preservingCaptures: preservingCaptures)
      
    case .customCharacterClass, .atom, .quotedLiteral, .matcher:
      break
      
    case .conditional:
      throw Unsupported("Conditionals")
    case .absentFunction:
      throw Unsupported("absent function")
    case .consumer:
      throw Unsupported("consumer")
    case .characterPredicate:
      throw Unsupported("character predicates")
      
    case .trivia, .empty:
      break
    }
  }

}
