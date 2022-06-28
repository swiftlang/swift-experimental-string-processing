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

@available(SwiftStdlib 5.7, *)
public enum _RegexFactory {
  @available(SwiftStdlib 5.7, *)
  public static func accumulate<Output>(
    _ left: some RegexComponent,
    _ right: some RegexComponent
  ) -> Regex<Output> {
    .init(node: left.regex.root.appending(right.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func accumulateAlternation<Output>(
    _ left: some RegexComponent,
    _ right: some RegexComponent
  ) -> Regex<Output> {
    .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func assertion<Output>(
    _ kind: DSLTree._AST.AssertionKind
  ) -> Regex<Output> {
    .init(node: .atom(.assertion(kind)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func empty<Output>() -> Regex<Output> {
    .init(node: .empty)
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func scalar<Output>(
    _ scalar: Unicode.Scalar
  ) -> Regex<Output> {
    .init(node: .atom(.scalar(scalar)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func char<Output>(
    _ char: Character
  ) -> Regex<Output> {
    .init(node: .atom(.char(char)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func symbolicReference<Output>(
    _ reference: ReferenceID
  ) -> Regex<Output> {
    .init(node: .atom(.symbolicReference(reference)))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func customCharacterClass<Output>(
    _ ccc: DSLTree.CustomCharacterClass
  ) -> Regex<Output> {
    .init(node: .customCharacterClass(ccc))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func zeroOrOne<Output>(
    _ component: some RegexComponent,
    _ behavior: RegexRepetitionBehavior? = nil
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return .init(node: .quantification(.zeroOrOne, kind, component.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func zeroOrMore<Output>(
    _ component: some RegexComponent,
    _ behavior: RegexRepetitionBehavior? = nil
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return .init(node: .quantification(.zeroOrMore, kind, component.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func oneOrMore<Output>(
    _ component: some RegexComponent,
    _ behavior: RegexRepetitionBehavior? = nil
  ) -> Regex<Output> {
    let kind: DSLTree.QuantificationKind = behavior.map { .explicit($0.dslTreeKind) } ?? .default
    return .init(node: .quantification(.oneOrMore, kind, component.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func exactly<Output>(
    _ count: Int,
    _ component: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .quantification(.exactly(count), .default, component.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func repeating<Output>(
    _ range: Range<Int>,
    _ behavior: RegexRepetitionBehavior?,
    _ component: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .repeating(range, behavior, component.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func atomicNonCapturing<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .nonCapturingGroup(.atomicNonCapturing, component.regex.root))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func lookaheadNonCapturing<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .nonCapturingGroup(.lookahead, component.regex.root))
  }
  
  @_spi(RegexBuilder)
  @available(SwiftStdlib 5.7, *)
  public static func negativeLookaheadNonCapturing<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .nonCapturingGroup(.negativeLookahead, component.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func orderedChoice<Output>(
    _ component: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .orderedChoice([component.regex.root]))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func capture<Output>(
    _ r: some RegexComponent
  ) -> Regex<Output> {
    .init(node: .capture(r.regex.root))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func capture<Output>(
    _ component: some RegexComponent,
    _ reference: Int
  ) -> Regex<Output> {
    .init(node: .capture(
      reference: ReferenceID(reference),
      component.regex.root
    ))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func capture<Output, W, NewCapture>(
    _ component: some RegexComponent,
    _ reference: Int? = nil,
    _ transform: @escaping (W) throws -> NewCapture
  ) -> Regex<Output> {
    .init(node: .capture(
      reference: reference.map { ReferenceID($0) },
      component.regex.root,
      CaptureTransform(transform)
    ))
  }
  
  @available(SwiftStdlib 5.7, *)
  public static func captureOptional<Output, W, NewCapture>(
    _ component: some RegexComponent,
    _ reference: Int? = nil,
    _ transform: @escaping (W) throws -> NewCapture?
  ) -> Regex<Output> {
    .init(node: .capture(
      reference: reference.map { ReferenceID($0) },
      component.regex.root,
      CaptureTransform(transform)
    ))
  }
}
