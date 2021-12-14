public protocol CollectionConsumer {
  associatedtype Consumed: Collection
  func consuming(_ consumed: Consumed, in range: Range<Consumed.Index>) -> Consumed.Index?
}

extension CollectionConsumer {
  public func consuming(_ consumed: Consumed) -> Consumed.Index? {
    consuming(consumed, in: consumed.startIndex..<consumed.endIndex)
  }
  
  // TODO: `@discardableResult`?
  /// Returns `true` if the consume was successful.
  public func consume(_ consumed: inout Consumed) -> Bool where Consumed.SubSequence == Consumed {
    guard let index = consuming(consumed) else { return false }
    consumed = consumed[index...]
    return true
  }
}

// MARK: Consuming from the back

public protocol BidirectionalCollectionConsumer: CollectionConsumer where Consumed: BidirectionalCollection {
  func consumingBack(_ consumed: Consumed, in range: Range<Consumed.Index>) -> Consumed.Index?
}

extension BidirectionalCollectionConsumer {
  public func consumingBack(_ consumed: Consumed) -> Consumed.Index? {
    consumingBack(consumed, in: consumed.startIndex..<consumed.endIndex)
  }
  
  public func consumeBack(_ consumed: inout Consumed) -> Bool where Consumed.SubSequence == Consumed {
    guard let index = consumingBack(consumed) else { return false }
    consumed = consumed[..<index]
    return true
  }
}
