extension Collection {
  public func firstRange<S: CollectionSearcher>(of searcher: S) -> Range<Index>? where S.Searched == SubSequence {
    var state = searcher.state(startingAt: startIndex, in: self[...])
    return searcher.search(self[...], &state)
  }
}

extension BidirectionalCollection {
  public func lastRange<S: BackwardCollectionSearcher>(of searcher: S) -> Range<Index>? where S.Searched == SubSequence {
    var state = searcher.backwardState(startingAt: endIndex, in: self[...])
    return searcher.searchBack(self[...], &state)
  }
}

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
    var state = searcher.state(startingAt: startIndex, in: self[...])
    return searcher.search(self[...], &state)
  }
}

// MARK: Regex

extension Collection where SubSequence == Substring {
  public func firstRange(of regex: Regex) -> Range<Index>? {
    firstRange(of: RegexConsumer(regex: regex))
  }
}

extension BidirectionalCollection where SubSequence == Substring {
  public func lastRange(of regex: Regex) -> Range<Index>? {
    lastRange(of: RegexConsumer(regex: regex))
  }
}

