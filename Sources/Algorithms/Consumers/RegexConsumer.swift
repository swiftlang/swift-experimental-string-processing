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
    _ consumed: String, subrange: Range<String.Index>
  ) -> String.Index? {
    let result = vm.execute(
      input: consumed, in: subrange, .partialFromFront)
    assert(result?.range ==
           referenceVM.execute(
            input: consumed, in: subrange, .partialFromFront
           )?.range)

    return result?.range.upperBound
  }
}

extension RegexConsumer: StatelessCollectionSearcher {
  public typealias Searched = String

  // TODO: We'll want to bake search into the engine so it can
  // take advantage of the structure of the regex itself and
  // its own internal state
  public func search(
    _ searched: String, subrange: Range<String.Index>
  ) -> Range<String.Index>? {
    // TODO: This definition should be available to any
    // consumer conformer that wants it.
    // TODO: What about empty consumes?
    var (start, end) = subrange.destructure
    while start != end {
      if let result = consume(searched, subrange: start..<end) {
        return start ..< result
      }
      searched.formIndex(after: &start)
    }

    return nil
  }

}

// TODO: We'll want to bake backwards into the engine
extension RegexConsumer: BidirectionalCollectionConsumer {
  private func findSearchStart(
    _ consumed: String, subrange: Range<String.Index>
  ) -> String.Index? {
    // TODO: This definition should be available to any
    // consumer conformer that wants it.
    // TODO: What about empty consumes?
    let end = subrange.upperBound
    var start = end
    repeat { // FIXME: empty subrange?
      consumed.formIndex(before: &start)
      if consume(consumed, subrange: start..<end) != nil {
        return start
      }
    } while start != subrange.lowerBound
    return nil
  }

  public func consumeBack(
    _ consumed: String, subrange: Range<String.Index>
  ) -> String.Index? {

    if let r = searchBack(consumed, subrange: subrange),
       r.upperBound == subrange.upperBound
    {
      return r.lowerBound
    }
    return nil
  }
}

// TODO: Bake in search-back to engine too
extension RegexConsumer: StatelessBackwardCollectionSearcher {
  public func searchBack(
    _ searched: String, subrange: Range<String.Index>
  ) -> Range<String.Index>? {
    // TODO: This definition should be available to any
    // consumer conformer that wants it.
    // TODO: What about empty consumes?
    let end = subrange.upperBound
    var start = end
    repeat { // FIXME: empty subrange?
      searched.formIndex(before: &start)
      if let upper = consume(searched, subrange: start..<end) {
        return start..<upper
      }
    } while start != subrange.lowerBound

    return nil
  }


}
