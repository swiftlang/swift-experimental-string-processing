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

// MARK: `MatchesCollection`

struct MatchesCollection<Searcher: MatchingCollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
  private(set) public var startIndex: Index

  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
    
    var state = searcher.state(for: base, in: base.startIndex..<base.endIndex)
    self.startIndex = Index(match: nil, state: state)

    if let match = searcher.matchingSearch(base, &state) {
      self.startIndex = Index(match: match, state: state)
    } else {
      self.startIndex = endIndex
    }
  }
}

struct MatchesIterator<
  Searcher: MatchingCollectionSearcher
>: IteratorProtocol {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
  var state: Searcher.State

  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
    self.state = searcher.state(for: base, in: base.startIndex..<base.endIndex)
  }

  public mutating func next() -> _MatchResult<Searcher>? {
    searcher.matchingSearch(base, &state).map { range, result in
      _MatchResult(match: base[range], result: result)
    }
  }
}

extension MatchesCollection: Sequence {
  public func makeIterator() -> MatchesIterator<Searcher> {
    Iterator(base: base, searcher: searcher)
  }
}

extension MatchesCollection: Collection {
  // TODO: Custom `SubSequence` for the sake of more efficient slice iteration
  
  struct Index {
    var match: (range: Range<Base.Index>, match: Searcher.Match)?
    var state: Searcher.State
  }

  public var endIndex: Index {
    // TODO: Avoid calling `state(for:startingAt)` here
    Index(
      match: nil,
      state: searcher.state(for: base, in: base.startIndex..<base.endIndex))
  }

  public func formIndex(after index: inout Index) {
    guard index != endIndex else { fatalError("Cannot advance past endIndex") }
    index.match = searcher.matchingSearch(base, &index.state)
  }

  public func index(after index: Index) -> Index {
    var index = index
    formIndex(after: &index)
    return index
  }

  public subscript(index: Index) -> _MatchResult<Searcher> {
    guard let (range, result) = index.match else {
      fatalError("Cannot subscript using endIndex")
    }
    return _MatchResult(match: base[range], result: result)
  }
}

extension MatchesCollection.Index: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.match?.range, rhs.match?.range) {
    case (nil, nil):
      return true
    case (nil, _?), (_?, nil):
      return false
    case (let lhs?, let rhs?):
      return lhs.lowerBound == rhs.lowerBound
    }
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.match?.range, rhs.match?.range) {
    case (nil, _):
      return false
    case (_, nil):
      return true
    case (let lhs?, let rhs?):
      return lhs.lowerBound < rhs.lowerBound
    }
  }
}

// MARK: `ReversedMatchesCollection`
// TODO: reversed matches

struct ReversedMatchesCollection<
  Searcher: BackwardMatchingCollectionSearcher
> {
  public typealias Base = Searcher.BackwardSearched

  let base: Base
  let searcher: Searcher

  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
  }
}

extension ReversedMatchesCollection: Sequence {
  struct Iterator: IteratorProtocol {
    let base: Base
    let searcher: Searcher
    var state: Searcher.BackwardState

    init(base: Base, searcher: Searcher) {
      self.base = base
      self.searcher = searcher
      self.state = searcher.backwardState(
        for: base, in: base.startIndex..<base.endIndex)
    }

    public mutating func next() -> _BackwardMatchResult<Searcher>? {
      searcher.matchingSearchBack(base, &state).map { range, result in
        _BackwardMatchResult(match: base[range], result: result)
      }
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(base: base, searcher: searcher)
  }
}

// TODO: `Collection` conformance

// MARK: `CollectionSearcher` algorithms

extension Collection {
  func matches<S: MatchingCollectionSearcher>(
    of searcher: S
  ) -> MatchesCollection<S> where S.Searched == Self {
    MatchesCollection(base: self, searcher: searcher)
  }
}

extension BidirectionalCollection {
  func matchesFromBack<S: BackwardMatchingCollectionSearcher>(
    of searcher: S
  ) -> ReversedMatchesCollection<S> where S.BackwardSearched == Self {
    ReversedMatchesCollection(base: self, searcher: searcher)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  // FIXME: Replace `MatchesCollection` when SE-0346 is enabled
  /// Returns a collection containing all matches of the specified regex.
  /// - Parameter regex: The regex to search for.
  /// - Returns: A collection of matches of `regex`.
  @available(SwiftStdlib 5.7, *)
  func matches<R: RegexComponent>(
    of regex: R
  ) -> MatchesCollection<RegexConsumer<R, Self>> {
    matches(of: RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  func matchesFromBack<R: RegexComponent>(
    of regex: R
  ) -> ReversedMatchesCollection<RegexConsumer<R, Self>> {
    matchesFromBack(of: RegexConsumer(regex))
  }

  // FIXME: Replace the returned value as `some Collection<Regex<R.Output>.Match>
  // when SE-0346 is enabled
  @available(SwiftStdlib 5.7, *)
  func _matches<R: RegexComponent>(of r: R) -> [Regex<R.RegexOutput>.Match] {
    let slice = self[...]
    var start = self.startIndex
    let end = self.endIndex
    let regex = r.regex

    var result = [Regex<R.RegexOutput>.Match]()
    while start < end {
      guard let match = try? regex._firstMatch(
        slice.base, in: start..<end
      ) else {
        break
      }
      result.append(match)
      start = match.range.upperBound
    }
    return result
  }

}
