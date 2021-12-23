
// Just a phantom-typed Int wrapper.
@frozen
public struct TypedInt<👻>: RawRepresentable, Hashable {
  @_alwaysEmitIntoClient
  public var rawValue: Int

  @_alwaysEmitIntoClient
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  @_alwaysEmitIntoClient
  public init(_ rawValue: Int) {
    self.init(rawValue: rawValue)
  }

  @_alwaysEmitIntoClient
  public init(_ uint: UInt64) {
    assert(uint.leadingZeroBitCount > 0)
    self.init(Int(truncatingIfNeeded: uint))
  }
}
extension TypedInt: Comparable {
  @_alwaysEmitIntoClient
  public static func <(lhs: TypedInt, rhs: TypedInt) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}
extension TypedInt: CustomStringConvertible {
  @_alwaysEmitIntoClient
  public var description: String { return "#\(rawValue)" }
}
extension TypedInt: ExpressibleByIntegerLiteral {
  @_alwaysEmitIntoClient
  public init(integerLiteral value: Int) {
    self.init(rawValue: value)
  }
}

public protocol TypedIntProtocol {
  associatedtype 👻
}
extension TypedInt: TypedIntProtocol { }

// A placeholder type for when we must supply a type.
// When the phantom type appears, it says boo
public enum _Boo {}

// Easier for clients to just have their own typealias
public typealias TypedInt_ = TypedInt

// TODO: BinaryInteger, etc.
extension TypedInt {
  @_alwaysEmitIntoClient
  public static func +(lhs: TypedInt, rhs: Int) -> TypedInt {
    return TypedInt(lhs.rawValue + rhs)
  }

  @_alwaysEmitIntoClient
  public var bits: UInt64 {
    UInt64(truncatingIfNeeded: self.rawValue)
  }
}

@frozen
public struct TypedSetVector<Element: Hashable, 👻> {
  public typealias Idx = TypedInt<👻>

  // TODO: Replace with real set vector
  @_alwaysEmitIntoClient
  public var lookup: Dictionary<Element, Idx> = [:]

  @_alwaysEmitIntoClient
  public var stored: Array<Element> = []

  @_alwaysEmitIntoClient
  public func load(_ idx: Idx) -> Element { stored[idx.rawValue] }

  @_alwaysEmitIntoClient
  @discardableResult
  public mutating func store(_ e: Element) -> Idx {
    if let reg = lookup[e] { return reg }
    let reg = Idx(stored.count)
    stored.append(e)
    lookup[e] = reg
    return reg
  }

  @_alwaysEmitIntoClient
  public var count: Int { stored.count }

  @_alwaysEmitIntoClient
  public init() {}
}

// MARK: - Strongly typed int wrappers

/// A distance in the Input, e.g. `n` in consume(n)
public typealias Distance = TypedInt<_Distance>
public enum _Distance {}

/// An instruction address, i.e. the index into our instruction list
public typealias InstructionAddress = TypedInt<_InstructionAddress>
public enum _InstructionAddress {}

/// A position in the call stack, i.e. for save point restores
public typealias CallStackAddress = TypedInt<_CallStackAddress>
public enum _CallStackAddress {}

/// A position in a position stack, i.e. for NFA simulation
public typealias PositionStackAddress = TypedInt<_PositionStackAddress>
public enum _PositionStackAddress {}

/// A position in the save point stack, i.e. for backtracking
public typealias SavePointStackAddress = TypedInt<_SavePointAddress>
public enum _SavePointAddress {}


// MARK: - Registers

/// The register number for a stored element
///
/// NOTE: Currently just used for static data, but e.g. could be
/// used to save the most recently seen element satisfying some
/// property
public typealias ElementRegister = TypedInt<_ElementRegister>
public enum _ElementRegister {}

/// The register number for a stored boolean value
///
/// E.g. used for conditional branches
public typealias BoolRegister = TypedInt<_BoolRegister>
public enum _BoolRegister {}

/// The register number for a string (e.g. comment, failure reason)
public typealias StringRegister = TypedInt<_StringRegister>
public enum _StringRegister {}

/// Used for consume functions, e.g. character classes
public typealias ConsumeFunctionRegister = TypedInt<_ConsumeFunctionRegister>
public enum _ConsumeFunctionRegister {}

/// UNIMPLEMENTED
public typealias IntRegister = TypedInt<_IntRegister>
public enum _IntRegister {}

/// UNIMPLEMENTED
public typealias FloatRegister = TypedInt<_FloatRegister>
public enum _FloatRegister {}

/// UNIMPLEMENTED
///
/// NOTE: This, along with a position stack, might
/// serve NFA-simulation style execution models
public typealias PositionRegister = TypedInt<_PositionRegister>
public enum _PositionRegister {}

/// UNIMPLEMENTED
public typealias InstructionAddressRegister = TypedInt<_InstructionAddressRegister>
public enum _InstructionAddressRegister {}

/// UNIMPLEMENTED
public typealias CallStackAddressRegister = TypedInt<_CallStackAddressRegister>
public enum _CallStackAddressRegister {}

/// UNIMPLEMENTED
public typealias PositionStackAddressRegister = TypedInt<_PositionStackAddressRegister>
public enum _PositionStackAddressRegister {}

/// UNIMPLEMENTED
public typealias SavePointAddressRegister = TypedInt<_SavePointAddressRegister>
public enum _SavePointAddressRegister {}

/// A numbered label
public typealias LabelId = TypedInt<_LabelId>
public enum _LabelId {}

/// A numbered function
public typealias FunctionId = TypedInt<_FunctionId>
public enum _FunctionId {}

/// A numbered capture
public typealias CaptureId = TypedInt<_CaptureId>
public enum _CaptureId {}


