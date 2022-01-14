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

// BEGIN AUTO-GENERATED CONTENT

import _MatchingEngine

extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0>(_ regex: R) -> R
  where R.Match == (W, C0)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1>(_ regex: R) -> R
  where R.Match == (W, C0, C1)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2, C3>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2, C3)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2, C3, C4>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2, C3, C4)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2, C3, C4, C5)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2, C3, C4, C5, C6)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7)
  {
    regex
  }
}
extension RegexBuilder {
  public static func buildBlock<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ regex: R) -> R
  where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  {
    regex
  }
}
public struct Concatenate_0_1<
  W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0) {
  public typealias Match = (Substring, C0)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_1<W0, W1, C0, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_2<
  W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1) {
  public typealias Match = (Substring, C0, C1)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_2<W0, W1, C0, C1, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_3<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2) {
  public typealias Match = (Substring, C0, C1, C2)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_3<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_4<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3) {
  public typealias Match = (Substring, C0, C1, C2, C3)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_4<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_5<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_5<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_6<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_6<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_8<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_8<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_9<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_9<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_10<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_10<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_1<
  W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1) {
  public typealias Match = (Substring, C0, C1)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_1<W0, W1, C0, C1, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_2<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
  public typealias Match = (Substring, C0, C1, C2)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_2<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_3<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
  public typealias Match = (Substring, C0, C1, C2, C3)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_3<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_4<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_4<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_5<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_5<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_8<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_8<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_9<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_9<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_1<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
  public typealias Match = (Substring, C0, C1, C2)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_1<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_2<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
  public typealias Match = (Substring, C0, C1, C2, C3)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_2<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_3<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_3<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_4<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_4<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_8<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_8<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_1<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
  public typealias Match = (Substring, C0, C1, C2, C3)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_1<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_2<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_2<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_3<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_3<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_1<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_1<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_2<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_2<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_1<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_1<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_8_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_8_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_8_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_8_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_9_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_9_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Substring> where R0.Match == W0  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0)> where R0.Match == (W0, C0)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)> where R0.Match == (W0, C0, C1)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)> where R0.Match == (W0, C0, C1, C2)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)> where R0.Match == (W0, C0, C1, C2, C3)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)> where R0.Match == (W0, C0, C1, C2, C3, C4)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}


public struct _ZeroOrOne_0<Component: RegexProtocol>: RegexProtocol  {
  public typealias Match = Substring
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_0<Component> {
  .init(component: component)
}

@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_0<Component> {
  optionally(component())
}

@_disfavoredOverload
public postfix func .?<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_0<Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_0<Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_0<Component: RegexProtocol>: RegexProtocol  {
  public typealias Match = Substring
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}

@_disfavoredOverload
public func many<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_0<Component> {
  .init(component: component)
}

@_disfavoredOverload
public func many<Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_0<Component> {
  many(component())
}

@_disfavoredOverload
public postfix func .+<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_0<Component> {
  many(component)
}


public struct _OneOrMore_0<Component: RegexProtocol>: RegexProtocol  {
  public typealias Match = Substring
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}

@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_0<Component> {
  .init(component: component)
}

@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_0<Component> {
  oneOrMore(component())
}

@_disfavoredOverload
public postfix func .*<Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_0<Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_1<W, C0, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0) {
  public typealias Match = (Substring, C0?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_1<W, C0, Component> {
  .init(component: component)
}


public func optionally<W, C0, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_1<W, C0, Component> {
  optionally(component())
}


public postfix func .?<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_1<W, C0, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_1<W, C0, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_1<W, C0, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0) {
  public typealias Match = (Substring, [C0])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_1<W, C0, Component> {
  .init(component: component)
}


public func many<W, C0, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_1<W, C0, Component> {
  many(component())
}


public postfix func .+<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_1<W, C0, Component> {
  many(component)
}


public struct _OneOrMore_1<W, C0, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0) {
  public typealias Match = (Substring, [C0])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_1<W, C0, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_1<W, C0, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_1<W, C0, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_2<W, C0, C1, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1) {
  public typealias Match = (Substring, (C0, C1)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_2<W, C0, C1, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_2<W, C0, C1, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_2<W, C0, C1, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_2<W, C0, C1, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_2<W, C0, C1, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1) {
  public typealias Match = (Substring, [(C0, C1)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_2<W, C0, C1, Component> {
  .init(component: component)
}


public func many<W, C0, C1, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_2<W, C0, C1, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_2<W, C0, C1, Component> {
  many(component)
}


public struct _OneOrMore_2<W, C0, C1, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1) {
  public typealias Match = (Substring, [(C0, C1)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_2<W, C0, C1, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_2<W, C0, C1, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_2<W, C0, C1, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_3<W, C0, C1, C2, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2) {
  public typealias Match = (Substring, (C0, C1, C2)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_3<W, C0, C1, C2, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2) {
  public typealias Match = (Substring, [(C0, C1, C2)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_3<W, C0, C1, C2, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_3<W, C0, C1, C2, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_3<W, C0, C1, C2, Component> {
  many(component)
}


public struct _OneOrMore_3<W, C0, C1, C2, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2) {
  public typealias Match = (Substring, [(C0, C1, C2)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_3<W, C0, C1, C2, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_3<W, C0, C1, C2, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_3<W, C0, C1, C2, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_4<W, C0, C1, C2, C3, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3) {
  public typealias Match = (Substring, (C0, C1, C2, C3)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_4<W, C0, C1, C2, C3, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3) {
  public typealias Match = (Substring, [(C0, C1, C2, C3)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_4<W, C0, C1, C2, C3, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_4<W, C0, C1, C2, C3, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_4<W, C0, C1, C2, C3, Component> {
  many(component)
}


public struct _OneOrMore_4<W, C0, C1, C2, C3, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3) {
  public typealias Match = (Substring, [(C0, C1, C2, C3)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_4<W, C0, C1, C2, C3, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_4<W, C0, C1, C2, C3, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_4<W, C0, C1, C2, C3, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4) {
  public typealias Match = (Substring, (C0, C1, C2, C3, C4)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  many(component)
}


public struct _OneOrMore_5<W, C0, C1, C2, C3, C4, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, (C0, C1, C2, C3, C4, C5)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  many(component)
}


public struct _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, (C0, C1, C2, C3, C4, C5, C6)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5, C6)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  many(component)
}


public struct _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5, C6)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  many(component)
}


public struct _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  many(component)
}


public struct _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>: RegexProtocol where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  oneOrMore(component)
}


public struct _Alternation_0_0<R0, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol {
  public typealias Match = Substring
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1>(combining next: R1, into combined: R0) -> _Alternation_0_0<R0, R1> {
    .init(combined, next)
  }
}

public func | <R0, R1>(lhs: R0, rhs: R1) -> _Alternation_0_0<R0, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_0_1<R0, R1, W1, C0>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0) {
  public typealias Match = (Substring, C0?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0>(combining next: R1, into combined: R0) -> _Alternation_0_1<R0, R1, W1, C0> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0>(lhs: R0, rhs: R1) -> _Alternation_0_1<R0, R1, W1, C0> {
  .init(lhs, rhs)
}
public struct _Alternation_0_2<R0, R1, W1, C0, C1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1) {
  public typealias Match = (Substring, C0?, C1?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1>(combining next: R1, into combined: R0) -> _Alternation_0_2<R0, R1, W1, C0, C1> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1>(lhs: R0, rhs: R1) -> _Alternation_0_2<R0, R1, W1, C0, C1> {
  .init(lhs, rhs)
}
public struct _Alternation_0_3<R0, R1, W1, C0, C1, C2>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2) {
  public typealias Match = (Substring, C0?, C1?, C2?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2>(combining next: R1, into combined: R0) -> _Alternation_0_3<R0, R1, W1, C0, C1, C2> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2>(lhs: R0, rhs: R1) -> _Alternation_0_3<R0, R1, W1, C0, C1, C2> {
  .init(lhs, rhs)
}
public struct _Alternation_0_4<R0, R1, W1, C0, C1, C2, C3>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3>(combining next: R1, into combined: R0) -> _Alternation_0_4<R0, R1, W1, C0, C1, C2, C3> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3>(lhs: R0, rhs: R1) -> _Alternation_0_4<R0, R1, W1, C0, C1, C2, C3> {
  .init(lhs, rhs)
}
public struct _Alternation_0_5<R0, R1, W1, C0, C1, C2, C3, C4>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?, C4?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4>(combining next: R1, into combined: R0) -> _Alternation_0_5<R0, R1, W1, C0, C1, C2, C3, C4> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4>(lhs: R0, rhs: R1) -> _Alternation_0_5<R0, R1, W1, C0, C1, C2, C3, C4> {
  .init(lhs, rhs)
}
public struct _Alternation_0_6<R0, R1, W1, C0, C1, C2, C3, C4, C5>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?, C4?, C5?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5>(combining next: R1, into combined: R0) -> _Alternation_0_6<R0, R1, W1, C0, C1, C2, C3, C4, C5> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> _Alternation_0_6<R0, R1, W1, C0, C1, C2, C3, C4, C5> {
  .init(lhs, rhs)
}
public struct _Alternation_0_7<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>(combining next: R1, into combined: R0) -> _Alternation_0_7<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> _Alternation_0_7<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_0_8<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_0_8<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_0_8<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_0_9<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_0_9<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_0_9<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_0_10<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_0_10<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_0_10<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_1_0<R0, W0, C0, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0) {
  public typealias Match = (Substring, C0)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1>(combining next: R1, into combined: R0) -> _Alternation_1_0<R0, W0, C0, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1>(lhs: R0, rhs: R1) -> _Alternation_1_0<R0, W0, C0, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_1_1<R0, W0, C0, R1, W1, C1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1) {
  public typealias Match = (Substring, C0, C1?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1>(combining next: R1, into combined: R0) -> _Alternation_1_1<R0, W0, C0, R1, W1, C1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1>(lhs: R0, rhs: R1) -> _Alternation_1_1<R0, W0, C0, R1, W1, C1> {
  .init(lhs, rhs)
}
public struct _Alternation_1_2<R0, W0, C0, R1, W1, C1, C2>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
  public typealias Match = (Substring, C0, C1?, C2?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2>(combining next: R1, into combined: R0) -> _Alternation_1_2<R0, W0, C0, R1, W1, C1, C2> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2>(lhs: R0, rhs: R1) -> _Alternation_1_2<R0, W0, C0, R1, W1, C1, C2> {
  .init(lhs, rhs)
}
public struct _Alternation_1_3<R0, W0, C0, R1, W1, C1, C2, C3>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3>(combining next: R1, into combined: R0) -> _Alternation_1_3<R0, W0, C0, R1, W1, C1, C2, C3> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3>(lhs: R0, rhs: R1) -> _Alternation_1_3<R0, W0, C0, R1, W1, C1, C2, C3> {
  .init(lhs, rhs)
}
public struct _Alternation_1_4<R0, W0, C0, R1, W1, C1, C2, C3, C4>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?, C4?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4>(combining next: R1, into combined: R0) -> _Alternation_1_4<R0, W0, C0, R1, W1, C1, C2, C3, C4> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4>(lhs: R0, rhs: R1) -> _Alternation_1_4<R0, W0, C0, R1, W1, C1, C2, C3, C4> {
  .init(lhs, rhs)
}
public struct _Alternation_1_5<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?, C4?, C5?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>(combining next: R1, into combined: R0) -> _Alternation_1_5<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> _Alternation_1_5<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5> {
  .init(lhs, rhs)
}
public struct _Alternation_1_6<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>(combining next: R1, into combined: R0) -> _Alternation_1_6<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> _Alternation_1_6<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_1_7<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_1_7<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_1_7<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_1_8<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_1_8<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_1_8<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_1_9<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_1_9<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_1_9<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_2_0<R0, W0, C0, C1, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1) {
  public typealias Match = (Substring, C0, C1)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1>(combining next: R1, into combined: R0) -> _Alternation_2_0<R0, W0, C0, C1, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1>(lhs: R0, rhs: R1) -> _Alternation_2_0<R0, W0, C0, C1, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_2_1<R0, W0, C0, C1, R1, W1, C2>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
  public typealias Match = (Substring, C0, C1, C2?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2>(combining next: R1, into combined: R0) -> _Alternation_2_1<R0, W0, C0, C1, R1, W1, C2> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2>(lhs: R0, rhs: R1) -> _Alternation_2_1<R0, W0, C0, C1, R1, W1, C2> {
  .init(lhs, rhs)
}
public struct _Alternation_2_2<R0, W0, C0, C1, R1, W1, C2, C3>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
  public typealias Match = (Substring, C0, C1, C2?, C3?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3>(combining next: R1, into combined: R0) -> _Alternation_2_2<R0, W0, C0, C1, R1, W1, C2, C3> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3>(lhs: R0, rhs: R1) -> _Alternation_2_2<R0, W0, C0, C1, R1, W1, C2, C3> {
  .init(lhs, rhs)
}
public struct _Alternation_2_3<R0, W0, C0, C1, R1, W1, C2, C3, C4>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2?, C3?, C4?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4>(combining next: R1, into combined: R0) -> _Alternation_2_3<R0, W0, C0, C1, R1, W1, C2, C3, C4> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4>(lhs: R0, rhs: R1) -> _Alternation_2_3<R0, W0, C0, C1, R1, W1, C2, C3, C4> {
  .init(lhs, rhs)
}
public struct _Alternation_2_4<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2?, C3?, C4?, C5?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>(combining next: R1, into combined: R0) -> _Alternation_2_4<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> _Alternation_2_4<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5> {
  .init(lhs, rhs)
}
public struct _Alternation_2_5<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2?, C3?, C4?, C5?, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>(combining next: R1, into combined: R0) -> _Alternation_2_5<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> _Alternation_2_5<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_2_6<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_2_6<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_2_6<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_2_7<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_2_7<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_2_7<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_2_8<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_2_8<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_2_8<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_3_0<R0, W0, C0, C1, C2, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2) {
  public typealias Match = (Substring, C0, C1, C2)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1>(combining next: R1, into combined: R0) -> _Alternation_3_0<R0, W0, C0, C1, C2, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1>(lhs: R0, rhs: R1) -> _Alternation_3_0<R0, W0, C0, C1, C2, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_3_1<R0, W0, C0, C1, C2, R1, W1, C3>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
  public typealias Match = (Substring, C0, C1, C2, C3?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3>(combining next: R1, into combined: R0) -> _Alternation_3_1<R0, W0, C0, C1, C2, R1, W1, C3> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3>(lhs: R0, rhs: R1) -> _Alternation_3_1<R0, W0, C0, C1, C2, R1, W1, C3> {
  .init(lhs, rhs)
}
public struct _Alternation_3_2<R0, W0, C0, C1, C2, R1, W1, C3, C4>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3?, C4?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4>(combining next: R1, into combined: R0) -> _Alternation_3_2<R0, W0, C0, C1, C2, R1, W1, C3, C4> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4>(lhs: R0, rhs: R1) -> _Alternation_3_2<R0, W0, C0, C1, C2, R1, W1, C3, C4> {
  .init(lhs, rhs)
}
public struct _Alternation_3_3<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3?, C4?, C5?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>(combining next: R1, into combined: R0) -> _Alternation_3_3<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>(lhs: R0, rhs: R1) -> _Alternation_3_3<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5> {
  .init(lhs, rhs)
}
public struct _Alternation_3_4<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3?, C4?, C5?, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>(combining next: R1, into combined: R0) -> _Alternation_3_4<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> _Alternation_3_4<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_3_5<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_3_5<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_3_5<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_3_6<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_3_6<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_3_6<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_3_7<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_3_7<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_3_7<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_4_0<R0, W0, C0, C1, C2, C3, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3) {
  public typealias Match = (Substring, C0, C1, C2, C3)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1>(combining next: R1, into combined: R0) -> _Alternation_4_0<R0, W0, C0, C1, C2, C3, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1>(lhs: R0, rhs: R1) -> _Alternation_4_0<R0, W0, C0, C1, C2, C3, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_4_1<R0, W0, C0, C1, C2, C3, R1, W1, C4>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4>(combining next: R1, into combined: R0) -> _Alternation_4_1<R0, W0, C0, C1, C2, C3, R1, W1, C4> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4>(lhs: R0, rhs: R1) -> _Alternation_4_1<R0, W0, C0, C1, C2, C3, R1, W1, C4> {
  .init(lhs, rhs)
}
public struct _Alternation_4_2<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4?, C5?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>(combining next: R1, into combined: R0) -> _Alternation_4_2<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>(lhs: R0, rhs: R1) -> _Alternation_4_2<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5> {
  .init(lhs, rhs)
}
public struct _Alternation_4_3<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4?, C5?, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>(combining next: R1, into combined: R0) -> _Alternation_4_3<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>(lhs: R0, rhs: R1) -> _Alternation_4_3<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_4_4<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_4_4<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_4_4<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_4_5<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_4_5<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_4_5<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_4_6<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_4_6<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_4_6<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_5_0<R0, W0, C0, C1, C2, C3, C4, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1>(combining next: R1, into combined: R0) -> _Alternation_5_0<R0, W0, C0, C1, C2, C3, C4, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1>(lhs: R0, rhs: R1) -> _Alternation_5_0<R0, W0, C0, C1, C2, C3, C4, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_5_1<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>(combining next: R1, into combined: R0) -> _Alternation_5_1<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>(lhs: R0, rhs: R1) -> _Alternation_5_1<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5> {
  .init(lhs, rhs)
}
public struct _Alternation_5_2<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5?, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>(combining next: R1, into combined: R0) -> _Alternation_5_2<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>(lhs: R0, rhs: R1) -> _Alternation_5_2<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_5_3<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_5_3<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_5_3<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_5_4<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_5_4<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_5_4<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_5_5<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_5_5<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_5_5<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_6_0<R0, W0, C0, C1, C2, C3, C4, C5, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1>(combining next: R1, into combined: R0) -> _Alternation_6_0<R0, W0, C0, C1, C2, C3, C4, C5, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1>(lhs: R0, rhs: R1) -> _Alternation_6_0<R0, W0, C0, C1, C2, C3, C4, C5, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_6_1<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>(combining next: R1, into combined: R0) -> _Alternation_6_1<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>(lhs: R0, rhs: R1) -> _Alternation_6_1<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6> {
  .init(lhs, rhs)
}
public struct _Alternation_6_2<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6?, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>(combining next: R1, into combined: R0) -> _Alternation_6_2<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>(lhs: R0, rhs: R1) -> _Alternation_6_2<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_6_3<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_6_3<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_6_3<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_6_4<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_6_4<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_6_4<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_7_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>(combining next: R1, into combined: R0) -> _Alternation_7_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>(lhs: R0, rhs: R1) -> _Alternation_7_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_7_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>(combining next: R1, into combined: R0) -> _Alternation_7_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>(lhs: R0, rhs: R1) -> _Alternation_7_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7> {
  .init(lhs, rhs)
}
public struct _Alternation_7_2<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>(combining next: R1, into combined: R0) -> _Alternation_7_2<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>(lhs: R0, rhs: R1) -> _Alternation_7_2<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_7_3<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_7_3<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_7_3<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_8_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>(combining next: R1, into combined: R0) -> _Alternation_8_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>(lhs: R0, rhs: R1) -> _Alternation_8_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_8_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>(combining next: R1, into combined: R0) -> _Alternation_8_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>(lhs: R0, rhs: R1) -> _Alternation_8_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8> {
  .init(lhs, rhs)
}
public struct _Alternation_8_2<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>(combining next: R1, into combined: R0) -> _Alternation_8_2<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>(lhs: R0, rhs: R1) -> _Alternation_8_2<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9> {
  .init(lhs, rhs)
}
public struct _Alternation_9_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>(combining next: R1, into combined: R0) -> _Alternation_9_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>(lhs: R0, rhs: R1) -> _Alternation_9_0<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1> {
  .init(lhs, rhs)
}
public struct _Alternation_9_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>: RegexProtocol where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
  public typealias Match = (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9?)
  public let regex: Regex<Match>

  public init(_ left: R0, _ right: R1) {
    self.regex = .init(node: left.regex.root.appendingAlternationCase(right.regex.root))
  }
}

extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>(combining next: R1, into combined: R0) -> _Alternation_9_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9> {
    .init(combined, next)
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>(lhs: R0, rhs: R1) -> _Alternation_9_1<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9> {
  .init(lhs, rhs)
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0>(_ regex: R) -> Regex<(W, C0?)> where R: RegexProtocol, R.Match == (W, C0) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1>(_ regex: R) -> Regex<(W, C0?, C1?)> where R: RegexProtocol, R.Match == (W, C0, C1) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2>(_ regex: R) -> Regex<(W, C0?, C1?, C2?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2, C3>(_ regex: R) -> Regex<(W, C0?, C1?, C2?, C3?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2, C3) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2, C3, C4>(_ regex: R) -> Regex<(W, C0?, C1?, C2?, C3?, C4?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2, C3, C4) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2, C3, C4, C5>(_ regex: R) -> Regex<(W, C0?, C1?, C2?, C3?, C4?, C5?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2, C3, C4, C5) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2, C3, C4, C5, C6>(_ regex: R) -> Regex<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2, C3, C4, C5, C6, C7>(_ regex: R) -> Regex<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: .alternation([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildBlock<R, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ regex: R) -> Regex<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R: RegexProtocol, R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: .alternation([regex.regex.root]))
  }
}


// END AUTO-GENERATED CONTENT
