//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// A tree representing the type of some captures.
public enum CaptureStructure: Equatable {
  case atom(name: String? = nil, type: AnyType? = nil)
  indirect case array(CaptureStructure)
  indirect case optional(CaptureStructure)
  indirect case tuple([CaptureStructure])

  public static func tuple(_ children: CaptureStructure...) -> Self {
    tuple(children)
  }

  public static var empty: Self {
    .tuple([])
  }
}

extension AST {
  public var captureStructure: CaptureStructure {
    // Note: This implementation could be more optimized.
    switch self {
    case .alternation(let alternation):
      assert(alternation.children.count > 1)
      return alternation.children
        .map(\.captureStructure)
        .reduce(.empty, +)
        .map(CaptureStructure.optional)
    case .concatenation(let concatenation):
      return concatenation.children.map(\.captureStructure).reduce(.empty, +)
    case .group(let group):
      let innerCaptures = group.child.captureStructure
      switch group.kind.value {
      case .capture:
        return .atom() + innerCaptures
      case .namedCapture(let name):
        return .atom(name: name.value) + innerCaptures
      default:
        return innerCaptures
      }
    case .groupTransform(let group, let transform):
      let innerCaptures = group.child.captureStructure
      switch group.kind.value {
      case .capture:
        return .atom(type: AnyType(transform.resultType)) + innerCaptures
      case .namedCapture(let name):
        return .atom(name: name.value, type: AnyType(transform.resultType))
          + innerCaptures
      default:
        return innerCaptures
      }
    case .conditional(let c):
      // A conditional's capture structure is effectively that of an alternation
      // between the true and false branches. However the condition may also
      // have captures in the case of a group condition.
      var captures = CaptureStructure.empty
      switch c.condition.kind {
      case .group(let g):
        captures = captures + AST.group(g).captureStructure
      default:
        break
      }
      let branchCaptures = c.trueBranch.captureStructure +
                           c.falseBranch.captureStructure
      return captures + branchCaptures.map(CaptureStructure.optional)

    case .quantification(let quantification):
      return quantification.child.captureStructure.map(
        quantification.amount.value == .zeroOrOne
          ? CaptureStructure.optional
          : CaptureStructure.array)
    case .quote, .trivia, .atom, .customCharacterClass, .empty:
      return .empty
    }
  }
}

// MARK: - Combination and transformation

extension CaptureStructure {
  /// Returns a capture structure by concatenating any tuples in `self` and
  /// `other`.
  func concatenating(with other: CaptureStructure) -> CaptureStructure {
    switch (self, other) {
    // (T...) + (U...) ==> (T..., U...)
    case let (.tuple(lhs), .tuple(rhs)):
      return .tuple(lhs + rhs)
    // T + () ==> T
    case (_, .tuple(let rhs)) where rhs.isEmpty:
      return self
    // () + T ==> T
    case (.tuple(let lhs), _) where lhs.isEmpty:
      return other
    // (T...) + U ==> (T..., U)
    case let (.tuple(lhs), _):
      return .tuple(lhs + [other])
    // T + (U...) ==> (T, U...)
    case let (_, .tuple(rhs)):
      return .tuple([self] + rhs)
    // T + U ==> (T, U)
    default:
      return .tuple([self, other])
    }
  }

  static func + (
    lhs: CaptureStructure, rhs: CaptureStructure
  ) -> CaptureStructure {
    lhs.concatenating(with: rhs)
  }

  /// Returns a capture structure by transforming any tuple element of `self`
  /// or transforming `self` directly if it is not a tuple.
  func map(
    _ transform: (CaptureStructure) -> CaptureStructure
  ) -> CaptureStructure {
    if case .tuple(let children) = self {
      return .tuple(children.map(transform))
    }
    return transform(self)
  }
}

// MARK: - Common properties

extension CaptureStructure {
  /// Returns a Boolean indicating whether the structure does not contain any
  /// captures.
  public var isEmpty: Bool {
    if case .tuple(let elements) = self, elements.isEmpty {
      return true
    }
    return false
  }

  public func type(withAtomType atomType: Any.Type) -> Any.Type {
    switch self {
    case .atom(_, type: nil):
      return atomType
    case .atom(_, type: let type?):
      return type.base
    case .array(let child):
      return TypeConstruction.arrayType(of: child.type(withAtomType: atomType))
    case .optional(let child):
      return TypeConstruction.optionalType(of: child.type(withAtomType: atomType))
    case .tuple(let children):
      return TypeConstruction.tupleType(of: children.map {
        $0.type(withAtomType: atomType)
      })
    }
  }

  public typealias DefaultAtomType = Substring

  public var type: Any.Type {
    type(withAtomType: DefaultAtomType.self)
  }
}

// MARK: - Serialization

extension CaptureStructure {
  /// A byte-sized serialization code.
  private enum Code: UInt8 {
    case end           = 0
    case atom          = 1
    case namedAtom     = 2
    case formArray     = 3
    case formOptional  = 4
    case beginTuple    = 5
    case endTuple      = 6
  }

  private typealias SerializationVersion = UInt16
  private static let currentSerializationVersion: SerializationVersion = 1

  public static func serializationBufferSize(
    forInputUTF8CodeUnitCount inputUTF8CodeUnitCount: Int
  ) -> Int {
    MemoryLayout<SerializationVersion>.stride + inputUTF8CodeUnitCount + 1
  }

  /// Encode the capture structure to the given buffer as a serialized
  /// representation.
  ///
  /// The encoding rules are as follows:
  /// ```
  /// encode(〚`T`〛) ==> <version>, 〚`T`〛, .end
  /// 〚`T` (atom)〛 ==> .atom
  /// 〚`name: T` (atom)〛 ==> .atom, `name`, '\0'
  /// 〚`[T]`〛 ==> 〚`T`〛, .formArray
  /// 〚`T?`〛 ==> 〚`T`〛, .formOptional
  /// 〚`(T0, T1, ...)` (top level)〛 ==> 〚`T0`〛, 〚`T1`〛, ...
  /// 〚`(T0, T1, ...)`〛 ==> .beginTuple, 〚`T0`〛, 〚`T1`〛, ..., .endTuple
  /// ```
  ///
  /// - Parameter buffer: A buffer whose byte count is at least the byte count
  ///   of the regular expression string that produced this capture structure.
  public func encode(to buffer: UnsafeMutableRawBufferPointer) {
    assert(!buffer.isEmpty, "Buffer must not be empty")
    assert(
      buffer.count >=
        MemoryLayout<SerializationVersion>.stride + MemoryLayout<Code>.stride)
    // Encode version.
    buffer.storeBytes(
      of: Self.currentSerializationVersion, as: SerializationVersion.self)
    // Encode contents.
    var offset = MemoryLayout<SerializationVersion>.stride
    /// Appends a code to the buffer, advancing the offset to the next position.
    func append(_ code: Code) {
      buffer.storeBytes(of: code, toByteOffset: offset, as: Code.self)
      offset += MemoryLayout<Code>.stride
    }
    /// Recursively encode the node to the buffer.
    func encode(_ node: CaptureStructure, isTopLevel: Bool = false) {
      switch node {
      // 〚`T` (atom)〛 ==> .atom
      case .atom(name: nil, type: nil):
        append(.atom)
      // 〚`name: T` (atom)〛 ==> .atom, `name`, '\0'
      case .atom(name: let name?, type: nil):
        append(.namedAtom)
        let nameCString = name.utf8CString
        let nameSlot = UnsafeMutableRawBufferPointer(
          rebasing: buffer[offset ..< offset+nameCString.count])
        nameCString.withUnsafeBytes(nameSlot.copyMemory(from:))
        offset += nameCString.count
      case .atom(_, _?):
        fatalError("Cannot encode a capture structure with explicit types")
      // 〚`[T]`〛 ==> 〚`T`〛, .formArray
      case .array(let child):
        encode(child)
        append(.formArray)
      // 〚`T?`〛 ==> 〚`T`〛, .formOptional
      case .optional(let child):
        encode(child)
        append(.formOptional)
      // 〚`(T0, T1, ...)` (top level)〛 ==> 〚`T0`〛, 〚`T1`〛, ...
      // 〚`(T0, T1, ...)`〛 ==> .beginTuple, 〚`T0`〛, 〚`T1`〛, ..., .endTuple
      case .tuple(let children):
        if !isTopLevel {
          append(.beginTuple)
        }
        for child in children {
          encode(child)
        }
        if !isTopLevel {
          append(.endTuple)
        }
      }
    }
    if !isEmpty {
      encode(self, isTopLevel: true)
    }
    append(.end)
  }

  /// Creates a capture structure by decoding a serialized representation from
  /// the given buffer.
  public init?(decoding buffer: UnsafeRawBufferPointer) {
    var scopes: [[CaptureStructure]] = [[]]
    var currentScope: [CaptureStructure] {
      get { scopes[scopes.endIndex - 1] }
      _modify { yield &scopes[scopes.endIndex - 1] }
    }
    // Decode version.
    let version = buffer.load(as: SerializationVersion.self)
    guard version == Self.currentSerializationVersion else {
      return nil
    }
    // Decode contents.
    var offset = MemoryLayout<SerializationVersion>.stride
    /// Returns the next code in the buffer, or nil if the memory does not
    /// contain a valid code.
    func nextCode() -> Code? {
      defer { offset += MemoryLayout<Code>.stride }
      let rawValue = buffer.load(fromByteOffset: offset, as: Code.RawValue.self)
      return Code(rawValue: rawValue)
    }
    repeat {
      guard let code = nextCode() else {
        return nil
      }
      switch code {
      case .end:
        offset = buffer.endIndex
      case .atom:
        currentScope.append(.atom())
      case .namedAtom:
        let stringAddress = buffer.baseAddress.unsafelyUnwrapped
          .advanced(by: offset)
          .assumingMemoryBound(to: CChar.self)
        let name = String(cString: stringAddress)
        offset += name.utf8CString.count
        currentScope.append(.atom(name: name))
      case .formArray:
        let lastIndex = currentScope.endIndex - 1
        currentScope[lastIndex] = .array(currentScope[lastIndex])
      case .formOptional:
        let lastIndex = currentScope.endIndex - 1
        currentScope[lastIndex] = .optional(currentScope[lastIndex])
      case .beginTuple:
        scopes.append([])
      case .endTuple:
        let lastScope = scopes.removeLast()
        currentScope.append(.tuple(lastScope))
      }
    } while offset < buffer.endIndex
    guard scopes.count == 1 else {
      return nil // Malformed serialization.
    }
    self = currentScope.count == 1 ? currentScope[0] : .tuple(currentScope)
  }
}
