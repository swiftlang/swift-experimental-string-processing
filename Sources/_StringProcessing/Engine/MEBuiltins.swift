@_implementationOnly import _RegexParser // For AssertionKind

extension Processor {
  mutating func matchBuiltin(
    _ cc: BuiltinCC,
    _ isStrictAscii: Bool
  ) -> Bool {
    guard let c = load() else {
      signalFailure()
      return false
    }

    var matched: Bool
    var next = input.index(after: currentPosition)
    switch cc {
    case .any, .anyGrapheme: matched = true
    case .anyScalar:
      matched = true
      next = input.unicodeScalars.index(after: currentPosition)
    case .digit:
      matched = c.isNumber && (c.isASCII || !isStrictAscii)
    case .hexDigit:
      matched = c.isHexDigit && (c.isASCII || !isStrictAscii)
    case .horizontalWhitespace:
      matched = c.unicodeScalars.first?.isHorizontalWhitespace == true
      && (c.isASCII || !isStrictAscii)
    case .newlineSequence, .verticalWhitespace:
      matched = c.unicodeScalars.first?.isNewline == true
      && (c.isASCII || !isStrictAscii)
    case .whitespace:
      matched = c.isWhitespace && (c.isASCII || !isStrictAscii)
    case .word:
      matched = c.isWordCharacter && (c.isASCII || !isStrictAscii)
    }
    
    if matched {
      currentPosition = next
      return true
    } else {
      signalFailure()
      return false
    }
  }
  
  mutating func matchBuiltinScalar(
    _ cc: BuiltinCC,
    _ isStrictAscii: Bool
  ) -> Bool {
    guard let c = loadScalar() else {
      signalFailure()
      return false
    }

    var matched: Bool
    var next = input.unicodeScalars.index(after: currentPosition)
    switch cc {
    case .any: matched = true
    case .anyScalar: matched = true
    case .anyGrapheme:
      matched = true
      next = input.index(after: currentPosition)
    case .digit:
      matched = c.properties.numericType != nil && (c.isASCII || !isStrictAscii)
    case .hexDigit:
      matched = Character(c).isHexDigit && (c.isASCII || !isStrictAscii)
    case .horizontalWhitespace:
      matched = c.isHorizontalWhitespace && (c.isASCII || !isStrictAscii)
    case .verticalWhitespace:
      matched = c.isNewline && (c.isASCII || !isStrictAscii)
    case .newlineSequence:
      matched = c.isNewline && (c.isASCII || !isStrictAscii)
      if c == "\r" && next != input.endIndex && input.unicodeScalars[next] == "\n" {
        input.unicodeScalars.formIndex(after: &next)
      }
    case .whitespace:
      matched = c.properties.isWhitespace && (c.isASCII || !isStrictAscii)
    case .word:
      matched = (c.properties.isAlphabetic || c == "_") && (c.isASCII || !isStrictAscii)
    }
    
    if matched {
      currentPosition = next
      return true
    } else {
      signalFailure()
      return false
    }
  }

  mutating func regexAssert(by payload: AssertionPayload) throws -> Bool {
    // Future work: Optimize layout and dispatch
    
    // FIXME: Depends on API model we have... We may want to
    // think through some of these with API interactions in mind
    //
    // This might break how we use `bounds` for both slicing
    // and things like `firstIndex`, that is `firstIndex` may
    // need to supply both a slice bounds and a per-search bounds.
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
      // FIXME: Figure out how to communicate this out
      throw Unsupported(#"\K (reset/keep assertion)"#)

    case .firstMatchingPositionInSubject:
      // TODO: We can probably build a nice model with API here

      // FIXME: This needs to be based on `searchBounds`,
      // not the `subjectBounds` given as an argument here
      // (Note: the above fixme was in reference to the old assert function API.
      //   Now that we're in processor, we have access to searchBounds)
      return false

    case .textSegment: return input.isOnGraphemeClusterBoundary(currentPosition)

    case .notTextSegment: return !input.isOnGraphemeClusterBoundary(currentPosition)

    case .startOfLine:
      // FIXME: Anchor.startOfLine must always use this first branch
      // The behavior of `^` should depend on `anchorsMatchNewlines`, but
      // the DSL-based `.startOfLine` anchor should always match the start
      // of a line. Right now we don't distinguish between those anchors.
      if payload.anchorsMatchNewlines {
        if currentPosition == subjectBounds.lowerBound { return true }
        switch payload.semanticLevel {
        case .graphemeCluster:
          return input[input.index(before: currentPosition)].isNewline
        case .unicodeScalar:
          return input.unicodeScalars[input.unicodeScalars.index(before: currentPosition)].isNewline
        }
      } else {
        return currentPosition == subjectBounds.lowerBound
      }
  
      case .endOfLine:
        // FIXME: Anchor.endOfLine must always use this first branch
        // The behavior of `$` should depend on `anchorsMatchNewlines`, but
        // the DSL-based `.endOfLine` anchor should always match the end
        // of a line. Right now we don't distinguish between those anchors.
        if payload.anchorsMatchNewlines {
          if currentPosition == subjectBounds.upperBound { return true }
          switch payload.semanticLevel {
          case .graphemeCluster:
            return input[currentPosition].isNewline
          case .unicodeScalar:
            return input.unicodeScalars[currentPosition].isNewline
          }
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

struct AssertionPayload: RawRepresentable {
  var _assertionKindMask: UInt64 { ~0xFFF0_0000_0000_0000 }
  var _opcodeMask: UInt64 { 0xFF00_0000_0000_0000 }
  
  let rawValue: UInt64

  init(rawValue: UInt64) {
    self.rawValue = rawValue
    assert(rawValue & _opcodeMask == 0)
  }
  
  init(_ assertion: AST.Atom.AssertionKind,
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
  
  var kind: AST.Atom.AssertionKind {
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
    return kind
  }
  var anchorsMatchNewlines: Bool { (self.rawValue >> 55) & 1 == 1 }
  var usesSimpleUnicodeBoundaries: Bool  { (self.rawValue >> 54) & 1 == 1 }
  var usesASCIIWord: Bool  { (self.rawValue >> 53) & 1 == 1 }
  var semanticLevel: MatchingOptions.SemanticLevel {
    if (self.rawValue >> 52) & 1 == 1 {
      return .unicodeScalar
    } else {
      return .graphemeCluster
    }
  }
}
