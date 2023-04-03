
/// TODO: better description
/// Whether this is the starting byte of a sub-300 (i.e. pre-combining scalar) scalars
private func _isSub300StartingByte(_ x: UInt8) -> Bool {
  x < 0xCC
}
private func _isASCII(_ x: UInt8) -> Bool {
  x < 0x80
}

private var _lineFeed: UInt8 { 0x0A }
private var _carriageReturn: UInt8 { 0x0D }
private var _lineTab: UInt8 { 0x0B }
private var _formFeed: UInt8 { 0x0C }
private var _space: UInt8 { 0x20 }
private var _tab: UInt8 { 0x09 }



private var _0: UInt8 { 0x30 }
private var _9: UInt8 { 0x39 }
private func _isASCIINumber(_ x: UInt8) -> Bool {
  return (_0..._9).contains(x)
}

private var _a: UInt8 { 0x61 }
private var _z: UInt8 { 0x7A }
private var _A: UInt8 { 0x41 }
private var _Z: UInt8 { 0x5A }
private func _isASCIILetter(_ x: UInt8) -> Bool {
  return (_a..._z).contains(x) || (_A..._Z).contains(x)
}

private var _underscore: UInt8 { 0x5F }


extension String {


  /// TODO: detailed description of nuanced semantics
  func _asciiCharacter(
    at idx: Index
  ) -> (first: UInt8, next: Index, crLF: Bool)? {
    // TODO: fastUTF8 version

    if idx == endIndex {
      return nil
    }
    let base = utf8[idx]
    guard _isASCII(base) else { return nil }

    var next = utf8.index(after: idx)
    if next == utf8.endIndex {
      return (first: base, next: next, crLF: false)
    }

    let tail = utf8[next]
    guard _isSub300StartingByte(tail) else { return nil }

    // Handle CR-LF:
    if base == _carriageReturn && tail == _lineFeed {
      utf8.formIndex(after: &next)
      guard next == endIndex || _isSub300StartingByte(utf8[next]) else {
        return nil
      }
      return (first: base, next: next, crLF: true)
    }

    return (first: base, next: next, crLF: false)
  }

  func _quickMatch(
    _ cc: _CharacterClassModel.Representation,
    at idx: Index,
    isScalarSemantics: Bool
  ) -> (next: Index, matchResult: Bool)? {
    /// ASCII fast-paths
    guard let (asciiValue, next, isCRLF) = _asciiCharacter(
      at: idx
    ) else {
      return nil
    }

    // TODO: bitvectors
    switch cc {
    case .any, .anyGrapheme, .anyScalar:
      // TODO: should any scalar not consume CR-LF in scalar semantic mode?
      return (next, true)

    case .digit:
      if _isASCIINumber(asciiValue) {
        return (next, true)
      }
      return (next, false)

    case .horizontalWhitespace:
      switch asciiValue {
        case _space, _tab: return (next, true)
        default: return (next, false)
      }

    case .verticalWhitespace, .newlineSequence:
      switch asciiValue {
        case _lineFeed, _carriageReturn, _lineTab, _formFeed:
        // Scalar semantics: For `\v`, only advance past the CR instead of CR-LF
        if isScalarSemantics && isCRLF && cc == .verticalWhitespace {
          return (utf8.index(before: next), true)
        }
        return (next, true)

        default:
          return (next, false)
      }

    case .whitespace:
      switch asciiValue {
        case _space, _tab, _lineFeed, _lineTab, _formFeed, _carriageReturn:
          return (next, true)
        default:
          return (next, false)
      }

    case .word:
      let matches = _isASCIINumber(asciiValue) || _isASCIILetter(asciiValue) || asciiValue == _underscore
      return (next, matches)
    }
  }

}

/// An enum for quick-check functions, which could return a yes, no, or maybe
/// result.
enum QuickResult<R> {
  case yes(_ r: R)
  case no
  case maybe

  static func definite(_ r: R?) -> QuickResult {
    if let r = r {
      return .yes(r)
    }
    return .no
  }
}


