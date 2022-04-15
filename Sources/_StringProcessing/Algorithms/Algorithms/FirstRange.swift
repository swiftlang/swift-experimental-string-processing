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
  func firstRange<S: CollectionSearcher>(
    of searcher: S
  ) -> Range<Index>? where S.Searched == Self {
    var state = searcher.state(for: self, in: startIndex..<endIndex)
    return searcher.search(self, &state)
  }
}

extension BidirectionalCollection {
  func lastRange<S: BackwardCollectionSearcher>(
    of searcher: S
  ) -> Range<Index>? where S.BackwardSearched == Self {
    var state = searcher.backwardState(for: self, in: startIndex..<endIndex)
    return searcher.searchBack(self, &state)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  /// Finds and returns the range of the first occurrence of a given sequence
  /// within the collection.
  /// - Parameter sequence: The sequence to search for.
  /// - Returns: A range in the collection of the first occurrence of `sequence`.
  /// Returns nil if `sequence` is not found.
  @available(SwiftStdlib 5.7, *)
  public func firstRange<S: Sequence>(
    of sequence: S
  ) -> Range<Index>? where S.Element == Element {
    // TODO: Use a more efficient search algorithm
    let searcher = ZSearcher<SubSequence>(pattern: Array(sequence), by: ==)
    return searcher.search(self[...], in: startIndex..<endIndex)
  }
}

extension BidirectionalCollection where Element: Comparable {
  /// Finds and returns the range of the first occurrence of a given sequence
  /// within the collection.
  /// - Parameter other: The sequence to search for.
  /// - Returns: A range in the collection of the first occurrence of `sequence`.
  /// Returns `nil` if `sequence` is not found.
  @available(SwiftStdlib 5.7, *)
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
  /// Finds and returns the range of the first occurrence of a given regex
  /// within the collection.
  /// - Parameter regex: The regex to search for.
  /// - Returns: A range in the collection of the first occurrence of `regex`.
  /// Returns `nil` if `regex` is not found.
  @available(SwiftStdlib 5.7, *)
  public func firstRange<R: RegexComponent>(of regex: R) -> Range<Index>? {
    firstRange(of: RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  func lastRange<R: RegexComponent>(of regex: R) -> Range<Index>? {
    lastRange(of: RegexConsumer(regex))
  }
}
