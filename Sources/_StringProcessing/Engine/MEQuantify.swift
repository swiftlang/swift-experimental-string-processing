private typealias ASCIIBitset = DSLTree.CustomCharacterClass.AsciiBitset

extension Processor {
  internal mutating func runQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind != .reluctant, ".reluctant is not supported by .quantify")

    let minMatches = payload.minTrips
    let maxMatches = payload.maxTrips
    let produceSavePointRange = payload.quantKind == .eager
    let isScalarSemantics = payload.isScalarSemantics

    let matchResult: (next: String.Index, savePointRange: Range<Position>?)?
    switch payload.type {
    case .asciiBitset:
      matchResult = input.matchQuantifiedASCIIBitset(
        registers[payload.bitset],
        at: currentPosition,
        limitedBy: end,
        minMatches: minMatches,
        maxMatches: maxMatches,
        produceSavePointRange: produceSavePointRange,
        isScalarSemantics: isScalarSemantics)

    case .asciiChar:
      matchResult = input.matchQuantifiedScalar(
        Unicode.Scalar(payload.asciiChar),
        at: currentPosition,
        limitedBy: end,
        minMatches: minMatches,
        maxMatches: maxMatches,
        produceSavePointRange: produceSavePointRange,
        isScalarSemantics: isScalarSemantics)

    case .any:
      matchResult = input.matchQuantifiedRegexDot(
        at: currentPosition,
        limitedBy: end,
        minMatches: minMatches,
        maxMatches: maxMatches,
        produceSavePointRange: produceSavePointRange,
        isScalarSemantics: isScalarSemantics,
        anyMatchesNewline: payload.anyMatchesNewline)

    case .builtin:
      matchResult = input.matchQuantifiedBuiltinCC(
        payload.builtin,
        at: currentPosition,
        limitedBy: end,
        minMatches: minMatches,
        maxMatches: maxMatches,
        produceSavePointRange: produceSavePointRange,
        isInverted: payload.builtinIsInverted,
        isStrictASCII: payload.builtinIsStrict,
        isScalarSemantics: isScalarSemantics)
    }

    guard let (next, savePointRange) = matchResult else {
      signalFailure()
      return false
    }
    if let savePointRange {
      savePoints.append(makeQuantifiedSavePoint(
        savePointRange, isScalarSemantics: payload.isScalarSemantics))
    }
    currentPosition = next
    return true
  }
}

/// MARK: - Non-reluctant quantification operations on String

extension String {
  /// Run the quant loop, using the supplied matching closure
  ///
  /// NOTE: inline-always to help elimiate the closure overhead,
  /// simplify some of the looping structure, etc.
  @inline(__always)
  fileprivate func _runQuantLoop(
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool,
    _ doMatch: (
     _ currentPosition: Index, _ limitedBy: Index, _ isScalarSemantics: Bool
    ) -> Index?
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    var currentPosition = currentPosition
    var rangeStart = currentPosition
    var rangeEnd = currentPosition

    var numMatches = 0

    while numMatches < maxMatches {
      guard let next = doMatch(
        currentPosition, end, isScalarSemantics
      ) else {
        break
      }
      numMatches &+= 1
      if numMatches == minMatches {
        rangeStart = next
      }
      rangeEnd = currentPosition
      currentPosition = next
      assert(currentPosition > rangeEnd)
    }

    guard numMatches >= minMatches else {
      return nil
    }

    guard produceSavePointRange && numMatches > minMatches else {
      // Consumed no input, no point saved
      return (currentPosition, nil)
    }
    assert(rangeStart <= rangeEnd)

    // NOTE: We can't assert that rangeEnd trails currentPosition by one
    // position, because newline-sequence in scalar semantic mode still
    // matches two scalars

    return (currentPosition, rangeStart..<rangeEnd)    
  }

  fileprivate func matchQuantifiedASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, end, isScalarSemantics in
      matchASCIIBitset(
        asciiBitset,
        at: currentPosition,
        limitedBy: end,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func matchQuantifiedScalar(
    _ scalar: Unicode.Scalar,
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, end, isScalarSemantics in
      matchScalar(
        scalar,
        at: currentPosition,
        limitedBy: end,
        boundaryCheck: !isScalarSemantics,
        isCaseInsensitive: false)

    }
  }

  fileprivate func matchQuantifiedBuiltinCC(
    _ builtinCC: _CharacterClassModel.Representation,
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, end, isScalarSemantics in
      matchBuiltinCC(
        builtinCC,
        at: currentPosition,
        limitedBy: end,
        isInverted: isInverted,
        isStrictASCII: isStrictASCII,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func matchQuantifiedRegexDot(
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool,
    anyMatchesNewline: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, end, isScalarSemantics in
      matchRegexDot(
        at: currentPosition,
        limitedBy: end,
        anyMatchesNewline: anyMatchesNewline,
        isScalarSemantics: isScalarSemantics)
    }
  }
}


