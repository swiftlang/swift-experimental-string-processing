internal import _RegexParser // For AssertionKind
extension Character {
  var _isHorizontalWhitespace: Bool {
    self.unicodeScalars.first?.isHorizontalWhitespace == true
  }
  var _isNewline: Bool {
    self.unicodeScalars.first?.isNewline == true
  }
}

extension Processor {
  mutating func matchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> Bool {
    guard currentPosition < end, let next = input.matchBuiltinCC(
      cc,
      at: currentPosition,
      limitedBy: end,
      isInverted: isInverted,
      isStrictASCII: isStrictASCII,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }
    currentPosition = next
    return true
  }

  mutating func reverseMatchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> Bool {
    guard currentPosition >= start, let previous = input.reverseMatchBuiltinCC(
      cc,
      at: currentPosition,
      limitedBy: start,
      isInverted: isInverted,
      isStrictASCII: isStrictASCII,
      isScalarSemantics: isScalarSemantics
    ) else {
      signalFailure()
      return false
    }
    currentPosition = previous
    return true
  }

  func isAtStartOfLine(_ payload: AssertionPayload) -> Bool {
    // TODO: needs benchmark coverage
    if currentPosition == subjectBounds.lowerBound { return true }
    switch payload.semanticLevel {
    case .graphemeCluster:
      return input[input.index(before: currentPosition)].isNewline
    case .unicodeScalar:
      return input.unicodeScalars[input.unicodeScalars.index(before: currentPosition)].isNewline
    }
  }

  func isAtEndOfLine(_ payload: AssertionPayload) -> Bool {
    // TODO: needs benchmark coverage
    if currentPosition == subjectBounds.upperBound { return true }
    switch payload.semanticLevel {
    case .graphemeCluster:
      return input[currentPosition].isNewline
    case .unicodeScalar:
      return input.unicodeScalars[currentPosition].isNewline
    }
  }

  mutating func builtinAssert(by payload: AssertionPayload) throws -> Bool {
    // TODO: needs benchmark coverage

    // Future work: Optimize layout and dispatch
    switch payload.kind {
    case .startOfSubject: return currentPosition == subjectBounds.lowerBound

    case .endOfSubjectBeforeNewline:
      if currentPosition == subjectBounds.upperBound { return true }
      switch payload.semanticLevel {
      case .graphemeCluster:
        return input.index(after: currentPosition) == subjectBounds.upperBound
        && input[currentPosition].isNewline
      case .unicodeScalar:
        return input.unicodeScalars.index(after: currentPosition) == subjectBounds.upperBound
        && input.unicodeScalars[currentPosition].isNewline
      }

    case .endOfSubject: return currentPosition == subjectBounds.upperBound

    case .resetStartOfMatch:
      fatalError("Unreachable, we should have thrown an error during compilation")

    case .firstMatchingPositionInSubject:
      return currentPosition == searchBounds.lowerBound

    case .textSegment: return input.isOnGraphemeClusterBoundary(currentPosition)

    case .notTextSegment: return !input.isOnGraphemeClusterBoundary(currentPosition)

    case .startOfLine:
      return isAtStartOfLine(payload)
    case .endOfLine:
      return isAtEndOfLine(payload)

    case .caretAnchor:
      if payload.anchorsMatchNewlines {
        return isAtStartOfLine(payload)
      } else {
        return currentPosition == subjectBounds.lowerBound
      }

    case .dollarAnchor:
      if payload.anchorsMatchNewlines {
        return isAtEndOfLine(payload)
      } else {
        return currentPosition == subjectBounds.upperBound
      }

    case .wordBoundary:
      if payload.usesSimpleUnicodeBoundaries {
        return atSimpleBoundary(payload.usesASCIIWord, payload.semanticLevel)
      } else {
        return input.isOnWordBoundary(at: currentPosition, in: subjectBounds, using: &wordIndexCache, &wordIndexMaxIndex)
      }

    case .notWordBoundary:
      if payload.usesSimpleUnicodeBoundaries {
        return !atSimpleBoundary(payload.usesASCIIWord, payload.semanticLevel)
      } else {
        return !input.isOnWordBoundary(at: currentPosition, in: subjectBounds, using: &wordIndexCache, &wordIndexMaxIndex)
      }
    }
  }
}

// MARK: Matching `.`
extension String {
  /// Returns the character at `pos`, bounded by `end`, as well as the upper
  /// boundary of the returned character.
  ///
  /// This function handles loading a character from a string while respecting
  /// an end boundary, even if that end boundary is sub-character or sub-scalar.
  ///
  ///   - If `pos` is at or past `end`, this function returns `nil`.
  ///   - If `end` is between `pos` and the next grapheme cluster boundary (i.e.,
  ///     `end` is before `self.index(after: pos)`, then the returned character
  ///     is smaller than the one that would be produced by `self[pos]` and the
  ///     returned index is at the end of that character.
  ///   - If `end` is between `pos` and the next grapheme cluster boundary, and
  ///     is not on a Unicode scalar boundary, the partial scalar is dropped. This
  ///     can result in a `nil` return or a character that includes only part of
  ///     the `self[pos]` character.
  ///
  /// - Parameters:
  ///   - pos: The position to load a character from.
  ///   - end: The limit for the character at `pos`.
  /// - Returns: The character at `pos`, bounded by `end`, if it exists, along
  ///   with the upper bound of that character. The upper bound is always
  ///   scalar-aligned.
  func characterAndEnd(at pos: String.Index, limitedBy end: String.Index) -> (Character, String.Index)? {
    // FIXME: Sink into the stdlib to avoid multiple boundary calculations
    guard pos < end else { return nil }
    let next = index(after: pos)
    if next <= end {
      return (self[pos], next)
    }

    // `end` must be a sub-character position that is between `pos` and the
    // next grapheme boundary. This is okay if `end` is on a Unicode scalar
    // boundary, but if it's in the middle of a scalar's code units, there
    // may not be a character to return at all after rounding down. Use
    // `Substring`'s rounding to determine what we can return.
    let substr = self[pos..<end]
    return substr.isEmpty
      ? nil
      : (substr.first!, substr.endIndex)
  }

  /// Returns the character at `pos`, bounded by `start`, as well as the lower
  /// boundary of the returned character.
  ///
  /// This function handles loading a character from a string while respecting
  /// an start boundary, even if that start boundary is sub-character or sub-scalar.
  ///
  ///   - If `pos` is at or past `start`, this function returns `nil`.
  ///   - If `start` is between `pos` and the next grapheme cluster boundary (i.e.,
  ///     `start` is before `self.index(after: pos)`, then the returned character
  ///     is smaller than the one that would be produced by `self[pos]` and the
  ///     returned index is at the start of that character.
  ///   - If `start` is between `pos` and the next grapheme cluster boundary, and
  ///     is not on a Unicode scalar boundary, the partial scalar is dropped. This
  ///     can result in a `nil` return or a character that includes only part of
  ///     the `self[pos]` character.
  ///
  /// - Parameters:
  ///   - pos: The position to load a character from.
  ///   - start: The limit for the character at `pos`.
  /// - Returns: The character at `pos`, bounded by `start`, if it exists, along
  ///   with the lower bound of that character. The lower bound is always
  ///   scalar-aligned.
  func characterAndStart(
    at pos: String.Index,
    limitedBy start: String.Index
  ) -> (Character, characterStart: String.Index)? {
    // FIXME: Sink into the stdlib to avoid multiple boundary calculations
    guard pos > start else { return nil }
    let previous = index(before: pos)
    if previous >= start {
      return (self[pos], previous)
    }

    // `start` must be a sub-character position that is between `pos` and the
    // next grapheme boundary. This is okay if `start` is on a Unicode scalar
    // boundary, but if it's in the middle of a scalar's code units, there
    // may not be a character to return at all after rounding down. Use
    // `Substring`'s rounding to determine what we can return.
    let substr = self[start..<pos]
    return substr.isEmpty ? nil : (substr.first!, substr.startIndex)
  }

  func matchAnyNonNewline(
    at currentPosition: String.Index,
    limitedBy end: String.Index,
    isScalarSemantics: Bool
  ) -> String.Index? {
    guard currentPosition < end else { return nil }
    if case .definite(let result) = _quickMatchAnyNonNewline(
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics
    ) {
      assert(result == _thoroughMatchAnyNonNewline(
        at: currentPosition,
        limitedBy: end,
        isScalarSemantics: isScalarSemantics))
      return result
    }
    return _thoroughMatchAnyNonNewline(
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics)
  }

  func reverseMatchAnyNonNewline(
    at currentPosition: String.Index,
    limitedBy start: String.Index,
    isScalarSemantics: Bool
  ) -> String.Index? {
    guard currentPosition > start else { return nil }
    if case .definite(let result) = _quickReverseMatchAnyNonNewline(
      at: currentPosition,
      limitedBy: start,
      isScalarSemantics: isScalarSemantics
    ) {
      assert(result == _thoroughReverseMatchAnyNonNewline(
        at: currentPosition,
        limitedBy: start,
        isScalarSemantics: isScalarSemantics))
      return result
    }
    return _thoroughReverseMatchAnyNonNewline(
      at: currentPosition,
      limitedBy: start,
      isScalarSemantics: isScalarSemantics)
  }

  @inline(__always)
  private func _quickMatchAnyNonNewline(
    at currentPosition: String.Index,
    limitedBy end: String.Index,
    isScalarSemantics: Bool
  ) -> QuickResult<String.Index?> {
    assert(currentPosition < end)
    guard let (asciiValue, next, isCRLF) = _quickASCIICharacter(
      at: currentPosition, limitedBy: end
    ) else {
      return .unknown
    }
    switch asciiValue {
    case (._lineFeed)...(._carriageReturn):
      return .definite(nil)
    default:
      assert(!isCRLF)
      return .definite(next)
    }
  }

  @inline(__always)
  private func _quickReverseMatchAnyNonNewline(
    at currentPosition: String.Index,
    limitedBy start: String.Index,
    isScalarSemantics: Bool
  ) -> QuickResult<String.Index?> {
    assert(currentPosition > start)
    guard let (asciiValue, previous, isCRLF) = _quickReverseASCIICharacter(
      at: currentPosition, limitedBy: start
    ) else {
      return .unknown
    }
    switch asciiValue {
    case (._lineFeed)...(._carriageReturn):
      return .definite(nil)
    default:
      assert(!isCRLF)
      return .definite(previous)
    }
  }

  @inline(never)
  private func _thoroughMatchAnyNonNewline(
    at currentPosition: String.Index,
    limitedBy end: String.Index,
    isScalarSemantics: Bool
  ) -> String.Index? {
    if isScalarSemantics {
      guard currentPosition < end else { return nil }
      let scalar = unicodeScalars[currentPosition]
      guard !scalar.isNewline else { return nil }
      return unicodeScalars.index(after: currentPosition)
    }

    guard let (char, next) = characterAndEnd(at: currentPosition, limitedBy: end),
          !char.isNewline
    else { return nil }
    return next
  }

  @inline(never)
  private func _thoroughReverseMatchAnyNonNewline(
    at currentPosition: String.Index,
    limitedBy start: String.Index,
    isScalarSemantics: Bool
  ) -> String.Index? {
    if isScalarSemantics {
      guard currentPosition > start else { return nil }
      let scalar = unicodeScalars[currentPosition]
      guard !scalar.isNewline else { return nil }
      return unicodeScalars.index(before: currentPosition)
    }

    guard let (char, previous) = characterAndStart(at: currentPosition, limitedBy: start),
          !char.isNewline
    else { return nil }
    return previous
  }

  internal func matchRegexDot(
    at currentPosition: Index,
    limitedBy end: Index,
    anyMatchesNewline: Bool,
    isScalarSemantics: Bool
  ) -> Index? {
    guard currentPosition < end else { return nil }

    if anyMatchesNewline {
      return index(
        after: currentPosition, isScalarSemantics: isScalarSemantics)
    }

    return matchAnyNonNewline(
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics)
  }
}

// MARK: - Built-in character class matching
extension String {
  // Mentioned in ProgrammersManual.md, update docs if redesigned
  func matchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    at currentPosition: String.Index,
    limitedBy end: String.Index,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> String.Index? {
    guard currentPosition < end else { return nil }
    if case .definite(let result) = _quickMatchBuiltinCC(
      cc,
      at: currentPosition,
      limitedBy: end,
      isInverted: isInverted,
      isStrictASCII: isStrictASCII,
      isScalarSemantics: isScalarSemantics
    ) {
      assert(result == _thoroughMatchBuiltinCC(
        cc,
        at: currentPosition,
        limitedBy: end,
        isInverted: isInverted,
        isStrictASCII: isStrictASCII,
        isScalarSemantics: isScalarSemantics))
      return result
    }
    return _thoroughMatchBuiltinCC(
      cc,
      at: currentPosition,
      limitedBy: end,
      isInverted: isInverted,
      isStrictASCII: isStrictASCII,
      isScalarSemantics: isScalarSemantics)
  }

  func reverseMatchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    at currentPosition: String.Index,
    limitedBy start: String.Index,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> String.Index? {
    guard currentPosition > start else { return nil }
    if case .definite(let result) = _quickReverseMatchBuiltinCC(
      cc,
      at: currentPosition,
      limitedBy: start,
      isInverted: isInverted,
      isStrictASCII: isStrictASCII,
      isScalarSemantics: isScalarSemantics
    ) {
      assert(result == _thoroughReverseMatchBuiltinCC(
        cc,
        at: currentPosition,
        limitedBy: start,
        isInverted: isInverted,
        isStrictASCII: isStrictASCII,
        isScalarSemantics: isScalarSemantics))
      return result
    }
    return _thoroughReverseMatchBuiltinCC(
      cc,
      at: currentPosition,
      limitedBy: start,
      isInverted: isInverted,
      isStrictASCII: isStrictASCII,
      isScalarSemantics: isScalarSemantics)
  }

  // TODO: JH - Is there any value in testing this? How would it be tested?
  // Mentioned in ProgrammersManual.md, update docs if redesigned
  @inline(__always)
  private func _quickMatchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    at currentPosition: String.Index,
    limitedBy end: String.Index,
    isInverted: Bool,
    isStrictASCII: Bool, // TODO: JH - Is this just reserved for future use? A relic of the past?
    isScalarSemantics: Bool
  ) -> QuickResult<String.Index?> {
    assert(currentPosition < end)
    guard let (next, result) = _quickMatch(
      cc,
      at: currentPosition,
      limitedBy: end,
      isScalarSemantics: isScalarSemantics
    ) else {
      return .unknown
    }
    return .definite(result == isInverted ? nil : next)
  }

  @inline(__always)
  private func _quickReverseMatchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    at currentPosition: String.Index,
    limitedBy start: String.Index,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> QuickResult<String.Index?> {
    assert(currentPosition > start)
    guard let (previous, result) = _quickReverseMatch(
      cc,
      at: currentPosition,
      limitedBy: start,
      isScalarSemantics: isScalarSemantics
    ) else {
      return .unknown
    }
    return .definite(result == isInverted ? nil : previous)
  }

  // TODO: JH - How can this be unit tested?
  // Mentioned in ProgrammersManual.md, update docs if redesigned
  @inline(never)
  private func _thoroughMatchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    at currentPosition: String.Index,
    limitedBy end: String.Index,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> String.Index? {
    // TODO: Branch here on scalar semantics
    // Don't want to pay character cost if unnecessary
    guard let (char, nextIndex) =
            characterAndEnd(at: currentPosition, limitedBy: end)
    else { return nil }
    var next = nextIndex
    let scalar = unicodeScalars[currentPosition]

    let asciiCheck = !isStrictASCII
    || (scalar.isASCII && isScalarSemantics)
    || char.isASCII

    var matched: Bool
    if isScalarSemantics && cc != .anyGrapheme {
      next = unicodeScalars.index(after: currentPosition)
    }

    switch cc {
    case .any, .anyGrapheme:
      matched = true
    case .digit:
      if isScalarSemantics {
        matched = scalar.properties.numericType != nil && asciiCheck
      } else {
        matched = char.isNumber && asciiCheck
      }
    case .horizontalWhitespace:
      if isScalarSemantics {
        matched = scalar.isHorizontalWhitespace && asciiCheck
      } else {
        matched = char._isHorizontalWhitespace && asciiCheck
      }
    case .verticalWhitespace:
      if isScalarSemantics {
        matched = scalar.isNewline && asciiCheck
      } else {
        matched = char._isNewline && asciiCheck
      }
    case .newlineSequence:
      if isScalarSemantics {
        matched = scalar.isNewline && asciiCheck
        if matched && scalar == "\r"
            && next < end && unicodeScalars[next] == "\n" {
          // Match a full CR-LF sequence even in scalar semantics
          unicodeScalars.formIndex(after: &next)
        }
      } else {
        matched = char._isNewline && asciiCheck
      }
    case .whitespace:
      if isScalarSemantics {
        matched = scalar.properties.isWhitespace && asciiCheck
      } else {
        matched = char.isWhitespace && asciiCheck
      }
    case .word:
      if isScalarSemantics {
        matched = scalar.properties.isAlphabetic && asciiCheck
      } else {
        matched = char.isWordCharacter && asciiCheck
      }
    }

    if isInverted {
      matched.toggle()
    }

    guard matched else {
      return nil
    }
    return next
  }

  @inline(never)
  private func _thoroughReverseMatchBuiltinCC(
    _ cc: _CharacterClassModel.Representation,
    at currentPosition: String.Index,
    limitedBy start: String.Index,
    isInverted: Bool,
    isStrictASCII: Bool,
    isScalarSemantics: Bool
  ) -> String.Index? {
    // TODO: Branch here on scalar semantics
    // Don't want to pay character cost if unnecessary
    guard let (char, previousIndex) =
            characterAndStart(at: currentPosition, limitedBy: start)
    else { return nil }
    var previous = previousIndex
    let scalar = unicodeScalars[currentPosition]

    let asciiCheck = !isStrictASCII
    || (scalar.isASCII && isScalarSemantics)
    || char.isASCII

    var matched: Bool
    if isScalarSemantics && cc != .anyGrapheme {
      previous = unicodeScalars.index(before: currentPosition)
    }

    switch cc {
    case .any, .anyGrapheme:
      matched = true
    case .digit:
      if isScalarSemantics {
        matched = scalar.properties.numericType != nil && asciiCheck
      } else {
        matched = char.isNumber && asciiCheck
      }
    case .horizontalWhitespace:
      if isScalarSemantics {
        matched = scalar.isHorizontalWhitespace && asciiCheck
      } else {
        matched = char._isHorizontalWhitespace && asciiCheck
      }
    case .verticalWhitespace:
      if isScalarSemantics {
        matched = scalar.isNewline && asciiCheck
      } else {
        matched = char._isNewline && asciiCheck
      }
    case .newlineSequence:
      if isScalarSemantics {
        matched = scalar.isNewline && asciiCheck
        if matched && scalar == "\r"
            && previous >= start && unicodeScalars[previous] == "\n" {
          // Match a full CR-LF sequence even in scalar semantics
          unicodeScalars.formIndex(after: &previous)
        }
      } else {
        matched = char._isNewline && asciiCheck
      }
    case .whitespace:
      if isScalarSemantics {
        matched = scalar.properties.isWhitespace && asciiCheck
      } else {
        matched = char.isWhitespace && asciiCheck
      }
    case .word:
      if isScalarSemantics {
        matched = scalar.properties.isAlphabetic && asciiCheck
      } else {
        matched = char.isWordCharacter && asciiCheck
      }
    }

    if isInverted {
      matched.toggle()
    }

    guard matched else {
      return nil
    }

    return previous
  }
}
