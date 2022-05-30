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

extension RangeReplaceableCollection {
  func _replacing<Ranges: Collection, Replacement: Collection>(
    _ ranges: Ranges,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Ranges.Element == Range<Index>,
                  Replacement.Element == Element
  {
    precondition(maxReplacements >= 0)
    
    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])
    
    for range in ranges.prefix(maxReplacements) {
      result.append(contentsOf: self[index..<range.lowerBound])
      result.append(contentsOf: replacement)
      index = range.upperBound
    }
    
    result.append(contentsOf: self[index...])
    return result
  }
  
  func _replacing<Ranges: Collection, Replacement: Collection>(
    _ ranges: Ranges,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Ranges.Element == Range<Index>,
                  Replacement.Element == Element
  {
    _replacing(
      ranges,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  mutating func _replace<
    Ranges: Collection, Replacement: Collection
  >(
    _ ranges: Ranges,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Ranges.Element == Range<Index>, Replacement.Element == Element {
    self = _replacing(
      ranges,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}

// MARK: Fixed pattern algorithms

extension RangeReplaceableCollection where Element: Equatable {
  /// Returns a new collection in which all occurrences of a target sequence
  /// are replaced by another collection.
  /// - Parameters:
  ///   - other: The sequence to replace.
  ///   - replacement: The new elements to add to the collection.
  ///   - subrange: The range in the collection in which to search for `other`.
  ///   - maxReplacements: A number specifying how many occurrences of `other`
  ///   to replace. Default is `Int.max`.
  /// - Returns: A new collection in which all occurrences of `other` in
  /// `subrange` of the collection are replaced by `replacement`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<C: Collection, Replacement: Collection>(
    _ other: C,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where C.Element == Element, Replacement.Element == Element {
    _replacing(
      _ranges(of: other),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }

  /// Returns a new collection in which all occurrences of a target sequence
  /// are replaced by another collection.
  /// - Parameters:
  ///   - other: The sequence to replace.
  ///   - replacement: The new elements to add to the collection.
  ///   - maxReplacements: A number specifying how many occurrences of `other`
  ///   to replace. Default is `Int.max`.
  /// - Returns: A new collection in which all occurrences of `other` in
  /// `subrange` of the collection are replaced by `replacement`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<C: Collection, Replacement: Collection>(
    _ other: C,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where C.Element == Element, Replacement.Element == Element {
    replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }

  /// Replaces all occurrences of a target sequence with a given collection
  /// - Parameters:
  ///   - other: The sequence to replace.
  ///   - replacement: The new elements to add to the collection.
  ///   - maxReplacements: A number specifying how many occurrences of `other`
  ///   to replace. Default is `Int.max`.
  @available(SwiftStdlib 5.7, *)
  public mutating func replace<C: Collection, Replacement: Collection>(
    _ other: C,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where C.Element == Element, Replacement.Element == Element {
    self = replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, Element: Comparable
{
  func _replacing<C: Collection, Replacement: Collection>(
    _ other: C,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where C.Element == Element, Replacement.Element == Element {
    _replacing(
      _ranges(of: other),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }
      
  func _replacing<C: Collection, Replacement: Collection>(
    _ other: C,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where C.Element == Element, Replacement.Element == Element {
    _replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  mutating func _replace<C: Collection, Replacement: Collection>(
    _ other: C,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where C.Element == Element, Replacement.Element == Element {
    self = _replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
}

// MARK: Regex algorithms

extension RangeReplaceableCollection where SubSequence == Substring {
  /// Returns a new collection in which all occurrences of a sequence matching
  /// the given regex are replaced by another collection.
  /// - Parameters:
  ///   - regex: A regex describing the sequence to replace.
  ///   - replacement: The new elements to add to the collection.
  ///   - subrange: The range in the collection in which to search for `regex`.
  ///   - maxReplacements: A number specifying how many occurrences of the
  ///   sequence matching `regex` to replace. Default is `Int.max`.
  /// - Returns: A new collection in which all occurrences of subsequence
  /// matching `regex` in `subrange` are replaced by `replacement`.
  @available(SwiftStdlib 5.7, *)
  public func replacing<Replacement: Collection>(
    _ regex: some RegexComponent,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    _replacing(
      _ranges(of: regex),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }

  /// Returns a new collection in which all occurrences of a sequence matching
  /// the given regex are replaced by another collection.
  /// - Parameters:
  ///   - regex: A regex describing the sequence to replace.
  ///   - replacement: The new elements to add to the collection.
  ///   - maxReplacements: A number specifying how many occurrences of the
  ///   sequence matching `regex` to replace. Default is `Int.max`.
  /// - Returns: A new collection in which all occurrences of subsequence
  /// matching `regex` are replaced by `replacement`.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public func replacing<Replacement: Collection>(
    _ regex: some RegexComponent,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      regex,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }

  /// Replaces all occurrences of the sequence matching the given regex with
  /// a given collection.
  /// - Parameters:
  ///   - regex: A regex describing the sequence to replace.
  ///   - replacement: The new elements to add to the collection.
  ///   - maxReplacements: A number specifying how many occurrences of the
  ///   sequence matching `regex` to replace. Default is `Int.max`.
  @available(SwiftStdlib 5.7, *)
  public mutating func replace<Replacement: Collection>(
    _ regex: some RegexComponent,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Replacement.Element == Element {
    self = replacing(
      regex,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}
