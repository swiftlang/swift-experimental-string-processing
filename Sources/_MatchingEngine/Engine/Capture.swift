public enum Capture<Input: Collection> {
  case range(Range<Input.Index>)
  // TODO: Remove `slice` and use `range` instead.
  case slice(Input.SubSequence)
  case concrete(Any)
  case none(childType: Any.Type)
  indirect case some(Capture<Input>)
  indirect case array([Capture<Input>], childType: Any.Type)
  indirect case tuple([Capture<Input>])
}

extension Capture {
  public static func tupleOrSingleton(_ elements: [Capture]) -> Self {
    elements.count == 1 ? elements[0] : .tuple(elements)
  }

  public static var void: Capture {
    .tuple([])
  }

  public var value: Any {
    switch self {
    case .range(let range):
      return range
    case .slice(let slice):
      return slice
    case .concrete(let value):
      return value
    case .tuple(let elements):
      return TypeConstruction.tuple(
        of: elements.map(\.value))
    case .array(let elements, let childType):
      func helper<T>(_: T.Type) -> Any {
        elements.map { $0.value as! T }
      }
      return _openExistential(childType, do: helper)
    case .some(let subcapture):
      return subcapture.value
    case .none(let childType):
      func helper<T>(_: T.Type) -> Any {
        nil as T? as Any
      }
      return _openExistential(childType, do: helper)
    }
  }

  public func prepending(_ newElement: Self) -> Self {
    switch self {
    case .range, .slice, .concrete, .some, .none, .array:
      return .tuple([newElement, self])
    case .tuple(let elements):
      return elements.isEmpty ? newElement : .tuple([newElement] + elements)
    }
  }

  public func map(_ transform: (Capture) -> Capture) -> Capture {
    switch self {
    case .tuple(let elements):
      return .tuple(elements.map(transform))
    default:
      return transform(self)
    }
  }

  public func mapRanges<T>(
    _ transform: (Range<Input.Index>) -> T
  ) -> Capture {
    switch self {
    case .range(let bounds) where T.self == Input.SubSequence.self:
      return .slice(transform(bounds) as! Input.SubSequence)
    case .range(let bounds):
      return .concrete(transform(bounds))
    case .slice, .concrete, .none:
      return self
    case .some(let child):
      return .some(child.mapRanges(transform))
    case .array(let elements, childType: let childType):
      return .array(
        elements.map { $0.mapRanges(transform) },
        childType: childType)
    case .tuple(let elements):
      return .tuple(elements.map { $0.mapRanges(transform) })
    }
  }
}

extension Capture where Input == String {
  public func matchValue(input: String) -> Any {
    return mapRanges { input[$0] }.prepending(.concrete(input[...])).value
  }
}

extension Capture: CustomStringConvertible {
  public func description(input: Input?) -> String {
    switch self {
    case .range(let bounds):
      return input.map { String(describing: $0[bounds]) }
        ?? String(describing: bounds)
    case .slice(let slice):
      return String(describing: slice)
    case .concrete(let value):
      return String(describing: value)
    case .none(childType: let childType):
      return "nil : \(childType)?"
    case .some(let value):
      return "some(\(value.description(input: input)))"
    case .array(let elements, childType: let childType):
      return """
        [\(elements.map { $0.description(input: input) }
             .joined(separator: ", "))] : \
        [\(childType)]
        """
    case .tuple(let elements):
      return """
        (\(elements.map { $0.description(input: input) }
             .joined(separator: ", ")))
        """
    }
  }

  public var description: String {
    description(input: nil)
  }
}

public struct CaptureTransform<Input: Collection>
  : Equatable, Hashable, CustomStringConvertible
{
  public let resultType: Any.Type
  public let closure: (Input, Range<Input.Index>) -> Any

  public init<T>(
    resultType: T.Type = T.self,
    _ closure: @escaping (Input, Range<Input.Index>) -> T
  ) {
    self.resultType = resultType
    self.closure = closure
  }

  public func callAsFunction(
    _ input: Input, at range: Range<Input.Index>
  ) -> Any {
    closure(input, range)
  }

  public static func == (lhs: CaptureTransform, rhs: CaptureTransform) -> Bool {
    lhs.resultType == rhs.resultType &&
      unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
        unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(resultType))
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  public var description: String {
    "<transform>"
  }
}
