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
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0)>  where R0.Match == W0, R1.Match == (W1, C0) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)>  where R0.Match == W0, R1.Match == (W1, C0, C1) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)>  where R0.Match == (W0, C0), R1.Match == (W1, C1) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
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


@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}

@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}

@_disfavoredOverload
public postfix func .?<Component: RegexProtocol>(
  _ component: Component
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<Substring>  {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
@_disfavoredOverload
public func many<Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}

@_disfavoredOverload
public func many<Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}

@_disfavoredOverload
public postfix func .+<Component: RegexProtocol>(
  _ component: Component
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<Substring>  {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}

@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}

@_disfavoredOverload
public postfix func .*<Component: RegexProtocol>(
  _ component: Component
) -> Regex<Substring>  {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1)?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1)?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1)?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1)?)> where Component.Match == (W, C0, C1) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2)?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2)?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2)?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2)?)> where Component.Match == (W, C0, C1, C2) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3)?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3)?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2, C3)?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2, C3)?)> where Component.Match == (W, C0, C1, C2, C3) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4)?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4)?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4)?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2, C3, C4)?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}



public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrOne, kind.astKind, component().regex.root))
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
    _ component: Component
  ) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component.regex.root))
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, kind.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  _ kind: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ kind: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, kind.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension AlternationBuilder {
  public static func buildBlock<R0, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<Substring> where R0: RegexProtocol, R1: RegexProtocol {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1>(lhs: R0, rhs: R1) -> Regex<Substring> where R0: RegexProtocol, R1: RegexProtocol {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
    .init(node: combined.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>(lhs: R0, rhs: R1) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9?)> where R0: RegexProtocol, R1: RegexProtocol, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
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
