struct PredicateConsumer<Consumed: Collection> {
  let predicate: (Consumed.Element) -> Bool
}

extension PredicateConsumer: CollectionConsumer {
  func consume(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index? {
    let start = index
    guard start != consumed.endIndex && predicate(consumed[start]) else { return nil }
    return consumed.index(after: start)
  }
}

extension PredicateConsumer: BackwardCollectionConsumer where Consumed: BidirectionalCollection {
  func consumeBack(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index? {
    let end = index
    guard end != consumed.startIndex else { return nil }
    let previous = consumed.index(before: end)
    return predicate(consumed[previous]) ? previous : nil
  }
}

//extension PredicateConsumer: BidirectionalCollectionConsumer where Consumed: BidirectionalCollection {}
