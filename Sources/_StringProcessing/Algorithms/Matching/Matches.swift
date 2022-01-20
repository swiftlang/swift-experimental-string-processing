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

public struct MatchesCollection<Searcher: MatchingCollectionSearcher> {
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

public struct MatchesIterator<
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

  public mutating func next() -> (Searcher.Match, Range<Base.Index>)? {
    searcher.matchingSearch(base, &state)
  }
}

extension MatchesCollection: Sequence {
  public func makeIterator() -> MatchesIterator<Searcher> {
    Iterator(base: base, searcher: searcher)
  }
}

extension MatchesCollection: Collection {
  // TODO: Custom `SubSequence` for the sake of more efficient slice iteration
  
  public struct Index {
    var match: (value: Searcher.Match, range: Range<Searcher.Searched.Index>)?
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

  public subscript(index: Index) -> (Searcher.Match, Range<Base.Index>) {
    guard let match = index.match else {
      fatalError("Cannot subscript using endIndex")
    }
    return match
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

public struct ReversedMatchesCollection<
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
  public struct Iterator: IteratorProtocol {
    let base: Base
    let searcher: Searcher
    var state: Searcher.BackwardState

    init(base: Base, searcher: Searcher) {
      self.base = base
      self.searcher = searcher
      self.state = searcher.backwardState(
        for: base, in: base.startIndex..<base.endIndex)
    }

    public mutating func next() -> (Searcher.Match, Range<Base.Index>)? {
      searcher.matchingSearchBack(base, &state)
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(base: base, searcher: searcher)
  }
}

//// TODO: `Collection` conformance
