//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal import _RegexParser

@available(SwiftStdlib 5.7, *)
extension Executor {
  static func createExistentialElements(
    _ program: MEProgram,
    matchRange: Range<String.Index>,
    storedCaptures: [Processor._StoredCapture],
    customValues: [Any],
    input: String,
    wholeMatchValue: Any?
  ) throws -> [AnyRegexOutput.ElementRepresentation] {
    let capList = program.captureList
    let capOffsets = program.referencedCaptureOffsets

    // Formal captures include the entire match
    assert(storedCaptures.count + 1 == capList.captures.count)

    var result = [AnyRegexOutput.ElementRepresentation]()
    result.reserveCapacity(1 + capList.captures.count)
    result.append(
      AnyRegexOutput.ElementRepresentation(
        optionalDepth: 0,
        content: (matchRange, wholeMatchValue),
        visibleInTypedOutput: capList.captures[0].visibleInTypedOutput)
      )

    for (i, (cap, meStored)) in zip(
      capList.captures.dropFirst(), storedCaptures
    ).enumerated() {
      var content = meStored.deconstructed(customValues: customValues)
      // A failable transform already ran while matching, and its result is the
      // capture's value. Any other transform needs to run now that matching has
      // succeeded.
      if let reg = program.captureTransforms[i], content != nil {
        let transform = program.registers[reg]
        let value = try transform(input, meStored.range, content?.value)
        content?.value = value
      }
      let element = AnyRegexOutput.ElementRepresentation(
        optionalDepth: cap.optionalDepth,
        content: content,
        name: cap.name,
        referenceID: capOffsets.first { $1 == i }?.key,
        visibleInTypedOutput: cap.visibleInTypedOutput
      )
      
      result.append(element)
    }
    
    return result
  }
}

