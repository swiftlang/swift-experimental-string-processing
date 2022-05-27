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
  func _replacing<
    Searcher: MatchingCollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: (_MatchResult<Searcher>) throws -> Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) rethrows -> Self where Searcher.Searched == SubSequence,
                  Replacement.Element == Element
  {
    precondition(maxReplacements >= 0)

    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])

    for match in self[subrange]._matches(of: searcher)
          .prefix(maxReplacements)
    {
      result.append(contentsOf: self[index..<match.range.lowerBound])
      result.append(contentsOf: try replacement(match))
      index = match.range.upperBound
    }

    result.append(contentsOf: self[index...])
    return result
  }

  func _replacing<
    Searcher: MatchingCollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: (_MatchResult<Searcher>) throws -> Replacement,
    maxReplacements: Int = .max
  ) rethrows -> Self where Searcher.Searched == SubSequence,
                           Replacement.Element == Element
  {
    try _replacing(
      searcher,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }

  mutating func _replace<
    Searcher: MatchingCollectionSearcher, Replacement: Collection
  >(
    _ searcher: Searcher,
    with replacement: (_MatchResult<Searcher>) throws -> Replacement,
    maxReplacements: Int = .max
  ) rethrows where Searcher.Searched == SubSequence,
                   Replacement.Element == Element
  {
    self = try _replacing(
      searcher,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}

// MARK: Regex algorithms

enum CaptureLookup {
  case numbered(Int)
  case named(Substring)
}

extension RangeReplaceableCollection where SubSequence == Substring {
  @available(SwiftStdlib 5.7, *)
  func _replacing<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    with replacement: (_MatchResult<RegexConsumer<R, Substring>>) throws -> Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) rethrows -> Self where Replacement.Element == Element {
    try _replacing(
      RegexConsumer(regex),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }

  @available(SwiftStdlib 5.7, *)
  func _replacing<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    with replacement: (_MatchResult<RegexConsumer<R, Substring>>) throws -> Replacement,
    maxReplacements: Int = .max
  ) rethrows -> Self where Replacement.Element == Element {
    try _replacing(
      regex,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }

  @available(SwiftStdlib 5.7, *)
  mutating func _replace<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    with replacement: (_MatchResult<RegexConsumer<R, Substring>>) throws -> Replacement,
    maxReplacements: Int = .max
  ) rethrows where Replacement.Element == Element {
    self = try _replacing(
      regex,
      with: replacement,
      maxReplacements: maxReplacements)
  }

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
  public func replacing<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    subrange: Range<Index>,
    maxReplacements: Int = .max,
    with replacement: (Regex<R.RegexOutput>.Match) throws -> Replacement
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
  public func replacing<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    maxReplacements: Int = .max,
    with replacement: (Regex<R.RegexOutput>.Match) throws -> Replacement
  ) rethrows -> Self where Replacement.Element == Element {
    try replacing(
      regex,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements,
      with: replacement)
  }
  
  @available(SwiftStdlib 5.7, *)
  public func replacing(
    _ regex: some RegexComponent,
    maxReplacements: Int = .max,
    withTemplate templateString: String
  ) -> Self {
    precondition(maxReplacements >= 0)
    
    let replacementRegex = try! Regex(#"(?D)\$(?:(\d++)|{(?:(\d++)|([^}]++))})"#)
    let replacements = templateString.matches(of: replacementRegex)
      .compactMap { match -> (Range<String.Index>, CaptureLookup)? in
        // Named capture?
        if let captureName = match.output[3].substring {
          return (match.range, .named(captureName))
        }
        
        // Numbered capture?
        if let captureNumberString = match.output[1].substring ?? match.output[2].substring,
           let captureNumber = Int(captureNumberString) {
          return (match.range, .numbered(captureNumber))
        }
        
        return nil
      }
    
    let subrange = startIndex..<endIndex
    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])

    for match in self[subrange].matches(of: regex)
      .prefix(maxReplacements)
    {
      result.append(contentsOf: self[index..<match.range.lowerBound])

      let erasedMatch = Regex<AnyRegexOutput>.Match(match)
      var templateIndex = templateString.startIndex
      for replacement in replacements {
        result.append(contentsOf: templateString[templateIndex..<(replacement.0.lowerBound)])
        switch replacement.1 {
        case .numbered(let captureNumber) where captureNumber < erasedMatch.output.count:
          result.append(contentsOf: erasedMatch.output[captureNumber].substring ?? "")
        case .named:
          fatalError("Replacing capture group by name is unsupported")
        default:
          break
        }
        templateIndex = replacement.0.upperBound
      }
      result.append(contentsOf: templateString[templateIndex...])
      
      index = match.range.upperBound
    }

    result.append(contentsOf: self[index...])
    return result
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
  public mutating func replace<R: RegexComponent, Replacement: Collection>(
    _ regex: R,
    maxReplacements: Int = .max,
    with replacement: (Regex<R.RegexOutput>.Match) throws -> Replacement
  ) rethrows where Replacement.Element == Element {
    self = try replacing(
      regex,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements,
      with: replacement)
  }
}
