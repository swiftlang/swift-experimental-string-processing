import _MatchingEngine

// TODO: what here should be in the compile-time module?

enum Capture {
  case atom(Any)
  indirect case tuple([Capture])
  indirect case optional(Capture?)
  indirect case array([Capture])
}

extension Capture {
  static func tupleOrAtom(_ elements: [Capture]) -> Self {
    elements.count == 1 ? elements[0] : .tuple(elements)
  }

  static var void: Capture {
    .tuple([])
  }

  var value: Any {
    switch self {
    case .atom(let atom):
      return atom
    case .tuple(let elements):
      return TypeConstruction.tuple(
        of: elements.map(\.value))
    case .array(let elements):
      guard let first = elements.first else {
        return [Any]()
      }
      // When the array is not empty, infer the concrete `Element `type from the first element.
      func helper<T>(_ first: T) -> Any {
        var castElements = [first]
        for element in elements.dropFirst() {
          castElements.append(element.value as! T)
        }
        return castElements
      }
      return _openExistential(first.value, do: helper)
    case .optional(let subcapture):
      return subcapture?.value as Any
    }
  }
}
