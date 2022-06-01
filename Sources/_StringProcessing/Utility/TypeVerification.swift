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

@_implementationOnly import _RegexParser

@available(SwiftStdlib 5.7, *)
extension Regex {
  internal func _verifyType() -> Bool {
    guard Output.self != AnyRegexOutput.self else { return true }

    var tupleElements: [Any.Type] = [Substring.self]
    var labels = " "
    
    for capture in program.tree.root._captureList.captures {
      var captureType: Any.Type = capture.type ?? Substring.self

      for _ in 0..<capture.optionalDepth {
        captureType = TypeConstruction.optionalType(of: captureType)
      }

      tupleElements.append(captureType)
      
      if let name = capture.name {
        labels += name
      }
      
      labels.unicodeScalars.append(" ")
    }
    
    // If we have no captures, then our Regex must be Regex<Substring>.
    if tupleElements.count == 1 {
      return Output.self == Substring.self
    }
    
    let createdType = TypeConstruction.tupleType(
      of: tupleElements,
      
      // If all of our labels are spaces, that means no actual label was added
      // to the tuple. In that case, don't pass a label string.
      labels: labels.all { $0 == " " } ? nil : labels
    )

    return Output.self == createdType
  }
}
