struct ManyConsumer<Base: CollectionConsumer> {
  let base: Base
}

extension ManyConsumer: CollectionConsumer {
  typealias Consumed = Base.Consumed
  
  func consuming(_ consumed: Base.Consumed, in range: Range<Consumed.Index>) -> Base.Consumed.Index? {
    var result = range.lowerBound
    while let index = base.consuming(consumed, in: result..<range.upperBound), index != result {
      result = index
    }
    return result
  }
}

extension ManyConsumer: BidirectionalCollectionConsumer where Base: BidirectionalCollectionConsumer {
  func consumingBack(_ consumed: Base.Consumed, in range: Range<Consumed.Index>) -> Base.Consumed.Index? {
    var result = range.upperBound
    while let index = base.consumingBack(consumed, in: range.lowerBound..<result), index != result {
      result = index
    }
    return result
  }
}
