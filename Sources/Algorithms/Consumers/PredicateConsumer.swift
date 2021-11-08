public struct PredicateConsumer<Consumed: Collection> where Consumed.SubSequence == Consumed {
  let predicate: (Consumed.Element) -> Bool
}

extension PredicateConsumer: CollectionConsumer {
  public func consuming(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index? {
    let start = index
    guard start != consumed.endIndex && predicate(consumed[start]) else { return nil }
    return consumed.index(after: start)
  }
}

extension PredicateConsumer: BackwardCollectionConsumer where Consumed: BidirectionalCollection {
  public func consumingBack(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index? {
    let end = index
    guard end != consumed.startIndex else { return nil }
    let previous = consumed.index(before: end)
    return predicate(consumed[previous]) ? previous : nil
  }
}

extension PredicateConsumer: StatelessCollectionSearcher {
  public typealias Searched = Consumed
  
  public func search(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>? {
    // TODO: Make this reusable
    guard let index = searched[index...].firstIndex(where: predicate) else { return nil }
    return index..<searched.index(after: index)
  }
}

extension PredicateConsumer: BackwardCollectionSearcher, StatelessBackwardCollectionSearcher
  where Searched: BidirectionalCollection
{
  public func searchBack(_ searched: Consumed, from index: Consumed.Index) -> Range<Consumed.Index>? {
    // TODO: Make this reusable
    guard let index = searched[..<index].lastIndex(where: predicate) else { return nil }
    return index..<searched.index(after: index)
  }
}
