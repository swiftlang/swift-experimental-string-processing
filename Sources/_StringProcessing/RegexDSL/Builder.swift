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

@resultBuilder
public enum RegexComponentBuilder {
  public static func buildBlock() -> Regex<Substring> {
    .init(node: .empty)
  }

  // TODO: Rename to `buildPartialBlock(first:)` when the feature lands.
  public static func buildBlock<R0: RegexComponent>(_ r0: R0) -> R0 {
    r0
  }

  public static func buildExpression<R: RegexComponent>(_ regex: R) -> R {
    regex
  }

  public static func buildEither<R: RegexComponent>(first component: R) -> R {
    component
  }

  public static func buildEither<R: RegexComponent>(second component: R) -> R {
    component
  }
}
