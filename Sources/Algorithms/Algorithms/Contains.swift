// MARK: `CollectionSearcher` algorithms

extension Collection {
  public func contains<Searcher: CollectionSearcher>(
    _ searcher: Searcher
  ) -> Bool where Searcher.Searched == SubSequence {
    firstRange(of: searcher) != nil
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  public func contains<S: Sequence>(_ other: S) -> Bool where S.Element == Element {
    firstRange(of: other) != nil
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func contains<S: Sequence>(_ other: S) -> Bool where S.Element == Element {
    firstRange(of: other) != nil
  }
}

// MARK: Regex algorithms

extension Collection where SubSequence == Substring {
  public func contains(_ regex: Regex) -> Bool {
    contains(RegexConsumer(regex))
  }
}
