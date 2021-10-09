extension Unicode.Scalar {
  // Convert a hexadecimal string to a scalar
  public init?<S: StringProtocol>(hex: S) {
    guard let val = UInt32(hex, radix: 16), let scalar = Self(val) else {
      return nil
    }
    self = scalar
  }
}

public struct GraphemeBreakScalars: Hashable {
  let scalars: ClosedRange<Unicode.Scalar>
  let property: Unicode.GraphemeBreakProperty

  public init(
    _ scalars: ClosedRange<Unicode.Scalar>,
    _ property: Unicode.GraphemeBreakProperty) {
    self.scalars = scalars
    self.property = property
  }
}

public func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakScalars? {
  let components = line.split(separator: ";")
  guard components.count >= 2 else { return nil }

  let splitProperty = components[1].split(separator: "#")
  let filteredProperty = splitProperty[0].filter { !$0.isWhitespace }
  guard let property = Unicode.GraphemeBreakProperty(filteredProperty) else {
    return nil
  }

  let scalars: ClosedRange<Unicode.Scalar>
  let filteredScalars = components[0].filter { !$0.isWhitespace }
  if filteredScalars.contains(".") {
    let range = filteredScalars
      .split(separator: ".")
      .map { Unicode.Scalar(hex: $0)! }
    scalars = range[0] ... range[1]
  } else {
    let scalar = Unicode.Scalar(hex: filteredScalars)!
    scalars = scalar...scalar
  }
  return GraphemeBreakScalars(scalars, property)
}

// Try to parse a Unicode scalar off the input
func parseScalar(_ str: inout Substring) -> Unicode.Scalar? {
  let val = str.eat(while: { $0.isHexDigit })
  guard !val.isEmpty else { return nil }

  // Subtle potential bug: if this init fails, we need to restore
  // str.startIndex. Because of how this is currently called, the bug wont
  // manifest now, but could if the call site is changed.
  return Unicode.Scalar(hex: val)
}

public func graphemeBreakPropertyData_consumers(
  forLine line: String
) -> GraphemeBreakScalars? {
  var line = line[...]
  guard let lower = parseScalar(&line) else {
    // Comment or whitespace line
    return nil
  }

  let upper: Unicode.Scalar
  if line.peek(".") {
    guard !line.eat(exactly: "..").isEmpty else {
      fatalError("Parse error")
    }
    guard let s = parseScalar(&line) else {
      fatalError("Parse error")
    }
    upper = s
  } else {
    upper = lower
  }

  line.eat(while: { !$0.isLetter })
  let name = line.eat(while: { $0.isLetter || $0 == "_" })
  guard let prop = Unicode.GraphemeBreakProperty(name) else {
    return nil
  }

  return GraphemeBreakScalars(lower ... upper, prop)
}



extension Unicode {
  public enum GraphemeBreakProperty: UInt32 {
    // We don't store the other properties, so we really don't care about them
    // here.
    case control = 0
    case extend = 1
    case prepend = 2
    case spacingMark = 3
    case extendedPictographic = 4

    init?<S: StringProtocol>(_ str: S) {
      switch str {
      case "Extend":
        self = .extend

      // Although CR and LF are distinct properties, we have fast paths in place
      // for those cases, so combine them here to allow for more contiguous
      // ranges.
      case "Control",
           "CR",
           "LF":
        self = .control
      case "Prepend":
        self = .prepend
      case "SpacingMark":
        self = .spacingMark
      case "Extended_Pictographic":
        self = .extendedPictographic
      default:
        return nil
      }
    }
  }
}

// TODO: eatBack for Bidi? eatAround? Consistent naming convention

extension Collection where SubSequence == Self {
  @discardableResult
  internal mutating func eat(upTo idx: Index) -> SubSequence {
    defer { self = self[idx...] }
    return self[..<idx]
  }

  @discardableResult
  internal mutating func eat(
    while predicate: (Element) -> Bool
  ) -> SubSequence {
    eat(upTo: self.firstIndex(where: { !predicate($0) }) ?? endIndex)
  }

}


//
// MARK: Eat Convenience Overloads
//

extension Collection where SubSequence == Self {
  // TODO: optionality of return? Probably a good idea to signal if something happened...

  // TODO: worth having?
  @discardableResult
  internal mutating func eat() -> Element? {
    self.eat(count: 1).first
  }

  @discardableResult
  internal mutating func eat(count n: Int = 0) -> SubSequence {
    let idx = self.index(self.startIndex, offsetBy: n, limitedBy: self.endIndex) ?? self.endIndex
    return self.eat(upTo: idx)
  }

  @discardableResult
  internal mutating func eat(one predicate: (Element) -> Bool) -> Element? {
    guard let elt = self.first, predicate(elt) else { return nil }
    return eat()
  }
}

extension Collection where SubSequence == Self, Element: Equatable {
  @discardableResult
  internal mutating func eat(one e: Element) -> Element? {
    self.eat(one: { (other: Element) in other == e })
  }
  @discardableResult
  internal mutating func eat(many e: Element) -> SubSequence {
    self.eat(while: { (other: Element) in other == e })
  }

  internal func peek(_ e: Element) -> Bool {
    self.first == e
  }

  @discardableResult
  internal mutating func eat<S: Sequence>(exactly s: S) -> SubSequence where S.Element == Element {
    var idx = startIndex
    for e in s {
      guard idx < endIndex, e == self[idx] else {
        idx = startIndex
        break
      }
      formIndex(after: &idx)
    }
    return eat(upTo: idx)
  }
}


extension Collection where SubSequence == Self, Element: Hashable {
  @discardableResult
  internal mutating func eat(oneIn s: Set<Element>) -> Element? {
    self.eat(one: { s.contains($0) })
  }
  @discardableResult
  internal mutating func eat(whileIn s: Set<Element>) -> SubSequence {
    self.eat(while: { s.contains($0) })
  }
}

