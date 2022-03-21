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
  public func replacing<Searcher: CollectionSearcher, Replacement: Collection>(
    _ searcher: Searcher,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Searcher.Searched == SubSequence,
                  Replacement.Element == Element
  {
    precondition(maxReplacements >= 0)
    
    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])
    
    for range in self[subrange].ranges(of: searcher).prefix(maxReplacements) {
      result.append(contentsOf: self[index..<range.lowerBound])
      result.append(contentsOf: replacement)
      index = range.upperBound
    }
    
    result.append(contentsOf: self[index...])
    return result
  }
  
  public func replacing<Searcher: CollectionSearcher, Replacement: Collection>(
    _ searcher: Searcher,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Searcher.Searched == SubSequence,
                  Replacement.Element == Element
  {
    replacing(
      searcher,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<
    Searcher: CollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Searcher.Searched == SubSequence, Replacement.Element == Element {
    self = replacing(
      searcher,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}

// MARK: Fixed pattern algorithms

extension RangeReplaceableCollection where Element: Equatable {
  public func replacing<S: Sequence, Replacement: Collection>(
    _ other: S,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where S.Element == Element, Replacement.Element == Element {
    replacing(
      ZSearcher(pattern: Array(other), by: ==),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }
  
  public func replacing<S: Sequence, Replacement: Collection>(
    _ other: S,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where S.Element == Element, Replacement.Element == Element {
    replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<S: Sequence, Replacement: Collection>(
    _ other: S,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where S.Element == Element, Replacement.Element == Element {
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
  public func replacing<S: Sequence, Replacement: Collection>(
    _ other: S,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where S.Element == Element, Replacement.Element == Element {
    replacing(
      PatternOrEmpty(searcher: TwoWaySearcher(pattern: Array(other))),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }
      
  public func replacing<S: Sequence, Replacement: Collection>(
    _ other: S,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where S.Element == Element, Replacement.Element == Element {
    replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<S: Sequence, Replacement: Collection>(
    _ other: S,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where S.Element == Element, Replacement.Element == Element {
    self = replacing(
      other,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
}

// MARK: Regex algorithms

extension RangeReplaceableCollection where SubSequence == Substring {
  public func replacing<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      RegexConsumer(regex),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }
  
  public func replacing<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      regex,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Replacement.Element == Element {
    self = replacing(
      regex,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}
