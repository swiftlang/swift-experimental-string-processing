public struct RangesCollection<Searcher: CollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
  private(set) public var startIndex: Index

  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
    
    let slice = base[...]
    var state = searcher.state(for: slice)
    self.startIndex = Index(range: nil, state: state)

    if let range = searcher.search(slice, &state) {
      self.startIndex = Index(range: range, state: state)
    } else {
      self.startIndex = endIndex
    }
  }
}

extension RangesCollection where Searcher: BidirectionalCollectionSearcher {
  public func reversed() -> ReversedRangesCollection<Searcher> {
    ReversedRangesCollection(base: base, searcher: searcher)
  }
}

public struct RangesIterator<Searcher: CollectionSearcher>: IteratorProtocol {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
  var state: Searcher.State

  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
    self.state = searcher.state(for: base)
  }

  public mutating func next() -> Range<Base.Index>? {
    searcher.search(base, &state)
  }
}

extension RangesCollection: Sequence {
  public func makeIterator() -> RangesIterator<Searcher> {
    Iterator(base: base, searcher: searcher)
  }
}

extension RangesCollection: Collection {
  public typealias SubSequence = Self
  
  public struct Index {
    var range: Range<Searcher.Searched.Index>?
    var state: Searcher.State
  }

  public var endIndex: Index {
    // TODO: Avoid calling `state(for:)` here
    Index(
      range: nil,
      state: searcher.state(for: base[...]))
  }

  public func formIndex(after index: inout Index) {
    guard index != endIndex else { fatalError("Cannot advance past endIndex") }
    index.range = searcher.search(base[...], &index.state)
  }

  public func index(after index: Index) -> Index {
    var index = index
    formIndex(after: &index)
    return index
  }

  public subscript(index: Index) -> Range<Base.Index> {
    guard let range = index.range else { fatalError("Cannot subscript using endIndex") }
    return range
  }
  
  public subscript(bounds: Range<Index>) -> Self {
    let start = bounds.lowerBound.range?.lowerBound ?? base.endIndex
    let end = bounds.upperBound.range?.lowerBound ?? base.endIndex
    // TODO: Avoid precomputing the `startIndex` of the slice again
    return Self(base: base[start..<end], searcher: searcher)
  }
}

extension RangesCollection.Index: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.range, rhs.range) {
    case (nil, nil):
      return true
    case (nil, _?), (_?, nil):
      return false
    case (let lhs?, let rhs?):
      return lhs.lowerBound == rhs.lowerBound
    }
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.range, rhs.range) {
    case (nil, _):
      return false
    case (_, nil):
      return true
    case (let lhs?, let rhs?):
      return lhs.lowerBound < rhs.lowerBound
    }
  }
}

public struct BidirectionalRangesCollection<Searcher: BidirectionalCollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
}

extension BidirectionalRangesCollection: Sequence {
  public func makeIterator() -> RangesIterator<Searcher> {
    Iterator(base: base, searcher: searcher)
  }
}

extension BidirectionalRangesCollection: BidirectionalCollection {
  public typealias Element = Range<Base.Index>
  
  public struct Index {
    var range: Range<Searcher.Searched.Index>?
    var forwardState: Searcher.State?
    var backwardState: Searcher.BackwardState?
  }
  
  public var startIndex: Index {
    // TODO: Precompute the start index
    var state = searcher.state(for: base)
    let range = searcher.search(base, &state)
    return Index(range: range, forwardState: state, backwardState: nil)
  }
  
  public var endIndex: Index {
    Index(range: nil, forwardState: nil, backwardState: nil)
  }
  
  public func formIndex(before index: inout Index) {
    index.forwardState = nil
    var state: Searcher.BackwardState
    
    if let s = index.backwardState {
      index.backwardState = nil
      state = s
    } else {
      let start: Base.Index
      
      if let range = index.range {
        if range.isEmpty {
          if range.upperBound == base.endIndex {
            index.range = nil
            return
          } else {
            start = base.index(after: range.upperBound)
          }
        } else {
          start = range.upperBound
        }
      } else {
        start = base.endIndex
      }
      
      state = searcher.backwardState(for: base[..<start])
    }
    
    index.range = searcher.searchBack(base, &state)
    index.backwardState = state
  }
  
  public func formIndex(after index: inout Index) {
    guard let range = index.range else { fatalError("Cannot advance past endIndex") }
    
    index.backwardState = nil
    var state: Searcher.State
    
    if let s = index.forwardState {
      index.forwardState = nil
      state = s
    } else {
      let start: Base.Index
      
      if range.isEmpty {
        if range.upperBound == base.endIndex {
          index.range = nil
          return
        } else {
          start = base.index(after: range.upperBound)
        }
      } else {
        start = range.upperBound
      }
      
      state = searcher.state(for: base[start...])
    }
    
    index.range = searcher.search(base, &state)
    index.forwardState = state
  }
  
  public func index(before index: Index) -> Index {
    var index = index
    formIndex(before: &index)
    return index
  }
  
  public func index(after index: Index) -> Index {
    var index = index
    formIndex(after: &index)
    return index
  }
  
  public subscript(index: Index) -> Range<Base.Index> {
    guard let range = index.range else { fatalError("Cannot subscript using endIndex") }
    return range
  }
}

extension BidirectionalRangesCollection.Index: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.range, rhs.range) {
    case (nil, nil):
      return true
    case (nil, _?), (_?, nil):
      return false
    case (let lhs?, let rhs?):
      return lhs.lowerBound == rhs.lowerBound
    }
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.range, rhs.range) {
    case (nil, _):
      return false
    case (_, nil):
      return true
    case (let lhs?, let rhs?):
      return lhs.lowerBound < rhs.lowerBound
    }
  }
}

public struct ReversedRangesCollection<Searcher: BackwardCollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
  
  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
  }
}

extension ReversedRangesCollection where Searcher: BidirectionalCollectionSearcher {
  public func reversed() -> RangesCollection<Searcher> {
    RangesCollection(base: base, searcher: searcher)
  }
}

extension ReversedRangesCollection: Sequence {
  public struct Iterator: IteratorProtocol {
    let base: Base
    let searcher: Searcher
    var state: Searcher.BackwardState
    
    init(base: Base, searcher: Searcher) {
      self.base = base
      self.searcher = searcher
      self.state = searcher.backwardState(for: base)
    }
    
    public mutating func next() -> Range<Base.Index>? {
      searcher.searchBack(base, &state)
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(base: base, searcher: searcher)
  }
}

// TODO: `Collection` conformance

extension Collection {
  public func ranges<S: CollectionSearcher>(
    of searcher: S
  ) -> RangesCollection<S> where S.Searched == SubSequence {
    RangesCollection(base: self[...], searcher: searcher)
  }
}

extension BidirectionalCollection {
  public func rangesFromBack<S: BackwardCollectionSearcher>(
    of searcher: S
  ) -> ReversedRangesCollection<S> where S.Searched == SubSequence {
    ReversedRangesCollection(base: self[...], searcher: searcher)
  }
}

extension Collection where Element: Equatable {
  public func ranges<S: Sequence>(
    of other: S
  ) -> RangesCollection<ZSearcher<SubSequence>> where S.Element == Element {
    ranges(of: ZSearcher(pattern: Array(other), by: ==))
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func ranges<S: Sequence>(
    of other: S
  ) -> RangesCollection<PatternOrEmpty<TwoWaySearcher<SubSequence>>> where S.Element == Element {
    ranges(of: PatternOrEmpty(searcher: TwoWaySearcher(pattern: Array(other))))
  }
}

// MARK: Regex

extension BidirectionalCollection where SubSequence == Substring {
  public func ranges(of regex: Regex) -> RangesCollection<RegexConsumer> {
    ranges(of: RegexConsumer(regex))
  }
}
