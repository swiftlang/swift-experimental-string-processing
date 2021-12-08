public struct RangesCollection<Searcher: CollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let base: Base
  let searcher: Searcher
  private(set) public var startIndex: Index

  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
    
    let startIndex = base.startIndex
    var state = searcher.state(startingAt: startIndex, in: base[...])
    self.startIndex = Index(range: nil, state: state)

    if let range = searcher.search(base[...], &state) {
      self.startIndex = Index(range: range, state: state)
    } else {
      self.startIndex = endIndex
    }
  }
}

extension RangesCollection: Sequence {
  public struct Iterator: IteratorProtocol {
    let base: Base
    let searcher: Searcher
    var state: Searcher.State

    init(base: Base, searcher: Searcher) {
      self.base = base
      self.searcher = searcher
      self.state = searcher.state(startingAt: base.startIndex, in: base)
    }

    public mutating func next() -> Range<Base.Index>? {
      searcher.search(base, &state)
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(base: base, searcher: searcher)
  }
}

extension RangesCollection: Collection {
  public struct Index {
    var range: Range<Searcher.Searched.Index>?
    var state: Searcher.State
  }

  public var endIndex: Index {
    // TODO: Avoid calling `state(startingAt:in:)` here
    Index(
      range: nil,
      state: searcher.state(startingAt: base.endIndex, in: base[...]))
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

// TODO: `BidirectionalCollection` conformance

extension Collection {
  public func ranges<S: CollectionSearcher>(of searcher: S) -> RangesCollection<S> where S.Searched == SubSequence {
    RangesCollection(base: self[...], searcher: searcher)
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
