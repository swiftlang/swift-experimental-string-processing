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

import _StringProcessing

extension BidirectionalCollection where SubSequence == Substring {
  /// Matches a regex in its entirety, where the regex is created by
  /// the given closure.
  ///
  /// - Parameter content: A closure that returns a regex to match against.
  /// - Returns: The match if there is one, or `nil` if none.
  @available(SwiftStdlib 5.7, *)
  public func wholeMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    wholeMatch(of: content())
  }

  /// Matches part of the regex, starting at the beginning, where the regex
  /// is created by the given closure.
  ///
  /// - Parameter content: A closure that returns a regex to match against.
  /// - Returns: The match if there is one, or `nil` if none.
  @available(SwiftStdlib 5.7, *)
  public func prefixMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    prefixMatch(of: content())
  }

  /// Returns a Boolean value indicating whether this collection contains a
  /// match for the regex, where the regex is created by the given closure.
  ///
  /// - Parameter content: A closure that returns a regex to search for within
  ///   this collection.
  /// - Returns: `true` if the regex returned by `content` matched anywhere in
  ///   this collection, otherwise `false`.
  @available(SwiftStdlib 5.7, *)
  public func contains<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) -> Bool {
    contains(content())
  }

  /// Returns the range of the first match for the regex within this collection,
  /// where the regex is created by the given closure.
  ///
  /// - Parameter content: A closure that returns a regex to search for.
  /// - Returns: A range in the collection of the first occurrence of the first
  ///   match of if the regex returned by `content`. Returns `nil` if no match
  ///   for the regex is found.
  @available(SwiftStdlib 5.7, *)
  public func firstRange<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Range<Index>? {
    firstRange(of: content())
  }

  // FIXME: Return `some Collection<Range<Index>>` for SE-0346
  /// Returns the ranges of the all non-overlapping matches for the regex
  /// within this collection, where the regex is created by the given closure.
  ///
  /// - Parameter content: A closure that returns a regex to search for.
  /// - Returns: A collection of ranges of all matches for the regex returned by
  ///   `content`. Returns an empty collection if no match for the regex
  ///   is found.
  @available(SwiftStdlib 5.7, *)
  public func ranges<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> [Range<Index>] {
    ranges(of: content())
  }

  // FIXME: Return `some Collection<Substring>` for SE-0346
  /// Returns the longest possible subsequences of the collection, in order,
  /// around subsequence that match the regex created by the given closure.
  ///
  /// - Parameters:
  ///   - maxSplits: The maximum number of times to split the collection,
  ///     or one less than the number of subsequences to return.
  ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
  ///     returned in the result for each consecutive pair of matches
  ///     and for each match at the start or end of the collection. If
  ///     `true`, only nonempty subsequences are returned.
  ///   - separator: A closure that returns a regex to be split upon.
  /// - Returns: A collection of substrings, split from this collection's
  ///   elements.
  @available(SwiftStdlib 5.7, *)
  public func split(
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    @RegexComponentBuilder separator: () -> some RegexComponent
  ) -> [SubSequence] {
    split(separator: separator(), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }

  /// Returns a Boolean value indicating whether the initial elements of this
  /// collection are a match for the regex created by the given closure.
  ///
  /// - Parameter content: A closure that returns a regex to match at
  ///   the beginning of this collection.
  /// - Returns: `true` if the initial elements of this collection match
  ///   regex returned by `content`; otherwise, `false`.
  @available(SwiftStdlib 5.7, *)
  public func starts<R: RegexComponent>(
    @RegexComponentBuilder with content: () -> R
  ) -> Bool {
    starts(with: content())
  }

  /// Returns a subsequence of this collection by removing the elements
  /// matching the regex from the start, where the regex is created by
  /// the given closure.
  ///
  /// - Parameter content: A closure that returns the regex to search for at
  ///   the start of this collection.
  /// - Returns: A collection containing the elements after those that match
  ///   the regex returned by `content`. If the regex does not match at
  ///   the start of the collection, the entire contents of this collection
  ///   are returned.
  @available(SwiftStdlib 5.7, *)
  public func trimmingPrefix<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) -> SubSequence {
    trimmingPrefix(content())
  }

  /// Returns the first match for the regex within this collection, where
  /// the regex is created by the given closure.
  ///
  /// - Parameter content: A closure that returns the regex to search for.
  /// - Returns: The first match for the regex created by `content` in this
  ///   collection, or `nil` if no match is found.
  @available(SwiftStdlib 5.7, *)
  public func firstMatch<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> Regex<R.RegexOutput>.Match? {
    firstMatch(of: content())
  }

  // FIXME: Return `some Collection<Regex<R.Output>.Match> for SE-0346
  /// Returns a collection containing all non-overlapping matches of
  /// the regex, created by the given closure.
  ///
  /// - Parameter content: A closure that returns the regex to search for.
  /// - Returns: A collection of matches for the regex returned by `content`.
  ///   If no matches are found, the returned collection is empty.
  @available(SwiftStdlib 5.7, *)
  public func matches<R: RegexComponent>(
    @RegexComponentBuilder of content: () -> R
  ) -> [Regex<R.RegexOutput>.Match] {
    matches(of: content())
  }
}

extension RangeReplaceableCollection
where Self: BidirectionalCollection, SubSequence == Substring {
  /// Removes the initial elements matching the regex from the start of
  /// this collection, if the initial elements match, using the given closure
  /// to create the regex.
  ///
  /// - Parameter content: A closure that returns the regex to search for
  ///   at the start of this collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) {
    trimPrefix(content())
  }

  /// Returns a new collection in which all matches for the regex
  /// are replaced, using the given closure to create the regex.
  ///
  /// - Parameters:
  ///   - replacement: The new elements to add to the collection in place of
  ///     each match for the regex, using `content` to create the regex.
  ///   - subrange: The range in the collection in which to search for
  ///     the regex.
  ///   - maxReplacements: A number specifying how many occurrences of
  ///     the regex to replace.
  ///   - content: A closure that returns the collection to search for
  ///     and replace.
  /// - Returns: A new collection in which all matches for regex in `subrange`
  ///   are replaced by `replacement`, using `content` to create the regex.
  @available(SwiftStdlib 5.7, *)
  public func replacing<Replacement: Collection>(
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max,
    @RegexComponentBuilder content: () -> some RegexComponent
  ) -> Self where Replacement.Element == Element {
    replacing(content(), with: replacement, subrange: subrange, maxReplacements: maxReplacements)
  }

  /// Returns a new collection in which all matches for the regex
  /// are replaced, using the given closure to create the regex.
  ///
  /// - Parameters:
  ///   - replacement: The new elements to add to the collection in place of
  ///     each match for the regex, using `content` to create the regex.
  ///   - maxReplacements: A number specifying how many occurrences of regex
  ///     to replace.
  ///   - content: A closure that returns the collection to search for
  ///     and replace.
  /// - Returns: A new collection in which all matches for regex in `subrange`
  ///   are replaced by `replacement`, using `content` to create the regex.
  @available(SwiftStdlib 5.7, *)
  public func replacing<Replacement: Collection>(
    with replacement: Replacement,
    maxReplacements: Int = .max,
    @RegexComponentBuilder content: () -> some RegexComponent
  ) -> Self where Replacement.Element == Element {
    replacing(content(), with: replacement, maxReplacements: maxReplacements)
  }

  /// Replaces all matches for the regex in this collection, using the given
  /// closure to create the regex.
  ///
  /// - Parameters:
  ///   - replacement: The new elements to add to the collection in place of
  ///     each match for the regex, using `content` to create the regex.
  ///   - maxReplacements: A number specifying how many occurrences of
  ///     the regex to replace.
  ///   - content: A closure that returns the collection to search for
  ///     and replace.
  @available(SwiftStdlib 5.7, *)
  public mutating func replace<Replacement: Collection>(
    with replacement: Replacement,
    maxReplacements: Int = .max,
    @RegexComponentBuilder content: () -> some RegexComponent
  ) where Replacement.Element == Element {
    replace(content(), with: replacement, maxReplacements: maxReplacements)
  }

  /// Returns a new collection in which all matches for the regex
  /// are replaced, using the given closures to create the replacement
  /// and the regex.
  ///
  /// - Parameters:
  ///   - subrange: The range in the collection in which to search for the
  ///     regex, using `content` to create the regex.
  ///   - maxReplacements: A number specifying how many occurrences of
  ///     the regex to replace.
  ///   - content: A closure that returns the collection to search for
  ///     and replace.
  ///   - replacement: A closure that receives the full match information,
  ///     including captures, and returns a replacement collection.
  /// - Returns: A new collection in which all matches for regex in `subrange`
  ///   are replaced by the result of calling `replacement`, where regex
  ///   is the result of calling `content`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<R: RegexComponent, Replacement: Collection>(
    subrange: Range<Index>,
    maxReplacements: Int = .max,
    @RegexComponentBuilder content: () -> R,
    with replacement: (Regex<R.RegexOutput>.Match) throws -> Replacement
  ) rethrows -> Self where Replacement.Element == Element {
    try replacing(content(), subrange: subrange, maxReplacements: maxReplacements, with: replacement)
  }

  /// Returns a new collection in which all matches for the regex
  /// are replaced, using the given closures to create the replacement
  /// and the regex.
  ///
  /// - Parameters:
  ///   - maxReplacements: A number specifying how many occurrences of
  ///     the regex to replace, using `content` to create the regex.
  ///   - content: A closure that returns the collection to search for
  ///     and replace.
  ///   - replacement: A closure that receives the full match information,
  ///     including captures, and returns a replacement collection.
  /// - Returns: A new collection in which all matches for regex in `subrange`
  ///   are replaced by the result of calling `replacement`, where regex is
  ///   the result of calling `content`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<R: RegexComponent, Replacement: Collection>(
    maxReplacements: Int = .max,
    @RegexComponentBuilder content: () -> R,
    with replacement: (Regex<R.RegexOutput>.Match) throws -> Replacement
  ) rethrows -> Self where Replacement.Element == Element {
    try replacing(content(), maxReplacements: maxReplacements, with: replacement)
  }

  /// Replaces all matches for the regex in this collection, using the
  /// given closures to create the replacement and the regex.
  ///
  /// - Parameters:
  ///   - maxReplacements: A number specifying how many occurrences of
  ///     the regex to replace, using `content` to create the regex.
  ///   - content: A closure that returns the collection to search for
  ///     and replace.
  ///   - replacement: A closure that receives the full match information,
  ///     including captures, and returns a replacement collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func replace<R: RegexComponent, Replacement: Collection>(
    maxReplacements: Int = .max,
    @RegexComponentBuilder content: () -> R,
    with replacement: (Regex<R.RegexOutput>.Match) throws -> Replacement
  ) rethrows where Replacement.Element == Element {
    try replace(content(), maxReplacements: maxReplacements, with: replacement)
  }
}
