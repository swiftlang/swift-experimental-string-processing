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

// MARK: Regex algorithms

extension RangeReplaceableCollection where SubSequence == Substring {
  /// Returns a new collection in which all occurrences of a sequence matching
  /// the given regex are replaced by another regex match.
  /// - Parameters:
  ///   - regex: A regex describing the sequence to replace.
  ///   - subrange: The range in the collection in which to search for `regex`.
  ///   - maxReplacements: A number specifying how many occurrences of the
  ///   sequence matching `regex` to replace. Default is `Int.max`.
  ///   - replacement: A closure that receives the full match information,
  ///   including captures, and returns a replacement collection.
  /// - Returns: A new collection in which all occurrences of subsequence
  /// matching `regex` are replaced by `replacement`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<Output, Replacement: Collection>(
    _ regex: some RegexComponent<Output>,
    subrange: Range<Index>,
    maxReplacements: Int = .max,
    with replacement: (Regex<Output>.Match) throws -> Replacement
  ) rethrows -> Self where Replacement.Element == Element {

    precondition(maxReplacements >= 0)

    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])

    for match in self[subrange].matches(of: regex)
      .prefix(maxReplacements)
    {
      result.append(contentsOf: self[index..<match.range.lowerBound])
      result.append(contentsOf: try replacement(match))
      index = match.range.upperBound
    }

    result.append(contentsOf: self[index...])
    return result
  }

  /// Returns a new collection in which all occurrences of a sequence matching
  /// the given regex are replaced by another collection.
  /// - Parameters:
  ///   - regex: A regex describing the sequence to replace.
  ///   - maxReplacements: A number specifying how many occurrences of the
  ///   sequence matching `regex` to replace. Default is `Int.max`.
  ///   - replacement: A closure that receives the full match information,
  ///   including captures, and returns a replacement collection.
  /// - Returns: A new collection in which all occurrences of subsequence
  /// matching `regex` are replaced by `replacement`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<Output, Replacement: Collection>(
    _ regex: some RegexComponent<Output>,
    maxReplacements: Int = .max,
    with replacement: (Regex<Output>.Match) throws -> Replacement
  ) rethrows -> Self where Replacement.Element == Element {
    try replacing(
      regex,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements,
      with: replacement)
  }

  /// Replaces all occurrences of the sequence matching the given regex with
  /// a given collection.
  /// - Parameters:
  ///   - regex: A regex describing the sequence to replace.
  ///   - maxReplacements: A number specifying how many occurrences of the
  ///   sequence matching `regex` to replace. Default is `Int.max`.
  ///   - replacement: A closure that receives the full match information,
  ///   including captures, and returns a replacement collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func replace<Output, Replacement: Collection>(
    _ regex: some RegexComponent<Output>,
    maxReplacements: Int = .max,
    with replacement: (Regex<Output>.Match) throws -> Replacement
  ) rethrows where Replacement.Element == Element {
    self = try replacing(
      regex,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements,
      with: replacement)
  }
}
