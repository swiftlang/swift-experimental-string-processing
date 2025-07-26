//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension UInt8 {
  static var _lineFeed: UInt8 { 0x0A }
  static var _carriageReturn: UInt8 { 0x0D }
  static var _lineTab: UInt8 { 0x0B }
  static var _formFeed: UInt8 { 0x0C }
  static var _space: UInt8 { 0x20 }
  static var _tab: UInt8 { 0x09 }

  static var _underscore: UInt8 { 0x5F }
}

private var _0: UInt8 { 0x30 }
private var _9: UInt8 { 0x39 }

private var _a: UInt8 { 0x61 }
private var _z: UInt8 { 0x7A }
private var _A: UInt8 { 0x41 }
private var _Z: UInt8 { 0x5A }

extension UInt8 {
  var _isASCII: Bool { self < 0x80 }

  // TODO: Bitvectors for the below

  /// Assuming we're ASCII, whether we match `\d`
  var _asciiIsDigit: Bool {
    assert(_isASCII)
    return(_0..._9).contains(self)
  }

  /// Assuming we're ASCII, whether we match `\h`
  var _asciiIsHorizontalWhitespace: Bool {
    assert(_isASCII)
    return self == ._space || self == ._tab
  }

  /// Assuming we're ASCII, whether we match `\v`
  var _asciiIsVerticalWhitespace: Bool {
    assert(_isASCII)
    switch self {
    case ._lineFeed, ._carriageReturn, ._lineTab, ._formFeed:
      return true
    default:
      return false
    }
  }

  /// Assuming we're ASCII, whether we match `\s`
  var _asciiIsWhitespace: Bool {
    assert(_isASCII)
    switch self {
    case ._space, ._tab, ._lineFeed, ._lineTab, ._formFeed, ._carriageReturn:
      return true
    default:
      return false
    }
  }

  /// Assuming we're ASCII, whether we match `[a-zA-Z]`
  var _asciiIsLetter: Bool {
    assert(_isASCII)
    return (_a..._z).contains(self) || (_A..._Z).contains(self)
  }

  /// Assuming we're ASCII, whether we match `\w`
  var _asciiIsWord: Bool {
    assert(_isASCII)
    return _asciiIsDigit || _asciiIsLetter || self == ._underscore
  }
}

extension String {
  /// Get the ASCII character at `idx` and the index following `idx`, advancing past
  /// CRLF sequences if necessary.
  ///
  /// If a CRLF sequence is detected, the returned `next` value will be at the index past
  /// both characters in the sequence.
  ///
  /// TODO: better to take isScalarSemantics parameter, we can return more results
  /// and we can give the right `next` index, not requiring the caller to re-adjust it
  /// TODO: detailed description of nuanced semantics
  /// - Parameters:
  ///   - idx: The index of the desired character.
  ///   - end: An upper bound that the `next` index cannot be greater than.
  /// - Returns: The character at `idx`, the index after `idx`,
  func _quickASCIICharacter(
    at idx: Index,
    limitedBy end: Index
  ) -> (first: UInt8, next: Index, crLF: Bool)? {
    // TODO: fastUTF8 version
    assert(String.Index(idx, within: unicodeScalars) != nil)
    assert(idx <= end)
    
    if idx == end {
      return nil
    }
    let base = utf8[idx]
    guard base._isASCII else {
      assert(!self[idx].isASCII)
      return nil
    }

    var next = utf8.index(after: idx)
    if next == end {
      return (first: base, next: next, crLF: false)
    }

    let tail = utf8[next]
    guard tail._isSub300StartingByte else { return nil }

    // Handle CR-LF by advancing past the sequence if both characters are present
    if base == ._carriageReturn && tail == ._lineFeed {
      utf8.formIndex(after: &next)
      guard next == end || utf8[next]._isSub300StartingByte else {
        return nil
      }
      return (first: base, next: next, crLF: true)
    }

    assert(self[idx].isASCII && self[idx] != "\r\n")
    return (first: base, next: next, crLF: false)
  }

  /// Get the ASCII character and index of the position before `idx`
  ///
  /// Treats CRLF sequences as a single character.
  ///
  /// TODO: better to take isScalarSemantics parameter, we can return more results
  /// and we can give the right `index`, not requiring the caller to re-adjust it
  /// TODO: detailed description of nuanced semantics
  /// - Parameters:
  ///   - idx: The index to look backwards from
  ///   - start: A lower bound that the `next` index can't be less than.
  /// - Returns: The character before the one at `idx`, the index of that character, and whether or not that character is a CRLF sequence. Nil if there is no character before `idx`.
  func _quickASCIICharacter(
    before idx: Index,
    limitedBy start: Index
  ) -> (char: UInt8, index: Index, crLF: Bool)? {
    // TODO: fastUTF8 version
    assert(String.Index(idx, within: unicodeScalars) != nil)
    assert(idx > start)

    // The index of the character we want to return
    var previous = utf8.index(before: idx)

    // The character we want to return
    let previousChar = utf8[previous]
    guard previousChar._isASCII else {
      assert(!self[previous].isASCII)
      return nil
    }

    if previous == start {
      return (char: previousChar, index: previous, crLF: false)
    }

    let head = utf8[utf8.index(before: previous)]
    guard head._isSub300StartingByte else { return nil }

    if previousChar == ._lineFeed && head == ._carriageReturn {
      utf8.formIndex(before: &previous)

      guard previous == start || utf8[previous]._isSub300StartingByte else {
        return nil
      }
      return (char: previousChar, index: previous, crLF: true)
    }

    assert(self[previous].isASCII && self[previous] != "\r\n")
    return (char: previousChar, index: previous, crLF: false)
  }

  func _quickMatch(
    _ cc: _CharacterClassModel.Representation,
    at idx: Index,
    limitedBy end: Index,
    isScalarSemantics: Bool
  ) -> (next: Index, matchResult: Bool)? {
    /// ASCII fast-paths
    guard let (asciiValue, next, isCRLF) = _quickASCIICharacter(
      at: idx, limitedBy: end
    ) else {
      return nil
    }

    // TODO: bitvectors
    switch cc {
    case .any, .anyGrapheme:
      return (next, true)

    case .digit:
      return (next, asciiValue._asciiIsDigit)

    case .horizontalWhitespace:
      return (next, asciiValue._asciiIsHorizontalWhitespace)

    case .verticalWhitespace, .newlineSequence:
      if asciiValue._asciiIsVerticalWhitespace {
        if isScalarSemantics && isCRLF && cc == .verticalWhitespace {
          return (utf8.index(before: next), true)
        }
        return (next, true)
      }
      return (next, false)

    case .whitespace:
      if asciiValue._asciiIsWhitespace {
        if isScalarSemantics && isCRLF {
          return (utf8.index(before: next), true)
        }
        return (next, true)
      }
      return (next, false)

    case .word:
      return (next, asciiValue._asciiIsWord)
    }
  }

  func _quickMatchPrevious(
    _ cc: _CharacterClassModel.Representation,
    at idx: Index,
    limitedBy start: Index,
    isScalarSemantics: Bool
  ) -> (previous: Index, matchResult: Bool)? {
    /// ASCII fast-paths
    guard let (asciiValue, previousIndex, isCRLF) = _quickASCIICharacter(
      before: idx, limitedBy: start
    ) else {
      return nil
    }

    // TODO: bitvectors
    switch cc {
    case .any, .anyGrapheme:
      return (previousIndex, true)

    case .digit:
      return (previousIndex, asciiValue._asciiIsDigit)

    case .horizontalWhitespace:
      return (previousIndex, asciiValue._asciiIsHorizontalWhitespace)

    case .verticalWhitespace, .newlineSequence:
      if asciiValue._asciiIsVerticalWhitespace {
        if isScalarSemantics && isCRLF && cc == .verticalWhitespace {
          return (utf8.index(after: previousIndex), true)
        }
        return (previousIndex, true)
      }
      return (previousIndex, false)

    case .whitespace:
      if asciiValue._asciiIsWhitespace {
        if isScalarSemantics && isCRLF {
          return (utf8.index(after: previousIndex), true)
        }
        return (previousIndex, true)
      }
      return (previousIndex, false)

    case .word:
      return (previousIndex, asciiValue._asciiIsWord)
    }
  }
}
