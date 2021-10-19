public protocol CollectionConsumer {
  associatedtype Consumed: Collection
  func consume(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index?
}

extension CollectionConsumer {
  public func consume(_ consumed: Consumed) -> Consumed.Index? {
    consume(consumed, from: consumed.startIndex)
  }
}

// MARK: Consuming from the back

public protocol BackwardCollectionConsumer: CollectionConsumer where Consumed: BidirectionalCollection {
  func consumeBack(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index?
}

extension BackwardCollectionConsumer {
  public func consumeBack(_ consumed: Consumed) -> Consumed.Index? {
    consumeBack(consumed, from: consumed.endIndex)
  }
}
