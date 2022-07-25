@_implementationOnly import _RegexParser // For AssertionKind

extension Processor {
  mutating func matchBuiltin(
    _ cc: _CharacterClassModel.Representation,
    _ isInverted: Bool,
    _ isStrictASCII: Bool,
    _ isScalarSemantics: Bool
  ) -> Bool {
    guard let char = load(), let scalar = loadScalar() else {
      signalFailure()
      return false
    }

    var asciiCheck: Bool {
      (char.isASCII && !isScalarSemantics)
      || (scalar.isASCII && isScalarSemantics)
      || !isStrictASCII
    }
    var matched: Bool
    var next: Input.Index
    if isScalarSemantics {
      next = input.unicodeScalars.index(after: currentPosition)
    } else {
      next = input.index(after: currentPosition)
    }
    switch cc {
    case .any:
      matched = true
    case .anyGrapheme:
      matched = true
      next = input.index(after: currentPosition)
    case .anyScalar:
      // FIXME: This allows us to be not-scalar aligned when in grapheme mode
      // Should this even be allowed?
      matched = true
      next = input.unicodeScalars.index(after: currentPosition)
    case .digit:
      if isScalarSemantics {
        matched = scalar.properties.numericType != nil
      } else {
        matched = char.isNumber && asciiCheck
      }
    case .horizontalWhitespace:
      matched = scalar.isHorizontalWhitespace && asciiCheck
    case .verticalWhitespace:
      matched = scalar.isNewline && asciiCheck
    case .newlineSequence:
      matched = scalar.isNewline && asciiCheck
      if isScalarSemantics && matched && scalar == "\r"
          && next != input.endIndex && input.unicodeScalars[next] == "\n" {
        // Match a full CR-LF sequence even in scalar sematnics
        input.unicodeScalars.formIndex(after: &next)
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
    if matched {
      currentPosition = next
      return true
    } else {
      signalFailure()
      return false
    }
  }
  
  func isAtStartOfLine(_ payload: AssertionPayload) -> Bool {
    if currentPosition == subjectBounds.lowerBound { return true }
    switch payload.semanticLevel {
    case .graphemeCluster:
      return input[input.index(before: currentPosition)].isNewline
    case .unicodeScalar:
      return input.unicodeScalars[input.unicodeScalars.index(before: currentPosition)].isNewline
    }
  }
  
  func isAtEndOfLine(_ payload: AssertionPayload) -> Bool {
    if currentPosition == subjectBounds.upperBound { return true }
    switch payload.semanticLevel {
    case .graphemeCluster:
      return input[currentPosition].isNewline
    case .unicodeScalar:
      return input.unicodeScalars[currentPosition].isNewline
    }
  }

  mutating func builtinAssert(by payload: AssertionPayload) throws -> Bool {
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
        // TODO: How should we handle bounds?
        return atSimpleBoundary(payload.usesASCIIWord, payload.semanticLevel)
      } else {
        return input.isOnWordBoundary(at: currentPosition, using: &wordIndexCache, &wordIndexMaxIndex)
      }

    case .notWordBoundary:
      if payload.usesSimpleUnicodeBoundaries {
        // TODO: How should we handle bounds?
        return !atSimpleBoundary(payload.usesASCIIWord, payload.semanticLevel)
      } else {
        return !input.isOnWordBoundary(at: currentPosition, using: &wordIndexCache, &wordIndexMaxIndex)
      }
      }
  }
}
