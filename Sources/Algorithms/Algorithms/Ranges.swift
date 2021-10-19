extension Collection {
  public func ranges<S: CollectionSearcher>(_ searcher: S) -> RangesSequence<Self, S> {
    RangesSequence(base: self, searcher: searcher)
  }
}

extension Collection where Element: Equatable {
  public func ranges<S: Sequence>(
    of other: S
  ) -> RangesSequence<Self, ZSearcher<Self>> where S.Element == Element {
    ranges(ZSearcher(pattern: Array(other), by: ==))
  }
}

extension BidirectionalCollection where Element: Comparable {
  public func ranges<S: Sequence>(
    of other: S
  ) -> RangesSequence<Self, TwoWaySearcher<Self>> where S.Element == Element {
    ranges(TwoWaySearcher(pattern: Array(other)))
  }
}

public struct RangesSequence<Base, Searcher: CollectionSearcher>
  where Searcher.Searched == Base
{
  let base: Base
  let searcher: Searcher
  private(set) public var startIndex: Index
  
  init(base: Base, searcher: Searcher) {
    self.base = base
    self.searcher = searcher
    
    let startIndex = base.startIndex
    var state = searcher.state(startingAt: startIndex, in: base)
    self.startIndex = Index(range: startIndex..<startIndex, state: state)
    
    if let range = searcher.search(base, &state) {
      self.startIndex = Index(range: range, state: state)
    } else {
      self.startIndex = endIndex
    }
  }
}

extension RangesSequence: Sequence {
  public struct Iterator: IteratorProtocol {
    let base: Base
    var searcher: Searcher
    var searcherState: Searcher.State
    var index: Base.Index
    
    public mutating func next() -> Range<Base.Index>? {
      guard let range = searcher.search(base, &searcherState) else { return nil }
      index = range.upperBound
      return range
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(
      base: base,
      searcher: searcher,
      searcherState: searcher.state(startingAt: base.startIndex, in: base),
      index: base.startIndex)
  }
}

extension RangesSequence: Collection {
  public struct Index {
    var range: Range<Searcher.Searched.Index>
    var state: Searcher.State
  }
  
  public var endIndex: Index {
    Index(
      range: base.endIndex..<base.endIndex,
      state: searcher.state(startingAt: base.endIndex, in: base))
  }
  
  public func formIndex(after index: inout Index) {
    index.range = searcher.search(base, &index.state) ?? base.endIndex..<base.endIndex
  }
  
  public func index(after index: Index) -> Index {
    var index = index
    formIndex(after: &index)
    return index
  }
  
  public subscript(index: Index) -> Range<Base.Index> {
    precondition(index != endIndex)
    return index.range
  }
}
 
extension RangesSequence.Index: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.range.lowerBound == rhs.range.lowerBound
  }
  
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.range.lowerBound < rhs.range.lowerBound
  }
}

// TODO: `BidirectionalCollection` conformance
