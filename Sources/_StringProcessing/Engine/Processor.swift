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

enum MatchMode {
  case wholeString
  case partialFromFront
}

/// A concrete CU. Somehow will run the concrete logic and
/// feed stuff back to generic code
struct Controller: Equatable {
  var pc: InstructionAddress

  mutating func step() {
    pc.rawValue += 1
  }
}

struct Processor {
  typealias Input = String
  typealias Element = Input.Element

  /// The base collection of the subject to search.
  ///
  /// Taken together, `input` and `subjectBounds` define the actual subject
  /// of the search. `input` can be a "supersequence" of the subject, while
  /// `input[subjectBounds]` is the logical entity that is being searched.
  let input: Input

  /// The bounds of the logical subject in `input`.
  ///
  /// `subjectBounds` represents the bounds of the string or substring that a
  /// regex operation is invoked upon. Anchors like `^` and `.startOfSubject`
  /// always use `subjectBounds` as their reference points, instead of
  /// `input`'s boundaries or `searchBounds`.
  ///
  /// `subjectBounds` is always equal to or a subrange of
  /// `input.startIndex..<input.endIndex`.
  let subjectBounds: Range<Position>

  let matchMode: MatchMode

  let instructions: InstructionList<Instruction>

  // MARK: Update-only state

  var wordIndexCache: Set<String.Index>? = nil
  var wordIndexMaxIndex: String.Index? = nil

  // MARK: Resettable state

  /// The bounds within the subject for an individual search.
  ///
  /// `searchBounds` is equal to `subjectBounds` in some cases, but can be a
  /// subrange when performing operations like searching for matches iteratively
  /// or calling `str.replacing(_:with:subrange:)`.
  ///
  /// Anchors like `^` and `.startOfSubject` use `subjectBounds` instead of
  /// `searchBounds`. The "start of matching" anchor `\G` uses `searchBounds`
  /// as its starting point.
  var searchBounds: Range<Position>

  /// The current search position while processing.
  ///
  /// `currentPosition` must always be in the range `subjectBounds` or equal
  /// to `subjectBounds.upperBound`.
  var currentPosition: Position

  var controller: Controller

  var registers: Registers

  var savePoints: [SavePoint] = []

  var storedCaptures: Array<_StoredCapture>

  var state: State = .inProgress

  var failureReason: Error? = nil

  var metrics: ProcessorMetrics
}

extension Processor {
  typealias Position = Input.Index

  var start: Position { searchBounds.lowerBound }
  var end: Position { searchBounds.upperBound }
}

extension Processor {
  // TODO: This has lots of retain/release traffic. We really just
  // want to borrow the program and most of its static stuff. The only
  // thing we need an actual copy of is the modifyable-resettable state
  init(
    program: MEProgram,
    input: Input,
    subjectBounds: Range<Position>,
    searchBounds: Range<Position>,
    matchMode: MatchMode
  ) {
    self.controller = Controller(pc: 0)
    self.instructions = program.instructions
    self.input = input
    self.subjectBounds = subjectBounds
    self.searchBounds = searchBounds
    self.matchMode = matchMode

    self.metrics = ProcessorMetrics(
      isTracingEnabled: program.enableTracing,
      shouldMeasureMetrics: program.enableMetrics)

    self.currentPosition = searchBounds.lowerBound

    // Initialize registers from stored starting state
    self.registers = program.registers

    self.storedCaptures = program.storedCaptures

    _checkInvariants()
  }

  mutating func reset(
    currentPosition: Position,
    searchBounds: Range<Position>
  ) {
    self.currentPosition = currentPosition
    self.searchBounds = searchBounds

    self.controller = Controller(pc: 0)

    self.registers.reset()

    if !self.savePoints.isEmpty {
      self.savePoints.removeAll(keepingCapacity: true)
    }

    for idx in storedCaptures.indices {
      storedCaptures[idx] = .init()
    }

    self.state = .inProgress
    self.failureReason = nil

    metrics.addReset()
    _checkInvariants()
  }

  // Check that resettable state has been reset. Note that `reset()`
  // takes a new current position and search bounds.
  func isReset() -> Bool {
    _checkInvariants()
    guard self.controller == Controller(pc: 0),
          self.savePoints.isEmpty,
          self.storedCaptures.allSatisfy({ $0.range == nil }),
          self.state == .inProgress,
          self.failureReason == nil
    else {
      return false
    }
    return true
  }

  func _checkInvariants() {
    assert(searchBounds.lowerBound >= subjectBounds.lowerBound)
    assert(searchBounds.upperBound <= subjectBounds.upperBound)
    assert(subjectBounds.lowerBound >= input.startIndex)
    assert(subjectBounds.upperBound <= input.endIndex)
    assert(currentPosition >= searchBounds.lowerBound)
    assert(currentPosition <= searchBounds.upperBound)
  }
}

extension Processor {
  func fetch() -> (Instruction.OpCode, Instruction.Payload) {
    instructions[controller.pc].destructure
  }

  var slice: Input.SubSequence {
    // TODO: Should we whole-scale switch to slices, or
    // does that depend on options for some anchors?
    input[searchBounds]
  }

  // Advance in our input
  //
  // Returns whether the advance succeeded. On failure, our
  // save point was restored
  mutating func consume(_ n: Distance) -> Bool {
    // TODO: needs benchmark coverage
    if let idx = input.index(
      currentPosition, offsetBy: n.rawValue, limitedBy: end
    ) {
      currentPosition = idx
      return true
    }

    // If `end` falls in the middle of a character, and we are trying to advance
    // by one "character", then we should max out at `end` even though the above
    // advancement will result in `nil`.
    if n == 1, let idx = input.unicodeScalars.index(
      currentPosition, offsetBy: n.rawValue, limitedBy: end
    ) {
      currentPosition = idx
      return true
    }

    signalFailure()
    return false
  }

  // Reverse in our input
  //
  // Returns whether the reverse succeeded. On failure, our
  // save point was restored
  mutating func reverseConsume(_ n: Distance) -> Bool {
    // TODO: needs benchmark coverage
    if let idx = input.index(
      currentPosition, offsetBy: -n.rawValue, limitedBy: start
    ) {
      currentPosition = idx
      return true
    }

    // If `start` falls in the middle of a character, and we are trying to reverse
    // by one "character", then we should max out at `start` even though the above
    // reversal will result in `nil`.
    if n == 1, let idx = input.unicodeScalars.index(
      currentPosition, offsetBy: -n.rawValue, limitedBy: start
    ) {
      currentPosition = idx
      return true
    }

    signalFailure()
    return false
  }

  // Advances in unicode scalar view
  mutating func consumeScalar(_ n: Distance) -> Bool {
    // TODO: needs benchmark coverage
    guard let idx = input.unicodeScalars.index(
      currentPosition, offsetBy: n.rawValue, limitedBy: end
    ) else {
      signalFailure()
      return false
    }
    currentPosition = idx
    return true
  }

  // Reverses in unicode scalar view
  mutating func reverseConsumeScalar(_ n: Distance) -> Bool {
    // TODO: needs benchmark coverage
    guard let idx = input.unicodeScalars.index(
      currentPosition, offsetBy: -n.rawValue, limitedBy: start
    ) else {
      signalFailure()
      return false
    }
    currentPosition = idx
    return true
  }

  /// Continue matching at the specified index.
  ///
  /// - Precondition: `bounds.contains(index) || index == bounds.upperBound`
  /// - Precondition: `index >= currentPosition`
  mutating func resume(at index: Input.Index) {
    assert(index >= searchBounds.lowerBound)
    assert(index <= searchBounds.upperBound)
    assert(index >= currentPosition)
    currentPosition = index
  }

  func doPrint(_ s: String) {
    var enablePrinting: Bool { false }
    if enablePrinting {
      print(s)
    }
  }

  func load() -> Element? {
    currentPosition < end ? input[currentPosition] : nil
  }

  // MARK: Match functions
  //
  // TODO: refactor these such that `cycle()` calls the corresponding String
  //       method directly, and all the step, signalFailure, and
  //       currentPosition logic is collected into a single place inside
  //       cycle().

  // Match against the current input element. Returns whether
  // it succeeded vs signaling an error.
  mutating func match(
    _ e: Element, isCaseInsensitive: Bool
  ) -> Bool {
    guard let next = input.match(
      e,
      at: currentPosition,
      limitedBy: end,
      isCaseInsensitive: isCaseInsensitive
    ) else {
      signalFailure()
      return false
    }
    currentPosition = next
    return true
  }

  // Reverse match against the current input element. Returns whether
  // it succeeded vs signaling an error.
  mutating func reverseMatch(
    _ e: Element, isCaseInsensitive: Bool
  ) -> Bool {
    let previous = input.matchPrevious(
      e,
      at: currentPosition,
      limitedBy: start,
      isCaseInsensitive: isCaseInsensitive
    )

    guard let previous else {
      guard currentPosition == start else {
        // If there's no previous character, and we're not
        // at the start of the string, the match has failed
        signalFailure()
        return false
      }

      return true
    }

    currentPosition = previous
    return true
  }

  // Match against the current input prefix. Returns whether
  // it succeeded vs signaling an error.
  mutating func matchSeq(
    _ seq: Substring,
    isScalarSemantics: Bool
  ) -> Bool  {
    guard let next = input.matchSeq(
      seq,
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }

    currentPosition = next
    return true
  }

  mutating func matchScalar(
    _ s: Unicode.Scalar,
    boundaryCheck: Bool,
    isCaseInsensitive: Bool
  ) -> Bool {
    guard let next = input.matchScalar(
      s,
      at: currentPosition,
      limitedBy: end,
      boundaryCheck: boundaryCheck,
      isCaseInsensitive: isCaseInsensitive
    ) else {
      signalFailure()
      return false
    }
    currentPosition = next
    return true
  }

  mutating func reverseMatchScalar(
    _ s: Unicode.Scalar,
    boundaryCheck: Bool,
    isCaseInsensitive: Bool
  ) -> Bool {
    let previous = input.matchPreviousScalar(
      s,
      at: currentPosition,
      limitedBy: start,
      boundaryCheck: boundaryCheck,
      isCaseInsensitive: isCaseInsensitive
    ) 

    guard let previous else {
      guard currentPosition == start else {
        signalFailure()
        return false
      }

      return true
    }

    currentPosition = previous
    return true
  }

  // TODO: bytes should be a Span or RawSpan
  mutating func matchUTF8(
    _ bytes: Array<UInt8>,
    boundaryCheck: Bool
  ) -> Bool {
    guard let next = input.matchUTF8(
      bytes,
      at: currentPosition,
      limitedBy: end,
      boundaryCheck: boundaryCheck
    ) else {
      signalFailure()
      return false
    }
    currentPosition = next
    return true
  }

  // TODO: bytes should be a Span or RawSpan
  mutating func reverseMatchUTF8(
    _ bytes: Array<UInt8>,
    boundaryCheck: Bool
  ) -> Bool {
    guard let previous = input.reverseMatchUTF8(
      bytes,
      at: currentPosition,
      limitedBy: start,
      boundaryCheck: boundaryCheck
    ) else {
      signalFailure()
      return false
    }
    currentPosition = previous
    return true
  }

  // If we have a bitset we know that the CharacterClass only matches against
  // ascii characters, so check if the current input element is ascii then
  // check if it is set in the bitset
  mutating func matchBitset(
    _ bitset: DSLTree.CustomCharacterClass.AsciiBitset,
    isScalarSemantics: Bool
  ) -> Bool {
    guard let next = input.matchASCIIBitset(
      bitset,
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }
    currentPosition = next
    return true
  }

  // If we have a bitset we know that the CharacterClass only matches against
  // ascii characters, so check if the current input element is ascii then
  // check if it is set in the bitset
  mutating func reverseMatchBitset(
    _ bitset: DSLTree.CustomCharacterClass.AsciiBitset,
    isScalarSemantics: Bool
  ) -> Bool {
    guard let previous = input.matchPreviousASCIIBitset(
      bitset,
      at: currentPosition,
      limitedBy: start,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }
    currentPosition = previous
    return true
  }

  // Matches the next character/scalar if it is not a newline
  mutating func matchAnyNonNewline(
    isScalarSemantics: Bool
  ) -> Bool {
    guard let next = input.matchAnyNonNewline(
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }
    currentPosition = next
    return true
  }

  // Matches the previous character/scalar if it is not a newline
  mutating func reverseMatchAnyNonNewline(
    isScalarSemantics: Bool
  ) -> Bool {
    guard let previous = input.matchPreviousAnyNonNewline(
      at: currentPosition,
      limitedBy: start,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }
    currentPosition = previous
    return true
  }

  mutating func signalFailure(preservingCaptures: Bool = false) {
    guard !savePoints.isEmpty else {
      state = .fail
      return
    }
    let (pc, pos, capEnds, intRegisters, posRegisters): (
      pc: InstructionAddress,
      pos: Position?,
      captureEnds: [_StoredCapture],
      intRegisters: [Int],
      PositionRegister: [Input.Index]
    )

    let idx = savePoints.index(before: savePoints.endIndex)

    // If we have a quantifier save point, move the next range position into
    // pos instead of removing it
    if savePoints[idx].isQuantified {
      savePoints[idx].takePositionFromQuantifiedRange(input)
      (pc, pos, capEnds, intRegisters, posRegisters) = savePoints[idx].destructure
    } else {
      (pc, pos, capEnds, intRegisters, posRegisters) = savePoints.removeLast().destructure
    }

    assert(capEnds.count == storedCaptures.count)

    controller.pc = pc
    currentPosition = pos ?? currentPosition
    registers.ints = intRegisters
    registers.positions = posRegisters

    if !preservingCaptures {
      // Reset all capture information
      storedCaptures = capEnds
    }

    metrics.addBacktrack()
  }

  mutating func abort(_ e: Error? = nil) {
    if let e = e {
      self.failureReason = e
    }
    self.state = .fail
  }

  mutating func tryAccept() {
    switch (currentPosition, matchMode) {
    // When reaching the end of the match bounds or when we are only doing a
    // prefix match, transition to accept.
    case (searchBounds.upperBound, _), (_, .partialFromFront):
      state = .accept

    // When we are doing a full match but did not reach the end of the match
    // bounds, backtrack if possible.
    case (_, .wholeString):
      signalFailure()
    }
  }

  mutating func clearThrough(_ address: InstructionAddress) {
    while let sp = savePoints.popLast() {
      if sp.pc == address {
        controller.step()
        return
      }
    }
    // TODO: What should we do here?
    fatalError("Invalid code: Tried to clear save points when empty")
  }

  mutating func cycle() {
    _checkInvariants()
    assert(state == .inProgress)

    startCycleMetrics()
    defer { endCycleMetrics() }

    let (opcode, payload) = fetch()
    switch opcode {
    case .invalid:
      fatalError("Invalid program")

    case .moveImmediate:
      let (imm, reg) = payload.pairedImmediateInt
      let int = Int(asserting: imm)
      assert(int == imm)

      registers[reg] = int
      controller.step()
    case .moveCurrentPosition:
      let reg = payload.position
      registers[reg] = currentPosition
      controller.step()
    case .restorePosition:
      let reg = payload.position
      currentPosition = registers[reg]
      controller.step()
    case .branch:
      controller.pc = payload.addr

    case .condBranchZeroElseDecrement:
      let (addr, int) = payload.pairedAddrInt
      if registers[int] == 0 {
        controller.pc = addr
      } else {
        registers[int] -= 1
        controller.step()
      }
    case .condBranchSamePosition:
      let (addr, pos) = payload.pairedAddrPos
      if registers[pos] == currentPosition {
        controller.pc = addr
      } else {
        controller.step()
      }
    case .save:
      let resumeAddr = payload.addr
      let sp = makeSavePoint(resumingAt: resumeAddr)
      savePoints.append(sp)
      controller.step()

    case .saveAddress:
      let resumeAddr = payload.addr
      let sp = makeAddressOnlySavePoint(resumingAt: resumeAddr)
      savePoints.append(sp)
      controller.step()

    case .splitSaving:
      let (nextPC, resumeAddr) = payload.pairedAddrAddr
      let sp = makeSavePoint(resumingAt: resumeAddr)
      savePoints.append(sp)
      controller.pc = nextPC

    case .clear:
      if let _ = savePoints.popLast() {
        controller.step()
      } else {
        // TODO: What should we do here?
        fatalError("Invalid code: Tried to clear save points when empty")
      }

    case .clearThrough:
      clearThrough(payload.addr)

    case .accept:
      tryAccept()

    case .fail:
      let preservingCaptures = payload.boolPayload
      signalFailure(preservingCaptures: preservingCaptures)

    case .advance:
      let (isScalar, distance) = payload.distance
      if isScalar {
        if consumeScalar(distance) {
          controller.step()
        }
      } else {
        if consume(distance) {
          controller.step()
        }
      }
    case .reverse:
      let (isScalar, distance) = payload.distance
      if isScalar {
        if reverseConsumeScalar(distance) {
          controller.step()
        }
      } else {
        if reverseConsume(distance) {
          controller.step()
        }
      }
    case .matchAnyNonNewline:
      if matchAnyNonNewline(isScalarSemantics: payload.isScalar) {
        controller.step()
      }
    case .reverseMatchAnyNonNewline:
      if reverseMatchAnyNonNewline(isScalarSemantics: payload.isScalar) {
        controller.step()
      }
    case .match:
      let (isCaseInsensitive, reg) = payload.elementPayload
      if match(registers[reg], isCaseInsensitive: isCaseInsensitive) {
        controller.step()
      }
    case .reverseMatch:
      let (isCaseInsensitive, reg) = payload.elementPayload
      if reverseMatch(registers[reg], isCaseInsensitive: isCaseInsensitive) {
        controller.step()
      }
    case .matchScalar:
      let (scalar, caseInsensitive, boundaryCheck) = payload.scalarPayload
      if matchScalar(
        scalar,
        boundaryCheck: boundaryCheck,
        isCaseInsensitive: caseInsensitive
      ) {
        controller.step()
      }
    case .reverseMatchScalar:
      let (scalar, caseInsensitive, boundaryCheck) = payload.scalarPayload
      if reverseMatchScalar(
        scalar,
        boundaryCheck: boundaryCheck,
        isCaseInsensitive: caseInsensitive
      ) {
        controller.step()
      }

    case .matchUTF8:
      let (utf8Reg, boundaryCheck) = payload.matchUTF8Payload
      let utf8Content = registers[utf8Reg]
      if matchUTF8(
        utf8Content, boundaryCheck: boundaryCheck
      ) {
        controller.step()
      }

    case .reverseMatchUTF8:
      let (utf8Reg, boundaryCheck) = payload.matchUTF8Payload
      let utf8Content = registers[utf8Reg]
      if reverseMatchUTF8(
        utf8Content, boundaryCheck: boundaryCheck
      ) {
        controller.step()
      }

    case .matchBitset:
      let (isScalar, reg) = payload.bitsetPayload
      let bitset = registers[reg]
      if matchBitset(bitset, isScalarSemantics: isScalar) {
        controller.step()
      }
    case .reverseMatchBitset:
      let (isScalar, reg) = payload.bitsetPayload
      let bitset = registers[reg]
      if reverseMatchBitset(bitset, isScalarSemantics: isScalar) {
        controller.step()
      }
    case .matchBuiltin:
      let payload = payload.characterClassPayload
      if matchBuiltinCC(
        payload.cc,
        isInverted: payload.isInverted,
        isStrictASCII: payload.isStrictASCII,
        isScalarSemantics: payload.isScalarSemantics
      ) {
        controller.step()
      }
    case .reverseMatchBuiltin:
      let payload = payload.characterClassPayload
      if reverseMatchBuiltinCC(
        payload.cc,
        isInverted: payload.isInverted,
        isStrictASCII: payload.isStrictASCII,
        isScalarSemantics: payload.isScalarSemantics
      ) {
        controller.step()
      }
    case .quantify:
      if runQuantify(payload.quantify) {
        controller.step()
      }
    case .reverseQuantify:
      if runReverseQuantify(payload.quantify) {
        controller.step()
      }

    case .consumeBy:
      let reg = payload.consumer
      let consumer = registers[reg]
      guard currentPosition < searchBounds.upperBound,
            let nextIndex = consumer(input, currentPosition..<searchBounds.upperBound),
            nextIndex <= end
      else {
        signalFailure()
        return
      }
      resume(at: nextIndex)
      controller.step()

    case .assertBy:
      let payload = payload.assertion
      do {
        guard try builtinAssert(by: payload) else {
          signalFailure()
          return
        }
      } catch {
        abort(error)
        return
      }
      controller.step()

    case .matchBy:
      let (matcherReg, valReg) = payload.pairedMatcherValue
      let matcher = registers[matcherReg]
      do {
        guard let (nextIdx, val) = try matcher(
          input, currentPosition, searchBounds
        ), nextIdx <= end else {
          signalFailure()
          return
        }
        registers[valReg] = val
        resume(at: nextIdx)
        controller.step()
      } catch {
        abort(error)
        return
      }

    case .backreference:
      let (isScalarMode, capture) = payload.captureAndMode
      let capNum = Int(
        asserting: capture.rawValue)
      guard capNum < storedCaptures.count else {
        fatalError("Should this be an assert?")
      }
      // TODO:
      //   Should we assert it's not finished yet?
      //   What's the behavior there?
      let cap = storedCaptures[capNum]
      guard let range = cap.range else {
        signalFailure()
        return
      }
      if matchSeq(input[range], isScalarSemantics: isScalarMode) {
        controller.step()
      }

    case .beginCapture:
      let capNum = Int(
        asserting: payload.capture.rawValue)
      storedCaptures[capNum].startCapture(currentPosition)
      controller.step()

    case .endCapture:
      let capNum = Int(
        asserting: payload.capture.rawValue)
      storedCaptures[capNum].endCapture(currentPosition)
      controller.step()

    case .transformCapture:
      let (cap, trans) = payload.pairedCaptureTransform
      let transform = registers[trans]
      let capNum = Int(asserting: cap.rawValue)

      do {
        // FIXME: Pass input or the slice?
        guard let value = try transform(input, storedCaptures[capNum]) else {
          signalFailure()
          return
        }
        storedCaptures[capNum].registerValue(value)
        controller.step()
      } catch {
        abort(error)
        return
      }

    case .captureValue:
      let (val, cap) = payload.pairedValueCapture
      let value = registers[val]
      let capNum = Int(asserting: cap.rawValue)
      storedCaptures[capNum].registerValue(value)
      controller.step()
    }
  }
}

// MARK: String matchers
//
// TODO: Refactor into separate file, formalize patterns

extension String {

  func match(
    _ char: Character,
    at pos: Index,
    limitedBy end: String.Index,
    isCaseInsensitive: Bool
  ) -> Index? {
    // TODO: This can be greatly sped up with string internals
    // TODO: This is also very much quick-check-able
    guard let (stringChar, next) = characterAndEnd(at: pos, limitedBy: end)
    else { return nil }

    if isCaseInsensitive {
      guard stringChar.lowercased() == char.lowercased() else { return nil }
    } else {
      guard stringChar == char else { return nil }
    }

    return next
  }

  // Match `char` to the character at the index before `pos`
  func matchPrevious(
    _ char: Character,
    at pos: Index,
    limitedBy start: String.Index,
    isCaseInsensitive: Bool
  ) -> Index? {
    // TODO: This can be greatly sped up with string internals
    // TODO: This is also very much quick-check-able
    guard let prev = character(before: pos, limitedBy: start) else { return nil }

    if isCaseInsensitive {
      guard prev.char.lowercased() == char.lowercased() else { return nil }
    } else {
      guard prev.char == char else { return nil }
    }

    return prev.index
  }

  func matchSeq(
    _ seq: Substring,
    at pos: Index,
    limitedBy end: Index,
    isScalarSemantics: Bool
  ) -> Index? {
    // TODO: This can be greatly sped up with string internals
    // TODO: This is also very much quick-check-able
    var cur = pos

    if isScalarSemantics {
      for e in seq.unicodeScalars {
        guard cur < end, unicodeScalars[cur] == e else { return nil }
        self.unicodeScalars.formIndex(after: &cur)
      }
    } else {
      for e in seq {
        guard let (char, next) = characterAndEnd(at: cur, limitedBy: end),
              char == e
        else { return nil }
        cur = next
      }
    }

    guard cur <= end else { return nil }
    return cur
  }

  func matchScalar(
    _ scalar: Unicode.Scalar,
    at pos: Index,
    limitedBy end: String.Index,
    boundaryCheck: Bool,
    isCaseInsensitive: Bool
  ) -> Index? {
    // TODO: extremely quick-check-able
    // TODO: can be sped up with string internals
    guard pos < end else { return nil }
    let curScalar = unicodeScalars[pos]

    if isCaseInsensitive {
      guard curScalar.properties.lowercaseMapping == scalar.properties.lowercaseMapping
      else {
        return nil
      }
    } else {
      guard curScalar == scalar else { return nil }
    }

    let idx = unicodeScalars.index(after: pos)
    assert(idx <= end, "Input is a substring with a sub-scalar endIndex.")

    if boundaryCheck && !isOnGraphemeClusterBoundary(idx) {
      return nil
    }

    return idx
  }

  func matchPreviousScalar(
    _ scalar: Unicode.Scalar,
    at pos: Index,
    limitedBy start: String.Index,
    boundaryCheck: Bool,
    isCaseInsensitive: Bool
  ) -> Index? {
    // TODO: extremely quick-check-able
    // TODO: can be sped up with string internals
    guard pos > start else { return nil }
    let prevIndex = unicodeScalars.index(before: pos)
    let prevScalar = unicodeScalars[prevIndex]

    if isCaseInsensitive {
      guard prevScalar.properties.lowercaseMapping == scalar.properties.lowercaseMapping
      else {
        return nil
      }
    } else {
      guard prevScalar == scalar else { return nil }
    }

    assert(prevIndex >= start, "Input is a substring with a sub-scalar startIndex.")

    if boundaryCheck && !isOnGraphemeClusterBoundary(prevIndex) {
      return nil
    }

    return prevIndex
  }

  func matchUTF8(
    _ bytes: Array<UInt8>,
    at pos: Index,
    limitedBy end: Index,
    boundaryCheck: Bool
  ) -> Index? {
    var cur = pos
    for b in bytes {
      guard cur < end, self.utf8[cur] == b else { return nil }
      self.utf8.formIndex(after: &cur)
    }

    assert(cur <= end)

    if boundaryCheck && !isOnGraphemeClusterBoundary(cur) {
      return nil
    }

    return cur
  }

  func reverseMatchUTF8(
    _ bytes: Array<UInt8>,
    at pos: Index,
    limitedBy start: Index,
    boundaryCheck: Bool
  ) -> Index? {
    var cur = pos
    for b in bytes.reversed() {
      guard cur > start, self.utf8[cur] == b else { return nil }
      self.utf8.formIndex(before: &cur)
    }

    assert(cur > start)

    if boundaryCheck && !isOnGraphemeClusterBoundary(cur) {
      return nil
    }

    return cur
  }

  func matchASCIIBitset(
    _ bitset: DSLTree.CustomCharacterClass.AsciiBitset,
    at pos: Index,
    limitedBy end: Index,
    isScalarSemantics: Bool
  ) -> Index? {

    // FIXME: Inversion should be tracked and handled in only one place.
    // That is, we should probably store it as a bit in the instruction, so that
    // bitset matching and bitset inversion is bit-based rather that semantically
    // inverting the notion of a match or not. As-is, we need to track both
    // meanings in some code paths.
    let isInverted = bitset.isInverted

    // TODO: More fodder for refactoring `_quickASCIICharacter`, see the comment 
    // there
    guard let (asciiByte, next, isCRLF) = _quickASCIICharacter(
      at: pos,
      limitedBy: end
    ) else {
      if isScalarSemantics {
        guard pos < end else { return nil }
        guard bitset.matches(unicodeScalars[pos]) else { return nil }
        return unicodeScalars.index(after: pos)
      } else {
        guard let (char, next) = characterAndEnd(at: pos, limitedBy: end),
              bitset.matches(char) else { return nil }
        return next
      }
    }

    guard bitset.matches(asciiByte) else {
      // FIXME: check inversion here after refactored out of bitset
      return nil
    }

    // CR-LF should only match `[\r]` in scalar semantic mode or if inverted
    if isCRLF {
      if isScalarSemantics {
        return self.unicodeScalars.index(before: next)
      }
      if isInverted {
        return next
      }
      return nil
    }

    return next
  }

  func matchPreviousASCIIBitset(
    _ bitset: DSLTree.CustomCharacterClass.AsciiBitset,
    at pos: Index,
    limitedBy start: Index,
    isScalarSemantics: Bool
  ) -> Index? {

    // FIXME: Inversion should be tracked and handled in only one place.
    // That is, we should probably store it as a bit in the instruction, so that
    // bitset matching and bitset inversion is bit-based rather that semantically
    // inverting the notion of a match or not. As-is, we need to track both
    // meanings in some code paths.
    let isInverted = bitset.isInverted

    // TODO: More fodder for refactoring `_quickASCIICharacter`, see the comment
    // there
    guard let (asciiByte, previous, isCRLF) = _quickPreviousASCIICharacter(
      at: pos,
      limitedBy: start
    ) else {
      if isScalarSemantics {
        guard pos > start else { return nil }
        let matchPos = unicodeScalars.index(before: pos)
        guard bitset.matches(unicodeScalars[matchPos]) else { return nil }
        return matchPos
      } else {
        guard let prev = character(before: pos, limitedBy: start),
              bitset.matches(prev.char) else { return nil }
        return prev.index
      }
    }

    guard bitset.matches(asciiByte) else {
      // FIXME: check inversion here after refactored out of bitset
      return nil
    }

    // CR-LF should only match `[\r]` in scalar semantic mode or if inverted
    if isCRLF {
      if isScalarSemantics {
        return self.unicodeScalars.index(after: previous)
      }
      if isInverted {
        return previous
      }
      return nil
    }

    return previous
  }
}
