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
  public static func buildBlock<W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0)>  where R0.Match == W0, R1.Match == (W1, C0) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)>  where R0.Match == W0, R1.Match == (W1, C0, C1) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)>  where R0.Match == (W0, C0), R1.Match == (W1, C1) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Substring> where R0.Match == W0  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0)> where R0.Match == (W0, C0)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1)> where R0.Match == (W0, C0, C1)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2)> where R0.Match == (W0, C0, C1, C2)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3)> where R0.Match == (W0, C0, C1, C2, C3)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)> where R0.Match == (W0, C0, C1, C2, C3, C4)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8)  {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}


@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}

@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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
public func zeroOrMore<Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}

@_disfavoredOverload
public func zeroOrMore<Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
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
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring>  {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}

@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}

@_disfavoredOverload
public postfix func .*<Component: RegexProtocol>(
  _ component: Component
) -> Regex<Substring>  {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


@_disfavoredOverload
public func repeat<Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<Substring>  {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

@_disfavoredOverload
public func repeat<Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring>  {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

@_disfavoredOverload
public func repeat<Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring> where R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

@_disfavoredOverload
public func repeat<Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<Substring> where R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [C0])> where Component.Match == (W, C0), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1)?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1)?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1)])> where Component.Match == (W, C0, C1), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2)?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2)?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2)])> where Component.Match == (W, C0, C1, C2), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3)?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3)?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, C3, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3)])> where Component.Match == (W, C0, C1, C2, C3), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4)?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4)?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4)])> where Component.Match == (W, C0, C1, C2, C3, C4), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
}

public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, (C0, C1, C2, C3, C4, C5, C6, C7, C8)?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
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

public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
}


public func zeroOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}



public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component,
  count: Int
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  count: Int,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  assert(count > 0, "Must specify a positive count")
  // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
  return Regex(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol, R: RangeExpression>(
  _ component: Component,
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
}

public func repeat<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol, R: RangeExpression>(
  _ expression: R,
  _ behavior: QuantificationBehavior = .eagerly,
  @RegexBuilder _ component: () -> Component
) -> Regex<(Substring, [(C0, C1, C2, C3, C4, C5, C6, C7, C8)])> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Bound == Int {
  .init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
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
// MARK: - Non-builder capture arity 0

public func capture<R: RegexProtocol, W>(_ component: R) -> Regex<(W, Substring)> where R.Match == W {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture)> where R.Match == W {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture)> where R.Match == W {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture)> where R.Match == W {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 0

public func capture<R: RegexProtocol, W>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring)> where R.Match == W {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture)> where R.Match == W {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture)> where R.Match == W {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture)> where R.Match == W {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 1

public func capture<R: RegexProtocol, W, C0>(_ component: R) -> Regex<(W, Substring, C0)> where R.Match == (W, C0) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0)> where R.Match == (W, C0) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0)> where R.Match == (W, C0) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0)> where R.Match == (W, C0) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 1

public func capture<R: RegexProtocol, W, C0>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0)> where R.Match == (W, C0) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0)> where R.Match == (W, C0) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0)> where R.Match == (W, C0) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0)> where R.Match == (W, C0) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 2

public func capture<R: RegexProtocol, W, C0, C1>(_ component: R) -> Regex<(W, Substring, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 2

public func capture<R: RegexProtocol, W, C0, C1>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1)> where R.Match == (W, C0, C1) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 3

public func capture<R: RegexProtocol, W, C0, C1, C2>(_ component: R) -> Regex<(W, Substring, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 3

public func capture<R: RegexProtocol, W, C0, C1, C2>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2)> where R.Match == (W, C0, C1, C2) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 4

public func capture<R: RegexProtocol, W, C0, C1, C2, C3>(_ component: R) -> Regex<(W, Substring, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 4

public func capture<R: RegexProtocol, W, C0, C1, C2, C3>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3)> where R.Match == (W, C0, C1, C2, C3) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 5

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4>(_ component: R) -> Regex<(W, Substring, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 5

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4)> where R.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 6

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5>(_ component: R) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 6

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5)> where R.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 7

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6>(_ component: R) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 7

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 8

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7>(_ component: R) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 8

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}
// MARK: - Non-builder capture arity 9

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ component: R) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .group(.capture, component.regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
  _ component: R, transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
  _ component: R, transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .groupTransform(
    .capture,
    component.regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}

// MARK: - Builder capture arity 9

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
  @RegexBuilder _ component: () -> R
) -> Regex<(W, Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .group(.capture, component().regex.root))
}

public func capture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) throws -> NewCapture
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      try transform($0) as Any
    }))
}

public func tryCapture<R: RegexProtocol, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
  @RegexBuilder _ component: () -> R,
  transform: @escaping (Substring) -> NewCapture?
) -> Regex<(W, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .groupTransform(
    .capture,
    component().regex.root,
    CaptureTransform(resultType: NewCapture.self) {
      transform($0) as Any?
    }))
}


// END AUTO-GENERATED CONTENT
