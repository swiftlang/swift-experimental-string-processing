extension Unicode.Scalar {
  public struct AllScalars: RandomAccessCollection {
    // Unicode scalar values are in two discontiguous blocks:
    // 0...0xD7FF and 0xE000...0x10FFFF
    private static var lowerSectionFirstIndex: Int { 0 }
    private static var lowerSectionLastIndex: Int { 0xD7FF }
    private static var upperSectionFirstIndex: Int { 0xE000 }
    private static var upperSectionLastIndex: Int { 0x10FFFF }
    
    private static var surrogateRangeCount: Int {
      (upperSectionFirstIndex - lowerSectionLastIndex) + 1
    }
    
    private func toContiguous(_ i: Int) -> Int {
      i >= Self.upperSectionFirstIndex
        ? i - Self.surrogateRangeCount
        : i
    }
    
    private func fromContiguous(_ i: Int) -> Int {
      i > Self.lowerSectionLastIndex
        ? i + Self.surrogateRangeCount
        : i
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { toContiguous(Self.upperSectionLastIndex + 1) }
    
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
