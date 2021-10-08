extension Collection {
  func starts<C: CollectionConsumer>(with consumer: C) -> Bool where C.Consumed == Self {
    consumer.consume(self) != nil
  }
}

extension BidirectionalCollection {
  func ends<C: BackwardCollectionConsumer>(with consumer: C) -> Bool where C.Consumed == Self {
    consumer.consumeBack(self) != nil
  }
}

extension Collection where Element: Equatable {
  public func starts<C: Collection>(with prefix: C) -> Bool where C.Element == Element {
    starts(with: SequenceConsumer(pattern: prefix))
  }
}

extension BidirectionalCollection where Element: Equatable {
  public func ends<C: BidirectionalCollection>(with suffix: C) -> Bool where C.Element == Element {
    ends(with: SequenceConsumer(pattern: suffix))
  }
}
