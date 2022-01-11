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

struct ManyConsumer<Base: CollectionConsumer> {
  let base: Base
}

extension ManyConsumer: CollectionConsumer {
  typealias Consumed = Base.Consumed
  
  func consuming(
    _ consumed: Base.Consumed,
    in range: Range<Consumed.Index>
  ) -> Base.Consumed.Index? {
    var result = range.lowerBound
    while let index = base.consuming(consumed, in: result..<range.upperBound),
            index != result {
      result = index
    }
    return result
  }
}

extension ManyConsumer: BidirectionalCollectionConsumer
  where Base: BidirectionalCollectionConsumer
{
  func consumingBack(
    _ consumed: Base.Consumed,
    in range: Range<Consumed.Index>
  ) -> Base.Consumed.Index? {
    var result = range.upperBound
    while let index = base.consumingBack(
      consumed,
      in: range.lowerBound..<result), index != result {
      result = index
    }
    return result
  }
}
