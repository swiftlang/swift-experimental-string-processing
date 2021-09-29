extension PEG.VM {

  // TODO: Consumers need a concept of forward progress.
  // They can return `nil` and `startIndex`, both which may
  // have the same effect for many API, but others might wish
  // to differentiate it. We should think through this issue
  // and likely make forward progress a more established
  // concept.

  func consume(_ input: Input) -> Input.Index? {
    var core = Core(
      instructions, input, enableTracing: enableTracing)
    while true {
      switch core.state {
      case .accept: return core.current.pos
      case .fail: return nil
      case .processing: core.cycle()
      }
    }
  }
}
