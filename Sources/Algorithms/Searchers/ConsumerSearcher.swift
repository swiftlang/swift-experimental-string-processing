struct ConsumerSearcher<C: CollectionConsumer> {
  let consumer: C
}

extension ConsumerSearcher: StatelessCollectionSearcher {
  typealias Searched = C.Consumed
  
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
