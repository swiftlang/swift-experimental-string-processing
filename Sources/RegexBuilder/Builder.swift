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

@available(SwiftStdlib 5.7, *)
@resultBuilder
public enum RegexComponentBuilder {
  public static func buildBlock() -> Regex<Substring> {
    .init(node: .empty)
  }

  public static func buildPartialBlock<R: RegexComponent>(
    first component: R
  ) -> Regex<R.RegexOutput> {
    component.regex
  }

  public static func buildExpression<R: RegexComponent>(_ regex: R) -> R {
    regex
  }
}
