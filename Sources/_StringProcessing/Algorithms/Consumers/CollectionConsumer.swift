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

protocol CollectionConsumer {
  associatedtype Consumed: Collection
  func consuming(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index?
}

extension CollectionConsumer {
  func consuming(_ consumed: Consumed) -> Consumed.Index? {
    consuming(consumed, in: consumed.startIndex..<consumed.endIndex)
  }
  
  // TODO: `@discardableResult`?
  /// Returns `true` if the consume was successful.
  func consume(_ consumed: inout Consumed) -> Bool
    where Consumed.SubSequence == Consumed
  {
    guard let index = consuming(consumed) else { return false }
    consumed = consumed[index...]
    return true
  }
}

// MARK: Consuming from the back

protocol BidirectionalCollectionConsumer: CollectionConsumer
  where Consumed: BidirectionalCollection
{
  func consumingBack(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index?
}

extension BidirectionalCollectionConsumer {
  func consumingBack(_ consumed: Consumed) -> Consumed.Index? {
    consumingBack(consumed, in: consumed.startIndex..<consumed.endIndex)
  }
  
  func consumeBack(_ consumed: inout Consumed) -> Bool
    where Consumed.SubSequence == Consumed
  {
    guard let index = consumingBack(consumed) else { return false }
    consumed = consumed[..<index]
    return true
  }
}
