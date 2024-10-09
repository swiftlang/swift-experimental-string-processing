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

// MARK: `RangesCollection`

struct RangesSequence<Searcher: CollectionSearcher> {
  let input: Searcher.Searched
  let searcher: Searcher

  init(input: Searcher.Searched, searcher: Searcher) {
    self.input = input
    self.searcher = searcher
  }

  struct Iterator: IteratorProtocol {
    let base: RangesSequence
    var state: Searcher.State

    init(_ base: RangesSequence) {
      self.base = base
      self.state = base.searcher.state(for: base.input, in: base.input.startIndex..<base.input.endIndex)
    }

    mutating func next() -> Range<Searcher.Searched.Index>? {
      base.searcher.search(base.input, &state)
    }
  }
}

extension RangesSequence: Sequence {
  func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// TODO: `Collection` conformance

// MARK: `CollectionSearcher` algorithms

extension Collection {
  func _ranges<S: CollectionSearcher>(
    of searcher: S
  ) -> RangesSequence<S> where S.Searched == Self {
    RangesSequence(input: self, searcher: searcher)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  func _ranges<C: Collection>(
    of other: C
  ) -> RangesSequence<ZSearcher<Self>> where C.Element == Element {
    _ranges(of: ZSearcher(pattern: Array(other), by: ==))
  }
  
  // FIXME: Return `some Collection<Range<Index>>` for SE-0346
  /// Finds and returns the ranges of the all occurrences of a given sequence
  /// within the collection.
  /// - Parameter other: The sequence to search for.
  /// - Returns: A collection of ranges of all occurrences of `other`. Returns
  ///  an empty collection if `other` is not found.
  @available(SwiftStdlib 5.7, *)
  public func ranges<C: Collection>(
    of other: C
  ) -> [Range<Index>] where C.Element == Element {
    switch (self, other) {
    case (let str as String, let other as String):
      return Array(SubstringSearcher(text: str[...], pattern: other[...])) as! [Range<Index>]
    case (let str as Substring, let other as String):
      return Array(SubstringSearcher(text: str, pattern: other[...])) as! [Range<Index>]
    case (let str as String, let other as Substring):
      return Array(SubstringSearcher(text: str[...], pattern: other)) as! [Range<Index>]
    case (let str as Substring, let other as Substring):
      return Array(SubstringSearcher(text: str, pattern: other)) as! [Range<Index>]
      
    default:
      return Array(_ranges(of: other))
    }
  }
}

@available(SwiftStdlib 5.7, *)
struct RegexRangesSequence<Output> {
  let base: RegexMatchesSequence<Output>

  init(
    input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>,
    regex: Regex<Output>
  ) {
    self.base = .init(
      input: input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      regex: regex)
  }
}

@available(SwiftStdlib 5.7, *)
extension RegexRangesSequence: Sequence {
  struct Iterator: IteratorProtocol {
    var matchesBase: RegexMatchesSequence<Output>.Iterator
    
    mutating func next() -> Range<String.Index>? {
      matchesBase.next().map(\.range)
    }
  }
  
  func makeIterator() -> Iterator {
    Iterator(matchesBase: base.makeIterator())
  }
}

// MARK: Regex algorithms

extension Collection where SubSequence == Substring {
  @available(SwiftStdlib 5.7, *)
  @_disfavoredOverload
  func _ranges<R: RegexComponent>(
    of regex: R,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>
  ) -> RegexRangesSequence<R.RegexOutput> {
    RegexRangesSequence(
      input: self[...].base,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      regex: regex.regex)
  }
  
  @available(SwiftStdlib 5.7, *)
  @_disfavoredOverload
  func _ranges<R: RegexComponent>(
    of regex: R
  ) -> RegexRangesSequence<R.RegexOutput> {
    _ranges(
      of: regex,
      subjectBounds: startIndex..<endIndex,
      searchBounds: startIndex..<endIndex)
  }
}

extension BidirectionalCollection where SubSequence == Substring {
  // FIXME: Return `some Collection<Range<Index>>` for SE-0346
  /// Finds and returns the ranges of the all occurrences of a given sequence
  /// within the collection.
  /// 
  /// - Parameter regex: The regex to search for.
  /// - Returns: A collection or ranges in the receiver of all occurrences of
  /// `regex`. Returns an empty collection if `regex` is not found.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public func ranges(
    of regex: some RegexComponent
  ) -> [Range<Index>] {
    Array(_ranges(of: regex))
  }
}
