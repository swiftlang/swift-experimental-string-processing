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
      searcherState: searcher.initialState(base),
      index: base.startIndex)
  }
}

// TODO: consider making this a collection even when the searcher maintains a state,
// and storing this state inside the `Index`.
extension RangesSequence: Collection where Searcher: StatelessCollectionSearcher {
  public struct Index {
    let range: Range<Searcher.Searched.Index>
  }
  
  public var startIndex: Index {
    _index(after: base.startIndex)
  }
  
  public var endIndex: Index {
    Index(range: base.endIndex..<base.endIndex)
  }
  
  func _index(after index: Base.Index) -> Index {
    if let range = searcher.search(base, subrange: index..<base.endIndex) {
      return Index(range: range)
    } else {
      return endIndex
    }
  }
  
  public func index(after index: Index) -> Index {
    _index(after: index.range.upperBound)
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

extension RangesSequence: BidirectionalCollection
  where Searcher: StatelessBidirectionalCollectionSearcher
{
  public func index(before index: Index) -> Index {
    let range = searcher.searchBack(base, subrange: base.startIndex..<index.range.lowerBound)!
    return Index(range: range)
  }
}
