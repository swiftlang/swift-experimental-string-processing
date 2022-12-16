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

// MARK: Regex algorithms

extension BidirectionalCollection where SubSequence == Substring {
  /// Returns a new collection of the same type by removing `prefix` from the
  /// start.
  /// - Parameter prefix: The collection to remove from this collection.
  /// - Returns: A collection containing the elements that does not match
  /// `prefix` from the start.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public func trimmingPrefix(_ regex: some RegexComponent) -> SubSequence {
    let s = self[...]
    guard let prefix = try? regex.regex.prefixMatch(in: s) else {
      return s
    }
    return s[prefix.range.upperBound...]
  }
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, SubSequence == Substring
{
  /// Removes the initial elements that matches the given regex.
  /// - Parameter regex: The regex to remove from this collection.
  @_disfavoredOverload
  @available(SwiftStdlib 5.7, *)
  public mutating func trimPrefix(_ regex: some RegexComponent) {
    let s = self[...]
    guard let prefix = try? regex.regex.prefixMatch(in: s) else {
      return
    }
    self.removeSubrange(prefix.range)
  }
}

