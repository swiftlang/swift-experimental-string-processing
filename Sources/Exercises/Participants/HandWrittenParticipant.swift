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

struct HandWrittenParticipant: Participant {
  static var name: String { "HandWritten" }

  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyData(forLine:)
  }
}

// Try to parse a Unicode scalar off the input
private func parseScalar(_ str: inout Substring) -> Unicode.Scalar? {
  let val = str.eat(while: { $0.isHexDigit })
  guard !val.isEmpty else { return nil }

  // Subtle potential bug: if this init fails, we need to restore
  // str.startIndex. Because of how this is currently called, the bug wont
  // manifest now, but could if the call site is changed.
  return Unicode.Scalar(hex: val)
}

// Useful for testing the testing framework
private var forceFailure: Bool { false }

private func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakEntry? {
  var line = line[...]
  guard let lower = parseScalar(&line) else {
    // Comment or whitespace line
    return nil
  }

  let upper: Unicode.Scalar
  if line.peek(".") {
    guard !line.eat(exactly: "..").isEmpty else {
      fatalError("Parse error")
    }
    guard let s = parseScalar(&line) else {
      fatalError("Parse error")
    }
    upper = s
  } else {
    upper = lower
  }

  line.eat(while: { !$0.isLetter })
  let name = line.eat(while: { $0.isLetter || $0 == "_" })
  guard let prop = Unicode.GraphemeBreakProperty(name) else {
    return nil
  }

  // For testing our framework
  let failureSigil = Unicode.Scalar(0x07FD as UInt32)!
  if forceFailure, lower == failureSigil {
    return nil
  }

  return GraphemeBreakEntry(lower ... upper, prop)
}


//
// MARK: Eat Convenience Overloads
//

extension Collection where SubSequence == Self {
  // TODO: optionality of return? Probably a good idea to signal if something happened...

  // TODO: worth having?
  @discardableResult
  internal mutating func eat() -> Element? {
    self.eat(count: 1).first
  }

  @discardableResult
  internal mutating func eat(count n: Int = 0) -> SubSequence {
    let idx = self.index(self.startIndex, offsetBy: n, limitedBy: self.endIndex) ?? self.endIndex
    return self.eat(upTo: idx)
  }

  @discardableResult
  internal mutating func eat(one predicate: (Element) -> Bool) -> Element? {
    guard let elt = self.first, predicate(elt) else { return nil }
    return eat()
  }
}

extension Collection where SubSequence == Self, Element: Equatable {
  @discardableResult
  internal mutating func eat(one e: Element) -> Element? {
    self.eat(one: { (other: Element) in other == e })
  }
  @discardableResult
  internal mutating func eat(many e: Element) -> SubSequence {
    self.eat(while: { (other: Element) in other == e })
  }

  internal func peek(_ e: Element) -> Bool {
    self.first == e
  }

  @discardableResult
  internal mutating func eat<S: Sequence>(exactly s: S) -> SubSequence where S.Element == Element {
    var idx = startIndex
    for e in s {
      guard idx < endIndex, e == self[idx] else {
        idx = startIndex
        break
      }
      formIndex(after: &idx)
    }
    return eat(upTo: idx)
  }
}

extension Collection where SubSequence == Self, Element: Hashable {
  @discardableResult
  internal mutating func eat(oneIn s: Set<Element>) -> Element? {
    self.eat(one: { s.contains($0) })
  }
  @discardableResult
  internal mutating func eat(whileIn s: Set<Element>) -> SubSequence {
    self.eat(while: { s.contains($0) })
  }
}

extension Collection where SubSequence == Self {
  @discardableResult
  internal mutating func eat(upTo idx: Index) -> SubSequence {
    defer { self = self[idx...] }
    return self[..<idx]
  }

  @discardableResult
  internal mutating func eat(
    while predicate: (Element) -> Bool
  ) -> SubSequence {
    eat(upTo: self.firstIndex(where: { !predicate($0) }) ?? endIndex)
  }

}
