import _MatchingEngine

// TODO: what here should be in the compile-time module?

public enum Capture {
  case atom(Any)
  indirect case tuple([Capture])
  indirect case optional(Capture?)
  indirect case array([Capture])
}

extension Capture {
  static func tupleOrAtom(_ elements: [Capture]) -> Self {
    elements.count == 1 ? elements[0] : .tuple(elements)
  }

  public static var void: Capture {
    .tuple([])
  }

  public var value: Any {
    switch self {
    case .atom(let atom):
      return atom
    case .tuple(let elements):
      return _tuple(of: elements.map(\.value))
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

extension AST {
  public var hasCaptures: Bool {
    switch self {
    case let .alternation(child), let .concatenation(child):
      return child.any(\.hasCaptures)
    case let .group(g, child), let .groupTransform(g, child, _):
      return g.isCapturing || child.hasCaptures
      || true // WIP: preserves old behavior
    case .quantification(_, let child):
      return child.hasCaptures
    case .any,
        .trivia, .quote, .atom, .customCharacterClass, .empty:
      return false

    }
  }
}
