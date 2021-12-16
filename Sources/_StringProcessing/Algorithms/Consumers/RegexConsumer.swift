import _MatchingEngine

public struct RegexConsumer<Consumed: BidirectionalCollection>
  where Consumed.SubSequence == Substring
{
  // TODO: consider let, for now lets us toggle tracing
    var vm: Executor

  public init<Capture>(_ regex: Regex<Capture>) {
    self.vm = .init(program: try! Compiler(ast: regex.ast).emit())
  }
  
  func _consuming(
    _ consumed: Substring, in range: Range<String.Index>
  ) -> String.Index? {
    let result = vm.execute(
      input: consumed.base,
      in: range,
      mode: .partialFromFront)
    return result?.range.upperBound
  }
  
  public func consuming(
    _ consumed: Consumed, in range: Range<Consumed.Index>
  ) -> String.Index? {
    _consuming(consumed[...], in: range)
  }
}

// TODO: We'll want to bake backwards into the engine
extension RegexConsumer: BidirectionalCollectionConsumer {
  public func consumingBack(
    _ consumed: Consumed, in range: Range<Consumed.Index>
  ) -> String.Index? {
    var i = range.lowerBound
    while true {
      if let end = _consuming(consumed[...], in: i..<range.upperBound),
         end == range.upperBound
      {
        return i
      } else if i == range.upperBound {
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
    _ searched: Searched, in range: Range<Searched.Index>
  ) -> Range<String.Index>? {
    ConsumerSearcher(consumer: self).search(searched, in: range)
  }
}

// TODO: Bake in search-back to engine too
extension RegexConsumer: StatelessBackwardCollectionSearcher {
  public typealias BackwardSearched = Consumed
  
  public func searchBack(
    _ searched: BackwardSearched, in range: Range<Searched.Index>
  ) -> Range<String.Index>? {
    ConsumerSearcher(consumer: self).searchBack(searched, in: range)
  }
}
