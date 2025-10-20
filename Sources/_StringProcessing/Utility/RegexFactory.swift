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

// This type is used to manipulate DSLTree.Nodes in RegexBuilder for AEIC
// marked functions. We explicitly don't want to expose DSLTree.Node as public
// in any form (SPI or not), so this lets us create the needed Regex's in the
// builder module.
@available(SwiftStdlib 5.7, *)
public struct _RegexFactory {
  
  // Don't allow people to create this type if they somehow manage to find this.
  // Hide is behind an SPI that only RegexBuilder can use.
  @_spi(RegexBuilder)
  public init() {}

  @available(SwiftStdlib 5.9, *)
  public func ignoreCapturesInTypedOutput(
    _ child: some RegexComponent
  ) -> Regex<Substring> {
    // Don't wrap `child` again if it's a leaf node.
    child.regex.list.hasChildren
      ? child.regex.prepending(.ignoreCapturesInTypedOutput(TEMP_FAKE_NODE)) as Regex<Substring>
      : .init(list: child.regex.program.tree)
  }
  
  @available(SwiftStdlib 5.7, *)
  public func accumulate<Output>(
    _ left: some RegexComponent,
    _ right: some RegexComponent
  ) -> Regex<Output> {
    left.regex.concatenating(right.regex.program.tree.nodes)
  }
  
  @available(SwiftStdlib 5.7, *)
  public func accumulateAlternation<Output>(
    _ left: some RegexComponent,
    _ right: some RegexComponent
  ) -> Regex<Output> {
    left.regex.alternating(with: right.regex.program.tree.nodes)
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func assertion<Output>(
    _ kind: DSLTree.Atom.Assertion
  ) -> Regex<Output> {
    .init(node: .atom(.assertion(kind)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func empty<Output>() -> Regex<Output> {
    .init(node: .empty)
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func scalar<Output>(
    _ scalar: Unicode.Scalar
  ) -> Regex<Output> {
    .init(node: .atom(.scalar(scalar)))
  }

  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func characterClass<Output>(
    _ cc: DSLTree.Atom.CharacterClass
  ) -> Regex<Output> {
    .init(node: .atom(.characterClass(cc)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func char<Output>(
    _ char: Character
  ) -> Regex<Output> {
    .init(node: .atom(.char(char)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func symbolicReference<Output>(
    _ reference: ReferenceID
  ) -> Regex<Output> {
    .init(node: .atom(.symbolicReference(reference)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func customCharacterClass<Output>(
    _ ccc: DSLTree.CustomCharacterClass
  ) -> Regex<Output> {
    .init(node: .customCharacterClass(ccc))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func zeroOrOne<Output>(
    _ component: some RegexComponent,
    _ behavior: RegexRepetitionBehavior? = nil
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return component.regex.prepending(.quantification(.zeroOrOne, kind, TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func zeroOrMore<Output>(
    _ component: some RegexComponent,
    _ behavior: RegexRepetitionBehavior? = nil
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return component.regex.prepending(.quantification(.zeroOrMore, kind, TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func oneOrMore<Output>(
    _ component: some RegexComponent,
    _ behavior: RegexRepetitionBehavior? = nil
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return component.regex.prepending(.quantification(.oneOrMore, kind, TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func exactly<Output>(
    _ count: Int,
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.quantification(.exactly(count), .default, TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func repeating<Output>(
    _ range: Range<Int>,
    _ behavior: RegexRepetitionBehavior?,
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.repeating(range, behavior, TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func atomicNonCapturing<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.nonCapturingGroup(.atomicNonCapturing, TEMP_FAKE_NODE))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func lookaheadNonCapturing<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.nonCapturingGroup(.lookahead, TEMP_FAKE_NODE))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public func negativeLookaheadNonCapturing<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.nonCapturingGroup(.negativeLookahead, TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func orderedChoice<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.orderedChoice([TEMP_FAKE_NODE]))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func capture<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    component.regex.prepending(.capture(TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func capture<Output>(
    _ component: some RegexComponent,
    _ reference: Int
  ) -> Regex<Output> {
    component.regex.prepending(.capture(reference: ReferenceID(reference), TEMP_FAKE_NODE))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func capture<Output, W, NewCapture>(
    _ component: some RegexComponent,
    _ reference: Int? = nil,
    _ transform: @escaping (W) throws -> NewCapture
  ) -> Regex<Output> {
    component.regex.prepending(
      .capture(
        reference: reference.map { ReferenceID($0) },
        TEMP_FAKE_NODE,
        CaptureTransform(transform)
      ))
  }
  
  @available(SwiftStdlib 5.7, *)
  public func captureOptional<Output, W, NewCapture>(
    _ component: some RegexComponent,
    _ reference: Int? = nil,
    _ transform: @escaping (W) throws -> NewCapture?
  ) -> Regex<Output> {
    component.regex.prepending(
      .capture(
        reference: reference.map { ReferenceID($0) },
        TEMP_FAKE_NODE,
        CaptureTransform(transform)
      ))
  }
}
