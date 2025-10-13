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
    public var type: Any.Type
    public var optionalDepth: Int
    public var location: SourceLocation
    public var visibleInTypedOutput: Bool

    public init(
      name: String? = nil,
      type: Any.Type = Substring.self,
      optionalDepth: Int,
      visibleInTypedOutput: Bool,
      _ location: SourceLocation
    ) {
      self.name = name
      self.type = type
      self.optionalDepth = optionalDepth
      self.visibleInTypedOutput = visibleInTypedOutput
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

extension CaptureList {
  public struct Builder {
    public var captures = CaptureList()

    public init() {}

    public struct OptionalNesting {
      // We maintain two depths, inner and outer. These allow e.g the nesting
      // of a regex literal in a DSL, where outside of the scope of the literal,
      // nesting is allowed, but inside the literal at most one extra layer of
      // optionality may be added.
      public var outerDepth: Int
      public var canNest: Bool
      public var innerDepth: Int

      internal init(outerDepth: Int, canNest: Bool) {
        self.outerDepth = outerDepth
        self.canNest = canNest
        self.innerDepth = 0
      }

      public init(canNest: Bool) {
        self.init(outerDepth: 0, canNest: canNest)
      }

      public var depth: Int { outerDepth + innerDepth }

      public var disablingNesting: Self {
        // If we are currently able to nest, store the current depth as the
        // outer depth, and disable nesting for an inner scope.
        guard canNest else { return self }
        return .init(outerDepth: depth, canNest: false)
      }

      public var addingOptional: Self {
        var result = self
        result.innerDepth = canNest ? innerDepth + 1 : 1
        return result
      }
    }
  }
}

// MARK: Generating from AST

extension CaptureList.Builder {
  public mutating func addCaptures(
    of node: AST.Node,
    optionalNesting nesting: OptionalNesting,
    visibleInTypedOutput: Bool
  ) {
    switch node {
    case let .alternation(a):
      for child in a.children {
        addCaptures(of: child, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)
      }

    case let .concatenation(c):
      for child in c.children {
        addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      }

    case let .group(g):
      switch g.kind.value {
      case .capture:
        captures.append(.init(optionalDepth: nesting.depth, visibleInTypedOutput: visibleInTypedOutput, g.location))

      case .namedCapture(let name):
        captures.append(.init(
          name: name.value, optionalDepth: nesting.depth, visibleInTypedOutput: visibleInTypedOutput, g.location))

      case .balancedCapture(let b):
        captures.append(.init(
          name: b.name?.value, optionalDepth: nesting.depth, visibleInTypedOutput: visibleInTypedOutput, g.location))

      default: break
      }
      addCaptures(of: g.child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)

    case .conditional(let c):
      switch c.condition.kind {
      case .group(let g):
        addCaptures(of: .group(g), optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      default:
        break
      }

      addCaptures(of: c.trueBranch, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)
      addCaptures(of: c.falseBranch, optionalNesting: nesting.addingOptional, visibleInTypedOutput: visibleInTypedOutput)

    case .quantification(let q):
      var optNesting = nesting
      if q.amount.value.bounds.atLeast == 0 {
        optNesting = optNesting.addingOptional
      }
      addCaptures(of: q.child, optionalNesting: optNesting, visibleInTypedOutput: visibleInTypedOutput)

    case .absentFunction(let abs):
      switch abs.kind {
      case .expression(_, _, let child):
        addCaptures(of: child, optionalNesting: nesting, visibleInTypedOutput: visibleInTypedOutput)
      case .clearer, .repeater, .stopper:
        break
      }

    case .quote, .trivia, .atom, .customCharacterClass, .empty, .interpolation:
      break
    }
  }
  public static func build(_ ast: AST) -> CaptureList {
    var builder = Self()
    builder.captures.append(.init(optionalDepth: 0, visibleInTypedOutput: true, .fake))
    builder.addCaptures(of: ast.root, optionalNesting: .init(canNest: false), visibleInTypedOutput: true)
    return builder.captures
  }
}

extension AST {
  /// The capture list (including the whole match) of this AST.
  public var captureList: CaptureList { .Builder.build(self) }
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
    let typeStr = String(describing: type)
    let suffix = String(repeating: "?", count: optionalDepth)
    return typeStr + suffix
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
