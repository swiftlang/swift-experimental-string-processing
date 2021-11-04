/// A collection searcher that naively searches the input by repeatedly trying to consume it using the underlying consumer.
struct ConsumerSearcher<Consumer: CollectionConsumer>
  where Consumer.Consumed.SubSequence == Consumer.Consumed
{
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
      if let end = consumer.consume(searched, from: start) {
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
  where Consumer: BackwardCollectionConsumer
{
  func searchBack(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>? {
    var end = index
    while true {
      if let start = consumer.consumeBack(searched, from: end) {
        return start..<end
      } else if end == searched.startIndex {
        return nil
      } else {
        searched.formIndex(before: &end)
      }
    }
  }
}
