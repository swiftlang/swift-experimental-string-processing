extension Collection {
  public func starts<C: CollectionConsumer>(with consumer: C) -> Bool where C.Consumed == SubSequence {
    consumer.consume(self[...]) != nil
  }
}

extension BidirectionalCollection {
  public func ends<C: BackwardCollectionConsumer>(with consumer: C) -> Bool where C.Consumed == SubSequence {
    consumer.consumeBack(self[...]) != nil
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

// MARK: Regex

extension Collection where SubSequence == Substring {
  public func starts(with regex: Regex) -> Bool {
    starts(with: RegexConsumer(regex: regex))
  }
}

extension BidirectionalCollection where SubSequence == Substring {
  public func ends(with regex: Regex) -> Bool {
    ends(with: RegexConsumer(regex: regex))
  }
}
