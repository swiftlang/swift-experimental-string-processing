@_implementationOnly import _RegexParser

extension CaptureList {
  func structuralize(
    _ list: MECaptureList,
    _ input: String
  ) -> [StructuredCapture] {
    assert(list.values.count == captures.count)

    var result = [StructuredCapture]()
    for (cap, meStored) in zip(self.captures, list.values) {
      let stored = StoredCapture(
        range: meStored.latest, value: meStored.latestValue)

      result.append(.init(
        optionalCount: cap.optionalDepth, storedCapture: stored))
    }
    return result
  }
}

