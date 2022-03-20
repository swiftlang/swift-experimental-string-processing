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

extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0)>  where R0.Match == W0, R1.Match == (W1, C0) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1)>  where R0.Match == W0, R1.Match == (W1, C0, C1) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == W0, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1)>  where R0.Match == (W0, C0), R1.Match == (W1, C1) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>  where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<Substring> where R0.Match == W0  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0)> where R0.Match == (W0, C0)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1)> where R0.Match == (W0, C0, C1)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2)> where R0.Match == (W0, C0, C1, C2)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3)> where R0.Match == (W0, C0, C1, C2, C3)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, C4, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4)> where R0.Match == (W0, C0, C1, C2, C3, C4)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, C4, C5, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, C4, C5, C6, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}
extension RegexComponentBuilder {
  public static func buildPartialBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexComponent, R1: RegexComponent>(
    accumulated: R0, next: R1
  ) -> Regex<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)  {
    .init(node: accumulated.regex.root.appending(next.regex.root))
  }
}


extension Optionally {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == Substring {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == Substring {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

@_disfavoredOverload
public postfix func .?<Component: RegexComponent>(
  _ component: Component
) -> Optionally<Substring>  {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<Component: RegexComponent>(
    _ component: Component
  ) -> Regex<Substring>  {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == Substring {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == Substring {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

@_disfavoredOverload
public postfix func .*<Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<Substring>  {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == Substring {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == Substring {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

@_disfavoredOverload
public postfix func .+<Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<Substring>  {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
  @_disfavoredOverload
  public init<Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == Substring {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

  @_disfavoredOverload
  public init<Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == Substring {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

  @_disfavoredOverload
  public init<Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == Substring, R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

  @_disfavoredOverload
  public init<Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == Substring, R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?), Component.Match == (W, C0) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?), Component.Match == (W, C0) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?)> where Component.Match == (W, C0) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?), Component.Match == (W, C0) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?), Component.Match == (W, C0) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?)> where Component.Match == (W, C0) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0), Component.Match == (W, C0) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0), Component.Match == (W, C0) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0)> where Component.Match == (W, C0) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?), Component.Match == (W, C0) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?), Component.Match == (W, C0) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?), Component.Match == (W, C0), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?), Component.Match == (W, C0), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?)> where Component.Match == (W, C0, C1) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1), Component.Match == (W, C0, C1) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1), Component.Match == (W, C0, C1) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1)> where Component.Match == (W, C0, C1) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?), Component.Match == (W, C0, C1), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?)> where Component.Match == (W, C0, C1, C2) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2), Component.Match == (W, C0, C1, C2) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2), Component.Match == (W, C0, C1, C2) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2)> where Component.Match == (W, C0, C1, C2) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?), Component.Match == (W, C0, C1, C2), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?)> where Component.Match == (W, C0, C1, C2, C3) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3), Component.Match == (W, C0, C1, C2, C3) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3), Component.Match == (W, C0, C1, C2, C3) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3)> where Component.Match == (W, C0, C1, C2, C3) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?), Component.Match == (W, C0, C1, C2, C3), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?, C4?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?, C4?)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3, C4), Component.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3, C4), Component.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3, C4)> where Component.Match == (W, C0, C1, C2, C3, C4) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?), Component.Match == (W, C0, C1, C2, C3, C4), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3, C4, C5)> where Component.Match == (W, C0, C1, C2, C3, C4, C5) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?), Component.Match == (W, C0, C1, C2, C3, C4, C5), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3, C4, C5, C6)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6, C7), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6, C7), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component.regex.root))
  }
}

extension Optionally {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .quantification(.zeroOrOne, behavior.astKind, component().regex.root))
  }
}

public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
  _ component: Component
) -> Optionally<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
}

extension RegexComponentBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ component: Component
  ) -> Regex<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}
extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component.regex.root))
  }
}

extension ZeroOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .quantification(.zeroOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
  _ component: Component
) -> ZeroOrMore<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
}


extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ component: Component,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component.regex.root))
  }
}

extension OneOrMore {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .quantification(.oneOrMore, behavior.astKind, component().regex.root))
  }
}

public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
  _ component: Component
) -> OneOrMore<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
}


extension Repeat {
    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    _ component: Component,
    count: Int
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent>(
    count: Int,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    assert(count > 0, "Must specify a positive count")
    // TODO: Emit a warning about `repeatMatch(count: 0)` or `repeatMatch(count: 1)`
    self.init(node: .quantification(.exactly(.init(faking: count)), .eager, component().regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent, R: RangeExpression>(
    _ component: Component,
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component.regex.root))
  }

    public init<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, Component: RegexComponent, R: RangeExpression>(
    _ expression: R,
    _ behavior: QuantificationBehavior = .eagerly,
    @RegexComponentBuilder _ component: () -> Component
  ) where Match == (Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?), Component.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Bound == Int {
    self.init(node: .repeating(expression.relative(to: 0..<Int.max), behavior, component().regex.root))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<Substring> where R0: RegexComponent, R1: RegexComponent {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1>(lhs: R0, rhs: R1) -> ChoiceOf<Substring> where R0: RegexComponent, R1: RegexComponent {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3, C4>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, R1, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R1.Match == (W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, R1, W1, C1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0), R1.Match == (W1, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, R1, W1, C2, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1), R1.Match == (W1, C2, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, R1, W1, C3, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2), R1.Match == (W1, C3, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, R1, W1, C4, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4?, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3), R1.Match == (W1, C4, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, R1, W1, C5, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5?, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4), R1.Match == (W1, C5, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, R1, W1, C6, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6?, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5), R1.Match == (W1, C6, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, R1, W1, C7, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7?, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6), R1.Match == (W1, C7, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, R1, W1, C8, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8?, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7), R1.Match == (W1, C8, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>(
    accumulated: R0, next: R1
  ) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
    .init(node: accumulated.regex.root.appendingAlternationCase(next.regex.root))
  }
}

public func | <R0, W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R1, W1, C9>(lhs: R0, rhs: R1) -> ChoiceOf<(Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9?)> where R0: RegexComponent, R1: RegexComponent, R0.Match == (W0, C0, C1, C2, C3, C4, C5, C6, C7, C8), R1.Match == (W1, C9) {
  .init(node: lhs.regex.root.appendingAlternationCase(rhs.regex.root))
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0>(first regex: R) -> ChoiceOf<(W, C0?)> where R: RegexComponent, R.Match == (W, C0) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1>(first regex: R) -> ChoiceOf<(W, C0?, C1?)> where R: RegexComponent, R.Match == (W, C0, C1) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?)> where R: RegexComponent, R.Match == (W, C0, C1, C2) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3, C4>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?, C4?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3, C4) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3, C4, C5>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?, C4?, C5?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3, C4, C5) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3, C4, C5, C6>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3, C4, C5, C6, C7>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
extension AlternationBuilder {
  public static func buildPartialBlock<R, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(first regex: R) -> ChoiceOf<(W, C0?, C1?, C2?, C3?, C4?, C5?, C6?, C7?, C8?, C9?)> where R: RegexComponent, R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    .init(node: .orderedChoice([regex.regex.root]))
  }
}
// MARK: - Non-builder capture arity 0

extension Capture {
  @_disfavoredOverload
  public init<R: RegexComponent, W>(
    _ component: R
  ) where Match == (Substring, W), R.Match == W {
    self.init(node: .capture(component.regex.root))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W), R.Match == W {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 0

extension Capture {
  @_disfavoredOverload
  public init<R: RegexComponent, W>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W), R.Match == W {
    self.init(node: .capture(component().regex.root))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

  @_disfavoredOverload
  public init<R: RegexComponent, W, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture), R.Match == W {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 1

extension Capture {
    public init<R: RegexComponent, W, C0>(
    _ component: R
  ) where Match == (Substring, W, C0), R.Match == (W, C0) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0), R.Match == (W, C0) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 1

extension Capture {
    public init<R: RegexComponent, W, C0>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0), R.Match == (W, C0) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0), R.Match == (W, C0) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 2

extension Capture {
    public init<R: RegexComponent, W, C0, C1>(
    _ component: R
  ) where Match == (Substring, W, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 2

extension Capture {
    public init<R: RegexComponent, W, C0, C1>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1), R.Match == (W, C0, C1) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 3

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 3

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2), R.Match == (W, C0, C1, C2) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 4

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 4

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3), R.Match == (W, C0, C1, C2, C3) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 5

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 5

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4), R.Match == (W, C0, C1, C2, C3, C4) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 6

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 6

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5), R.Match == (W, C0, C1, C2, C3, C4, C5) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 7

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 7

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6), R.Match == (W, C0, C1, C2, C3, C4, C5, C6) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 8

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 8

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 9

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 9

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}

// MARK: - Non-builder capture arity 10

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    _ component: R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    _ component: R, as reference: Reference<W>
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(reference: reference.id, component.regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component.regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    _ component: R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component.regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    _ component: R,
    as reference: Reference<NewCapture>,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component.regex.root)))
  }
}

// MARK: - Builder capture arity 10

extension Capture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    as reference: Reference<W>,
    @RegexComponentBuilder _ component: () -> R
  ) where Match == (Substring, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      component().regex.root))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any
        },
        component().regex.root)))
  }
}

extension TryCapture {
    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) throws -> NewCapture
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          try transform($0) as Any
        },
        component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(.transform(
      CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      },
      component().regex.root)))
  }

    public init<R: RegexComponent, W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, NewCapture>(
    as reference: Reference<NewCapture>,
    @RegexComponentBuilder _ component: () -> R,
    transform: @escaping (Substring) -> NewCapture?
  ) where Match == (Substring, NewCapture, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9), R.Match == (W, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9) {
    self.init(node: .capture(
      reference: reference.id,
      .transform(
        CaptureTransform(resultType: NewCapture.self) {
          transform($0) as Any?
        },
        component().regex.root)))
  }
}



// END AUTO-GENERATED CONTENT
