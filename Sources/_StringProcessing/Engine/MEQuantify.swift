@_implementationOnly import _RegexParser
private typealias ASCIIBitset = DSLTree.CustomCharacterClass.AsciiBitset

extension Processor {
  internal mutating func runQuantify(_ payload: QuantifyPayload) -> Bool {
    if payload.type == .asciiBitset {
      guard let (next, savePointRange) = input.matchQuantifiedASCIIBitset(
        registers[payload.bitset],
        at: currentPosition,
        limitedBy: end,
        minMatches: payload.minTrips,
        maxMatches: payload.maxTrips,
        quantificationKind: payload.quantKind,
        isScalarSemantics: payload.isScalarSemantics
      ) else {
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

    // TODO: Refactor below called functions to be non-mutating.
    // They might need to communicate save-point info upwards in addition to
    // a new (optional) currentPosition. Then, we can assert in testing that the
    // specialized functions produce the same answer as `runGeneralQuantify`.
    switch (payload.quantKind, payload.minTrips, payload.maxExtraTrips) {
    case (.reluctant, _, _):
      assertionFailure(".reluctant is not supported by .quantify")
      // TODO: this was pre-refactoring behavior, should we fatal error
      //       instead?
      return false 
    case (_, 0, nil):
      let (next, savePointRange) = input.runZeroOrMoreQuantify(
        payload,
        asciiBitset: nil,
        at: currentPosition,
        limitedBy: end)
      if let savePointRange {
        savePoints.append(makeQuantifiedSavePoint(
          savePointRange, isScalarSemantics: payload.isScalarSemantics))
      }
      currentPosition = next
      return true
    case (_, 1, nil):
      guard let (next, savePointRange) = input.runOneOrMoreQuantify(
        payload,
        asciiBitset: nil,
        at: currentPosition,
        limitedBy: end
      ) else {
        signalFailure()
        return false
      }
      if let savePointRange {
        savePoints.append(makeQuantifiedSavePoint(
          savePointRange, isScalarSemantics: payload.isScalarSemantics))
      }
      currentPosition = next
      return true
    case (_, _, nil):
      guard let (next, savePointRange) = input.runNOrMoreQuantify(
        payload,
        asciiBitset: nil,
        at: currentPosition,
        limitedBy: end
      ) else {
        signalFailure()
        return false
      }
      if let savePointRange {
        savePoints.append(makeQuantifiedSavePoint(
          savePointRange, isScalarSemantics: payload.isScalarSemantics))
      }
      currentPosition = next
      return true
    case (_, 0, 1):
      // FIXME: Is this correct for lazy zero-or-one?
      let (next, savePointRange) = input.runZeroOrOneQuantify(
        payload,
        asciiBitset: nil,
        at: currentPosition,
        limitedBy: end)
      if let savePointRange {
        savePoints.append(makeQuantifiedSavePoint(
          savePointRange, isScalarSemantics: payload.isScalarSemantics))
      }
      currentPosition = next
      return true
    default:
      guard let (next, savePointRange) = input.runGeneralQuantify(
        payload,
        asciiBitset: nil,
        at: currentPosition,
        limitedBy: end
      ) else {
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
}

extension String {
  fileprivate func matchQuantifiedASCIIBitset(
    _ asciiBitset: ASCIIBitset,
    at currentPosition: Index,
    limitedBy end: Index,
    minMatches: UInt64,
    maxMatches: UInt64,
    quantificationKind: AST.Quantification.Kind,
    isScalarSemantics: Bool
  ) -> (next: Index, savePointRange: Range<Index>?)? {
    // Create a quantified save point for every part of the input
    // (after minTrips) matched up to the final position.
    var currentPosition = currentPosition
    var rangeStart = currentPosition
    var rangeEnd = currentPosition

    var numMatches = 0

    while numMatches < maxMatches {
      guard let next = matchASCIIBitset(
        asciiBitset,
        at: currentPosition,
        limitedBy: end,
        isScalarSemantics: isScalarSemantics)
      else {
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

    guard quantificationKind == .eager && numMatches > minMatches else {
      // Consumed no input, no point saved
      return (currentPosition, nil)
    }
    assert(rangeStart <= rangeEnd)

    // NOTE: We can't assert that rangeEnd trails currentPosition by one
    // position, because newline-sequence in scalar semantic mode still
    // matches two scalars

    return (currentPosition, rangeStart..<rangeEnd)
  }

  /// Generic quantify instruction interpreter
  /// - Handles .eager and .posessive
  /// - Handles arbitrary minTrips and maxExtraTrips
  fileprivate func runGeneralQuantify(
    _ payload: QuantifyPayload,
    asciiBitset: ASCIIBitset?,
    at currentPosition: Index,
    limitedBy end: Index
  ) -> (
    nextPosition: Index,
    savePointRange: Range<Index>?
  )? {
    assert(payload.quantKind != .reluctant)

    let minTrips = payload.minTrips
    let maxTrips: UInt64
    if let maxExtraTrips = payload.maxExtraTrips {
      maxTrips = payload.minTrips + maxExtraTrips
    } else {
      maxTrips = UInt64.max
    }

    return _runNOrMoreQuantify(
      payload,
      minTrips: minTrips,
      maxTrips: maxTrips,
      asciiBitset: asciiBitset,
      at: currentPosition,
      limitedBy: end)
  }

  /// Specialized quantify instruction interpreter for `*`, always succeeds
  fileprivate func runZeroOrMoreQuantify(
    _ payload: QuantifyPayload,
    asciiBitset: ASCIIBitset?, // Necessary ugliness...
    at currentPosition: Index,
    limitedBy end: Index
  ) -> (Index, savePointRange: Range<Index>?) {
    assert(payload.minTrips == 0 && payload.maxExtraTrips == nil)
    guard let res = _runNOrMoreQuantify(
      payload,
      minTrips: 0,
      maxTrips: UInt64.max,
      asciiBitset: asciiBitset,
      at: currentPosition,
      limitedBy: end
    ) else {
      fatalError("Unreachable: zero-or-more always succeeds")
    }

    return res
  }

  /// Specialized n-or-more eager quantification interpreter
  ///
  /// NOTE: inline always makes a huge perf difference for zero-or-more case
  @inline(__always)
  fileprivate func _runNOrMoreQuantify(
    _ payload: QuantifyPayload,
    minTrips: UInt64,
    maxTrips: UInt64,
    asciiBitset: ASCIIBitset?, // Necessary ugliness...
    at currentPosition: Index,
    limitedBy end: Index
  ) -> (Index, savePointRange: Range<Index>?)? {
    assert(minTrips == payload.minTrips)
    assert(minTrips + (payload.maxExtraTrips ?? (UInt64.max - minTrips)) == maxTrips)

    // Create a quantified save point for every part of the input
    // (after minTrips) matched up to the final position.
    var currentPosition = currentPosition
    let isScalarSemantics = payload.isScalarSemantics
    var rangeStart = currentPosition
    var rangeEnd = currentPosition

    var numMatches = 0

    switch payload.type {
    case .asciiBitset:
      fatalError("handled above")
    case .asciiChar:
      let asciiScalar = UnicodeScalar.init(_value: UInt32(payload.asciiChar))
      while numMatches < maxTrips {
        guard let next = matchScalar(
          asciiScalar,
          at: currentPosition,
          limitedBy: end,
          boundaryCheck: !isScalarSemantics,
          isCaseInsensitive: false)
        else {
          break
        }
        numMatches &+= 1
        if numMatches == minTrips {
          rangeStart = next
        }
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    case .builtin:
      let builtin = payload.builtin
      let isInverted = payload.builtinIsInverted
      let isStrictASCII = payload.builtinIsStrict
      while numMatches < maxTrips {
        guard let next = matchBuiltinCC(
          builtin,
          at: currentPosition,
          limitedBy: end,
          isInverted: isInverted,
          isStrictASCII: isStrictASCII,
          isScalarSemantics: isScalarSemantics)
        else {
          break
        }
        numMatches &+= 1
        if numMatches == minTrips {
          rangeStart = next
        }
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    case .any:
      let anyMatchesNewline = payload.anyMatchesNewline
      while numMatches < maxTrips {
        guard let next = matchRegexDot(
          at: currentPosition,
          limitedBy: end,
          anyMatchesNewline: anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
        else {
          break
        }
        numMatches &+= 1
        if numMatches == minTrips {
          rangeStart = next
        }
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    }

    guard numMatches >= minTrips else {
      return nil
    }

    guard payload.quantKind == .eager && numMatches > minTrips else {
      // Consumed no input, no point saved
      return (currentPosition, nil)
    }
    assert(rangeStart <= rangeEnd)

    // NOTE: We can't assert that rangeEnd trails currentPosition by one
    // position, because newline-sequence in scalar semantic mode still
    // matches two scalars

    return (currentPosition, rangeStart..<rangeEnd)
  }

  /// Specialized quantify instruction interpreter for `+`
  fileprivate func runNOrMoreQuantify(
    _ payload: QuantifyPayload,
    asciiBitset: ASCIIBitset?, // Necessary ugliness...
    at currentPosition: Index,
    limitedBy end: Index
  ) -> (Index, savePointRange: Range<Index>?)? {
    assert(payload.maxExtraTrips == nil)

    return _runNOrMoreQuantify(
      payload,
      minTrips: payload.minTrips,
      maxTrips: UInt64.max,
      asciiBitset: asciiBitset,
      at: currentPosition,
      limitedBy: end)
  }

  /// Specialized quantify instruction interpreter for `+`
  fileprivate func runOneOrMoreQuantify(
    _ payload: QuantifyPayload,
    asciiBitset: ASCIIBitset?, // Necessary ugliness...
    at currentPosition: Index,
    limitedBy end: Index
  ) -> (Index, savePointRange: Range<Index>?)? {
    assert(payload.minTrips == 1 && payload.maxExtraTrips == nil)

    return _runNOrMoreQuantify(
      payload,
      minTrips: 1,
      maxTrips: UInt64.max,
      asciiBitset: asciiBitset,
      at: currentPosition,
      limitedBy: end)
  }

  /// Specialized quantify instruction interpreter for ?
  fileprivate func runZeroOrOneQuantify(
    _ payload: QuantifyPayload,
    asciiBitset: ASCIIBitset?, // Necessary ugliness...
    at currentPosition: Index,
    limitedBy end: Index
  ) -> (Index, savePointRange: Range<Index>?) {
    assert(payload.minTrips == 0 && payload.maxExtraTrips == 1)

    guard let res = _runNOrMoreQuantify(
      payload,
      minTrips: 0,
      maxTrips: 1,
      asciiBitset: asciiBitset,
      at: currentPosition,
      limitedBy: end
    ) else {
      fatalError("Unreachable: zero-or-more always succeeds")
    }

    return res
  }  
}


