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

extension Unicode.Scalar {
  public struct AllScalars: RandomAccessCollection {
    // Unicode scalar values are in two discontiguous blocks:
    // 0...0xD7FF and 0xE000...0x10FFFF
    internal static var lowerSectionFirstValue: Int { 0 }
    internal static var lowerSectionLastValue: Int { 0xD7FF }
    internal static var upperSectionFirstValue: Int { 0xE000 }
    internal static var upperSectionLastValue: Int { 0x10FFFF }
    
    internal static var surrogateRangeCount: Int {
      (upperSectionFirstValue - lowerSectionLastValue) - 1
    }
    
    internal func toContiguous(_ i: Int) -> Int {
      i >= Self.upperSectionFirstValue
        ? i - Self.surrogateRangeCount
        : i
    }
    
    internal func fromContiguous(_ i: Int) -> Int {
      i > Self.lowerSectionLastValue
        ? i + Self.surrogateRangeCount
        : i
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { toContiguous(Self.upperSectionLastValue + 1) }
    
    public subscript(position: Int) -> Unicode.Scalar {
      Unicode.Scalar(UInt32(fromContiguous(position)))!
    }
    
    public func _customIndexOfEquatableElement(_ scalar: Unicode.Scalar) -> Int?? {
      toContiguous(Int(scalar.value))
    }
    
    public func _customContainsEquatableElement(_: Unicode.Scalar) -> Bool? {
      true
    }
  }
  
  public static var allScalars: AllScalars {
    AllScalars()
  }
}
