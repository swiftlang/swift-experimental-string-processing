import _MatchingEngine

// TODO: what here should be in the compile-time module?

enum Capture {
  case atom(Any)
  indirect case tuple([Capture])
  indirect case some(Capture)
  case none(childType: AnyCaptureType)
  indirect case array([Capture], childType: AnyCaptureType)

  static func none(childType: Any.Type) -> Capture {
    .none(childType: AnyCaptureType(childType))
  }

  static func array(_ children: [Capture], childType: Any.Type) -> Capture {
    .array(children, childType: AnyCaptureType(childType))
  }
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
    case .array(let elements, let childType):
      func helper<T>(_: T.Type) -> Any {
        elements.map { $0.value as! T }
      }
      return _openExistential(childType.base, do: helper)
    case .some(let subcapture):
      return subcapture.value
    case .none(let childType):
      func helper<T>(_: T.Type) -> Any {
        nil as T? as Any
      }
      return _openExistential(childType.base, do: helper)
    }
  }

  private func prepending(_ newElement: Any) -> Self {
    switch self {
    case .atom, .some, .none, .array:
      return .tuple([.atom(newElement), self])
    case .tuple(let elements):
      return .tuple([.atom(newElement)] + elements)
    }
  }

  func matchValue(withWholeMatch wholeMatch: Substring) -> Any {
    prepending(wholeMatch).value
  }
}

/// A wrapper of an existential metatype, equatable and hashable by reference.
struct AnyCaptureType: Equatable, Hashable {
  var base: Any.Type

  init(_ type: Any.Type) {
    base = type
  }

  static func == (lhs: AnyCaptureType, rhs: AnyCaptureType) -> Bool {
    lhs.base == rhs.base
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(base))
  }
}
