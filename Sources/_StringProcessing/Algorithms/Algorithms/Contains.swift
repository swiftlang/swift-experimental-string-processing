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
  func contains<Searcher: CollectionSearcher>(
    _ searcher: Searcher
  ) -> Bool where Searcher.Searched == Self {
    firstRange(of: searcher) != nil
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  /// Returns a Boolean value indicating whether the collection contains the
  /// given sequence.
  /// - Parameter other: A sequence to search for within this collection.
  /// - Returns: `true` if the collection contains the specified sequence,
  /// otherwise `false`.
  @available(SwiftStdlib 5.7, *)
  public func contains<C: Collection>(pattern other: C) -> Bool
    where C.Element == Element
  {
    firstRange(of: other) != nil
  }
}

extension BidirectionalCollection where Element: Comparable {
  func contains<C: Collection>(_ other: C) -> Bool
    where C.Element == Element
  {
    if #available(SwiftStdlib 5.7, *) {
      return firstRange(of: other) != nil
    }
    fatalError()
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  /// Returns a Boolean value indicating whether the collection contains the
  /// given regex.
  /// - Parameter regex: A regex to search for within this collection.
  /// - Returns: `true` if the regex was found in the collection, otherwise
  /// `false`.
  @available(SwiftStdlib 5.7, *)
  public func contains<R: RegexComponent>(pattern regex: R) -> Bool {
    contains(RegexConsumer(regex))
  }
}
