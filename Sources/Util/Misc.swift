extension CustomStringConvertible {
  @_alwaysEmitIntoClient
  public var halfWidthCornerQuoted: String {
    "｢\(self)｣"
  }
}

//extension String: Error {}

extension Array {
  @_alwaysEmitIntoClient
  public init(_ e: Element) {
    self.init(repeating: e, count: 1)
  }
}

@_alwaysEmitIntoClient
public func joined<T>(_ elements: [[T]]) -> [T] {
  Array(elements.joined())
}

extension Array {
  @_alwaysEmitIntoClient
  public init(reservingCapacity cap: Int) {
    self.init()
    self.reserveCapacity(cap)
  }
}

extension Sequence {
  @_alwaysEmitIntoClient
  public func all(_ f: (Element) -> Bool) -> Bool {
    for element in self {
      guard f(element) else { return false }
    }
    return true
  }
  @_alwaysEmitIntoClient
  public func none(_ f: (Element) -> Bool) -> Bool {
    return self.all { !f($0) }
  }
  @_alwaysEmitIntoClient
  public func any(_ f: (Element) -> Bool) -> Bool {
    for element in self {
      if f(element) { return true }
    }
    return false
  }
}

extension Range {
  public var destructure: (
    lowerBound: Bound, upperBound: Bound
  ) {
    (lowerBound, upperBound)
  }
}

public typealias Offsets = (lower: Int, upper: Int)
extension BidirectionalCollection {
  public func mapOffsets(_ offsets: Offsets) -> Range<Index> {
    assert(offsets.lower >= 0 && offsets.upper <= 0)
    let lower = index(startIndex, offsetBy: offsets.lower)
    let upper = index(endIndex, offsetBy: offsets.upper)
    return lower ..< upper
  }

  // Is this the right name?
  public func flatmapOffsets(_ offsets: Offsets?) -> Range<Index> {
    if let o = offsets {
      return mapOffsets(o)
    }
    return startIndex ..< endIndex
  }
}
