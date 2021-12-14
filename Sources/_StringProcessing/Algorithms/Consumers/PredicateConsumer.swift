public struct PredicateConsumer<Consumed: Collection> {
  let predicate: (Consumed.Element) -> Bool
}

extension PredicateConsumer: CollectionConsumer {
  public func consuming(_ consumed: Consumed, in range: Range<Consumed.Index>) -> Consumed.Index? {
    let start = range.lowerBound
    guard start != range.upperBound && predicate(consumed[start]) else { return nil }
    return consumed.index(after: start)
  }
}

extension PredicateConsumer: BidirectionalCollectionConsumer where Consumed: BidirectionalCollection {
  public func consumingBack(_ consumed: Consumed, in range: Range<Consumed.Index>) -> Consumed.Index? {
    let end = range.upperBound
    guard end != range.lowerBound else { return nil }
    let previous = consumed.index(before: end)
    return predicate(consumed[previous]) ? previous : nil
  }
}

extension PredicateConsumer: StatelessCollectionSearcher {
  public typealias Searched = Consumed
  
  public func search(_ searched: Searched, in range: Range<Searched.Index>) -> Range<Searched.Index>? {
    // TODO: Make this reusable
    guard let index = searched[range].firstIndex(where: predicate) else { return nil }
    return index..<searched.index(after: index)
  }
}

extension PredicateConsumer: BackwardCollectionSearcher, StatelessBackwardCollectionSearcher
  where Searched: BidirectionalCollection
{
  public typealias BackwardSearched = Consumed
  
  public func searchBack(_ searched: BackwardSearched, in range: Range<BackwardSearched.Index>) -> Range<BackwardSearched.Index>? {
    // TODO: Make this reusable
    guard let index = searched[range].lastIndex(where: predicate) else { return nil }
    return index..<searched.index(after: index)
  }
}
