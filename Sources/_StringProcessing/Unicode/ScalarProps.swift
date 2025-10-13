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

@_silgen_name("_swift_string_processing_getScript")
func _swift_string_processing_getScript(_: UInt32) -> UInt8

@_silgen_name("_swift_string_processing_getScriptExtensions")
func _swift_string_processing_getScriptExtensions(
  _: UInt32,
  _: UnsafeMutablePointer<UInt8>
) -> UnsafePointer<UInt8>?

extension Unicode.Script {
  init(_ scalar: Unicode.Scalar) {
    let rawValue = _swift_string_processing_getScript(scalar.value)
    
    _internalInvariant(rawValue != .max, "Unknown script rawValue: \(rawValue)")
    
    self = unsafeBitCast(rawValue, to: Self.self)
  }
  
  static func extensions(for scalar: Unicode.Scalar) -> [Unicode.Script] {
    var count: UInt8 = 0
    let pointer = withUnsafeMutablePointer(to: &count) {
      _swift_string_processing_getScriptExtensions(scalar.value, $0)
    }

    guard let pointer = pointer else {
      return [Unicode.Script(scalar)]
    }
    
    var result: [Unicode.Script] = []
    
    for i in 0 ..< count {
      let script = pointer[Int(i)]
      
      result.append(unsafeBitCast(script, to: Unicode.Script.self))
    }
    
    return result
  }
}

extension UnicodeScalar {
  var isHorizontalWhitespace: Bool {
    value == 0x09 || properties.generalCategory == .spaceSeparator
  }
  
  var isNewline: Bool {
    switch value {
      case 0x000A...0x000D /* LF ... CR */: return true
      case 0x0085 /* NEXT LINE (NEL) */: return true
      case 0x2028 /* LINE SEPARATOR */: return true
      case 0x2029 /* PARAGRAPH SEPARATOR */: return true
      default: return false
    }
  }
}
