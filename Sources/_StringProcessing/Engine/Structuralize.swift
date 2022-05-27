@_implementationOnly import _RegexParser

extension CaptureList {
  @available(SwiftStdlib 5.7, *)
  func createElements(
    _ list: MECaptureList,
    _ input: String
  ) -> [AnyRegexOutput.ElementRepresentation] {
    assert(list.values.count == captures.count)
    
    var result = [AnyRegexOutput.ElementRepresentation]()
    
    for (i, (cap, meStored)) in zip(captures, list.values).enumerated() {
      let element = AnyRegexOutput.ElementRepresentation(
        optionalDepth: cap.optionalDepth,
        bounds: meStored.latest,
        name: cap.name,
        referenceID: list.referencedCaptureOffsets.first { $1 == i }?.key,
        value: meStored.latestValue
      )
      
      result.append(element)
    }
    
    return result
  }
}

