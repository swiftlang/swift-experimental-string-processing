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
