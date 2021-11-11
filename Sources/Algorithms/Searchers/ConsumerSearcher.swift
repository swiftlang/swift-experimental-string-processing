/// A collection searcher that naively searches the input by repeatedly trying to consume it using the underlying consumer.
struct ConsumerSearcher<Consumer: CollectionConsumer> {
  let consumer: Consumer
}

extension ConsumerSearcher: StatelessCollectionSearcher {
  typealias Searched = Consumer.Consumed
  
  func search(
    _ searched: Searched,
    from index: Searched.Index
  ) -> Range<Searched.Index>? {
    var start = index
    while true {
      if let end = consumer.consuming(searched, from: start) {
        return start..<end
      } else if start == searched.endIndex {
        return nil
      } else {
        searched.formIndex(after: &start)
      }
    }
  }
}

extension ConsumerSearcher: BackwardCollectionSearcher, StatelessBackwardCollectionSearcher
  where Consumer: BidirectionalCollectionConsumer
{
  func searchBack(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>? {
    var end = index
    while true {
      if let start = consumer.consumingBack(searched, from: end) {
        return start..<end
      } else if end == searched.startIndex {
        return nil
      } else {
        searched.formIndex(before: &end)
      }
    }
  }
}
