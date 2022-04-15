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
  func trimmingPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence where Consumer.Consumed == Self {
    let start = consumer.consuming(self) ?? startIndex
    return self[start...]
  }
}

extension Collection where SubSequence == Self {
  mutating func trimPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    _ = consumer.consume(&self)
  }
}

extension RangeReplaceableCollection {
  // NOTE: Disfavored because the `Collection with SubSequence == Self` overload
  // should be preferred whenever both are available
  @_disfavoredOverload
  mutating func trimPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    if let start = consumer.consuming(self) {
      removeSubrange(..<start)
    }
  }
}

extension BidirectionalCollection {
  func trimmingSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence
    where Consumer.Consumed == Self
  {
    let end = consumer.consumingBack(self) ?? endIndex
    return self[..<end]
  }
  
  func trimming<Consumer: BidirectionalCollectionConsumer>(
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
  mutating func trimSuffix<Consumer: BidirectionalCollectionConsumer>(
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
  mutating func trimSuffix<Consumer: BidirectionalCollectionConsumer>(
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
  func trimmingPrefix(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    trimmingPrefix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension Collection where SubSequence == Self {
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimPrefix(ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }
}

extension RangeReplaceableCollection {
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimPrefix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension BidirectionalCollection {
  func trimmingSuffix(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    trimmingSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  func trimming(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    trimming(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension BidirectionalCollection where SubSequence == Self {
  mutating func trimSuffix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimSuffix(ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }

  mutating func trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate))
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  mutating func trimSuffix(
    while predicate: @escaping (Element) -> Bool
  ) {
    trimSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  @_disfavoredOverload
  mutating func trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(
      base: PredicateConsumer<Self>(predicate: predicate))
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

// MARK: Fixed pattern algorithms

extension Collection where Element: Equatable {
  /// Returns a new collection of the same type by removing initial elements
  /// that satisfy the given predicate from the start.
  /// - Parameter predicate: A closure that takes an element of the sequence
  /// as its argument and returns a Boolean value indicating whether the
  /// element should be removed from the collection.
  /// - Returns: A collection containing the elements of the collection that are
  ///  not removed by `predicate`.
  @available(SwiftStdlib 5.7, *)
  public func trimmingPrefix<Prefix: Collection>(
    _ prefix: Prefix
  ) -> SubSequence where Prefix.Element == Element {
    trimmingPrefix(FixedPatternConsumer(pattern: prefix))
  }
}

extension Collection where SubSequence == Self, Element: Equatable {
  /// Removes the initial elements that satisfy the given predicate from the
  /// start of the sequence.
  /// - Parameter predicate: A closure that takes an element of the sequence
  /// as its argument and returns a Boolean value indicating whether the
  /// element should be removed from the collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<Prefix: Collection>(
    _ prefix: Prefix
  ) where Prefix.Element == Element {
    trimPrefix(FixedPatternConsumer<SubSequence, Prefix>(pattern: prefix))
  }
}

extension RangeReplaceableCollection where Element: Equatable {
  @_disfavoredOverload
  /// Removes the initial elements that satisfy the given predicate from the
  /// start of the sequence.
  /// - Parameter predicate: A closure that takes an element of the sequence
  /// as its argument and returns a Boolean value indicating whether the
  /// element should be removed from the collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<Prefix: Collection>(
    _ prefix: Prefix
  ) where Prefix.Element == Element {
    trimPrefix(FixedPatternConsumer(pattern: prefix))
  }
}

extension BidirectionalCollection where Element: Equatable {
  func trimmingSuffix<Suffix: BidirectionalCollection>(
    _ suffix: Suffix
  ) -> SubSequence where Suffix.Element == Element {
    trimmingSuffix(FixedPatternConsumer(pattern: suffix))
  }
  
  func trimming<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) -> SubSequence where Pattern.Element == Element {
    trimming(FixedPatternConsumer(pattern: pattern))
  }
}

extension BidirectionalCollection
  where SubSequence == Self, Element: Equatable
{
  mutating func trimSuffix<Suffix: BidirectionalCollection>(
    _ suffix: Suffix
  ) where Suffix.Element == Element {
    trimSuffix(FixedPatternConsumer<SubSequence, Suffix>(pattern: suffix))
  }
  
  mutating func trim<Pattern: BidirectionalCollection>(
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
  mutating func trimSuffix<Suffix: BidirectionalCollection>(
    _ prefix: Suffix
  ) where Suffix.Element == Element {
    trimSuffix(FixedPatternConsumer(pattern: prefix))
  }
  
  @_disfavoredOverload
  mutating func trim<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) where Pattern.Element == Element {
    let consumer = FixedPatternConsumer<Self, Pattern>(pattern: pattern)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  /// Returns a new collection of the same type by removing `prefix` from the
  /// start.
  /// - Parameter prefix: The collection to remove from this collection.
  /// - Returns: A collection containing the elements that does not match
  /// `prefix` from the start.
  @available(SwiftStdlib 5.7, *)
  public func trimmingPrefix<R: RegexComponent>(_ regex: R) -> SubSequence {
    trimmingPrefix(RegexConsumer(regex))
  }
  
  func trimmingSuffix<R: RegexComponent>(_ regex: R) -> SubSequence {
    trimmingSuffix(RegexConsumer(regex))
  }
  
  func trimming<R: RegexComponent>(_ regex: R) -> SubSequence {
    trimming(RegexConsumer(regex))
  }
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, SubSequence == Substring
{
  /// Removes the initial elements that matches the given regex.
  /// - Parameter regex: The regex to remove from this collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<R: RegexComponent>(_ regex: R) {
    trimPrefix(RegexConsumer(regex))
  }
  
  mutating func trimSuffix<R: RegexComponent>(_ regex: R) {
    trimSuffix(RegexConsumer(regex))
  }
  
  mutating func trim<R: RegexComponent>(_ regex: R) {
    let consumer = RegexConsumer<R, Self>(regex)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}

extension Substring {
  mutating func trimPrefix<R: RegexComponent>(_ regex: R) {
    trimPrefix(RegexConsumer(regex))
  }
  
  mutating func trimSuffix<R: RegexComponent>(_ regex: R) {
    trimSuffix(RegexConsumer(regex))
  }
  
  mutating func trim<R: RegexComponent>(_ regex: R) {
    let consumer = RegexConsumer<R, Self>(regex)
    trimPrefix(consumer)
    trimSuffix(consumer)
  }
}
