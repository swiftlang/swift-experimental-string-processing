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
  ) -> _MatchResult<S>? where S.Searched == Self {
    var state = searcher.state(for: self, in: startIndex..<endIndex)
    return searcher.matchingSearch(self, &state).map { range, result in
      _MatchResult(match: self[range], result: result)
    }
  }
}

extension BidirectionalCollection {
  public func lastMatch<S: BackwardMatchingCollectionSearcher>(
    of searcher: S
  ) -> _BackwardMatchResult<S>?
    where S.BackwardSearched == Self
  {
    var state = searcher.backwardState(for: self, in: startIndex..<endIndex)
    return searcher.matchingSearchBack(self, &state).map { range, result in
      _BackwardMatchResult(match: self[range], result: result)
    }
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func firstMatch<R: RegexComponent>(
    of regex: R
  ) -> _MatchResult<RegexConsumer<R, Self>>? {
    firstMatch(of: RegexConsumer(regex))
  }
  
  public func lastMatch<R: RegexComponent>(
    of regex: R
  ) -> _BackwardMatchResult<RegexConsumer<R, Self>>? {
    lastMatch(of: RegexConsumer(regex))
  }
}
