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

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  /// Returns the first match of the specified regex within the collection.
  /// - Parameter regex: The regex to search for.
  /// - Returns: The first match of `regex` in the collection, or `nil` if
  /// there isn't a match.
  @available(SwiftStdlib 5.7, *)
  @inlinable
  public func firstMatch<Output>(
    of r: some RegexComponent<Output>
  ) -> Regex<Output>.Match? {
    let slice = self[...]
    return try? r.regex.firstMatch(in: slice)
  }
}
