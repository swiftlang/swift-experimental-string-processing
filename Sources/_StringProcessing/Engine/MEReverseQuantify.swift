internal import _RegexParser

private typealias ASCIIBitset = DSLTree.CustomCharacterClass.AsciiBitset

extension Processor {
  internal mutating func runReverseQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind != .reluctant, ".reluctant is not supported by .quantify")

    let minMatches = payload.minTrips
    let maxMatches = payload.maxTrips
    let produceSavePointRange = payload.quantKind == .eager
    let isScalarSemantics = payload.isScalarSemantics

    let isZeroOrMore = payload.minTrips == 0 && payload.maxExtraTrips == nil
    let isOneOrMore = payload.minTrips == 1 && payload.maxExtraTrips == nil

    let matchResult: (previous: String.Index, savePointRange: Range<Position>?)?
    switch payload.type {
    case .asciiBitset:
      if isZeroOrMore {
        matchResult = input.reverseMatchZeroOrMoreASCIIBitset(
          registers[payload.bitset],
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.reverseMatchOneOrMoreASCIIBitset(
          registers[payload.bitset],
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.reverseMatchQuantifiedASCIIBitset(
          registers[payload.bitset],
          at: currentPosition,
          limitedBy: start,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      }

    case .asciiChar:
      if isZeroOrMore {
        matchResult = input.reverseMatchZeroOrMoreScalar(
          Unicode.Scalar(payload.asciiChar),
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.reverseMatchOneOrMoreScalar(
          Unicode.Scalar(payload.asciiChar),
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.reverseMatchQuantifiedScalar(
          Unicode.Scalar(payload.asciiChar),
          at: currentPosition,
          limitedBy: start,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          isScalarSemantics: isScalarSemantics)
      }

    case .any:
      if isZeroOrMore {
        matchResult = input.reverseMatchZeroOrMoreRegexDot(
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          anyMatchesNewline: payload.anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.reverseMatchOneOrMoreRegexDot(
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          anyMatchesNewline: payload.anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.reverseMatchQuantifiedRegexDot(
          at: currentPosition,
          limitedBy: start,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          anyMatchesNewline: payload.anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
      }

    case .builtinCC:
      if isZeroOrMore {
        matchResult = input.reverseMatchZeroOrMoreBuiltinCC(
          payload.builtinCC,
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          isInverted: payload.builtinIsInverted,
          isStrictASCII: payload.builtinIsStrict,
          isScalarSemantics: isScalarSemantics)
      } else if isOneOrMore {
        matchResult = input.reverseMatchOneOrMoreBuiltinCC(
          payload.builtinCC,
          at: currentPosition,
          limitedBy: start,
          produceSavePointRange: produceSavePointRange,
          isInverted: payload.builtinIsInverted,
          isStrictASCII: payload.builtinIsStrict,
          isScalarSemantics: isScalarSemantics)
      } else {
        matchResult = input.reverseMatchQuantifiedBuiltinCC(
          payload.builtinCC,
          at: currentPosition,
          limitedBy: start,
          minMatches: minMatches,
          maxMatches: maxMatches,
          produceSavePointRange: produceSavePointRange,
          isInverted: payload.builtinIsInverted,
          isStrictASCII: payload.builtinIsStrict,
          isScalarSemantics: isScalarSemantics)
      }
    }

    guard let (previous, savePointRange) = matchResult else {
      signalFailure()
      return false
    }
    if let savePointRange {
      assert(produceSavePointRange)
      savePoints.append(makeQuantifiedSavePoint(
        savePointRange, isScalarSemantics: payload.isScalarSemantics))
    }
    currentPosition = previous
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
  fileprivate func _runReverseQuantLoop(
    at currentPosition: Index,
    limitedBy start: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool,
    _ doMatch: (
      _ currentPosition: Index, _ limitedBy: Index, _ isScalarSemantics: Bool
    ) -> Index?
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    var currentPosition = currentPosition

    // The range of backtracking positions to try. For zero-or-more, starts
    // before any match happens. Always ends before the final match, since
    // the final match is what is tried without backtracking. An empty range
    // is valid and means a single backtracking position at rangeStart.
    var rangeStart = currentPosition
    var rangeEnd = currentPosition

    var numMatches = 0

    while numMatches < maxMatches {
      guard let previous = doMatch(
        currentPosition, start, isScalarSemantics
      ) else {
        break
      }
      numMatches &+= 1
      if numMatches == minMatches {
        // For this loop iteration, rangeStart will actually trail rangeEnd by
        // a single match position. Next iteration, they will be equal
        // (empty range denoting a single backtracking point). Note that we
        // only ever return a range if we have exceeded `minMatches`; if we
        // exactly match `minMatches` there is no backtracking positions to
        // remember.
        rangeEnd = previous
      }
      rangeStart = currentPosition
      currentPosition = previous
      assert(currentPosition < rangeStart)
    }

    guard numMatches >= minMatches else {
      return nil
    }

    guard produceSavePointRange && numMatches > minMatches else {
      // No backtracking positions to try
      return (currentPosition, nil)
    }
    assert(rangeStart <= rangeEnd)

    // NOTE: We can't assert that rangeEnd trails currentPosition by exactly
    // one position, because newline-sequence in scalar semantic mode still
    // matches two scalars

    return (
      currentPosition,
      Range(uncheckedBounds: (lower: rangeStart, upper: rangeEnd))
    )
  }

  // NOTE: [Zero|One]OrMore overloads are to specialize the inlined run loop,
  // which has a perf impact. At the time of writing this, 10% for
  // zero-or-more and 5% for one-or-more improvement, which could very well
  // be much higher if/when the inner match functions are made faster.

  fileprivate func reverseMatchZeroOrMoreASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 0,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      reverseMatchASCIIBitset(
        asciiBitset,
        at: currentPosition,
        limitedBy: start,
        isScalarSemantics: isScalarSemantics)
    }
  }
  fileprivate func reverseMatchOneOrMoreASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 1,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      reverseMatchASCIIBitset(
        asciiBitset,
        at: currentPosition,
        limitedBy: start,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func reverseMatchQuantifiedASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy start: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      reverseMatchASCIIBitset(
        asciiBitset,
        at: currentPosition,
        limitedBy: start,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func reverseMatchZeroOrMoreScalar(
    _ scalar: Unicode.Scalar,
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 0,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      matchPreviousScalar(
        scalar,
        at: currentPosition,
        limitedBy: start,
        boundaryCheck: !isScalarSemantics,
        isCaseInsensitive: false)
    }
  }
  fileprivate func reverseMatchOneOrMoreScalar(
    _ scalar: Unicode.Scalar,
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 1,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      matchPreviousScalar(
        scalar,
        at: currentPosition,
        limitedBy: start,
        boundaryCheck: !isScalarSemantics,
        isCaseInsensitive: false)
    }
  }

  fileprivate func reverseMatchQuantifiedScalar(
    _ scalar: Unicode.Scalar,
    at currentPosition: Index,
    limitedBy start: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      matchPreviousScalar(
        scalar,
        at: currentPosition,
        limitedBy: start,
        boundaryCheck: !isScalarSemantics,
        isCaseInsensitive: false)

    }
  }

  fileprivate func reverseMatchZeroOrMoreBuiltinCC(
    _ builtinCC: _CharacterClassModel.Representation,
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 0,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      matchPreviousBuiltinCC(
        builtinCC,
        at: currentPosition,
        limitedBy: start,
        isInverted: isInverted,
        isStrictASCII: isStrictASCII,
        isScalarSemantics: isScalarSemantics)
    }
  }
  fileprivate func reverseMatchOneOrMoreBuiltinCC(
    _ builtinCC: _CharacterClassModel.Representation,
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 1,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      matchPreviousBuiltinCC(
        builtinCC,
        at: currentPosition,
        limitedBy: start,
        isInverted: isInverted,
        isStrictASCII: isStrictASCII,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func reverseMatchQuantifiedBuiltinCC(
    _ builtinCC: _CharacterClassModel.Representation,
    at currentPosition: Index,
    limitedBy start: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      matchPreviousBuiltinCC(
        builtinCC,
        at: currentPosition,
        limitedBy: start,
        isInverted: isInverted,
        isStrictASCII: isStrictASCII,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func reverseMatchZeroOrMoreRegexDot(
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    anyMatchesNewline: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 0,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      reverseMatchRegexDot(
        at: currentPosition,
        limitedBy: start,
        anyMatchesNewline: anyMatchesNewline,
        isScalarSemantics: isScalarSemantics)
    }
  }
  fileprivate func reverseMatchOneOrMoreRegexDot(
    at currentPosition: Index,
    limitedBy start: Index,
    produceSavePointRange: Bool,
    anyMatchesNewline: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: 1,
      maxMatches: UInt64.max,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      reverseMatchRegexDot(
        at: currentPosition,
        limitedBy: start,
        anyMatchesNewline: anyMatchesNewline,
        isScalarSemantics: isScalarSemantics)
    }
  }

  fileprivate func reverseMatchQuantifiedRegexDot(
    at currentPosition: Index,
    limitedBy start: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    produceSavePointRange: Bool,
    anyMatchesNewline: Bool,
    isScalarSemantics: Bool
  ) -> (previous: Index, savePointRange: Range<Index>?)? {
    _runReverseQuantLoop(
      at: currentPosition,
      limitedBy: start,
      minMatches: minMatches,
      maxMatches: maxMatches,
      produceSavePointRange: produceSavePointRange,
      isScalarSemantics: isScalarSemantics
    ) { currentPosition, start, isScalarSemantics in
      reverseMatchRegexDot(
        at: currentPosition,
        limitedBy: start,
        anyMatchesNewline: anyMatchesNewline,
        isScalarSemantics: isScalarSemantics)
    }
  }
}


