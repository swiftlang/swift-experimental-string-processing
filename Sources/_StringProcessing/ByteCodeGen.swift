@_implementationOnly import _RegexParser

extension Compiler {
  struct ByteCodeGen {
    var options: MatchingOptions
    var builder = Program.Builder()
    /// A Boolean indicating whether the first matchable atom has been emitted.
    /// This is used to determine whether to apply initial options.
    var hasEmittedFirstMatchableAtom = false

    init(options: MatchingOptions, captureList: CaptureList) {
      self.options = options
      self.builder.captureList = captureList
    }
  }
}

extension Compiler.ByteCodeGen {
  mutating func emitRoot(_ root: DSLTree.Node) throws -> Program {
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

    case let .char(c):
      try emitCharacter(c)

    case let .scalar(s):
      try emitScalar(s)

    case let .assertion(kind):
      try emitAssertion(kind.ast)

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

  mutating func emitBackreference(
    _ ref: AST.Reference
  ) throws {
    if ref.recursesWholePattern {
      // TODO: A recursive call isn't a backreference, but
      // we could in theory match the whole match so far...
      throw Unsupported("Backreference kind: \(ref)")
    }

    switch ref.kind {
    case .absolute(let i):
      builder.buildBackreference(.init(i))
    case .named(let name):
      try builder.buildNamedReference(name)
    case .relative:
      throw Unsupported("Backreference kind: \(ref)")
    }
  }

  mutating func emitAssertion(
    _ kind: AST.Atom.AssertionKind
  ) throws {
    // FIXME: Depends on API model we have... We may want to
    // think through some of these with API interactions in mind
    //
    // This might break how we use `bounds` for both slicing
    // and things like `firstIndex`, that is `firstIndex` may
    // need to supply both a slice bounds and a per-search bounds.
    switch kind {
    case .startOfSubject:
      builder.buildAssert { (input, pos, bounds) in
        pos == input.startIndex
      }

    case .endOfSubjectBeforeNewline:
      builder.buildAssert { [semanticLevel = options.semanticLevel] (input, pos, bounds) in
        if pos == input.endIndex { return true }
        switch semanticLevel {
        case .graphemeCluster:
          return input.index(after: pos) == input.endIndex
           && input[pos].isNewline
        case .unicodeScalar:
          return input.unicodeScalars.index(after: pos) == input.endIndex
           && input.unicodeScalars[pos].isNewline
        }
      }

    case .endOfSubject:
      builder.buildAssert { (input, pos, bounds) in
        pos == input.endIndex
      }

    case .resetStartOfMatch:
      // FIXME: Figure out how to communicate this out
      throw Unsupported(#"\K (reset/keep assertion)"#)

    case .firstMatchingPositionInSubject:
      // TODO: We can probably build a nice model with API here
      builder.buildAssert { (input, pos, bounds) in
        pos == bounds.lowerBound
      }

    case .textSegment:
      builder.buildAssert { (input, pos, _) in
        // FIXME: Grapheme or word based on options
        input.isOnGraphemeClusterBoundary(pos)
      }

    case .notTextSegment:
      builder.buildAssert { (input, pos, _) in
        // FIXME: Grapheme or word based on options
        !input.isOnGraphemeClusterBoundary(pos)
      }

    case .startOfLine:
      if options.anchorsMatchNewlines {
        builder.buildAssert { [semanticLevel = options.semanticLevel] (input, pos, bounds) in
          if pos == input.startIndex { return true }
          switch semanticLevel {
          case .graphemeCluster:
            return input[input.index(before: pos)].isNewline
          case .unicodeScalar:
            return input.unicodeScalars[input.unicodeScalars.index(before: pos)].isNewline
          }
        }
      } else {
        builder.buildAssert { (input, pos, bounds) in
          pos == input.startIndex
        }
      }
      
    case .endOfLine:
      if options.anchorsMatchNewlines {
        builder.buildAssert { [semanticLevel = options.semanticLevel] (input, pos, bounds) in
          if pos == input.endIndex { return true }
          switch semanticLevel {
          case .graphemeCluster:
            return input[pos].isNewline
          case .unicodeScalar:
            return input.unicodeScalars[pos].isNewline
          }
        }
      } else {
        builder.buildAssert { (input, pos, bounds) in
          pos == input.endIndex
        }
      }

    case .wordBoundary:
      // TODO: May want to consider Unicode level
      builder.buildAssert { [options] (input, pos, bounds) in
        // TODO: How should we handle bounds?
        _CharacterClassModel.word.isBoundary(
          input, at: pos, bounds: bounds, with: options)
      }

    case .notWordBoundary:
      // TODO: May want to consider Unicode level
      builder.buildAssert { [options] (input, pos, bounds) in
        // TODO: How should we handle bounds?
        !_CharacterClassModel.word.isBoundary(
          input, at: pos, bounds: bounds, with: options)
      }
    }
  }
  
  mutating func emitScalar(_ s: UnicodeScalar) throws {
    // TODO: Native instruction buildMatchScalar(s)
    if options.isCaseInsensitive {
      // TODO: e.g. buildCaseInsensitiveMatchScalar(s)
      builder.buildConsume(by: consumeScalar {
        $0.properties.lowercaseMapping == s.properties.lowercaseMapping
      })
    } else {
      builder.buildConsume(by: consumeScalar {
        $0 == s
      })
    }
  }
  
  mutating func emitCharacter(_ c: Character) throws {
    // Unicode scalar matches the specific scalars that comprise a character
    if options.semanticLevel == .unicodeScalar {
      for scalar in c.unicodeScalars {
        try emitScalar(scalar)
      }
      return
    }
    
    if options.isCaseInsensitive && c.isCased {
      // TODO: buildCaseInsensitiveMatch(c) or buildMatch(c, caseInsensitive: true)
      builder.buildConsume { input, bounds in
        let inputChar = input[bounds.lowerBound].lowercased()
        let matchChar = c.lowercased()
        return inputChar == matchChar
          ? input.index(after: bounds.lowerBound)
          : nil
      }
    } else {
      builder.buildMatch(c)
    }
  }

  mutating func emitAny() {
    switch (options.semanticLevel, options.dotMatchesNewline) {
    case (.graphemeCluster, true):
      builder.buildAdvance(1)
    case (.graphemeCluster, false):
      builder.buildConsume { input, bounds in
        input[bounds.lowerBound].isNewline
        ? nil
        : input.index(after: bounds.lowerBound)
      }

    case (.unicodeScalar, true):
      // TODO: builder.buildAdvanceUnicodeScalar(1)
      builder.buildConsume { input, bounds in
        input.unicodeScalars.index(after: bounds.lowerBound)
      }
    case (.unicodeScalar, false):
      builder.buildConsume { input, bounds in
        input[bounds.lowerBound].isNewline
        ? nil
        : input.unicodeScalars.index(after: bounds.lowerBound)
      }
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
      clearSavePoint   // remove intercept
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
    builder.buildClear()
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
        evaluate the subexpression
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
    try emitNode(child)
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

  mutating func emitCustomCharacterClass(
    _ ccc: DSLTree.CustomCharacterClass
  ) throws {
    let consumer = try ccc.generateConsumer(options)
    builder.buildConsume(by: consumer)
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
        let fn = builder.makeTransformFunction { input, storedCapture in
          // If it's a substring capture with no custom value, apply the
          // transform directly to the substring to avoid existential traffic.
          if let cap = storedCapture.latest, cap.value == nil {
            return try transform(input[cap.range])
          }
          let value = constructExistentialOutputComponent(
             from: input,
             component: storedCapture.latest,
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
      if ccc.containsAny {
        if !ccc.isInverted {
          emitAny()
        } else {
          throw Unsupported("Inverted any")
        }
      } else {
        try emitCustomCharacterClass(ccc)
      }

    case let .atom(a):
      try emitAtom(a)

    case let .quotedLiteral(s):
      if options.semanticLevel == .graphemeCluster {
        if options.isCaseInsensitive {
          // TODO: buildCaseInsensitiveMatchSequence(c) or alternative
          builder.buildConsume { input, bounds in
            var iterator = s.makeIterator()
            var currentIndex = bounds.lowerBound
            while let ch = iterator.next() {
              guard currentIndex < bounds.upperBound,
                    ch.lowercased() == input[currentIndex].lowercased()
              else { return nil }
              input.formIndex(after: &currentIndex)
            }
            return currentIndex
          }
        } else {
          builder.buildMatchSequence(s)
        }
      } else {
        builder.buildConsume {
          [caseInsensitive = options.isCaseInsensitive] input, bounds in
          // TODO: Case folding
          var iterator = s.unicodeScalars.makeIterator()
          var currentIndex = bounds.lowerBound
          while let scalar = iterator.next() {
            guard currentIndex < bounds.upperBound else { return nil }
            if caseInsensitive {
              if scalar.properties.lowercaseMapping != input.unicodeScalars[currentIndex].properties.lowercaseMapping {
                return nil
              }
            } else {
              if scalar != input.unicodeScalars[currentIndex] {
                return nil
              }
            }
            input.unicodeScalars.formIndex(after: &currentIndex)
          }
          return currentIndex
        }
      }

    case let .regexLiteral(l):
      return try emitNode(l.ast.dslTreeNode)

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
