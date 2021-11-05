// MARK: `CollectionConsumer` algorithms

extension Collection {
  public func trimmingPrefix<Consumer: CollectionConsumer>(_ consumer: Consumer) -> SubSequence where Consumer.Consumed == SubSequence {
    let start = consumer.consuming(self[...]) ?? startIndex
    return self[start...]
  }
}

extension Collection where SubSequence == Self {
  public mutating func trimPrefix<Consumer: CollectionConsumer>(_ consumer: Consumer) where Consumer.Consumed == SubSequence {
    _ = consumer.consume(&self)
  }
}

extension RangeReplaceableCollection {
  // NOTE: Disfavored because the `Collection with SubSequence == Self` overload
  // should be preferred whenever both are available
  @_disfavoredOverload
  public mutating func trimPrefix<Consumer: CollectionConsumer>(_ consumer: Consumer) where Consumer.Consumed == SubSequence {
    if let start = consumer.consuming(self[...]) {
      removeSubrange(..<start)
    }
  }
}

extension BidirectionalCollection {
  public func trimmingSuffix<Consumer: BackwardCollectionConsumer>(_ consumer: Consumer) -> SubSequence where Consumer.Consumed == SubSequence {
    let end = consumer.consumingBack(self[...]) ?? endIndex
    return self[..<end]
  }
  
  public func trimming<Consumer: BackwardCollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence where Consumer.Consumed == SubSequence {
    // NOTE: Might give different results than trimming the suffix before trimming the prefix
    trimmingPrefix(consumer).trimmingSuffix(consumer)
  }
}

extension BidirectionalCollection where SubSequence == Self {
  public mutating func trimSuffix<Consumer: BackwardCollectionConsumer>(_ consumer: Consumer) where Consumer.Consumed == SubSequence {
    _ = consumer.consumeBack(&self)
  }

  mutating func trim<Consumer: BackwardCollectionConsumer>(_ consumer: Consumer) where Consumer.Consumed == Self {
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  public mutating func trimSuffix<Consumer: BackwardCollectionConsumer>(_ consumer: Consumer) where Consumer.Consumed == SubSequence {
    if let end = consumer.consumingBack(self[...]) {
      removeSubrange(end...)
    }
  }
  
  @_disfavoredOverload
  mutating func trim<Consumer: BackwardCollectionConsumer>(_ consumer: Consumer) where Consumer.Consumed == SubSequence {
    trimSuffix(consumer)
    trimPrefix(consumer)
  }
}

// MARK: Predicate algorithms

extension Collection {
  // TODO: Non-escaping and throwing
  public func trimmingPrefix(while predicate: @escaping (Element) -> Bool) -> SubSequence {
    trimmingPrefix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension Collection where SubSequence == Self {
  public mutating func trimPrefix(while predicate: @escaping (Element) -> Bool) {
    trimPrefix(ManyConsumer(base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }
}

extension RangeReplaceableCollection {
  @_disfavoredOverload
  public mutating func trimPrefix(while predicate: @escaping (Element) -> Bool) {
    trimPrefix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension BidirectionalCollection {
  public func trimmingSuffix(while predicate: @escaping (Element) -> Bool) -> SubSequence {
    trimmingSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  public func trimming(while predicate: @escaping (Element) -> Bool) -> SubSequence {
    let consumer = ManyConsumer(base: PredicateConsumer<SubSequence>(predicate: predicate))
    return trimmingPrefix(consumer).trimmingSuffix(consumer)
  }
}

extension BidirectionalCollection where SubSequence == Self {
  public mutating func trimSuffix(while predicate: @escaping (Element) -> Bool) {
    trimSuffix(ManyConsumer(base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }

  public mutating func trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(base: PredicateConsumer<SubSequence>(predicate: predicate))
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  public mutating func trimSuffix(while predicate: @escaping (Element) -> Bool) {
    trimSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  @_disfavoredOverload
  public mutating func trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(base: PredicateConsumer<SubSequence>(predicate: predicate))
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  public func trimmingPrefix<Prefix: Collection>(
    _ prefix: Prefix
  ) -> SubSequence where Prefix.Element == Element {
    trimmingPrefix(FixedPatternConsumer(pattern: prefix))
  }
}

// FIXME: Restore this once the CI accepts this constraint
//extension Collection where SubSequence == Self, Element: Equatable {
//  public mutating func trimPrefix<Prefix: Collection>(
//    _ prefix: Prefix
//  ) where Prefix.Element == Element {
//    trimPrefix(FixedPatternConsumer<SubSequence, Prefix>(pattern: prefix))
//  }
//}

extension RangeReplaceableCollection where Element: Equatable {
  @_disfavoredOverload
  public mutating func trimPrefix<Prefix: Collection>(
    _ prefix: Prefix
  ) where Prefix.Element == Element {
    trimPrefix(FixedPatternConsumer(pattern: prefix))
  }
}

extension BidirectionalCollection where Element: Equatable {
  public func trimmingSuffix<Suffix: BidirectionalCollection>(
    _ suffix: Suffix
  ) -> SubSequence where Suffix.Element == Element {
    trimmingSuffix(FixedPatternConsumer(pattern: suffix))
  }
  
  public func trimming<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) -> SubSequence where Pattern.Element == Element {
    let consumer = FixedPatternConsumer<SubSequence, Pattern>(pattern: pattern)
    return trimmingPrefix(consumer).trimmingSuffix(consumer)
  }
}

extension BidirectionalCollection where SubSequence == Self, Element: Equatable {
  public mutating func trimSuffix<Suffix: BidirectionalCollection>(
    _ suffix: Suffix
  ) where Suffix.Element == Element {
    trimSuffix(FixedPatternConsumer<SubSequence, Suffix>(pattern: suffix))
  }
  
  public mutating func trim<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) where Pattern.Element == Element {
    let consumer = FixedPatternConsumer<SubSequence, Pattern>(pattern: pattern)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection, Element: Equatable {
  @_disfavoredOverload
  public mutating func trimSuffix<Suffix: BidirectionalCollection>(
    _ prefix: Suffix
  ) where Suffix.Element == Element {
    trimSuffix(FixedPatternConsumer(pattern: prefix))
  }
  
  @_disfavoredOverload
  public mutating func trim<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) where Pattern.Element == Element {
    let consumer = FixedPatternConsumer<SubSequence, Pattern>(pattern: pattern)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func trimmingPrefix(_ regex: Regex) -> SubSequence {
    trimmingPrefix(RegexConsumer(regex: regex))
  }
  
  public func trimmingSuffix(_ regex: Regex) -> SubSequence {
    trimmingSuffix(RegexConsumer(regex))
  }
  
  public func trimming(_ regex: Regex) -> SubSequence {
    let consumer = RegexConsumer(regex)
    return trimmingPrefix(consumer).trimmingSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection, SubSequence == Substring {
  public mutating func trimPrefix(_ regex: Regex) {
    trimPrefix(RegexConsumer(regex: regex))
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
