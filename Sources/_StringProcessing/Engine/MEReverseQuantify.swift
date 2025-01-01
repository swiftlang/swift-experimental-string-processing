extension Processor {
  func _doReverseQuantifyMatch(_ payload: QuantifyPayload) -> Input.Index? {
    let isScalarSemantics = payload.isScalarSemantics

    switch payload.type {
    case .asciiBitset:
      return input.reverseMatchASCIIBitset(
        registers[payload.bitset],
        at: currentPosition,
        limitedBy: start,
        isScalarSemantics: isScalarSemantics)
    case .asciiChar:
      return input.reverseMatchScalar(
        UnicodeScalar.init(_value: UInt32(payload.asciiChar)),
        at: currentPosition,
        limitedBy: start,
        boundaryCheck: !isScalarSemantics,
        isCaseInsensitive: false)
    case .builtinCC:
      guard currentPosition >= start else { return nil }

      // We only emit .quantify if it consumes a single character
      return input.reverseMatchBuiltinCC(
        payload.builtinCC,
        at: currentPosition,
        limitedBy: start,
        isInverted: payload.builtinIsInverted,
        isStrictASCII: payload.builtinIsStrict,
        isScalarSemantics: isScalarSemantics)
    case .any:
      guard currentPosition >= start else { return nil }

      if payload.anyMatchesNewline {
        if isScalarSemantics {
          return input.unicodeScalars.index(before: currentPosition)
        }
        return input.index(before: currentPosition)
      }

      return input.reverseMatchAnyNonNewline(
        at: currentPosition,
        limitedBy: start,
        isScalarSemantics: isScalarSemantics)
    }
  }

  /// Generic bounded reverseQuantify instruction interpreter
  /// - Handles .eager and .posessive
  /// - Handles arbitrary minTrips and maxExtraTrips
  mutating func runReverseQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind != .reluctant)

    var trips = 0
    var maxExtraTrips = payload.maxExtraTrips

    while trips < payload.minTrips {
      guard let previous = _doReverseQuantifyMatch(payload) else {
        signalFailure()
        return false
      }

      currentPosition = previous

      // If we've reached the start of the string but still have more trips, fail
      if currentPosition == start, trips < payload.minTrips {
        signalFailure()
        return false
      }

      trips += 1
    }

    // If we don't have any more trips to take:
    if maxExtraTrips == 0 {
      // We're done
      return true
    }

    // We've already consumed the minimum number of characters,
    // If we can't get another match, the reverse quantify was successful
    guard let previous = _doReverseQuantifyMatch(payload) else {
      return true
    }
    maxExtraTrips = maxExtraTrips.map { $0 - 1 }

    // Remember the range of valid positions in case we can create a quantified
    // save point
    var rangeStart = currentPosition
    let rangeEnd = currentPosition
    currentPosition = previous

    while true {
      if maxExtraTrips == 0 { break }

      guard let previous = _doReverseQuantifyMatch(payload) else {
        break
      }
      maxExtraTrips = maxExtraTrips.map({$0 - 1})
      rangeStart = currentPosition
      currentPosition = previous
    }

    if payload.quantKind == .eager {
      savePoints.append(makeQuantifiedSavePoint(
        rangeStart..<rangeEnd, isScalarSemantics: payload.isScalarSemantics))
    } else {
      // No backtracking permitted after a successful advance
      assert(payload.quantKind == .possessive)
    }
    return true
  }

  /// Specialized quantify instruction interpreter for `*`, always succeeds
  mutating func runEagerZeroOrMoreReverseQuantify(_ payload: QuantifyPayload) {
    assert(payload.quantKind == .eager
           && payload.minTrips == 0
           && payload.maxExtraTrips == nil)
    _doRunEagerZeroOrMoreReverseQuantify(payload)
  }

  // NOTE: So-as to inline into one-or-more call, which makes a significant
  // performance difference
  @inline(__always)
  mutating func _doRunEagerZeroOrMoreReverseQuantify(_ payload: QuantifyPayload) {
    guard let previous = _doReverseQuantifyMatch(payload) else {
      // Consumed no input, no point saved
      return
    }

    // Create a quantified save point for every part of the input matched up
    // to the final position.
    var rangeStart = currentPosition
    let rangeEnd = currentPosition
    currentPosition = previous
    while true {
      guard let previous = _doReverseQuantifyMatch(payload) else { break }
      rangeStart = currentPosition
      currentPosition = previous
    }

    savePoints.append(makeQuantifiedSavePoint(rangeStart..<rangeEnd, isScalarSemantics: payload.isScalarSemantics))
  }

  /// Specialized quantify instruction interpreter for `+`
  mutating func runEagerOneOrMoreReverseQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind == .eager
           && payload.minTrips == 1
           && payload.maxExtraTrips == nil)

    // Match at least once
    guard let previous = _doReverseQuantifyMatch(payload) else {
      signalFailure()
      return false
    }

    // Run `a+` as `aa*`
    currentPosition = previous
    _doRunEagerZeroOrMoreReverseQuantify(payload)
    return true
  }

  /// Specialized quantify instruction interpreter for ?
  mutating func runZeroOrOneReverseQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.minTrips == 0
           && payload.maxExtraTrips == 1)
    let previous = _doReverseQuantifyMatch(payload)
    guard let idx = previous else {
      return true // matched zero times
    }
    if payload.quantKind != .possessive {
      // Save the zero match
      savePoints.append(makeSavePoint(resumingAt: currentPC+1))
    }
    currentPosition = idx
    return true
  }
}
