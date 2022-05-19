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
  func _trimmingPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence where Consumer.Consumed == Self {
    let start = consumer.consuming(self) ?? startIndex
    return self[start...]
  }
}

extension Collection where SubSequence == Self {
  mutating func _trimPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    _ = consumer.consume(&self)
  }
}

extension RangeReplaceableCollection {
  // NOTE: Disfavored because the `Collection with SubSequence == Self` overload
  // should be preferred whenever both are available
  @_disfavoredOverload
  mutating func _trimPrefix<Consumer: CollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    if let start = consumer.consuming(self) {
      removeSubrange(..<start)
    }
  }
}

extension BidirectionalCollection {
  func _trimmingSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) -> SubSequence
    where Consumer.Consumed == Self
  {
    let end = consumer.consumingBack(self) ?? endIndex
    return self[..<end]
  }
  
  func _trimming<Consumer: BidirectionalCollectionConsumer>(
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
  mutating func _trimSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == SubSequence
  {
    _ = consumer.consumeBack(&self)
  }

  mutating func _trim<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    _trimPrefix(consumer)
    _trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  mutating func _trimSuffix<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self
  {
    if let end = consumer.consumingBack(self) {
      removeSubrange(end...)
    }
  }
  
  @_disfavoredOverload
  mutating func _trim<Consumer: BidirectionalCollectionConsumer>(
    _ consumer: Consumer
  ) where Consumer.Consumed == Self {
    _trimSuffix(consumer)
    _trimPrefix(consumer)
  }
}

// MARK: Predicate algorithms

extension Collection {
  fileprivate func endOfPrefix(while predicate: (Element) throws -> Bool) rethrows -> Index {
    try firstIndex(where: { try !predicate($0) }) ?? endIndex
  }

  @available(SwiftStdlib 5.7, *)
  public func trimmingPrefix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    let end = try endOfPrefix(while: predicate)
    return self[end...]
  }
}

extension Collection where SubSequence == Self {
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix(
    while predicate: (Element) throws -> Bool
  ) throws {
    let end = try endOfPrefix(while: predicate)
    self = self[end...]
  }
}

extension RangeReplaceableCollection {
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    let end = try endOfPrefix(while: predicate)
    removeSubrange(startIndex..<end)
  }
}

extension BidirectionalCollection {
  func _trimmingSuffix(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    _trimmingSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  func _trimming(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    _trimming(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
}

extension BidirectionalCollection where SubSequence == Self {
  mutating func _trimSuffix(
    while predicate: @escaping (Element) -> Bool
  ) {
    _trimSuffix(ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate)))
  }

  mutating func _trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(
      base: PredicateConsumer<SubSequence>(predicate: predicate))
    _trimPrefix(consumer)
    _trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
  @_disfavoredOverload
  mutating func _trimSuffix(
    while predicate: @escaping (Element) -> Bool
  ) {
    _trimSuffix(ManyConsumer(base: PredicateConsumer(predicate: predicate)))
  }
  
  @_disfavoredOverload
  mutating func _trim(while predicate: @escaping (Element) -> Bool) {
    let consumer = ManyConsumer(
      base: PredicateConsumer<Self>(predicate: predicate))
    _trimPrefix(consumer)
    _trimSuffix(consumer)
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
  public func trimmingPrefix<Prefix: Sequence>(
    _ prefix: Prefix
  ) -> SubSequence where Prefix.Element == Element {
    _trimmingPrefix(FixedPatternConsumer(pattern: prefix))
  }
}

extension Collection where SubSequence == Self, Element: Equatable {
  /// Removes the initial elements that satisfy the given predicate from the
  /// start of the sequence.
  /// - Parameter predicate: A closure that takes an element of the sequence
  /// as its argument and returns a Boolean value indicating whether the
  /// element should be removed from the collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<Prefix: Sequence>(
    _ prefix: Prefix
  ) where Prefix.Element == Element {
    _trimPrefix(FixedPatternConsumer<SubSequence, Prefix>(pattern: prefix))
  }
}

extension RangeReplaceableCollection where Element: Equatable {
  /// Removes the initial elements that satisfy the given predicate from the
  /// start of the sequence.
  /// - Parameter predicate: A closure that takes an element of the sequence
  /// as its argument and returns a Boolean value indicating whether the
  /// element should be removed from the collection.
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<Prefix: Sequence>(
    _ prefix: Prefix
  ) where Prefix.Element == Element {
    _trimPrefix(FixedPatternConsumer(pattern: prefix))
  }
}

extension BidirectionalCollection where Element: Equatable {
  func _trimmingSuffix<Suffix: BidirectionalCollection>(
    _ suffix: Suffix
  ) -> SubSequence where Suffix.Element == Element {
    _trimmingSuffix(FixedPatternConsumer(pattern: suffix))
  }
  
  func _trimming<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) -> SubSequence where Pattern.Element == Element {
    _trimming(FixedPatternConsumer(pattern: pattern))
  }
}

extension BidirectionalCollection
  where SubSequence == Self, Element: Equatable
{
  mutating func _trimSuffix<Suffix: BidirectionalCollection>(
    _ suffix: Suffix
  ) where Suffix.Element == Element {
    _trimSuffix(FixedPatternConsumer<SubSequence, Suffix>(pattern: suffix))
  }
  
  mutating func _trim<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) where Pattern.Element == Element {
    let consumer = FixedPatternConsumer<SubSequence, Pattern>(pattern: pattern)
    _trimPrefix(consumer)
    _trimSuffix(consumer)
  }
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, Element: Equatable
{
  @_disfavoredOverload
  mutating func _trimSuffix<Suffix: BidirectionalCollection>(
    _ prefix: Suffix
  ) where Suffix.Element == Element {
    _trimSuffix(FixedPatternConsumer(pattern: prefix))
  }
  
  @_disfavoredOverload
  mutating func _trim<Pattern: BidirectionalCollection>(
    _ pattern: Pattern
  ) where Pattern.Element == Element {
    let consumer = FixedPatternConsumer<Self, Pattern>(pattern: pattern)
    _trimPrefix(consumer)
    _trimSuffix(consumer)
  }
}

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  /// Returns a new collection of the same type by removing `prefix` from the
  /// start.
  /// - Parameter prefix: The collection to remove from this collection.
  /// - Returns: A collection containing the elements that does not match
  /// `prefix` from the start.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public func trimmingPrefix<R: RegexComponent>(_ regex: R) -> SubSequence {
    _trimmingPrefix(RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  func _trimmingSuffix<R: RegexComponent>(_ regex: R) -> SubSequence {
    _trimmingSuffix(RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  func _trimming<R: RegexComponent>(_ regex: R) -> SubSequence {
    _trimming(RegexConsumer(regex))
  }
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, SubSequence == Substring
{
  /// Removes the initial elements that matches the given regex.
  /// - Parameter regex: The regex to remove from this collection.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix<R: RegexComponent>(_ regex: R) {
    _trimPrefix(RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  mutating func _trimSuffix<R: RegexComponent>(_ regex: R) {
    _trimSuffix(RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  mutating func _trim<R: RegexComponent>(_ regex: R) {
    let consumer = RegexConsumer<R, Self>(regex)
    _trimPrefix(consumer)
    _trimSuffix(consumer)
  }
}

extension Substring {
  @available(SwiftStdlib 5.7, *)
  mutating func _trimPrefix<R: RegexComponent>(_ regex: R) {
    _trimPrefix(RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  mutating func _trimSuffix<R: RegexComponent>(_ regex: R) {
    _trimSuffix(RegexConsumer(regex))
  }

  @available(SwiftStdlib 5.7, *)
  mutating func _trim<R: RegexComponent>(_ regex: R) {
    let consumer = RegexConsumer<R, Self>(regex)
    _trimPrefix(consumer)
    _trimSuffix(consumer)
  }
}
