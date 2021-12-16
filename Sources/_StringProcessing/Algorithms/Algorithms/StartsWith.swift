// MARK: `CollectionConsumer` algorithms

extension Collection {
  public func starts<C: CollectionConsumer>(with consumer: C) -> Bool
    where C.Consumed == SubSequence
  {
    consumer.consuming(self[...]) != nil
  }
}

extension BidirectionalCollection {
  public func ends<C: BidirectionalCollectionConsumer>(with consumer: C) -> Bool
    where C.Consumed == SubSequence
  {
    consumer.consumingBack(self[...]) != nil
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  public func starts<C: Collection>(with prefix: C) -> Bool
    where C.Element == Element
  {
    starts(with: FixedPatternConsumer(pattern: prefix))
  }
}

extension BidirectionalCollection where Element: Equatable {
  public func ends<C: BidirectionalCollection>(with suffix: C) -> Bool
    where C.Element == Element
  {
    ends(with: FixedPatternConsumer(pattern: suffix))
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func starts<Capture>(with regex: Regex<Capture>) -> Bool {
    starts(with: RegexConsumer(regex))
  }
  
  public func ends<Capture>(with regex: Regex<Capture>) -> Bool {
    ends(with: RegexConsumer(regex))
  }
}
