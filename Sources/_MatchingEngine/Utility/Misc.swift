
extension FixedWidthInteger {
  var hexStr: String {
    String(self, radix: 16, uppercase: true)
  }
}

func unreachable(_ s: @autoclosure () -> String) -> Never {
  fatalError("unreachable \(s())")
}
func unreachable() -> Never {
  fatalError("unreachable")
}

// From Algorithms...
extension Array /* for enumerated */ {
  /// Returns a collection of subsequences of this collection, chunked by the
  /// given predicate.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  public func chunked(
    by belongInSameGroup: (Element, Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    guard !isEmpty else { return [] }
    var result: [SubSequence] = []

    var start = startIndex
    var current = self[start]

    for (index, element) in enumerated().dropFirst() {
      if try !belongInSameGroup(current, element) {
        result.append(self[start..<index])
        start = index
      }
      current = element
    }

    if start != endIndex {
      result.append(self[start...])
    }

    return result
  }
}

extension Substring {
  var string: String { String(self) }
}
