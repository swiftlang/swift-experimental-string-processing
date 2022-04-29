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

// TODO: Remove and directly serialize CaptureList instead

// A tree representing the type of some captures, used for communication
// with the compiler.
enum CaptureStructure: Equatable {
  case atom(name: String? = nil, type: AnyType? = nil)
  indirect case optional(CaptureStructure)
  indirect case tuple([CaptureStructure])

  static func tuple(_ children: CaptureStructure...) -> Self {
    tuple(children)
  }

  static var empty: Self {
    .tuple([])
  }
}

// MARK: - Common properties

extension CaptureStructure {
  /// Returns a Boolean indicating whether the structure does not contain any
  /// captures.
  private var isEmpty: Bool {
    if case .tuple(let elements) = self, elements.isEmpty {
      return true
    }
    return false
  }
}

// MARK: - Serialization

extension CaptureStructure {
  /// A byte-sized serialization code.
  private enum Code: UInt8 {
    case end           = 0
    case atom          = 1
    case namedAtom     = 2
//    case formArray     = 3
    case formOptional  = 4
    case beginTuple    = 5
    case endTuple      = 6
  }

  private typealias SerializationVersion = UInt16
  private static let currentSerializationVersion: SerializationVersion = 1

  static func serializationBufferSize(
    forInputUTF8CodeUnitCount inputUTF8CodeUnitCount: Int
  ) -> Int {
    MemoryLayout<SerializationVersion>.stride + inputUTF8CodeUnitCount + 1
  }

  /// Encodes the capture structure to the given buffer as a serialized
  /// representation.
  ///
  /// The encoding rules are as follows:
  ///
  /// ```
  /// encode(〚`T`〛) ==> <version>, 〚`T`〛, .end
  /// 〚`T` (atom)〛 ==> .atom
  /// 〚`name: T` (atom)〛 ==> .atom, `name`, '\0'
  /// 〚`T?`〛 ==> 〚`T`〛, .formOptional
  /// 〚`(T0, T1, ...)` (top level)〛 ==> 〚`T0`〛, 〚`T1`〛, ...
  /// 〚`(T0, T1, ...)`〛 ==> .beginTuple, 〚`T0`〛, 〚`T1`〛, ..., .endTuple
  /// ```
  ///
  /// - Parameter buffer: A buffer whose byte count is at least the byte count
  ///   of the regular expression string that produced this capture structure.
  func encode(to buffer: UnsafeMutableRawBufferPointer) {
    assert(!buffer.isEmpty, "Buffer must not be empty")
    assert(
      buffer.count >=
        MemoryLayout<SerializationVersion>.stride + MemoryLayout<Code>.stride)
    // Encode version (unaligned store).
    withUnsafeBytes(of: Self.currentSerializationVersion) {
      buffer.copyMemory(from: $0)
    }
    // Encode contents.
    var offset = MemoryLayout<SerializationVersion>.stride
    /// Appends a code to the buffer, advancing the offset to the next position.
    func append(_ code: Code) {
      buffer.storeBytes(
        of: code.rawValue, toByteOffset: offset, as: UInt8.self)
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
  init?(decoding buffer: UnsafeRawBufferPointer) {
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

extension CaptureStructure: CustomStringConvertible {
  var description: String {
    var printer = PrettyPrinter()
    _print(&printer)
    return printer.finish()
  }

  func _print(_ printer: inout PrettyPrinter) {
    switch self {
    case let .atom(name, type):
      let name = name ?? "<unnamed>"
      let type = type == nil ? "<untyped>"
                             : String(describing: type)
      printer.print("Atom(\(name): \(type))")

    case let .optional(c):
      printer.printBlock("Optional") { printer in
        c._print(&printer)
      }

    case let .tuple(cs):
      printer.printBlock("Tuple") { printer in
        for c in cs {
          c._print(&printer)
        }
      }

    }
  }
}

extension AST {
  /// The capture structure of this AST for compiler communication.
  var captureStructure: CaptureStructure {
    root._captureList._captureStructure(nestOptionals: true)
  }
}

// MARK: Convert CaptureList into CaptureStructure

extension CaptureList {
  func _captureStructure(nestOptionals: Bool) -> CaptureStructure {
    if captures.isEmpty { return .empty }
    if captures.count == 1 {
      return captures.first!._captureStructure(nestOptionals: nestOptionals)
    }
    return .tuple(captures.map {
      $0._captureStructure(nestOptionals: nestOptionals)
    })
  }
}

extension CaptureList.Capture {
  func _captureStructure(nestOptionals: Bool) -> CaptureStructure {
    if optionalDepth == 0 {
      if let ty = type {
        return .atom(name: name, type: .init(ty))
      }
      return .atom(name: name)
    }
    var copy = self
    copy.optionalDepth = 0
    var base = copy._captureStructure(nestOptionals: false)
    for _ in 0..<(nestOptionals ? optionalDepth : 1) {
      base = .optional(base)
    }
    return base
  }
}
