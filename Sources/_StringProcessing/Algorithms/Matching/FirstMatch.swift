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
  public func firstMatch<S: MatchingCollectionSearcher>(
    of searcher: S
  ) -> (S.Match, Range<S.Searched.Index>)? where S.Searched == Self {
    var state = searcher.state(for: self, in: startIndex..<endIndex)
    return searcher.matchingSearch(self, &state)
  }
}

extension BidirectionalCollection {
  public func lastMatch<S: BackwardMatchingCollectionSearcher>(
    of searcher: S
  ) -> (S.Match, Range<S.BackwardSearched.Index>)?
    where S.BackwardSearched == Self
  {
    var state = searcher.backwardState(for: self, in: startIndex..<endIndex)
    return searcher.matchingSearchBack(self, &state)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func firstMatch<Capture>(
    of regex: Regex<Capture>
  ) -> (Capture, Range<String.Index>)? {
    firstMatch(of: RegexConsumer(regex))
  }
  
  public func lastMatch<Capture>(
    of regex: Regex<Capture>
  ) -> (Capture, Range<String.Index>)? {
    lastMatch(of: RegexConsumer(regex))
  }
}
