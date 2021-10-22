public struct SplitCollection<Searcher: CollectionSearcher> {
  public typealias Base = Searcher.Searched
  
  let ranges: RangesCollection<Searcher>

  init(base: Base, searcher: Searcher) {
    self.ranges = base.ranges(of: searcher)
  }
}

extension SplitCollection: Collection {
  public struct Index {
    var start: Base.Index
    var base: RangesCollection<Searcher>.Index
    var isEndIndex: Bool
  }

  public var startIndex: Index {
    let base = ranges.startIndex
    return Index(start: ranges.base.startIndex, base: base, isEndIndex: false)
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

extension Collection {
  public func split<Searcher: CollectionSearcher>(
    separator searcher: Searcher
  ) -> SplitCollection<Searcher> where Searcher.Searched == SubSequence {
    // TODO: `maxSplits`, `omittingEmptySubsequences`
    SplitCollection(base: self[...], searcher: searcher)
  }
}

extension Collection where Element: Equatable {
  public func split<S: Sequence>(
    separator: S
  ) -> SplitCollection<PatternOrEmpty<ZSearcher<SubSequence>>> where S.Element == Element {
    let pattern: [Element] = Array(separator)
    let searcher = pattern.isEmpty ? nil : ZSearcher<SubSequence>(pattern: pattern, by: ==)
    return split(separator: PatternOrEmpty(searcher: searcher))
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func split<S: Sequence>(
    separator: S
  ) -> SplitCollection<PatternOrEmpty<TwoWaySearcher<SubSequence>>> where S.Element == Element {
    split(separator: PatternOrEmpty(searcher: TwoWaySearcher(pattern: Array(separator))))
  }
}

// MARK: Regex

extension Collection where SubSequence == Substring {
  public func split(separator: Regex) -> SplitCollection<RegexConsumer> {
    split(separator: RegexConsumer(regex: separator))
  }
}
