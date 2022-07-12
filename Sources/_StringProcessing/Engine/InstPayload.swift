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
@_implementationOnly import _RegexParser // For AssertionKind

extension Instruction {
  /// An instruction's payload packs operands and destination
  /// registers.
  ///
  /// A payload is 56 bits and its contents structurally depend
  /// on the specific instruction
  struct Payload: RawRepresentable {
    var rawValue: UInt64
    init(rawValue: UInt64) {
      assert(rawValue == rawValue & _payloadMask)
      self.rawValue = rawValue
      // TODO: post conditions
    }
  }
}

extension Instruction.Payload {
  // For modeling, perhaps tooling, but likely not for
  // execution
  private enum Kind {
    // TODO: We should choose operand ordering based on codegen
    //
    // For now, we do:
    //   Immediate < InstAddr < ConsumeFuncReg < ElementReg
    //   (compile)   (link)     (link)           (link)
    //
    //   ... < BoolReg < IntReg
    //
    // That is, optimization-time constant, link-time constant,
    // and variables

    case string(StringRegister)
    case sequence(SequenceRegister)
    case position(PositionRegister)
    case optionalString(StringRegister?)
    case int(IntRegister)
    case distance(Distance)
    case bool(BoolRegister)
    case element(ElementRegister)
    case consumer(ConsumeFunctionRegister)
    case bitset(AsciiBitsetRegister)
    case addr(InstructionAddress)
    case capture(CaptureRegister)

    case packedImmInt(Int, IntRegister)
    case packedAddrBool(InstructionAddress, BoolRegister)
    case packedAddrInt(InstructionAddress, IntRegister)
    case packedAddrAddr(InstructionAddress, InstructionAddress)
    case packedBoolInt(BoolRegister, IntRegister)
    case packedEltBool(ElementRegister, BoolRegister)
    case packedPosPos(PositionRegister, PositionRegister)
    case packedCapTran(CaptureRegister, TransformRegister)
    case packedMatchVal(MatcherRegister, ValueRegister)
    case packedValueCapture(ValueRegister, CaptureRegister)
  }
}

// MARK: - Payload getters

extension Instruction.Payload {
  /// A `nil` payload, for e.g. StringRegister?
  static var nilPayload: Self {
    self.init(rawValue: _payloadMask)
  }

  private init(_ r: UInt64) {
    self.init(rawValue: r)
  }
  private init<👻>(_ r: TypedInt<👻>) {
    self.init(r.bits)
  }
  private init<👻>(_ r: TypedInt<👻>?) {
    if let r = r {
      self.init(r)
    } else {
      self = .nilPayload
    }
  }

  // Two values packed together
  //
  // For now, we just use 16 bits, because if that's good enough
  // for 1990s Unicode it's good enough for us.
  //
  // TODO: but really, let's come up with something
  private var firstSplitMask: UInt64 { 0x0000_FFFF }
  private var secondSplitMask: UInt64 { 0xFFFF_0000 }

  private var split: (first: UInt64, second: UInt64) {
    assert(rawValue == ((firstSplitMask|secondSplitMask) & rawValue))

    // TODO: Which order is better?
    let first = rawValue & firstSplitMask
    let second = (rawValue & secondSplitMask) &>> 16
    return (first, second)
  }

  private init(_ a: UInt64, _ b: UInt64) {
    self.init(a | (b &<< 16))
    assert(a == a & firstSplitMask)
    assert(b == b & firstSplitMask)
  }
  private init<👻>(_ a: UInt64, _ b: TypedInt<👻>) {
    self.init(a, b.bits)
  }
  private init<👻, 👺>(_ a: TypedInt<👻>, _ b: TypedInt<👺>) {
    self.init(a.bits, b.bits)
  }

  private func interpret<👻>(
    as: TypedInt<👻>.Type = TypedInt<👻>.self
  ) -> TypedInt<👻> {
    // TODO: We'd like to use shadow bits to assert on kind
    return TypedInt(rawValue)
  }

  private func interpretPair<👻>(
    secondAs: TypedInt<👻>.Type = TypedInt<👻>.self
  ) -> (UInt64, TypedInt<👻>) {
    (split.first, TypedInt(split.second) )
  }
  private func interpretPair<👻, 👺>(
    firstAs: TypedInt<👻>.Type = TypedInt<👻>.self,
    secondAs: TypedInt<👺>.Type = TypedInt<👺>.self
  ) -> (TypedInt<👻>, TypedInt<👺>) {
    (TypedInt(split.first), TypedInt(split.second) )
  }

  // MARK: Single operand payloads

  init(string: StringRegister) {
    self.init(string)
  }
  var string: StringRegister {
    interpret()
  }

  init(sequence: SequenceRegister) {
    self.init(sequence)
  }
  var sequence: SequenceRegister {
    interpret()
  }

  init(optionalString: StringRegister?) {
    self.init(optionalString)
  }
  var optionalString: StringRegister? {
    interpret()
  }

  init(position: PositionRegister) {
    self.init(position)
  }
  var position: PositionRegister {
    interpret()
  }

  init(int: IntRegister) {
    self.init(int)
  }
  var int: IntRegister {
    interpret()
  }

  init(distance: Distance) {
    self.init(distance)
  }
  var distance: Distance {
    interpret()
  }

  init(bool: BoolRegister) {
    self.init(bool)
  }
  var bool: BoolRegister {
    interpret()
  }

  init(element: ElementRegister) {
    self.init(element)
  }
  var element: ElementRegister {
    interpret()
  }

  init(bitset: AsciiBitsetRegister) {
    self.init(bitset)
  }
  var bitset: AsciiBitsetRegister {
    interpret()
  }

  init(_ cc: BuiltinCC, _ isStrict: Bool, _ isScalar: Bool) {
    let strictBit = isStrict ? 1 << 15 : 0
    let scalarBit = isScalar ? 1 << 14 : 0
    // val must be 16 bits, reserve the top 2 bits for if it is strict ascii or scalar
    assert(cc.rawValue <= 0x3F_FF)
    let val = cc.rawValue + UInt64(strictBit) + UInt64(scalarBit)
    self.init(val)
  }
  var builtinCCPayload: (cc: BuiltinCC, isStrict: Bool, isScalar: Bool) {
    let val = self.rawValue
    let cc = BuiltinCC(rawValue: val & 0x3F_FF)!
    let isStrict = (val >> 15) & 1 == 1
    let isScalar = (val >> 14) & 1 == 1
    return (cc, isStrict, isScalar)
  }
  
  init(consumer: ConsumeFunctionRegister) {
    self.init(consumer)
  }
  var consumer: ConsumeFunctionRegister {
    interpret()
  }

  var _assertionKindMask: UInt64 { ~0xFFF0_0000_0000_0000 }
  init(assertion: AST.Atom.AssertionKind,
       _ anchorsMatchNewlines: Bool,
       _ usesSimpleUnicodeBoundaries: Bool,
       _ usesASCIIWord: Bool,
       _ semanticLevel: MatchingOptions.SemanticLevel
  ) {
    // 4 bits of options
    let anchorBit: UInt64 = anchorsMatchNewlines ? (1 << 55) : 0
    let boundaryBit: UInt64 = usesSimpleUnicodeBoundaries ? (1 << 54) : 0
    let strictBit: UInt64 = usesASCIIWord ? (1 << 53) : 0
    let semanticLevelBit: UInt64 = semanticLevel == .unicodeScalar ? (1 << 52) : 0
    let optionsBits: UInt64 = anchorBit + boundaryBit + strictBit + semanticLevelBit

    // 4 bits for the assertion kind
    // Future work: Optimize this layout
    let kind: UInt64
    switch assertion {
    case .endOfLine: kind = 0
    case .endOfSubject: kind = 1
    case .endOfSubjectBeforeNewline: kind = 2
    case .firstMatchingPositionInSubject: kind = 3
    case .notTextSegment: kind = 4
    case .notWordBoundary: kind = 5
    case .resetStartOfMatch: kind = 6
    case .startOfLine: kind = 7
    case .startOfSubject: kind = 8
    case .textSegment: kind = 9
    case .wordBoundary: kind = 10
    }
    self.init(rawValue: kind + optionsBits)
  }
  var assertion: (AST.Atom.AssertionKind, Bool, Bool, Bool, MatchingOptions.SemanticLevel) {
    let anchorsMatchNewlines = (self.rawValue >> 55) & 1 == 1
    let usesSimpleUnicodeBoundaries = (self.rawValue >> 54) & 1 == 1
    let usesASCIIWord = (self.rawValue >> 53) & 1 == 1
    let semanticLevel: MatchingOptions.SemanticLevel
    if (self.rawValue >> 52) & 1 == 1 {
      semanticLevel = .unicodeScalar
    } else {
      semanticLevel = .graphemeCluster
    }
    let kind: AST.Atom.AssertionKind
    switch self.rawValue & _assertionKindMask {
    case 0: kind = .endOfLine
    case 1: kind = .endOfSubject
    case 2: kind = .endOfSubjectBeforeNewline
    case 3: kind = .firstMatchingPositionInSubject
    case 4: kind = .notTextSegment
    case 5: kind = .notWordBoundary
    case 6: kind = .resetStartOfMatch
    case 7: kind = .startOfLine
    case 8: kind = .startOfSubject
    case 9: kind = .textSegment
    case 10: kind = .wordBoundary
    default: fatalError("Unreachable")
    }
    return (kind, anchorsMatchNewlines, usesSimpleUnicodeBoundaries, usesASCIIWord, semanticLevel)
  }

  init(addr: InstructionAddress) {
    self.init(addr)
  }
  var addr: InstructionAddress {
    interpret()
  }

  init(capture: CaptureRegister) {
    self.init(capture)
  }
  var capture: CaptureRegister {
    interpret()
  }


  // MARK: Packed operand payloads

  init(immediate: UInt64, int: IntRegister) {
    self.init(immediate, int)
  }
  var pairedImmediateInt: (UInt64, IntRegister) {
    interpretPair()
  }

  init(immediate: UInt64, bool: BoolRegister) {
    self.init(immediate, bool)
  }
  var pairedImmediateBool: (UInt64, BoolRegister) {
    interpretPair()
  }

  init(addr: InstructionAddress, bool: BoolRegister) {
    self.init(addr, bool)
  }
  var pairedAddrBool: (InstructionAddress, BoolRegister) {
    interpretPair()
  }

  init(addr: InstructionAddress, int: IntRegister) {
    self.init(addr, int)
  }
  var pairedAddrInt: (InstructionAddress, IntRegister) {
    interpretPair()
  }

  init(addr: InstructionAddress, addr2: InstructionAddress) {
    self.init(addr, addr2)
  }
  var pairedAddrAddr: (InstructionAddress, InstructionAddress) {
    interpretPair()
  }

  init(bool: BoolRegister, int: IntRegister) {
    self.init(bool, int)
  }
  var pairedBoolInt: (BoolRegister, IntRegister) {
    interpretPair()
  }

  init(element: ElementRegister, bool: BoolRegister) {
    self.init(element, bool)
  }
  var pairedElementBool: (ElementRegister, BoolRegister) {
    interpretPair()
  }

  init(addr: InstructionAddress, position: PositionRegister) {
    self.init(addr, position)
  }
  var pairedAddrPos: (InstructionAddress, PositionRegister) {
    interpretPair()
  }

  init(capture: CaptureRegister, transform: TransformRegister) {
    self.init(capture, transform)
  }
  var pairedCaptureTransform: (
    CaptureRegister, TransformRegister
  ) {
    interpretPair()
  }

  init(value: ValueRegister, capture: CaptureRegister) {
    self.init(value, capture)
  }
  var pairedValueCapture: (
    ValueRegister, CaptureRegister
  ) {
    interpretPair()
  }

  init(matcher: MatcherRegister, value: ValueRegister) {
    self.init(matcher, value)
  }
  var pairedMatcherValue: (
    MatcherRegister, ValueRegister
  ) {
    interpretPair()
  }
}

