struct ManyConsumer<Base: CollectionConsumer> {
  let base: Base
}

extension ManyConsumer: CollectionConsumer {
  typealias Consumed = Base.Consumed
  
  func consuming(_ consumed: Base.Consumed, from index: Consumed.Index) -> Base.Consumed.Index? {
    var result = index
    while let index = base.consuming(consumed, from: result), index != result {
      result = index
    }
    return result
  }
}

extension ManyConsumer: BackwardCollectionConsumer where Base: BackwardCollectionConsumer {
  func consumingBack(_ consumed: Base.Consumed, from index: Consumed.Index) -> Base.Consumed.Index? {
    var result = index
    while let index = base.consumingBack(consumed, from: result), index != result {
      result = index
    }
    return result
  }
}
