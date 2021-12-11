import _MatchingEngine

extension Regex where Match == Tuple2<Substring, DynamicCaptures> {
  public init(_ pattern: String) throws {
    self.init(ast: try parse(pattern, .traditional))
  }
}

public enum DynamicCaptures: Equatable {
  case substring(Substring)
  indirect case tuple([DynamicCaptures])
  indirect case optional(DynamicCaptures?)
  indirect case array([DynamicCaptures])

  public static var empty: Self {
    .tuple([])
  }

  internal init(_ capture: Capture) {
    switch capture {
    case .atom(let atom):
      self = .substring(atom as! Substring)
    case .tuple(let components):
      self = .tuple(components.map(Self.init))
    case .some(let component):
      self = .optional(Self(component))
    case .none:
      self = .optional(nil)
    case .array(let components, _):
      self = .array(components.map(Self.init))
    }
  }
}
