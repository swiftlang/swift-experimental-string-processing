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

  public init() {
    captures = []
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

    public init(
      name: String? = nil,
      type: Any.Type? = nil,
      optionalDepth: Int
    ) {
      self.name = name
      self.type = type
      self.optionalDepth = optionalDepth
    }
  }
}

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
        list.append(.init(optionalDepth: nesting))

      case .namedCapture(let name):
        list.append(.init(name: name.value, optionalDepth: nesting))

      case .balancedCapture(let b):
        list.append(.init(name: b.name?.value, optionalDepth: nesting))

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

    case .quote, .trivia, .atom, .customCharacterClass, .empty:
      break
    }
  }

  public var _captureList: CaptureList {
    var caps = CaptureList()
    self._addCaptures(to: &caps, optionalNesting: 0)
    return caps
  }
}

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
