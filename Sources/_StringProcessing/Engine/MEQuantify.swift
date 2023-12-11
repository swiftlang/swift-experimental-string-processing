private typealias ASCIIBitset = DSLTree.CustomCharacterClass.AsciiBitset

extension Processor {
  internal mutating func runQuantify(_ payload: QuantifyPayload) -> Bool {
    let matched: Bool
    switch (payload.quantKind, payload.minTrips, payload.maxExtraTrips) {
    case (.reluctant, _, _):
      assertionFailure(".reluctant is not supported by .quantify")
      // TODO: this was pre-refactoring behavior, should we fatal error
      //       instead?
      return false 
    case (.eager, 0, nil):
      runEagerZeroOrMoreQuantify(payload)
      return true
    case (.eager, 1, nil):
      return runEagerOneOrMoreQuantify(payload)
    case (_, 0, 1):
      runZeroOrOneQuantify(payload)
      return true
    default:
      return runGeneralQuantify(payload)
    }
  }

  private func doQuantifyMatch(_ payload: QuantifyPayload) -> Input.Index? {
    let isScalarSemantics = payload.isScalarSemantics

    switch payload.type {
    case .asciiBitset:
      return input.matchASCIIBitset(
        registers[payload.bitset],
        at: currentPosition,
        limitedBy: end,
        isScalarSemantics: isScalarSemantics)
    case .asciiChar:
      return input.matchScalar(
        UnicodeScalar.init(_value: UInt32(payload.asciiChar)),
        at: currentPosition,
        limitedBy: end,
        boundaryCheck: !isScalarSemantics,
        isCaseInsensitive: false)
    case .builtin:
      // We only emit .quantify if it consumes a single character
      return input.matchBuiltinCC(
        payload.builtin,
        at: currentPosition,
        limitedBy: end,
        isInverted: payload.builtinIsInverted,
        isStrictASCII: payload.builtinIsStrict,
        isScalarSemantics: isScalarSemantics)
    case .any:
      return input.matchRegexDot(
        at: currentPosition,
        limitedBy: end,
        anyMatchesNewline: payload.anyMatchesNewline,
        isScalarSemantics: isScalarSemantics)
    }
  }

  /// Generic quantify instruction interpreter
  /// - Handles .eager and .posessive
  /// - Handles arbitrary minTrips and maxExtraTrips
  private mutating func runGeneralQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind != .reluctant)

    var trips = 0
    var maxExtraTrips = payload.maxExtraTrips

    while trips < payload.minTrips {
      guard let next = doQuantifyMatch(payload) else {
        signalFailure()
        return false
      }
      currentPosition = next
      trips += 1
    }

    if maxExtraTrips == 0 {
      // We're done
      return true
    }

    guard let next = doQuantifyMatch(payload) else {
      return true
    }
    maxExtraTrips = maxExtraTrips.map { $0 - 1 }

    // Remember the range of valid positions in case we can create a quantified
    // save point
    let rangeStart = currentPosition
    var rangeEnd = currentPosition
    currentPosition = next

    while true {
      if maxExtraTrips == 0 { break }

      guard let next = doQuantifyMatch(payload) else {
        break
      }
      maxExtraTrips = maxExtraTrips.map({$0 - 1})
      rangeEnd = currentPosition
      currentPosition = next
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
  private mutating func runEagerZeroOrMoreQuantify(_ payload: QuantifyPayload) {
    assert(payload.quantKind == .eager
           && payload.minTrips == 0
           && payload.maxExtraTrips == nil)
    _ = doRunEagerZeroOrMoreQuantify(payload)
  }

  // Returns whether it matched at least once
  //
  // NOTE: inline-always so-as to inline into one-or-more call, which makes a
  // significant performance difference
  @inline(__always)
  private mutating func doRunEagerZeroOrMoreQuantify(_ payload: QuantifyPayload) -> Bool {
    // Create a quantified save point for every part of the input matched up
    // to the final position.
    let isScalarSemantics = payload.isScalarSemantics
    let rangeStart = currentPosition
    var rangeEnd = currentPosition
    var matchedOnce = false

    switch payload.type {
    case .asciiBitset:
      let bitset = registers[payload.bitset]
      while true {
        guard let next = input.matchASCIIBitset(
          bitset,
          at: currentPosition,
          limitedBy: end,
          isScalarSemantics: isScalarSemantics)
        else {
          break
        }
        matchedOnce = true
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    case .asciiChar:
      let asciiScalar = UnicodeScalar.init(_value: UInt32(payload.asciiChar))
      while true {
        guard let next = input.matchScalar(
          asciiScalar,
          at: currentPosition,
          limitedBy: end,
          boundaryCheck: !isScalarSemantics,
          isCaseInsensitive: false)
        else {
          break
        }
        matchedOnce = true
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    case .builtin:
      let builtin = payload.builtin
      let isInverted = payload.builtinIsInverted
      let isStrictASCII = payload.builtinIsStrict
      while true {
        guard let next = input.matchBuiltinCC(
          builtin,
          at: currentPosition,
          limitedBy: end,
          isInverted: isInverted,
          isStrictASCII: isStrictASCII,
          isScalarSemantics: isScalarSemantics)
        else {
          break
        }
        matchedOnce = true
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    case .any:
      let anyMatchesNewline = payload.anyMatchesNewline
      while true {
        guard let next = input.matchRegexDot(
          at: currentPosition,
          limitedBy: end,
          anyMatchesNewline: anyMatchesNewline,
          isScalarSemantics: isScalarSemantics)
        else {
          break
        }
        matchedOnce = true
        rangeEnd = currentPosition
        currentPosition = next
        assert(currentPosition > rangeEnd)
      }
    }

    guard matchedOnce else {
      // Consumed no input, no point saved
      return false
    }

    // NOTE: We can't assert that rangeEnd trails currentPosition by one
    // position, because newline-sequence in scalar semantic mode still
    // matches two scalars

    savePoints.append(makeQuantifiedSavePoint(
      rangeStart..<rangeEnd, isScalarSemantics: payload.isScalarSemantics))
    return true
  }

  /// Specialized quantify instruction interpreter for `+`
  private mutating func runEagerOneOrMoreQuantify(_ payload: QuantifyPayload) -> Bool {
    assert(payload.quantKind == .eager
           && payload.minTrips == 1
           && payload.maxExtraTrips == nil)

    // Match at least once
    guard let next = doQuantifyMatch(payload) else {
      signalFailure()
      return false
    }

    // Run `a+` as `aa*`
    currentPosition = next
    doRunEagerZeroOrMoreQuantify(payload)
    return true
  }

  /// Specialized quantify instruction interpreter for ?
  private mutating func runZeroOrOneQuantify(_ payload: QuantifyPayload) {
    assert(payload.minTrips == 0
           && payload.maxExtraTrips == 1)
    let next = doQuantifyMatch(payload)
    guard let idx = next else {
      return // matched zero times
    }
    if payload.quantKind != .possessive {
      // Save the zero match
      savePoints.append(makeSavePoint(resumingAt: currentPC+1))
    }
    currentPosition = idx
    return
  }
}
