// MARK: `CollectionSearcher` algorithms

extension Collection {
  public func firstRange<S: CollectionSearcher>(of searcher: S) -> Range<Index>? where S.Searched == SubSequence {
    let slice = self[...]
    var state = searcher.state(for: slice, startingAt: startIndex)
    return searcher.search(slice, &state)
  }
}

extension BidirectionalCollection {
  public func lastRange<S: BackwardCollectionSearcher>(of searcher: S) -> Range<Index>? where S.Searched == SubSequence {
    let slice = self[...]
    var state = searcher.backwardState(for: slice)
    return searcher.searchBack(slice, &state)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  public func firstRange<S: Sequence>(of sequence: S) -> Range<Index>? where S.Element == Element {
    // TODO: Use a more efficient search algorithm
    let searcher = ZSearcher<SubSequence>(pattern: Array(sequence), by: ==)
    return searcher.search(self[...], from: startIndex)
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func firstRange<S: Sequence>(of other: S) -> Range<Index>? where S.Element == Element {
    let searcher = PatternOrEmpty(searcher: TwoWaySearcher<SubSequence>(pattern: Array(other)))
    let slice = self[...]
    var state = searcher.state(for: slice, startingAt: startIndex)
    return searcher.search(slice, &state)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func firstRange(of regex: Regex) -> Range<Index>? {
    firstRange(of: RegexConsumer(regex))
  }
  
  public func lastRange(of regex: Regex) -> Range<Index>? {
    lastRange(of: RegexConsumer(regex))
  }
}
