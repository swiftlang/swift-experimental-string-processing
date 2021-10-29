struct PredicateConsumer<Consumed: Collection> {
  let predicate: (Consumed.Element) -> Bool
}

extension PredicateConsumer: CollectionConsumer {
  func consume(_ consumed: Consumed, subrange: Range<Consumed.Index>) -> Consumed.Index? {
    let start = subrange.lowerBound
    guard start != subrange.upperBound && predicate(consumed[start]) else { return nil }
    return consumed.index(after: start)
  }
}

extension PredicateConsumer: BackwardCollectionConsumer where Consumed: BidirectionalCollection {
  func consumeBack(_ consumed: Consumed, subrange: Range<Consumed.Index>) -> Consumed.Index? {
    let end = subrange.upperBound
    guard end != subrange.lowerBound else { return nil }
    let previous = consumed.index(before: end)
    return predicate(consumed[previous]) ? previous : nil
  }
}

extension PredicateConsumer: BidirectionalCollectionConsumer where Consumed: BidirectionalCollection {}
