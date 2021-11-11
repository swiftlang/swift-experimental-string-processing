import _MatchingEngine

import _StringProcessing

public struct Regex {
  let string: String
  let options: REOptions
  
  public init(_ string: String, options: REOptions = .none) {
    self.string = string
    self.options = options
  }
}

public struct RegexConsumer<Consumed: BidirectionalCollection> where Consumed.SubSequence == Substring {
  // NOTE: existential
  let vm: Executor

  public init(_ regex: Regex) {
    self.vm = _compileRegex(regex.string)
  }
  
  func _consuming(
    _ consumed: Substring, from index: String.Index
  ) -> String.Index? {
    let result = vm.execute(
      input: consumed.base,
      in: index..<consumed.endIndex,
      mode: .partialFromFront)
    return result?.range.upperBound
  }
  
  public func consuming(
    _ consumed: Consumed, from index: Consumed.Index
  ) -> String.Index? {
    _consuming(consumed[...], from: index)
  }
}

// TODO: We'll want to bake backwards into the engine
extension RegexConsumer: BidirectionalCollectionConsumer {
  public func consumingBack(
    _ consumed: Consumed, from index: Consumed.Index
  ) -> String.Index? {
    var i = consumed.startIndex
    while true {
      if let end = _consuming(consumed[..<index], from: i), end == index {
        return i
      } else if i == index {
        return nil
      } else {
        consumed.formIndex(after: &i)
      }
    }
  }
}

extension RegexConsumer: StatelessCollectionSearcher {
  public typealias Searched = Consumed

  // TODO: We'll want to bake search into the engine so it can
  // take advantage of the structure of the regex itself and
  // its own internal state
  public func search(
    _ searched: Searched, from index: Searched.Index
  ) -> Range<String.Index>? {
    ConsumerSearcher(consumer: self).search(searched, from: index)
  }
}

// TODO: Bake in search-back to engine too
extension RegexConsumer: StatelessBackwardCollectionSearcher {
  public typealias BackwardSearched = Consumed
  
  public func searchBack(
    _ searched: BackwardSearched, from index: Searched.Index
  ) -> Range<String.Index>? {
    ConsumerSearcher(consumer: self).searchBack(searched, from: index)
  }
}
