import Regex

extension Regex where Capture == DynamicCaptures {
  public init(_ string: String) throws {
    self.init(ast: try parse(string, .traditional))
  }
}

public enum DynamicCaptures: Equatable {
  case substring(Substring)
  indirect case tuple([DynamicCaptures])
  indirect case optional(DynamicCaptures?)
  indirect case array([DynamicCaptures])

  internal init(_ capture: Capture) {
    switch capture {
    case .atom(let atom):
      self = .substring(atom as! Substring)
    case .tuple(let components):
      self = .tuple(components.map(Self.init))
    case .optional(let component):
      self = .optional(component.map(Self.init))
    case .array(let components):
      self = .array(components.map(Self.init))
    }
  }
}
