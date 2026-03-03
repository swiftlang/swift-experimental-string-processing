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
        // Custom expansion of emitAlternation for (?:newlineSequence|anyNonNewline)
        let done = builder.makeAddress()
        let next = builder.makeAddress()
        builder.buildSave(next)
        emitCharacterClass(.newlineSequence)
        builder.buildBranch(to: done)
        builder.label(next)
        emitAnyNonNewline()
        builder.label(done)
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
