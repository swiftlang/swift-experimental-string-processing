public protocol CollectionConsumer {
  // NOTE: Adding the constraint `where Consumed.SubSequence == Consumed` currently causes
  // compiler errors elsewhere
  associatedtype Consumed: Collection
  func consuming(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index?
}

extension CollectionConsumer {
  public func consuming(_ consumed: Consumed) -> Consumed.Index? {
    consuming(consumed, from: consumed.startIndex)
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

public protocol BackwardCollectionConsumer: CollectionConsumer where Consumed: BidirectionalCollection {
  func consumingBack(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index?
}

extension BackwardCollectionConsumer {
  public func consumingBack(_ consumed: Consumed) -> Consumed.Index? {
    consumingBack(consumed, from: consumed.endIndex)
  }
  
  public func consumeBack(_ consumed: inout Consumed) -> Bool where Consumed.SubSequence == Consumed {
    guard let index = consumingBack(consumed) else { return false }
    consumed = consumed[..<index]
    return true
  }
}
