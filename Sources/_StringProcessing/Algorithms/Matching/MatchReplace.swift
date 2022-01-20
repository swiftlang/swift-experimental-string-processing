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

// MARK: `MatchingCollectionSearcher` algorithms

extension RangeReplaceableCollection {
  public func replacing<
    Searcher: MatchingCollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: (Searcher.Match,
                       Range<Searcher.Searched.Index>) -> Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Searcher.Searched == SubSequence,
                  Replacement.Element == Element
  {
    precondition(maxReplacements >= 0)

    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])

    for (match, range) in self[subrange].matches(of: searcher)
          .prefix(maxReplacements)
    {
      result.append(contentsOf: self[index..<range.lowerBound])
      result.append(contentsOf: replacement(match, range))
      index = range.upperBound
    }

    result.append(contentsOf: self[index...])
    return result
  }

  public func replacing<
    Searcher: MatchingCollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: (Searcher.Match,
                       Range<Searcher.Searched.Index>) -> Replacement,
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
    Searcher: MatchingCollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: (Searcher.Match,
                       Range<Searcher.Searched.Index>) -> Replacement,
    maxReplacements: Int = .max
  ) where Searcher.Searched == SubSequence, Replacement.Element == Element {
    self = replacing(
      searcher,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}

// MARK: Regex algorithms

extension RangeReplaceableCollection where SubSequence == Substring {
  public func replacing<Capture, Replacement: Collection>(
    _ regex: Regex<Capture>,
    with replacement: (Capture, Range<String.Index>) -> Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      RegexConsumer(regex),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }
  
  public func replacing<Capture, Replacement: Collection>(
    _ regex: Regex<Capture>,
    with replacement: (Capture, Range<String.Index>) -> Replacement,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      regex,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<Capture, Replacement: Collection>(
    _ regex: Regex<Capture>,
    with replacement: (Capture, Range<String.Index>) -> Replacement,
    maxReplacements: Int = .max
  ) where Replacement.Element == Element {
    self = replacing(
      regex,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}
