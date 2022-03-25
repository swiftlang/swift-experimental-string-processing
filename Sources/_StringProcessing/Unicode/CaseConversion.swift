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

@_silgen_name("_swift_stdlib_getCaseMapping")
func _swift_stdlib_getCaseMapping(
  _ scalar: UInt32,
  _ buffer: UnsafeMutableBufferPointer<UInt32>
)

extension Unicode.Scalar {
  var caseFolded: String {
    var buffer: [UInt32] = [0, 0, 0]
    
    buffer.withUnsafeMutableBufferPointer {
      _swift_stdlib_getCaseMapping(value, $0)
    }
    
    var result = ""
    
    for scalar in buffer {
      guard scalar != 0 else {
        break
      }
      
      result.unicodeScalars.append(Unicode.Scalar(scalar)!)
    }
    
    return result
  }
}
