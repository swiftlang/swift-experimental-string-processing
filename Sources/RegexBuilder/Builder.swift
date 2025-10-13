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

/// A custom parameter attribute that constructs regular expressions from
/// closures.
///
/// You typically see `RegexComponentBuilder` as a parameter attribute for
/// `Regex`- or `RegexComponent`-producing closure parameters, allowing those
/// closures to combine multiple regular expression components. Type
/// initializers and string algorithm methods in the RegexBuilder framework
/// include a builder closure parameter, so that you can use regular expression
/// components together.
@available(SwiftStdlib 5.7, *)
@resultBuilder
public enum RegexComponentBuilder {
  public static func buildBlock() -> Regex<Substring> {
    _RegexFactory().empty()
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
