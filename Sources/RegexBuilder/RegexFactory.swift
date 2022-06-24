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

@_spi(RegexBuilder) import _StringProcessing

@usableFromInline
enum _RegexFactory {
  @usableFromInline
  struct _Node {
    let node: DSLTree.Node
    
    @usableFromInline
    func appending(_ other: _Node) -> _Node {
      node.appending(other.node).factory
    }
    
    @usableFromInline
    func appendingAlternationCase(_ other: _Node) -> _Node {
      node.appendingAlternationCase(other.node).factory
    }
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func node<Output>(_ node: _Node) -> Regex<Output> {
    .init(node: node.node)
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func zeroOrOne<Output>(
    _ behavior: RegexRepetitionBehavior?,
    _ node: _Node
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return .init(node: .quantification(.zeroOrOne, kind, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func zeroOrMore<Output>(
    _ behavior: RegexRepetitionBehavior?,
    _ node: _Node
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return .init(node: .quantification(.zeroOrMore, kind, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func oneOrMore<Output>(
    _ behavior: RegexRepetitionBehavior?,
    _ node: _Node
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return .init(node: .quantification(.oneOrMore, kind, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func exactly<Output>(
    _ count: Int,
    _ node: _Node
  ) -> Regex<Output> {
    .init(node: .quantification(.exactly(count), .default, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func repeating<Output>(
    _ range: Range<Int>,
    _ behavior: RegexRepetitionBehavior?,
    _ node: _Node
  ) -> Regex<Output> {
    .init(node: .repeating(range, behavior, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func atomicNonCapturing<Output>(_ node: _Node) -> Regex<Output> {
    .init(node: .nonCapturingGroup(.atomicNonCapturing, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func orderedChoice<Output>(_ node: _Node) -> Regex<Output> {
    .init(node: .orderedChoice([node.node]))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func capture<Output>(
    _ node: _Node
  ) -> Regex<Output> {
    .init(node: .capture(node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func capture<Output, W>(
    _ node: _Node,
    _ reference: Reference<W>
  ) -> Regex<Output> {
    .init(node: .capture(reference: reference.id, node.node))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func capture<Output, W, NewCapture>(
    _ node: _Node,
    _ reference: Reference<NewCapture>? = nil,
    _ transform: @escaping (W) throws -> NewCapture
  ) -> Regex<Output> {
    .init(node: .capture(
      reference: reference?.id,
      node.node,
      CaptureTransform(transform)
    ))
  }
  
  @available(SwiftStdlib 5.7, *)
  @usableFromInline
  static func captureOptional<Output, W, NewCapture>(
    _ node: _Node,
    _ reference: Reference<NewCapture>? = nil,
    _ transform: @escaping (W) throws -> NewCapture?
  ) -> Regex<Output> {
    .init(node: .capture(
      reference: reference?.id,
      node.node,
      CaptureTransform(transform)
    ))
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  @usableFromInline
  var _root: _RegexFactory._Node {
    root.factory
  }
}

extension DSLTree.Node {
  @usableFromInline
  var factory: _RegexFactory._Node {
    _RegexFactory._Node(node: self)
  }
}
