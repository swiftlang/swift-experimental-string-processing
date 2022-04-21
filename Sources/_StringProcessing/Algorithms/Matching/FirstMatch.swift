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
  func firstMatch<S: MatchingCollectionSearcher>(
    of searcher: S
  ) -> _MatchResult<S>? where S.Searched == Self {
    var state = searcher.state(for: self, in: startIndex..<endIndex)
    return searcher.matchingSearch(self, &state).map { range, result in
      _MatchResult(match: self[range], result: result)
    }
  }
}

extension BidirectionalCollection {
  func lastMatch<S: BackwardMatchingCollectionSearcher>(
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
  @available(SwiftStdlib 5.7, *)
  func firstMatch<R: RegexComponent>(
    of regex: R
  ) -> _MatchResult<RegexConsumer<R, Self>>? {
    firstMatch(of: RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  func lastMatch<R: RegexComponent>(
    of regex: R
  ) -> _BackwardMatchResult<RegexConsumer<R, Self>>? {
    lastMatch(of: RegexConsumer(regex))
  }

  /// Returns the first match of the specified regex within the collection.
  /// - Parameter regex: The regex to search for.
  /// - Returns: The first match of `regex` in the collection, or `nil` if
  /// there isn't a match.
  @available(SwiftStdlib 5.7, *)
  public func firstMatch<R: RegexComponent>(
    of r: R
  ) -> Regex<R.RegexOutput>.Match? {
    let slice = self[...]
    return try? r.regex.firstMatch(in: slice)
  }
}
