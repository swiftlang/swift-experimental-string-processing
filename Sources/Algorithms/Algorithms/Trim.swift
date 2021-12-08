extension Collection {
  public func trimmingPrefix<C: CollectionConsumer>(_ consumer: C) -> SubSequence where C.Consumed == SubSequence {
    let start = consumer.consume(self[...]) ?? startIndex
    return self[start...]
  }
}

// FIXME: Restore this once the CI accepts
//extension Collection where SubSequence == Self {
//  public mutating func trimPrefix<C: CollectionConsumer>(_ consumer: C) where C.Consumed == SubSequence {
//    if let start = consumer.consume(self) {
//      self = self[start...]
//    }
//  }
//}

extension RangeReplaceableCollection {
  // NOTE: Disfavored because the `Collection with SubSequence == Self` overload
  // should be preferred whenever both are available
  @_disfavoredOverload
  public mutating func trimPrefix<C: CollectionConsumer>(_ consumer: C) where C.Consumed == SubSequence {
    if let start = consumer.consume(self[...]) {
      removeSubrange(..<start)
    }
  }
}

extension BidirectionalCollection {
  public func trimmingSuffix<C: BackwardCollectionConsumer>(_ consumer: C) -> SubSequence where C.Consumed == SubSequence {
    let end = consumer.consumeBack(self[...]) ?? endIndex
    return self[..<end]
  }
}

// FIXME: Restore this once the CI accepts
//extension BidirectionalCollection where SubSequence == Self {
//  public mutating func trimSuffix<C: BackwardCollectionConsumer>(_ consumer: C) where C.Consumed == SubSequence {
//    if let end = consumer.consumeBack(self) {
//      self = self[..<end]
//    }
//  }
//}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  public mutating func trimSuffix<C: BackwardCollectionConsumer>(_ consumer: C) where C.Consumed == SubSequence {
    if let end = consumer.consumeBack(self[...]) {
      removeSubrange(end...)
    }
  }
}

extension BidirectionalCollection {
  public func trimming<C: CollectionConsumer & BackwardCollectionConsumer>(
    _ consumer: C
  ) -> SubSequence where C.Consumed == SubSequence {
    // NOTE: Might give different results than trimming the suffix before trimming the prefix
    trimmingPrefix(consumer).trimmingSuffix(consumer)
  }
}

//extension BidirectionalCollection where SubSequence == Self {
//  mutating func trim<C: BackwardCollectionConsumer>(_ consumer: C) where C.Consumed == Self {
//    trimPrefix(consumer)
//    trimSuffix(consumer)
//  }
//}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  mutating func trim<C: BackwardCollectionConsumer>(_ consumer: C) where C.Consumed == SubSequence {
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

// Some example overloads that take something other than a consumer

extension Collection where Element: Equatable {
  public func trimmingPrefix<Prefix: Collection>(_ prefix: Prefix) -> SubSequence where Prefix.Element == Element {
    trimmingPrefix(SequenceConsumer(pattern: prefix))
  }
}

extension Collection {
  public func trimmingPrefix(while predicate: @escaping (Element) -> Bool) -> SubSequence {
    let consumer = ManyConsumer(base: PredicateConsumer<SubSequence>(predicate: predicate))
    return trimmingPrefix(consumer)
  }
}

// MARK: Regex

extension Collection where SubSequence == Substring {
  public func trimmingPrefix(_ regex: Regex) -> SubSequence {
    trimmingPrefix(RegexConsumer(regex))
  }
}

extension RangeReplaceableCollection where SubSequence == Substring {
  public mutating func trimPrefix(_ regex: Regex) {
    trimPrefix(RegexConsumer(regex))
  }
}

extension BidirectionalCollection where SubSequence == Substring {
  public func trimmingSuffix(_ regex: Regex) -> SubSequence {
    trimmingSuffix(RegexConsumer(regex))
  }
  
  public func trimming(_ regex: Regex) -> SubSequence {
    let consumer = RegexConsumer(regex)
    return trimmingPrefix(consumer).trimmingSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection, SubSequence == Substring {
  public mutating func trimSuffix(_ regex: Regex) {
    trimSuffix(RegexConsumer(regex))
  }
  
  public mutating func trim(_ regex: Regex) {
    let consumer = RegexConsumer(regex)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension Substring {
  public mutating func trimPrefix(_ regex: Regex) {
    trimPrefix(RegexConsumer(regex))
  }
  
  public mutating func trimSuffix(_ regex: Regex) {
    trimSuffix(RegexConsumer(regex))
  }
  
  public mutating func trim(_ regex: Regex) {
    let consumer = RegexConsumer(regex)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}
