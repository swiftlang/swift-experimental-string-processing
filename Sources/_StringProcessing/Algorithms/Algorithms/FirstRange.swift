// MARK: `CollectionSearcher` algorithms

extension Collection {
  public func firstRange<S: CollectionSearcher>(
    of searcher: S
  ) -> Range<Index>? where S.Searched == Self {
    var state = searcher.state(for: self, in: startIndex..<endIndex)
    return searcher.search(self, &state)
  }
}

extension BidirectionalCollection {
  public func lastRange<S: BackwardCollectionSearcher>(
    of searcher: S
  ) -> Range<Index>? where S.BackwardSearched == Self {
    var state = searcher.backwardState(for: self, in: startIndex..<endIndex)
    return searcher.searchBack(self, &state)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  public func firstRange<S: Sequence>(
    of sequence: S
  ) -> Range<Index>? where S.Element == Element {
    // TODO: Use a more efficient search algorithm
    let searcher = ZSearcher<SubSequence>(pattern: Array(sequence), by: ==)
    return searcher.search(self[...], in: startIndex..<endIndex)
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func firstRange<S: Sequence>(
    of other: S
  ) -> Range<Index>? where S.Element == Element {
    let searcher = PatternOrEmpty(
      searcher: TwoWaySearcher<SubSequence>(pattern: Array(other)))
    let slice = self[...]
    var state = searcher.state(for: slice, in: startIndex..<endIndex)
    return searcher.search(slice, &state)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func firstRange<Capture>(of regex: Regex<Capture>) -> Range<Index>? {
    firstRange(of: RegexConsumer(regex))
  }
  
  public func lastRange<Capture>(of regex: Regex<Capture>) -> Range<Index>? {
    lastRange(of: RegexConsumer(regex))
  }
}
