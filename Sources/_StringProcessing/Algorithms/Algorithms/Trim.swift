//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// MARK: `CollectionConsumer` algorithms

extension Collection {
  public func trimmingPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence where Consumer.Consumed == Self {
    let start = consumer.consuming(self) ?? startIndex
    return self[start...]
  }
}

extension Collection where SubSequence == Self {
  public mutating func trimPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    _ = consumer.consume(&self)
  }
}

extension RangeReplaceableCollection {
  // NOTE: Disfavored because the `Collection with SubSequence == Self` overload
  // should be preferred whenever both are available
  @_disfavoredOverload
  public mutating func trimPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    if let start = consumer.consuming(self) {
      removeSubrange(..<start)
    }
  }
}

extension BidirectionalCollection {
  public func trimmingSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence
    where Consumer.Consumed == Self
  {
    let end = consumer.consumingBack(self) ?? endIndex
    return self[..<end]
  }
  
  public func trimming<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence where Consumer.Consumed == Self {
    // NOTE: Might give different results than trimming the suffix before
    // trimming the prefix
    let start = consumer.consuming(self) ?? startIndex
    let end = consumer.consumingBack(self) ?? endIndex
    let actualEnd = end < start ? start : end
    return self[start..<actualEnd]
  }
}

extension BidirectionalCollection where SubSequence == Self {
  public mutating func trimSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == SubSequence
  {
    _ = consumer.consumeBack(&self)
  }

  mutating func trim<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  public mutating func trimSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self
  {
    if let end = consumer.consumingBack(self) {
      removeSubrange(end...)
    }
  }
  
  @_disfavoredOverload
  mutating func trim<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    trimSuffix(consumer)
    trimPrefix(consumer)
  }
}

// MARK: Predicate algorithms

extension Collection {
  // TODO: Non-escaping and throwing
  public func trimmingPrefix(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    trimmingPrefix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension Collection where SubSequence == Self {
  public mutating func trimPrefix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimPrefix(ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }
}

extension RangeReplaceableCollection {
  @_disfavoredOverload
  public mutating func trimPrefix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimPrefix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension BidirectionalCollection {
  public func trimmingSuffix(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    trimmingSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  public func trimming(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    trimming(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension BidirectionalCollection where SubSequence == Self {
  public mutating func trimSuffix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimSuffix(ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }

  public mutating func trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate))
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  public mutating func trimSuffix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  @_disfavoredOverload
  public mutating func trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(
      base: PredicateConsumer<Self>(predicate: predicate))
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

extension Collection where SubSequence == Self, Element: Equatable {
  public mutating func trimPrefix<Prefix: Collection>(
    _ prefix: Prefix
  ) where Prefix.Element == Element {
    trimPrefix(FixedPatternConsumer<SubSequence, Prefix>(pattern: prefix))
  }
}

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
    trimming(FixedPatternConsumer(pattern: pattern))
  }
}

extension BidirectionalCollection
  where SubSequence == Self, Element: Equatable
{
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

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, Element: Equatable
{
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
    let consumer = FixedPatternConsumer<Self, Pattern>(pattern: pattern)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  public func trimmingPrefix<Capture>(_ regex: Regex<Capture>) -> SubSequence {
    trimmingPrefix(RegexConsumer(regex))
  }
  
  public func trimmingSuffix<Capture>(_ regex: Regex<Capture>) -> SubSequence {
    trimmingSuffix(RegexConsumer(regex))
  }
  
  public func trimming<Capture>(_ regex: Regex<Capture>) -> SubSequence {
    trimming(RegexConsumer(regex))
  }
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, SubSequence == Substring
{
  public mutating func trimPrefix<Capture>(_ regex: Regex<Capture>) {
    trimPrefix(RegexConsumer(regex))
  }
  
  public mutating func trimSuffix<Capture>(_ regex: Regex<Capture>) {
    trimSuffix(RegexConsumer(regex))
  }
  
  public mutating func trim<Capture>(_ regex: Regex<Capture>) {
    let consumer = RegexConsumer<Self>(regex)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension Substring {
  public mutating func trimPrefix<Capture>(_ regex: Regex<Capture>) {
    trimPrefix(RegexConsumer(regex))
  }
  
  public mutating func trimSuffix<Capture>(_ regex: Regex<Capture>) {
    trimSuffix(RegexConsumer(regex))
  }
  
  public mutating func trim<Capture>(_ regex: Regex<Capture>) {
    let consumer = RegexConsumer<Self>(regex)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}
