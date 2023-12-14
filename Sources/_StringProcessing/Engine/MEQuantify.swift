private typealias ASCIIBitset = DSLTree.CustomCharacterClass.AsciiBitset

extension Processor {
  internal mutating func runQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind != .reluctant, ".reluctant is not supported by .quantify")

    let minMatches = payload.minTrips
    let maxMatches = payload.maxTrips
    let produceSavePointRange = payload.quantKind == .eager
    let isScalarSemantics = payload.isScalarSemantics

    let isZeroOrMore = payload.minTrips == 0 && payload.maxExtraTrips == nil
    let isOneOrMore = payload.minTrips == 1 && payload.maxExtraTrips == nil

    let matchResult: (next: String.Index, savePointRange: Range<Position>?)?
    switch payload.type {
    case .asciiBitset:
      if isZeroOrMore {
        matchResult = input.matchZeroOrMoreASCIIBitset(
          registers[payload.bitset],
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.matchOneOrMoreASCIIBitset(
          registers[payload.bitset],
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.matchQuantifiedASCIIBitset(
          registers[payload.bitset],
          at: currentPosition,
          limitedBy: end,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      }

    case .asciiChar:
      if isZeroOrMore {
        matchResult = input.matchZeroOrMoreScalar(
          Unicode.Scalar(payload.asciiChar),
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.matchOneOrMoreScalar(
          Unicode.Scalar(payload.asciiChar),
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.matchQuantifiedScalar(
          Unicode.Scalar(payload.asciiChar),
          at: currentPosition,
          limitedBy: end,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      }

    case .any:
      if isZeroOrMore {
        matchResult = input.matchZeroOrMoreRegexDot(
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          anyMatchesNewline: payload.anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.matchOneOrMoreRegexDot(
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          anyMatchesNewline: payload.anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.matchQuantifiedRegexDot(
          at: currentPosition,
          limitedBy: end,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          anyMatchesNewline: payload.anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
      }

    case .builtin:
      if isZeroOrMore {
        matchResult = input.matchZeroOrMoreBuiltinCC(
          payload.builtin,
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          isInverted: payload.builtinIsInverted,
          isStrictASCII: payload.builtinIsStrict,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.matchOneOrMoreBuiltinCC(
          payload.builtin,
          at: currentPosition,
          limitedBy: end,
          produceSavePointRange: produceSavePointRange,
          isInverted: payload.builtinIsInverted,
          isStrictASCII: payload.builtinIsStrict,
          isScalarSemantics: isScalarSemantics)
      } else {
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

  /// NOTE: [Zero|One]OrMore overloads are to specialize the inlined run loop,
  /// which has a substantive perf impact (especially for zero-or-more)

  fileprivate func matchZeroOrMoreASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 0,
      maxMatches: UInt64.max,
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
  fileprivate func matchOneOrMoreASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 1,
      maxMatches: UInt64.max,
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

  fileprivate func matchZeroOrMoreScalar(
    _ scalar: Unicode.Scalar,
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 0,
      maxMatches: UInt64.max,
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
  fileprivate func matchOneOrMoreScalar(
    _ scalar: Unicode.Scalar,
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 1,
      maxMatches: UInt64.max,
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

  fileprivate func matchZeroOrMoreBuiltinCC(
    _ builtinCC: _CharacterClassModel.Representation,
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 0,
      maxMatches: UInt64.max,
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
  fileprivate func matchOneOrMoreBuiltinCC(
    _ builtinCC: _CharacterClassModel.Representation,
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 1,
      maxMatches: UInt64.max,
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

  fileprivate func matchZeroOrMoreRegexDot(
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    anyMatchesNewline: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 0,
      maxMatches: UInt64.max,
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
  fileprivate func matchOneOrMoreRegexDot(
    at currentPosition: Index,
    limitedBy end: Index,
    produceSavePointRange: Bool,
    anyMatchesNewline: Bool,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    _runQuantLoop(
      at: currentPosition,
      limitedBy: end,
      minMatches: 1,
      maxMatches: UInt64.max,
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

  fileprivate func matchQuantifiedRegexDot(
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    anyMatchesNewline: Bool,
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
      matchRegexDot(
        at: currentPosition,
        limitedBy: end,
        anyMatchesNewline: anyMatchesNewline,
        isScalarSemantics: isScalarSemantics)
    }
  }
}


