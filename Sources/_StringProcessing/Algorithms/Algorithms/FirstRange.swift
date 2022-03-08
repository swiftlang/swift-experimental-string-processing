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
  public func firstRange<R: RegexComponent>(of regex: R) -> Range<Index>? {
    firstRange(of: RegexConsumer(regex))
  }
  
  public func lastRange<R: RegexComponent>(of regex: R) -> Range<Index>? {
    lastRange(of: RegexConsumer(regex))
  }
}
