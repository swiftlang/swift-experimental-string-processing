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
    var tupleElements: [Any.Type] = [Substring.self]
    var labels = " "
    
    for capture in program.tree.root._captureList.captures {
      var captureType: Any.Type = capture.type ?? Substring.self
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
      return Output.self == Substring.self
    }
    
    let createdType = TypeConstruction.tupleType(
      of: tupleElements,
      labels: labels
    )
    
    return Output.self == createdType
  }
}
