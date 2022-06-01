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

public struct CaptureList {
  public var captures: [Capture]

  public init<S: Sequence>(_ s: S) where S.Element == Capture {
    captures = Array(s)
  }

  public mutating func append(_ c: Capture) {
    captures.append(c)
  }
}

extension CaptureList {
  public struct Capture {
    public var name: String?
    public var type: Any.Type?
    public var optionalDepth: Int
    public var location: SourceLocation

    public init(
      name: String? = nil,
      type: Any.Type? = nil,
      optionalDepth: Int,
      _ location: SourceLocation
    ) {
      self.name = name
      self.type = type
      self.optionalDepth = optionalDepth
      self.location = location
    }
  }
}

extension CaptureList {
  /// Retrieve the capture index of a given named capture, or `nil` if there is
  /// no such capture.
  public func indexOfCapture(named name: String) -> Int? {
    // Named references are guaranteed to be unique for literal ASTs by Sema.
    // The DSL tree does not use named references.
    captures.indices.first(where: { captures[$0].name == name })
  }

  /// Whether the capture list has a given named capture.
  public func hasCapture(named name: String) -> Bool {
    indexOfCapture(named: name) != nil
  }
}

// MARK: Generating from AST

extension AST.Node {
  public func _addCaptures(
    to list: inout CaptureList,
    optionalNesting nesting: Int
  ) {
    let addOptional = nesting+1
    switch self {
    case let .alternation(a):
      for child in a.children {
        child._addCaptures(to: &list, optionalNesting: addOptional)
      }

    case let .concatenation(c):
      for child in c.children {
        child._addCaptures(to: &list, optionalNesting: nesting)
      }

    case let .group(g):
      switch g.kind.value {
      case .capture:
        list.append(.init(optionalDepth: nesting, g.location))

      case .namedCapture(let name):
        list.append(.init(name: name.value, optionalDepth: nesting, g.location))

      case .balancedCapture(let b):
        list.append(.init(name: b.name?.value, optionalDepth: nesting,
                          g.location))

      default: break
      }
      g.child._addCaptures(to: &list, optionalNesting: nesting)

    case .conditional(let c):
      switch c.condition.kind {
      case .group(let g):
        AST.Node.group(g)._addCaptures(to: &list, optionalNesting: nesting)
      default:
        break
      }

      c.trueBranch._addCaptures(to: &list, optionalNesting: addOptional)
      c.falseBranch._addCaptures(to: &list, optionalNesting: addOptional)

    case .quantification(let q):
      var optNesting = nesting
      if q.amount.value.bounds.atLeast == 0 {
        optNesting += 1
      }
      q.child._addCaptures(to: &list, optionalNesting: optNesting)

    case .absentFunction(let abs):
      switch abs.kind {
      case .expression(_, _, let child):
        child._addCaptures(to: &list, optionalNesting: nesting)
      case .clearer, .repeater, .stopper:
        break
      }

    case .quote, .trivia, .atom, .customCharacterClass, .empty, .interpolation:
      break
    }
  }

  public var _captureList: CaptureList {
    var caps = CaptureList()
    self._addCaptures(to: &caps, optionalNesting: 0)
    return caps
  }
}

extension AST {
  /// Get the capture list for this AST
  public var captureList: CaptureList {
    root._captureList
  }
}

// MARK: Convenience for testing and inspection

extension CaptureList.Capture: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.name == rhs.name &&
    lhs.optionalDepth == rhs.optionalDepth &&
    lhs.type == rhs.type &&
    lhs.location == rhs.location
  }
}
extension CaptureList: Equatable {}

extension CaptureList.Capture: CustomStringConvertible {
  public var description: String {
    let typeStr: String
    if let ty = type {
      typeStr = "\(ty)"
    } else {
      typeStr = "Substring"
    }
    let suffix = String(repeating: "?", count: optionalDepth)

    let prefix: String
    if let name = name {
      prefix = name + ": "
    } else {
      prefix = ""
    }

    return prefix + typeStr + suffix
  }
}
extension CaptureList: CustomStringConvertible {
  public var description: String {
    "(" + captures.map(\.description).joined(separator: ", ") + ")"
  }
}

extension CaptureList: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Capture...) {
    self.init(elements)
  }
}
