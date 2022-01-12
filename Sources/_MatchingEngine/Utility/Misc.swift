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


extension FixedWidthInteger {
  var hexStr: String {
    String(self, radix: 16, uppercase: true)
  }
}

func unreachable(_ s: @autoclosure () -> String) -> Never {
  fatalError("unreachable \(s())")
}
func unreachable() -> Never {
  fatalError("unreachable")
}

// From Algorithms...
extension Array /* for enumerated */ {
  /// Returns a collection of subsequences of this collection, chunked by the
  /// given predicate.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  public func chunked(
    by belongInSameGroup: (Element, Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    guard !isEmpty else { return [] }
    var result: [SubSequence] = []

    var start = startIndex
    var current = self[start]

    for (index, element) in enumerated().dropFirst() {
      if try !belongInSameGroup(current, element) {
        result.append(self[start..<index])
        start = index
      }
      current = element
    }

    if start != endIndex {
      result.append(self[start...])
    }

    return result
  }
}

extension Substring {
  var string: String { String(self) }
}


extension CustomStringConvertible {
  @_alwaysEmitIntoClient
  public var halfWidthCornerQuoted: String {
    "｢\(self)｣"
  }
}

//extension String: Error {}

extension Array {
  @_alwaysEmitIntoClient
  public init(singleElement e: Element) {
    self.init(repeating: e, count: 1)
  }
}

@_alwaysEmitIntoClient
public func joined<T>(_ elements: [[T]]) -> [T] {
  Array(elements.joined())
}

extension Array {
  @_alwaysEmitIntoClient
  public init(reservingCapacity cap: Int) {
    self.init()
    self.reserveCapacity(cap)
  }
}

extension Sequence {
  @_alwaysEmitIntoClient
  public func all(_ f: (Element) -> Bool) -> Bool {
    for element in self {
      guard f(element) else { return false }
    }
    return true
  }
  @_alwaysEmitIntoClient
  public func none(_ f: (Element) -> Bool) -> Bool {
    return self.all { !f($0) }
  }
  @_alwaysEmitIntoClient
  public func any(_ f: (Element) -> Bool) -> Bool {
    for element in self {
      if f(element) { return true }
    }
    return false
  }
}

extension Range {
  public var destructure: (
    lowerBound: Bound, upperBound: Bound
  ) {
    (lowerBound, upperBound)
  }
}

public typealias Offsets = (lower: Int, upper: Int)
extension BidirectionalCollection {
  public func mapOffsets(_ offsets: Offsets) -> Range<Index> {
    assert(offsets.lower >= 0 && offsets.upper <= 0)
    let lower = index(startIndex, offsetBy: offsets.lower)
    let upper = index(endIndex, offsetBy: offsets.upper)
    return lower ..< upper
  }

  // Is this the right name?
  public func flatmapOffsets(_ offsets: Offsets?) -> Range<Index> {
    if let o = offsets {
      return mapOffsets(o)
    }
    return startIndex ..< endIndex
  }
}

extension Collection {
  public func index(atOffset i: Int) -> Index {
    index(startIndex, offsetBy: i)
  }

  public func offset(ofIndex index: Index) -> Int {
    distance(from: startIndex, to: index)
  }

  public func split(
    around r: Range<Index>
  ) -> (prefix: SubSequence, SubSequence, suffix: SubSequence) {
    (self[..<r.lowerBound], self[r], self[r.upperBound...])
  }

  public func offset(of i: Index) -> Int {
    distance(from: startIndex, to: i)
  }

  public func offsets(of r: Range<Index>) -> Range<Int> {
    offset(of: r.lowerBound) ..< offset(of: r.upperBound)
  }

  public func convertByOffset<
    C: Collection
  >(_ range: Range<Index>, in c: C) -> Range<C.Index> {
    convertByOffset(range.lowerBound, in: c) ..<
    convertByOffset(range.upperBound, in: c)
  }

  public func convertByOffset<
    C: Collection
  >(_ idx: Index, in c: C) -> C.Index {
    c.index(atOffset: offset(of: idx))
  }

}

extension UnsafeMutableRawPointer {
  public func roundedUp<T>(toAlignmentOf type: T.Type) -> Self {
    let alignmentMask = MemoryLayout<T>.alignment - 1
    let rounded = (Int(bitPattern: self) + alignmentMask) & ~alignmentMask
    return UnsafeMutableRawPointer(bitPattern: rounded).unsafelyUnwrapped
  }
}

extension String {
  public func isOnGraphemeClusterBoundary(_ i: Index) -> Bool {
    String.Index(i, within: self) != nil
  }
  public init<Scalars: Collection>(
    _ scs: Scalars
  ) where Scalars.Element == Unicode.Scalar {
    self.init(decoding: scs.map { $0.value }, as: UTF32.self)
  }
}


extension BinaryInteger {
  public init<T: BinaryInteger>(asserting i: T) {
    self.init(truncatingIfNeeded: i)
    assert(self == i)
  }
}

