struct ManyConsumer<Base: CollectionConsumer> {
  let base: Base
}

extension ManyConsumer: CollectionConsumer {
  typealias Consumed = Base.Consumed
  
  func consume(_ consumed: Base.Consumed, from index: Consumed.Index) -> Base.Consumed.Index? {
    var start = index
    while let index = base.consume(consumed, from: start) {
      start = index
    }
    return start
  }
}

extension ManyConsumer: BackwardCollectionConsumer where Base: BackwardCollectionConsumer {
  func consumeBack(_ consumed: Base.Consumed, from index: Consumed.Index) -> Base.Consumed.Index? {
    var end = index
    while let index = base.consumeBack(consumed, from: end) {
      end = index
    }
    return end
  }
}

//extension ManyConsumer: BidirectionalCollectionConsumer where Base: BidirectionalCollectionConsumer {}
