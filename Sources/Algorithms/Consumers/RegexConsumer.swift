import Regex

public struct RegexConsumer: CollectionConsumer {
  // NOTE: existential
  let vm: VirtualMachine
  let referenceVM: VirtualMachine

  public init(regex: String, options: REOptions = .none) {
    let code = try! compile(regex, options: options)
    self.vm = HareVM(code)
    self.referenceVM = TortoiseVM(code)
  }

  public func consume(
    _ consumed: String, from index: String.Index
  ) -> String.Index? {
    let result = vm.execute(
      input: consumed, in: index..<consumed.endIndex, .partialFromFront)
    assert(result?.matched ==
           referenceVM.execute(
            input: consumed, in: index..<consumed.endIndex, .partialFromFront
           )?.matched)

    return result?.matched.upperBound
  }
}

extension RegexConsumer: StatelessCollectionSearcher {
  public typealias Searched = String

  // TODO: We'll want to bake search into the engine so it can
  // take advantage of the structure of the regex itself and
  // its own internal state
  public func search(
    _ searched: String, from index: String.Index
  ) -> Range<String.Index>? {
    // TODO: This definition should be available to any
    // consumer conformer that wants it.
    // TODO: What about empty consumes?
    var (start, end) = (index, searched.endIndex)
    while start != end {
      if let result = consume(searched, from: start) {
        return start ..< result
      }
      searched.formIndex(after: &start)
    }

    return nil
  }

}

// TODO: We'll want to bake backwards into the engine
extension RegexConsumer: BackwardCollectionConsumer {
  public func consumeBack(
    _ consumed: String, from index: String.Index
  ) -> String.Index? {

    if let r = searchBack(consumed, from: index),
       r.upperBound == index
    {
      return r.lowerBound
    }
    return nil
  }
}

// TODO: Bake in search-back to engine too
extension RegexConsumer: StatelessBackwardCollectionSearcher {
  public func searchBack(
    _ searched: String, from index: String.Index
  ) -> Range<String.Index>? {
    // TODO: This definition should be available to any
    // consumer conformer that wants it.
    // TODO: What about empty consumes?
    let end = index
    var start = end
    repeat { // FIXME: empty subrange?
      searched.formIndex(before: &start)
      if let upper = consume(searched, from: start) {
        return start..<upper
      }
    } while start != searched.startIndex

    return nil
  }
}
