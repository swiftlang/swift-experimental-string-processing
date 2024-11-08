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

internal import _RegexParser // For errors

extension MEProgram {
  struct Builder {
    var instructions: [Instruction] = []
    
    // Tracing
    var enableTracing = false
    var enableMetrics = false

    var elements = TypedSetVector<Input.Element, _ElementRegister>()
    var utf8Contents = TypedSetVector<[UInt8], _UTF8Register>()

    var asciiBitsets: [DSLTree.CustomCharacterClass.AsciiBitset] = []
    var consumeFunctions: [ConsumeFunction] = []
    var transformFunctions: [TransformFunction] = []
    var matcherFunctions: [MatcherFunction] = []

    // Map tokens to actual addresses
    var addressTokens: [InstructionAddress?] = []
    var addressFixups: [(InstructionAddress, AddressFixup)] = []

    // Registers
    var nextIntRegister = IntRegister(0)
    var nextValueRegister = ValueRegister(0)
    var nextPositionRegister = PositionRegister(0)

    // Set to non-nil when a value register holds the whole-match
    // value (i.e. when a regex consists entirely of a custom matcher)
    var wholeMatchValue: ValueRegister? = nil

    // Note: Capture 0 (i.e. whole-match) is handled specially
    // by the engine, so `n` here refers to the regex AST's `n+1`
    // capture
    var nextCaptureRegister = CaptureRegister(0)

    // Special addresses or instructions
    var failAddressToken: AddressToken? = nil

    var captureList = CaptureList()
    var initialOptions = MatchingOptions()

    // Starting constraint
    var canOnlyMatchAtStart = false
    
    // Symbolic reference resolution
    var unresolvedReferences: [ReferenceID: [InstructionAddress]] = [:]
    var referencedCaptureOffsets: [ReferenceID: Int] = [:]

    var captureCount: Int {
      // We currently deduce the capture count from the capture register number.
      nextCaptureRegister.rawValue
    }

    init() {}
  }
}

extension MEProgram.Builder {
  struct AddressFixup {
    var first: AddressToken
    var second: AddressToken? = nil

    init(_ a: AddressToken) { self.first = a }
    init(_ a: AddressToken, _ b: AddressToken) {
      self.first = a
      self.second = b
    }
  }

  // Maps the AST's named capture offset to a capture register
  func captureRegister(named name: String) throws -> CaptureRegister {
    guard let index = captureList.indexOfCapture(named: name) else {
      throw RegexCompilationError.uncapturedReference
    }
    return .init(index - 1)
  }

  // Map an AST's backreference number to a capture register
  func captureRegister(forBackreference i: Int) -> CaptureRegister {
    .init(i - 1)
  }

  mutating func denoteCurrentValueIsWholeMatchValue() {
    assert(wholeMatchValue == nil)
    wholeMatchValue = nextValueRegister
  }
}

extension MEProgram.Builder {
  // TODO: We want a better strategy for fixups, leaving
  // the operand in a different form isn't great...

  init<S: Sequence>(staticElements: S) where S.Element == Character {
    staticElements.forEach { elements.store($0) }
  }

  var lastInstructionAddress: InstructionAddress {
    .init(instructions.endIndex - 1)
  }

  mutating func buildFatalError() {
    instructions.append(.init(.invalid))
  }

  mutating func buildMoveImmediate(
    _ value: UInt64, into: IntRegister
  ) {
    instructions.append(.init(
      .moveImmediate, .init(immediate: value, int: into)))
  }

  // TODO: generic
  mutating func buildMoveImmediate(
    _ value: Int, into: IntRegister
  ) {
    let uint = UInt64(asserting: value)
    buildMoveImmediate(uint, into: into)
  }

  mutating func buildBranch(to t: AddressToken) {
    instructions.append(.init(.branch))
    fixup(to: t)
  }

  mutating func buildCondBranch(
    to t: AddressToken, ifZeroElseDecrement i: IntRegister
  ) {
    instructions.append(
      .init(.condBranchZeroElseDecrement, .init(int: i)))
    fixup(to: t)
  }

  mutating func buildCondBranch(
    to t: AddressToken,
    ifSamePositionAs r: PositionRegister
  ) {
    instructions.append(.init(.condBranchSamePosition, .init(position: r)))
    fixup(to: t)
  }

  mutating func buildSave(_ t: AddressToken) {
    instructions.append(.init(.save))
    fixup(to: t)
  }
  mutating func buildSaveAddress(_ t: AddressToken) {
    instructions.append(.init(.saveAddress))
    fixup(to: t)
  }
  mutating func buildSplit(
    to: AddressToken, saving: AddressToken
  ) {
    instructions.append(.init(.splitSaving))
    fixup(to: (to, saving))
  }

  mutating func buildClear() {
    instructions.append(.init(.clear))
  }
  mutating func buildClearThrough(_ t: AddressToken) {
    instructions.append(.init(.clearThrough))
    fixup(to: t)
  }
  mutating func buildFail(preservingCaptures: Bool = false) {
    instructions.append(.init(.fail, .init(bool: preservingCaptures)))
  }

  mutating func buildAdvance(_ n: Distance) {
    instructions.append(.init(.advance, .init(distance: n)))
  }
  
  mutating func buildAdvanceUnicodeScalar(_ n: Distance) {
    instructions.append(
      .init(.advance, .init(distance: n, isScalarDistance: true)))
  }
  
  mutating func buildConsumeNonNewline() {
    instructions.append(.init(.matchAnyNonNewline, .init(isScalar: false)))
  }
                        
  mutating func buildConsumeScalarNonNewline() {
    instructions.append(.init(.matchAnyNonNewline, .init(isScalar: true)))
  }

  mutating func buildMatch(_ e: Character, isCaseInsensitive: Bool) {
    instructions.append(.init(
      .match, .init(element: elements.store(e), isCaseInsensitive: isCaseInsensitive)))
  }

  mutating func buildMatchUTF8(_ utf8: Array<UInt8>, boundaryCheck: Bool) {
    instructions.append(.init(.matchUTF8, .init(
      utf8: utf8Contents.store(utf8), boundaryCheck: boundaryCheck)))
  }

  mutating func buildMatchScalar(_ s: Unicode.Scalar, boundaryCheck: Bool) {
    instructions.append(.init(.matchScalar, .init(scalar: s, caseInsensitive: false, boundaryCheck: boundaryCheck)))
  }
  
  mutating func buildMatchScalarCaseInsensitive(_ s: Unicode.Scalar, boundaryCheck: Bool) {
    instructions.append(.init(.matchScalar, .init(scalar: s, caseInsensitive: true, boundaryCheck: boundaryCheck)))
  }


  mutating func buildMatchAsciiBitset(
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
  ) {
    instructions.append(.init(
      .matchBitset, .init(bitset: makeAsciiBitset(b), isScalar: false)))
  }

  mutating func buildScalarMatchAsciiBitset(
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
  ) {
    instructions.append(.init(
      .matchBitset, .init(bitset: makeAsciiBitset(b), isScalar: true)))
  }
  
  mutating func buildMatchBuiltin(model: _CharacterClassModel) {
    instructions.append(.init(
      .matchBuiltin, .init(model)))
  }

  mutating func buildConsume(
    by p: @escaping MEProgram.ConsumeFunction
  ) {
    instructions.append(.init(
      .consumeBy, .init(consumer: makeConsumeFunction(p))))
  }

  mutating func buildAssert(
    by kind: DSLTree.Atom.Assertion,
    _ anchorsMatchNewlines: Bool,
    _ usesSimpleUnicodeBoundaries: Bool,
    _ usesASCIIWord: Bool,
    _ semanticLevel: MatchingOptions.SemanticLevel
  ) {
    let payload = AssertionPayload.init(
      kind,
      anchorsMatchNewlines,
      usesSimpleUnicodeBoundaries,
      usesASCIIWord,
      semanticLevel)
    instructions.append(.init(
      .assertBy,
      .init(assertion: payload)))
  }

  mutating func buildQuantify(
    bitset: DSLTree.CustomCharacterClass.AsciiBitset,
    _ kind: AST.Quantification.Kind,
    _ minTrips: Int,
    _ maxExtraTrips: Int?,
    isScalarSemantics: Bool
  ) {
    instructions.append(.init(
      .quantify,
      .init(quantify: .init(bitset: makeAsciiBitset(bitset), kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics))))
  }

  mutating func buildQuantify(
    asciiChar: UInt8,
    _ kind: AST.Quantification.Kind,
    _ minTrips: Int,
    _ maxExtraTrips: Int?,
    isScalarSemantics: Bool
  ) {
    instructions.append(.init(
      .quantify,
      .init(quantify: .init(asciiChar: asciiChar, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics))))
  }

  mutating func buildQuantifyAny(
    matchesNewlines: Bool,
    _ kind: AST.Quantification.Kind,
    _ minTrips: Int,
    _ maxExtraTrips: Int?,
    isScalarSemantics: Bool
  ) {
    instructions.append(.init(
      .quantify,
      .init(quantify: .init(matchesNewlines: matchesNewlines, kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics))))
  }

  mutating func buildQuantify(
    model: _CharacterClassModel,
    _ kind: AST.Quantification.Kind,
    _ minTrips: Int,
    _ maxExtraTrips: Int?,
    isScalarSemantics: Bool
  ) {
    instructions.append(.init(
      .quantify,
      .init(quantify: .init(model: model,kind, minTrips, maxExtraTrips, isScalarSemantics: isScalarSemantics))))
  }

  mutating func buildAccept() {
    instructions.append(.init(.accept))
  }

  mutating func buildBeginCapture(
    _ cap: CaptureRegister
  ) {
    instructions.append(
      .init(.beginCapture, .init(capture: cap)))
  }

  mutating func buildEndCapture(
    _ cap: CaptureRegister
  ) {
    instructions.append(
      .init(.endCapture, .init(capture: cap)))
  }

  mutating func buildTransformCapture(
    _ cap: CaptureRegister, _ trans: TransformRegister
  ) {
    instructions.append(.init(
      .transformCapture,
      .init(capture: cap, transform: trans)))
  }

  mutating func buildMatcher(
    _ fun: MatcherRegister, into reg: ValueRegister
  ) {
    instructions.append(.init(
      .matchBy,
      .init(matcher: fun, value: reg)))
  }

  mutating func buildMove(
    _ value: ValueRegister, into capture: CaptureRegister
  ) {
    instructions.append(.init(
      .captureValue,
      .init(value: value, capture: capture)))
  }

  mutating func buildMoveCurrentPosition(into r: PositionRegister) {
    instructions.append(.init(.moveCurrentPosition, .init(position: r)))
  }

  mutating func buildRestorePosition(from r: PositionRegister) {
    instructions.append(.init(.restorePosition, .init(position: r)))
  }

  mutating func buildBackreference(
    _ cap: CaptureRegister,
    isScalarMode: Bool
  ) {
    instructions.append(
      .init(.backreference, .init(capture: cap, isScalarMode: isScalarMode)))
  }

  mutating func buildUnresolvedReference(id: ReferenceID, isScalarMode: Bool) {
    buildBackreference(.init(0), isScalarMode: isScalarMode)
    unresolvedReferences[id, default: []].append(lastInstructionAddress)
  }

  mutating func buildNamedReference(_ name: String, isScalarMode: Bool) throws {
    let cap = try captureRegister(named: name)
    buildBackreference(cap, isScalarMode: isScalarMode)
  }

  // TODO: Mutating because of fail address fixup, drop when
  // that's removed
  mutating func assemble() throws -> MEProgram {
    try resolveReferences()

    // TODO: This will add a fail instruction at the end every
    // time it's assembled. Better to do to the local instruction
    // list copy, but that complicates logic. It's possible we
    // end up going a different route all-together eventually,
    // though.
    if let tok = failAddressToken {
      label(tok)
      buildFail()
    }

    // Do a pass to map address tokens to addresses
    var instructions = instructions
    for (instAddr, tok) in addressFixups {
      // FIXME: based on opcode, decide if we split...
      // Unfortunate...
      let inst = instructions[instAddr.rawValue]
      let addr = addressTokens[tok.first.rawValue]!
      let payload: Instruction.Payload

      switch inst.opcode {
      case .condBranchZeroElseDecrement:
        payload = .init(addr: addr, int: inst.payload.int)
      case .condBranchSamePosition:
        payload = .init(addr: addr, position: inst.payload.position)
      case .branch, .save, .saveAddress, .clearThrough:
        payload = .init(addr: addr)

      case .splitSaving:
        guard let fix2 = tok.second else {
          throw Unreachable("TODO: reason")
        }
        let saving = addressTokens[fix2.rawValue]!
        payload = .init(addr: addr, addr2: saving)

      default: throw Unreachable("TODO: reason")

      }

      instructions[instAddr.rawValue] = .init(
        inst.opcode, payload)
    }

    var regInfo = MEProgram.RegisterInfo()
    regInfo.elements = elements.count
    regInfo.utf8Contents = utf8Contents.count
    regInfo.ints = nextIntRegister.rawValue
    regInfo.values = nextValueRegister.rawValue
    regInfo.positions = nextPositionRegister.rawValue
    regInfo.bitsets = asciiBitsets.count
    regInfo.consumeFunctions = consumeFunctions.count
    regInfo.transformFunctions = transformFunctions.count
    regInfo.matcherFunctions = matcherFunctions.count
    regInfo.captures = nextCaptureRegister.rawValue
    regInfo.wholeMatchValue = wholeMatchValue?.rawValue

    return MEProgram(
      instructions: InstructionList(instructions),
      staticElements: elements.stored,
      staticUTF8Contents: utf8Contents.stored,
      staticBitsets: asciiBitsets,
      staticConsumeFunctions: consumeFunctions,
      staticTransformFunctions: transformFunctions,
      staticMatcherFunctions: matcherFunctions,
      registerInfo: regInfo,
      enableTracing: enableTracing,
      enableMetrics: enableMetrics,
      captureList: captureList,
      referencedCaptureOffsets: referencedCaptureOffsets,
      initialOptions: initialOptions,
      canOnlyMatchAtStart: canOnlyMatchAtStart)
  }

  mutating func reset() { self = Self() }
}

// Address-agnostic interfaces for label-like support
extension MEProgram.Builder {
  enum _AddressToken {}
  typealias AddressToken = TypedInt<_AddressToken>

  mutating func makeAddress() -> AddressToken {
    defer { addressTokens.append(nil) }
    return AddressToken(addressTokens.count)
  }

  // Resolves the address token to the most recently added
  // instruction, updating prior and future address references
  mutating func resolve(_ t: AddressToken) {
    assert(!instructions.isEmpty)

    addressTokens[t.rawValue] =
      InstructionAddress(instructions.count &- 1)
  }

  // Resolves the address token to the next instruction (one past the most
  // recently added one), updating prior and future address references.
  mutating func label(_ t: AddressToken) {
    addressTokens[t.rawValue] =
      InstructionAddress(instructions.count)
  }

  // Associate the most recently added instruction with
  // the provided token, ensuring it is fixed up during
  // assembly
  mutating func fixup(to t: AddressToken) {
    assert(!instructions.isEmpty)
    addressFixups.append(
      (InstructionAddress(instructions.endIndex-1), .init(t)))
  }

  // Associate the most recently added instruction with
  // the provided tokens, ensuring it is fixed up during
  // assembly
  mutating func fixup(
    to ts: (AddressToken, AddressToken)
  ) {
    assert(!instructions.isEmpty)
    addressFixups.append((
      InstructionAddress(instructions.endIndex-1),
      .init(ts.0, ts.1)))
  }

  // Push an "empty" save point which will, upon restore, just restore from
  // the next save point. Currently, this is modelled by a branch to a "fail"
  // instruction, which the builder will ensure exists for us.
  //
  // This is useful for possessive quantification that needs some initial save
  // point to "ratchet" upon a successful match.
  mutating func pushEmptySavePoint() {
    if failAddressToken == nil {
      failAddressToken = makeAddress()
    }
    buildSaveAddress(failAddressToken!)
  }

}

// Symbolic reference helpers
fileprivate extension MEProgram.Builder {
  mutating func resolveReferences() throws {
    for (id, uses) in unresolvedReferences {
      guard let offset = referencedCaptureOffsets[id] else {
        throw RegexCompilationError.uncapturedReference
      }
      for use in uses {
        let (isScalarMode, _) = instructions[use.rawValue].payload.captureAndMode
        instructions[use.rawValue] =
          Instruction(.backreference,
            .init(capture: .init(offset), isScalarMode: isScalarMode))
      }
    }
  }
}

// Register helpers
extension MEProgram.Builder {
  mutating func makeCapture(
    id: ReferenceID?, name: String?
  ) -> CaptureRegister {
    defer { nextCaptureRegister.rawValue += 1 }
    // Register the capture for later lookup via symbolic references.
    if let id = id {
      let preexistingValue = referencedCaptureOffsets.updateValue(
        captureCount, forKey: id)
      assert(preexistingValue == nil)
    }
    if let name = name {
      let cap = try? captureRegister(named: name)
      assert(cap == nextCaptureRegister)
    }
    assert(nextCaptureRegister.rawValue < captureList.captures.count)
    return nextCaptureRegister
  }

  mutating func makeIntRegister() -> IntRegister {
    defer { nextIntRegister.rawValue += 1 }
    return nextIntRegister
  }
  mutating func makeValueRegister() -> ValueRegister {
    defer { nextValueRegister.rawValue += 1 }
    return nextValueRegister
  }

  // Allocate and initialize a register
  mutating func makeIntRegister(
    initialValue: Int
  ) -> IntRegister {
    let r = makeIntRegister()
    self.buildMoveImmediate(initialValue, into: r)
    return r
  }

  mutating func makePositionRegister() -> PositionRegister {
    let r = nextPositionRegister
    defer { nextPositionRegister.rawValue += 1 }
    return r
  }

  // TODO: A register-mapping helper struct, which could release
  // registers without monotonicity required

  mutating func makeAsciiBitset(
    _ b: DSLTree.CustomCharacterClass.AsciiBitset
  ) -> AsciiBitsetRegister {
    defer { asciiBitsets.append(b) }
    return AsciiBitsetRegister(asciiBitsets.count)
  }
  
  mutating func makeConsumeFunction(
    _ f: @escaping MEProgram.ConsumeFunction
  ) -> ConsumeFunctionRegister {
    defer { consumeFunctions.append(f) }
    return ConsumeFunctionRegister(consumeFunctions.count)
  }
  mutating func makeTransformFunction(
    _ f: @escaping MEProgram.TransformFunction
  ) -> TransformRegister {
    defer { transformFunctions.append(f) }
    return TransformRegister(transformFunctions.count)
  }
  mutating func makeMatcherFunction(
    _ f: @escaping MEProgram.MatcherFunction
  ) -> MatcherRegister {
    defer { matcherFunctions.append(f) }
    return MatcherRegister(matcherFunctions.count)
  }
}

