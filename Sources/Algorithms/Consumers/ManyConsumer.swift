struct ManyConsumer<Base: CollectionConsumer> {
  let base: Base
}

extension ManyConsumer: CollectionConsumer {
  typealias Consumed = Base.Consumed
  
  func consume(_ consumed: Base.Consumed, from index: Consumed.Index) -> Base.Consumed.Index? {
    var result = index
    while let index = base.consume(consumed, from: result), index != result {
      result = index
    }
    return result
  }
}

extension ManyConsumer: BackwardCollectionConsumer where Base: BackwardCollectionConsumer {
  func consumeBack(_ consumed: Base.Consumed, from index: Consumed.Index) -> Base.Consumed.Index? {
    var result = index
    while let index = base.consumeBack(consumed, from: result), index != result {
      result = index
    }
    return result
  }
}
