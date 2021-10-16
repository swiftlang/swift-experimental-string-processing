extension Collection {
  func trimmingPrefix<C: CollectionConsumer>(_ consumer: C) -> SubSequence where C.Consumed == Self {
    let start = consumer.consume(self) ?? startIndex
    return self[start...]
  }
}

extension Collection where SubSequence == Self {
  mutating func trimPrefix<C: CollectionConsumer>(_ consumer: C) where C.Consumed == Self {
    if let start = consumer.consume(self) {
      self = self[start...]
    }
  }
}

extension RangeReplaceableCollection {
  mutating func trimPrefix<C: CollectionConsumer>(_ consumer: C) where C.Consumed == Self {
    let start = consumer.consume(self) ?? startIndex
    self.removeSubrange(..<start)
  }
}

extension BidirectionalCollection {
  func trimmingSuffix<C: BackwardCollectionConsumer>(_ consumer: C) -> SubSequence where C.Consumed == Self {
    let end = consumer.consume(self) ?? endIndex
    return self[..<end]
  }
}

extension BidirectionalCollection where SubSequence == Self {
  mutating func trimSuffix<C: BackwardCollectionConsumer>(_ consumer: C) where C.Consumed == Self {
    if let end = consumer.consume(self) {
      self = self[..<end]
    }
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  mutating func trimSuffix<C: BackwardCollectionConsumer>(_ consumer: C) where C.Consumed == Self {
    let end = consumer.consume(self) ?? endIndex
    self.removeSubrange(end...)
  }
}

extension BidirectionalCollection {
  func trimming<C: BidirectionalCollectionConsumer>(_ consumer: C) -> SubSequence where C.Consumed == Self {
    let start = consumer.consume(self) ?? startIndex
    let end = consumer.consumeBack(self, subrange: start..<endIndex) ?? endIndex
    return self[start..<end]
  }
}

extension BidirectionalCollection where SubSequence == Self {
  mutating func trim<C: BidirectionalCollectionConsumer>(_ consumer: C) where C.Consumed == Self {
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  mutating func trim<C: BidirectionalCollectionConsumer>(_ consumer: C) where C.Consumed == Self {
    let end = consumer.consume(self) ?? endIndex
    removeSubrange(end...)
    let start = consumer.consume(self) ?? startIndex
    removeSubrange(..<start)
  }
}

// Some example overloads that take something other than a consumer

extension Collection where Element: Equatable {
  public func trimmingPrefix<Prefix: Collection>(_ prefix: Prefix) -> SubSequence where Prefix.Element == Element {
    trimmingPrefix(SequenceConsumer(pattern: prefix))
  }
}

extension BidirectionalCollection {
  public func trimming(while predicate: @escaping (Element) -> Bool) -> SubSequence {
    let consumer = ManyConsumer(base: PredicateConsumer<Self>(predicate: predicate))
    return self.trimming(consumer)
  }
}
