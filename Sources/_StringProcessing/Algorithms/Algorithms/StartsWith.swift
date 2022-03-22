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
  public func starts<R: RegexComponent>(with regex: R) -> Bool {
    starts(with: RegexConsumer(regex))
  }
  
  public func ends<R: RegexComponent>(with regex: R) -> Bool {
    ends(with: RegexConsumer(regex))
  }
}
