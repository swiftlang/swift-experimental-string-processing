//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal import _RegexParser

@available(SwiftStdlib 5.7, *)
extension Regex {
  internal func _verifyType() -> (Bool, Any.Type) {
    guard Output.self != AnyRegexOutput.self else {
      return (true, Output.self)
    }
    
    var tupleElements: [Any.Type] = []
    var labels = ""
    
    for capture in program.list.captureList.captures {
      var captureType = capture.type
      var i = capture.optionalDepth
      
      while i != 0 {
        captureType = TypeConstruction.optionalType(of: captureType)
        i -= 1
      }
      
      tupleElements.append(captureType)
      
      if let name = capture.name {
        labels += name
      }
      
      labels.unicodeScalars.append(" ")
    }
    
    // If we have no captures, then our Regex must be Regex<Substring>.
    if tupleElements.count == 1 {
      let wholeMatchType = program.list.wholeMatchType
      return (Output.self == wholeMatchType, wholeMatchType)
    }
    
    let createdType = TypeConstruction.tupleType(
      of: tupleElements,
      
      // If all of our labels are spaces, that means no actual label was added
      // to the tuple. In that case, don't pass a label string.
      labels: labels.all { $0 == " " } ? nil : labels
    )
    
    return (Output.self == createdType, createdType)
  }
}
