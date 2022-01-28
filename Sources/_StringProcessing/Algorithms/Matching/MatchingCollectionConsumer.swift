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

public protocol MatchingCollectionConsumer: CollectionConsumer {
  associatedtype Match
  func matchingConsuming(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> (upperBound: Consumed.Index, match: Match)?
}

extension MatchingCollectionConsumer {
  public func consuming(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index? {
    matchingConsuming(consumed, in: range)?.upperBound
  }
}

// MARK: Consuming from the back

public protocol BidirectionalMatchingCollectionConsumer:
  MatchingCollectionConsumer, BidirectionalCollectionConsumer
{
  func matchingConsumingBack(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> (lowerBound: Consumed.Index, match: Match)?
}

extension BidirectionalMatchingCollectionConsumer {
  public func consumingBack(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index? {
    matchingConsumingBack(consumed, in: range)?.lowerBound
  }
}

