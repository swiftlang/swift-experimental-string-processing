extension Collection {
  public func split<Searcher: CollectionSearcher>(
    _ searcher: Searcher
  ) -> SplitCollection<Self, Searcher> where Searcher.Searched == Self {
    // TODO: `maxSplits`, `omittingEmptySubsequences`
    SplitCollection(base: self, searcher: searcher)
  }
}

extension Collection where Element: Equatable {
  public func split<S: Sequence>(
    separator: S
  ) -> SplitCollection<Self, PatternOrEmpty<ZSearcher<Self>>> where S.Element == Element {
    let pattern: [Element] = Array(separator)
    let searcher = pattern.isEmpty ? nil : ZSearcher<Self>(pattern: pattern, by: ==)
    return split(PatternOrEmpty(searcher: searcher))
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func split<S: Sequence>(
    separator: S
  ) -> SplitCollection<Self, PatternOrEmpty<TwoWaySearcher<Self>>> where S.Element == Element {
    let pattern: [Element] = Array(separator)
    let searcher = PatternOrEmpty(searcher: TwoWaySearcher<Self>(pattern: pattern))
    return split(searcher)
  }
}

public struct SplitCollection<Base, Searcher: CollectionSearcher> where Searcher.Searched == Base {
  let ranges: RangesCollection<Base, Searcher>
  
  init(base: Base, searcher: Searcher) {
    self.ranges = base.ranges(searcher)
  }
}

extension SplitCollection: Collection {
  public struct Index {
    var start: Base.Index
    var base: RangesCollection<Base, Searcher>.Index
    var isEndIndex: Bool
  }
  
  public var startIndex: Index {
    let base = ranges.startIndex
    return Index(start: ranges.base.startIndex, base: base, isEndIndex: base == ranges.endIndex)
  }
  
  public var endIndex: Index {
    Index(start: ranges.base.endIndex, base: ranges.endIndex, isEndIndex: true)
  }
  
  public func formIndex(after index: inout Index) {
    guard !index.isEndIndex else { fatalError("Cannot advance past endIndex") }
    
    if let range = index.base.range {
      let newStart = range.upperBound
      ranges.formIndex(after: &index.base)
      index.start = newStart
    } else {
      index.isEndIndex = true
    }
  }
  
  public func index(after index: Index) -> Index {
    var index = index
    formIndex(after: &index)
    return index
  }
  
  public subscript(index: Index) -> Base.SubSequence {
    guard !index.isEndIndex else { fatalError("Cannot subscript using endIndex") }
    let end = index.base.range?.lowerBound ?? ranges.base.endIndex
    return ranges.base[index.start..<end]
  }
}

extension SplitCollection.Index: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.isEndIndex, rhs.isEndIndex) {
    case (false, false):
      return lhs.start == rhs.start
    case (let lhs, let rhs):
      return lhs == rhs
    }
  }
  
  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.isEndIndex, rhs.isEndIndex) {
    case (true, _):
      return false
    case (_, true):
      return true
    case (false, false):
      return lhs.start < rhs.start
    }
  }
}
