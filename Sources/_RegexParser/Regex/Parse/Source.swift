//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// For now, we use String as the source while prototyping...

/// The source of text being given to a parser.
///
/// This can be bytes in memory, a file on disk,
/// something streamed over a network connection, and so on.
///
public struct Source {
  var input: Input
  var bounds: Range<Input.Index>

  // TODO: source should hold outer collection and range, at least
  // for error reporting if nothing else

  init(_ str: Input) {
    self.input = str
    self.bounds = str.startIndex ..< str.endIndex
  }

  subscript(_ range: Range<Input.Index>) -> Input.SubSequence { input[range] }
}

// MARK: - Prototype uses String

// For prototyping, base everything on String. Might be buffer
// of bytes, etc., in the future
extension Source {
  public typealias Input = String    // for wrapper...
  public typealias Char  = Character // for wrapper...

  /// A precise point in the input, commonly used for bounded ranges.
  public typealias Position = String.Index
}

// MARK: - Source as a peekable consumer

extension Source {
  var _slice: Input.SubSequence { input[bounds] }

  var isEmpty: Bool { _slice.isEmpty }

  func peek() -> Char? { _slice.first }

  @discardableResult
  mutating func tryAdvance(_ n: Int = 1) -> Bool {
    guard n > 0, let newLower = _slice.index(
      bounds.lowerBound, offsetBy: n, limitedBy: bounds.upperBound)
    else {
      return false
    }
    self.bounds = newLower ..< bounds.upperBound
    return true
  }

  mutating func eat(upToCount count: Int) -> Input.SubSequence {
    let pre = _slice.prefix(count)
    tryAdvance(pre.count)
    return pre
  }

  mutating func tryEatPrefix(
    maxLength: Int? = nil,
    _ f: (Char) -> Bool
  ) -> Input.SubSequence? {
    guard let pre = peekPrefix(maxLength: maxLength, f) else { return nil }
    tryAdvance(pre.count)
    return pre
  }

  mutating func tryEat(count: Int) -> Input.SubSequence? {
    let pre = _slice.prefix(count)
    guard tryAdvance(count) else { return nil }
    return pre
  }

  func starts<S: Sequence>(with s: S) -> Bool where S.Element == Char {
    _slice.starts(with: s)
  }

  func peekPrefix(
    maxLength: Int? = nil,
    _ f: (Char) -> Bool
  ) -> Input.SubSequence? {
    let chunk: Input.SubSequence
    if let maxLength = maxLength {
      chunk = _slice.prefix(maxLength)
    } else {
      chunk = _slice[...]
    }
    let pre = chunk.prefix(while: f)
    guard !pre.isEmpty else { return nil }

    return pre
  }
}
