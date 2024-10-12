internal import _RegexParser

extension CaptureList {
  @available(SwiftStdlib 5.7, *)
  func createElements(
    _ list: MECaptureList
  ) -> [AnyRegexOutput.ElementRepresentation] {
    assert(list.values.count == captures.count)
    
    var result = [AnyRegexOutput.ElementRepresentation]()
    
    for (i, (cap, meStored)) in zip(captures, list.values).enumerated() {
      if !cap.visibleInTypedOutput {
        fatalError("Why does this never get hit?")
      }
      let element = AnyRegexOutput.ElementRepresentation(
        optionalDepth: cap.optionalDepth,
        content: meStored.deconstructed,
        name: cap.name,
        referenceID: list.referencedCaptureOffsets.first { $1 == i }?.key,
        visibleInTypedOutput: cap.visibleInTypedOutput
      )
      
      result.append(element)
    }
    
    return result
  }
}

