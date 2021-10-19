extension Collection {
  public func firstRange<S: CollectionSearcher>(_ searcher: S) -> Range<Index>? where S.Searched == Self {
    var state = searcher.state(startingAt: startIndex, in: self)
    return searcher.search(self, &state)
  }
}

extension BidirectionalCollection {
  public func lastRange<S: BackwardCollectionSearcher>(_ searcher: S) -> Range<Index>? where S.Searched == Self {
    var state = searcher.backwardState(startingAt: endIndex, in: self)
    return searcher.searchBack(self, &state)
  }
}

extension Collection where Element: Equatable {
  public func firstRange<S: Sequence>(of sequence: S) -> Range<Index>? where S.Element == Element {
    // TODO: Use a more efficient search algorithm
    let searcher = ZSearcher<Self>(pattern: Array(sequence), by: ==)
    return searcher.search(self, from: startIndex)
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func firstRange<S: Sequence>(of other: S) -> Range<Index>? where S.Element == Element {
    let searcher = TwoWaySearcher<Self>(pattern: Array(other))
    var state = searcher.state(startingAt: startIndex, in: self)
    return searcher.search(self, &state)
  }
}
