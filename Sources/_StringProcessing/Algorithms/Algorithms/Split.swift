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

// MARK: `SplitCollection`

struct SplitSequence<Searcher: CollectionSearcher> {
  public typealias Input = Searcher.Searched
  
  let ranges: RangesSequence<Searcher>
  var maxSplits: Int
  var omittingEmptySubsequences: Bool

  init(
    ranges: RangesSequence<Searcher>,
    maxSplits: Int,
    omittingEmptySubsequences: Bool)
  {
    self.ranges = ranges
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences
  }

  init(
    input: Input,
    searcher: Searcher,
    maxSplits: Int,
    omittingEmptySubsequences: Bool)
  {
    self.ranges = input._ranges(of: searcher)
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences
  }
}

extension SplitSequence: Sequence {
  public struct Iterator: IteratorProtocol {
    var ranges: RangesSequence<Searcher>.Iterator
    var index: Input.Index

    var maxSplits: Int
    var splitCounter = 0
    var omittingEmptySubsequences: Bool
    var isDone = false

    var input: Input { ranges.base.input }

    init(
      ranges: RangesSequence<Searcher>,
      maxSplits: Int,
      omittingEmptySubsequences: Bool
    ) {
      self.index = ranges.input.startIndex
      self.ranges = ranges.makeIterator()
      self.maxSplits = maxSplits
      self.omittingEmptySubsequences = omittingEmptySubsequences
    }
    
    public mutating func next() -> Input.SubSequence? {
      guard !isDone else { return nil }
      
      /// Return the rest of base if it's non-empty or we're including
      /// empty subsequences.
      func finish() -> Input.SubSequence? {
        isDone = true
        return index == input.endIndex && omittingEmptySubsequences
          ? nil
          : input[index...]
      }
      
      if index == input.endIndex {
        return finish()
      }
      
      if splitCounter >= maxSplits {
        return finish()
      }
      
      while true {
        // If there are no more ranges that matched, return the rest of `base`.
        guard let range = ranges.next() else {
          return finish()
        }
        
        defer { index = range.upperBound }

        if omittingEmptySubsequences && index == range.lowerBound {
          continue
        }
        
        splitCounter += 1
        return input[index..<range.lowerBound]
      }
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(ranges: ranges, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }
}

// MARK: `CollectionSearcher` algorithms

extension Collection {
  func _split<Searcher: CollectionSearcher>(
    by separator: Searcher,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitSequence<Searcher> where Searcher.Searched == Self {
    SplitSequence(
      input: self,
      searcher: separator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  @_disfavoredOverload
  func _split<C: Collection>(
    by separator: C,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) -> SplitSequence<ZSearcher<Self>> where C.Element == Element {
    _split(by: ZSearcher(pattern: Array(separator), by: ==), maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
  }

  // FIXME: Return `some Collection<SubSequence>` for SE-0346
  /// Returns the longest possible subsequences of the collection, in order,
  /// around elements equal to the given separator.
  ///
  /// - Parameter separator: The element to be split upon.
  /// - Returns: A collection of subsequences, split from this collection's
  ///   elements.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public func split<C: Collection>(
    separator: C,
    maxSplits: Int = .max,
    omittingEmptySubsequences: Bool = true
  ) -> [SubSequence] where C.Element == Element {
    switch (self, separator) {
    case (let str as String, let sep as String):
      return str[...]._split(separator: sep, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) as! [SubSequence]
    case (let str as String, let sep as Substring):
      return str[...]._split(separator: sep, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) as! [SubSequence]
    case (let str as Substring, let sep as String):
      return str._split(separator: sep, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) as! [SubSequence]
    case (let str as Substring, let sep as Substring):
      return str._split(separator: sep, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) as! [SubSequence]
      
    default:
      return Array(_split(
        by: ZSearcher(pattern: Array(separator), by: ==),
        maxSplits: maxSplits,
        omittingEmptySubsequences: omittingEmptySubsequences))
    }
  }
}

// String split overload breakers
//
// These are underscored and marked as SPI so that the *actual* public overloads
// are only visible in RegexBuilder, to avoid breaking source with the
// standard library's function of the same name that takes a `Character`
// as the separator. *Those* overloads are necessary as tie-breakers between
// the Collection-based and Regex-based `split`s, which in turn are both marked
// @_disfavoredOverload to avoid the wrong overload being selected when a
// collection's element type could be used interchangably with a collection of
// that element (e.g. `Array<OptionSet>.split(separator: [])`).

extension StringProtocol where SubSequence == Substring {
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func _split(
    separator: String,
    maxSplits: Int = .max,
    omittingEmptySubsequences: Bool = true
  ) -> [Substring] {
    Array(self[...]._split(
      by: SubstringSearcher(text: "" as Substring, pattern: separator[...]),
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func _split(
    separator: Substring,
    maxSplits: Int = .max,
    omittingEmptySubsequences: Bool = true
  ) -> [Substring] {
    Array(self[...]._split(
      by: SubstringSearcher(text: "" as Substring, pattern: separator[...]),
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences))
  }
}

// MARK: Regex algorithms

@available(SwiftStdlib 5.7, *)
extension BidirectionalCollection where SubSequence == Substring {
  // TODO: Is this @_disfavoredOverload necessary?
  // It prevents split(separator: String) from choosing this overload instead
  // of the collection-based version when String has RegexComponent conformance

  // FIXME: Return `some Collection<Subsequence>` for SE-0346
  /// Returns the longest possible subsequences of the collection, in order,
  /// around elements equal to the given separator.
  ///
  /// - Parameter separator: A regex describing elements to be split upon.
  /// - Returns: A collection of substrings, split from this collection's
  ///   elements.
  @_disfavoredOverload
  public func split(
    separator: some RegexComponent,
    maxSplits: Int = .max,
    omittingEmptySubsequences: Bool = true
  ) -> [SubSequence] {
    var result: [SubSequence] = []
    var subSequenceStart = startIndex
    
    func appendSubsequence(end: Index) -> Bool {
      if subSequenceStart == end && omittingEmptySubsequences {
        return false
      }
      result.append(self[subSequenceStart..<end])
      return true
    }
    
    guard maxSplits > 0 && !isEmpty else {
      _ = appendSubsequence(end: endIndex)
      return result
    }

    for match in _matches(of: separator) {
      defer { subSequenceStart = match.range.upperBound }
      let didAppend = appendSubsequence(end: match.range.lowerBound)
      if didAppend && result.count == maxSplits {
        break
      }
    }
    
    if subSequenceStart != endIndex || !omittingEmptySubsequences {
      result.append(self[subSequenceStart..<endIndex])
    }
    
    return result
  }
}
