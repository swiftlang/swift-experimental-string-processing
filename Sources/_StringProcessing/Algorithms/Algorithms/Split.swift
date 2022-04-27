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

// MARK: `SplitCollection`

struct SplitCollection<Searcher: CollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let ranges: RangesCollection<Searcher>
  var maxSplits: Int
  var omittingEmptySubsequences: Bool

  init(
    ranges: RangesCollection<Searcher>,
    maxSplits: Int,
    omittingEmptySubsequences: Bool)
  {
    self.ranges = ranges
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences
  }

  init(
    base: Base,
    searcher: Searcher,
    maxSplits: Int,
    omittingEmptySubsequences: Bool)
  {
    self.ranges = base.ranges(of: searcher)
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences
  }
}

extension SplitCollection: Sequence {
  public struct Iterator: IteratorProtocol {
    let base: Base
    var index: Base.Index
    var ranges: RangesCollection<Searcher>.Iterator
    var maxSplits: Int
    var omittingEmptySubsequences: Bool

    var splitCounter = 0
    var isDone = false

    init(
      ranges: RangesCollection<Searcher>,
      maxSplits: Int,
      omittingEmptySubsequences: Bool
    ) {
      self.base = ranges.base
      self.index = base.startIndex
      self.ranges = ranges.makeIterator()
      self.maxSplits = maxSplits
      self.omittingEmptySubsequences = omittingEmptySubsequences
    }
    
    public mutating func next() -> Base.SubSequence? {
      guard !isDone else { return nil }
      
      /// Return the rest of base if it's non-empty or we're including
      /// empty subsequences.
      func finish() -> Base.SubSequence? {
        isDone = true
        return index == base.endIndex && omittingEmptySubsequences
          ? nil
          : base[index...]
      }
      
      if index == base.endIndex {
        return finish()
      }
      
      if splitCounter >= maxSplits {
        return finish()
      }
      
      while true {
        // If there are no more ranges that matched, return the rest of `base`.
        guard let range = ranges.next() else {
          return finish()
        }
        
        defer { index = range.upperBound }

        if omittingEmptySubsequences && index == range.lowerBound {
          continue
        }
        
        splitCounter += 1
        return base[index..<range.lowerBound]
      }
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(ranges: ranges, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }
}

//extension SplitCollection: Collection {
//  public struct Index {
//    var start: Base.Index
//    var base: RangesCollection<Searcher>.Index
//    var isEndIndex: Bool
//  }
//
//  public var startIndex: Index {
//    let base = ranges.startIndex
//    return Index(start: ranges.base.startIndex, base: base, isEndIndex: false)
//  }
//
//  public var endIndex: Index {
//    Index(start: ranges.base.endIndex, base: ranges.endIndex, isEndIndex: true)
//  }
//
//  public func formIndex(after index: inout Index) {
//    guard !index.isEndIndex else { fatalError("Cannot advance past endIndex") }
//
//    if let range = index.base.range {
//      let newStart = range.upperBound
//      ranges.formIndex(after: &index.base)
//      index.start = newStart
//    } else {
//      index.isEndIndex = true
//    }
//  }
//
//  public func index(after index: Index) -> Index {
//    var index = index
//    formIndex(after: &index)
//    return index
//  }
//
//  public subscript(index: Index) -> Base.SubSequence {
//    guard !index.isEndIndex else {
//      fatalError("Cannot subscript using endIndex")
//    }
//    let end = index.base.range?.lowerBound ?? ranges.base.endIndex
//    return ranges.base[index.start..<end]
//  }
//}
//
//extension SplitCollection.Index: Comparable {
//   static func == (lhs: Self, rhs: Self) -> Bool {
//    switch (lhs.isEndIndex, rhs.isEndIndex) {
//    case (false, false):
//      return lhs.start == rhs.start
//    case (let lhs, let rhs):
//      return lhs == rhs
//    }
//  }
//
//  static func < (lhs: Self, rhs: Self) -> Bool {
//    switch (lhs.isEndIndex, rhs.isEndIndex) {
//    case (true, _):
//      return false
//    case (_, true):
//      return true
//    case (false, false):
//      return lhs.start < rhs.start
//    }
//  }
//}

// MARK: `ReversedSplitCollection`

struct ReversedSplitCollection<Searcher: BackwardCollectionSearcher> {
  public typealias Base = Searcher.BackwardSearched
  
  let ranges: ReversedRangesCollection<Searcher>
  
  init(ranges: ReversedRangesCollection<Searcher>) {
    self.ranges = ranges
  }

  init(base: Base, searcher: Searcher) {
    self.ranges = base.rangesFromBack(of: searcher)
  }
}

extension ReversedSplitCollection: Sequence {
  public struct Iterator: IteratorProtocol {
    let base: Base
    var index: Base.Index
    var ranges: ReversedRangesCollection<Searcher>.Iterator
    var isDone: Bool
    
    init(ranges: ReversedRangesCollection<Searcher>) {
      self.base = ranges.base
      self.index = base.endIndex
      self.ranges = ranges.makeIterator()
      self.isDone = false
    }
    
    public mutating func next() -> Base.SubSequence? {
      guard !isDone else { return nil }
      
      guard let range = ranges.next() else {
        isDone = true
        return base[..<index]
      }
      
      defer { index = range.lowerBound }
      return base[range.upperBound..<index]
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(ranges: ranges)
  }
}

// TODO: `Collection` conformance

// MARK: `CollectionSearcher` algorithms

extension Collection {
  func split<Searcher: CollectionSearcher>(
    by separator: Searcher,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitCollection<Searcher> where Searcher.Searched == Self {
    SplitCollection(
      base: self,
      searcher: separator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences)
  }
}

extension BidirectionalCollection {
  func splitFromBack<Searcher: BackwardCollectionSearcher>(
    by separator: Searcher
  ) -> ReversedSplitCollection<Searcher>
    where Searcher.BackwardSearched == Self
  {
    ReversedSplitCollection(base: self, searcher: separator)
  }
}

// MARK: Predicate algorithms

extension Collection {
  // TODO: Non-escaping and throwing
  func split(
    whereSeparator predicate: @escaping (Element) -> Bool,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitCollection<PredicateConsumer<Self>> {
    split(by: PredicateConsumer(predicate: predicate), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }
}

extension BidirectionalCollection where Element: Equatable {
  func splitFromBack(
    whereSeparator predicate: @escaping (Element) -> Bool
  ) -> ReversedSplitCollection<PredicateConsumer<Self>> {
    splitFromBack(by: PredicateConsumer(predicate: predicate))
  }
}

// MARK: Single element algorithms

extension Collection where Element: Equatable {
  func split(
    by separator: Element,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitCollection<PredicateConsumer<Self>> {
    split(whereSeparator: { $0 == separator }, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }
}

extension BidirectionalCollection where Element: Equatable {
  func splitFromBack(
    by separator: Element
  ) -> ReversedSplitCollection<PredicateConsumer<Self>> {
    splitFromBack(whereSeparator: { $0 == separator })
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  @_disfavoredOverload
  func split<C: Collection>(
    by separator: C,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitCollection<ZSearcher<Self>> where C.Element == Element {
    split(by: ZSearcher(pattern: Array(separator), by: ==), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }

  // FIXME: Return `some Collection<SubSequence>` for SE-0346
  /// Returns the longest possible subsequences of the collection, in order,
  /// around elements equal to the given separator.
  ///
  /// - Parameter separator: The element to be split upon.
  /// - Returns: A collection of subsequences, split from this collection's
  ///   elements.
  @available(SwiftStdlib 5.7, *)
  public func split<C: Collection>(
    separator: C,
    maxSplits: Int = .max,
    omittingEmptySubsequences: Bool = true
  ) -> [SubSequence] where C.Element == Element {
    Array(split(by: ZSearcher(pattern: Array(separator), by: ==), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences))
  }
}

extension BidirectionalCollection where Element: Equatable {
  // FIXME
//  public func splitFromBack<S: Sequence>(
//    separator: S
//  ) -> ReversedSplitCollection<ZSearcher<SubSequence>>
//    where S.Element == Element
//  {
//    splitFromBack(separator: ZSearcher(pattern: Array(separator), by: ==))
//  }
}

extension BidirectionalCollection where Element: Comparable {
  func split<C: Collection>(
    by separator: C,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitCollection<PatternOrEmpty<TwoWaySearcher<Self>>>
    where C.Element == Element
  {
    split(
      by: PatternOrEmpty(searcher: TwoWaySearcher(pattern: Array(separator))),
    maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }
  
  // FIXME
//  public func splitFromBack<S: Sequence>(
//    separator: S
//  ) -> ReversedSplitCollection<PatternOrEmpty<TwoWaySearcher<SubSequence>>>
//    where S.Element == Element
//  {
//    splitFromBack(separator: PatternOrEmpty(
//      searcher: TwoWaySearcher(pattern: Array(separator))))
//  }
}

// MARK: Regex algorithms

@available(SwiftStdlib 5.7, *)
extension BidirectionalCollection where SubSequence == Substring {
  @_disfavoredOverload
  func split<R: RegexComponent>(
    by separator: R,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitCollection<RegexConsumer<R, Self>> {
    split(by: RegexConsumer(separator), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }
  
  func splitFromBack<R: RegexComponent>(
    by separator: R
  ) -> ReversedSplitCollection<RegexConsumer<R, Self>> {
    splitFromBack(by: RegexConsumer(separator))
  }

  // TODO: Is this @_disfavoredOverload necessary?
  // It prevents split(separator: String) from choosing this overload instead
  // of the collection-based version when String has RegexComponent conformance

  // FIXME: Return `some Collection<Subsequence>` for SE-0346
  /// Returns the longest possible subsequences of the collection, in order,
  /// around elements equal to the given separator.
  ///
  /// - Parameter separator: A regex describing elements to be split upon.
  /// - Returns: A collection of substrings, split from this collection's
  ///   elements.
  @_disfavoredOverload
  public func split<R: RegexComponent>(
    separator: R,
    maxSplits: Int = .max,
    omittingEmptySubsequences: Bool = true
  ) -> [SubSequence] {
    Array(split(by: RegexConsumer(separator), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences))
  }
}
