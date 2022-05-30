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
  func _matches<S: MatchingCollectionSearcher>(
    of searcher: S
  ) -> MatchesCollection<S> where S.Searched == Self {
    MatchesCollection(base: self, searcher: searcher)
  }
}

extension BidirectionalCollection {
  func _matchesFromBack<S: BackwardMatchingCollectionSearcher>(
    of searcher: S
  ) -> ReversedMatchesCollection<S> where S.BackwardSearched == Self {
    ReversedMatchesCollection(base: self, searcher: searcher)
  }
}

// MARK: Regex algorithms

@available(SwiftStdlib 5.7, *)
struct RegexMatchesCollection<Output> {
  let base: Substring
  let regex: Regex<Output>
  let startIndex: Index
  
  init(base: Substring, regex: Regex<Output>) {
    self.base = base
    self.regex = regex
    self.startIndex = base.firstMatch(of: regex).map(Index.match) ?? .end
  }
}

@available(SwiftStdlib 5.7, *)
extension RegexMatchesCollection: Collection {
  enum Index: Comparable {
    case match(Regex<Output>.Match)
    case end
    
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.match(let lhs), .match(let rhs)):
        return lhs.range == rhs.range
      case (.end, .end):
        return true
      case (.end, .match), (.match, .end):
        return false
      }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.match(let lhs), .match(let rhs)):
        // This implementation uses a tuple comparison so that an empty
        // range `i..<i` will be ordered before a non-empty range at that
        // same starting point `i..<j`. As of 2022-05-30, `Regex` does not
        // return matches of this kind, but that is one behavior under
        // discussion for regexes like /a*|b/ when matched against "b".
        return (lhs.range.lowerBound, lhs.range.upperBound)
          < (rhs.range.lowerBound, rhs.range.upperBound)
      case (.match, .end):
        return true
      case (.end, .match), (.end, .end):
        return false
      }
    }
  }
  
  var endIndex: Index {
    Index.end
  }
  
  func index(after i: Index) -> Index {
    let currentMatch: Element
    switch i {
    case .match(let match):
      currentMatch = match
    case .end:
      fatalError("Can't advance past the 'endIndex' of a match collection.")
    }
    
    let start: String.Index
    if currentMatch.range.isEmpty {
      if currentMatch.range.lowerBound == base.endIndex {
        return .end
      }
      
      switch regex.initialOptions.semanticLevel {
      case .graphemeCluster:
        start = base.index(after: currentMatch.range.upperBound)
      case .unicodeScalar:
        start = base.unicodeScalars.index(after: currentMatch.range.upperBound)
      }
    } else {
      start = currentMatch.range.upperBound
    }

    guard let nextMatch = try? regex.firstMatch(in: base[start...]) else {
      return .end
    }
    return Index.match(nextMatch)
  }
  
  subscript(position: Index) -> Regex<Output>.Match {
    switch position {
    case .match(let match):
      return match
    case .end:
      fatalError("Can't subscript the 'endIndex' of a match collection.")
    }
  }
}

extension BidirectionalCollection where SubSequence == Substring {
  @available(SwiftStdlib 5.7, *)
  @_disfavoredOverload
  func _matches<R: RegexComponent>(
    of regex: R
  ) -> RegexMatchesCollection<R.RegexOutput> {
    RegexMatchesCollection(base: self[...], regex: regex.regex)
  }

  @available(SwiftStdlib 5.7, *)
  func _matchesFromBack<R: RegexComponent>(
    of regex: R
  ) -> ReversedMatchesCollection<RegexConsumer<R, Self>> {
    _matchesFromBack(of: RegexConsumer(regex))
  }

  // FIXME: Return `some Collection<Regex<R.Output>.Match> for SE-0346
  /// Returns a collection containing all matches of the specified regex.
  /// - Parameter regex: The regex to search for.
  /// - Returns: A collection of matches of `regex`.
  @available(SwiftStdlib 5.7, *)
  public func matches<Output>(
    of r: some RegexComponent<Output>
  ) -> [Regex<Output>.Match] {
    Array(_matches(of: r))
  }
}
