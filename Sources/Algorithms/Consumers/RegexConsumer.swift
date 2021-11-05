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

public struct RegexConsumer: CollectionConsumer {
  // NOTE: existential
  let vm: Executor

  public init(_ regex: Regex) {
    self.vm = _compileRegex(regex.string)
  }

  public func consuming(
    _ consumed: Substring, from index: String.Index
  ) -> String.Index? {
    let result = vm.execute(
      input: consumed.base,
      in: index..<consumed.endIndex,
      mode: .partialFromFront)
    return result?.range.upperBound
  }
}

// TODO: We'll want to bake backwards into the engine
extension RegexConsumer: BackwardCollectionConsumer {
  public func consumingBack(
    _ consumed: Substring, from index: String.Index
  ) -> String.Index? {
    var i = consumed.startIndex
    while true {
      if let end = consuming(consumed[..<index], from: i), end == index {
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
  public typealias Searched = Substring

  // TODO: We'll want to bake search into the engine so it can
  // take advantage of the structure of the regex itself and
  // its own internal state
  public func search(
    _ searched: Substring, from index: String.Index
  ) -> Range<String.Index>? {
    ConsumerSearcher(consumer: self).search(searched, from: index)
  }
}

// TODO: Bake in search-back to engine too
extension RegexConsumer: StatelessBackwardCollectionSearcher {
  public func searchBack(
    _ searched: Substring, from index: String.Index
  ) -> Range<String.Index>? {
    ConsumerSearcher(consumer: self).searchBack(searched, from: index)
  }
}
