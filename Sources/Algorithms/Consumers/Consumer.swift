public protocol CollectionConsumer {
  associatedtype Consumed: Collection
  func consume(_ consumed: Consumed, subrange: Range<Consumed.Index>) -> Consumed.Index?
}

extension CollectionConsumer {
  public func consume(_ consumed: Consumed) -> Consumed.Index? {
    consume(consumed, subrange: consumed.startIndex..<consumed.endIndex)
  }
}

// MARK: Consuming from the back

public protocol BackwardCollectionConsumer: CollectionConsumer where Consumed: BidirectionalCollection {
  func consumeBack(_ consumed: Consumed, subrange: Range<Consumed.Index>) -> Consumed.Index?
}

extension BackwardCollectionConsumer {
  public func consumeBack(_ consumed: Consumed) -> Consumed.Index? {
    consumeBack(consumed, subrange: consumed.startIndex..<consumed.endIndex)
  }
}

public protocol BidirectionalCollectionConsumer: BackwardCollectionConsumer {}
