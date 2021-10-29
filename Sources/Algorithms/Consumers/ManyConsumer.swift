struct ManyConsumer<Base: CollectionConsumer> {
  let base: Base
}

extension ManyConsumer: CollectionConsumer {
  typealias Consumed = Base.Consumed
  
  func consume(_ consumed: Base.Consumed, subrange: Range<Consumed.Index>) -> Base.Consumed.Index? {
    var start = subrange.lowerBound
    while let index = base.consume(consumed, subrange: start..<subrange.upperBound) {
      start = index
    }
    return start
  }
}

extension ManyConsumer: BackwardCollectionConsumer where Base: BackwardCollectionConsumer {
  func consumeBack(_ consumed: Base.Consumed, subrange: Range<Consumed.Index>) -> Base.Consumed.Index? {
    var end = subrange.upperBound
    while let index = base.consumeBack(consumed, subrange: subrange.lowerBound..<end) {
      end = index
    }
    return end
  }
}

extension ManyConsumer: BidirectionalCollectionConsumer where Base: BidirectionalCollectionConsumer {}
