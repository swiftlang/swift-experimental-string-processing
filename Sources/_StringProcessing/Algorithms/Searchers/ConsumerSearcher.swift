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

/// A collection searcher that naively searches the input by repeatedly trying to consume it using the underlying consumer.
struct ConsumerSearcher<Consumer: CollectionConsumer> {
  let consumer: Consumer
}

extension ConsumerSearcher: StatelessCollectionSearcher {
  typealias Searched = Consumer.Consumed
  
  func search(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    var start = range.lowerBound
    while true {
      if let end = consumer.consuming(searched, in: start..<range.upperBound) {
        return start..<end
      } else if start == range.upperBound {
        return nil
      } else {
        searched.formIndex(after: &start)
      }
    }
  }
}

extension ConsumerSearcher: BackwardCollectionSearcher,
                            StatelessBackwardCollectionSearcher
  where Consumer: BidirectionalCollectionConsumer
{
  typealias BackwardSearched = Consumer.Consumed
  
  func searchBack(
    _ searched: BackwardSearched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    var end = range.upperBound
    while true {
      if let start = consumer.consumingBack(
        searched, in: range.lowerBound..<end) {
        return start..<end
      } else if end == searched.startIndex {
        return nil
      } else {
        searched.formIndex(before: &end)
      }
    }
  }
}
