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
    _RegexFactory().empty()
  }

  public static func buildPartialBlock<R: RegexComponent>(
    first component: R
  ) -> Regex<R.RegexOutput> {
    component.regex
  }

  @available(*, unavailable)
  public static func buildExpression<R: RegexComponent>(_ regex: R) -> R {
    regex
  }

  @_alwaysEmitIntoClient
  public static func buildExpression<R: RegexComponent>(
    _ expression: R
  ) -> Regex<R.RegexOutput> {
    expression.regex
  }

  @_alwaysEmitIntoClient
  public static func buildFinalResult<R: RegexComponent>(
    _ component: R
  ) -> R {
    component
  }

  // TODO: ApolloZhu @available(SwiftStdlib 5.8, *)
  public static func buildDebuggable<Output>(
    component: Regex<Output>,
    debugInfoProvider: DSLDebugInfoProvider
  ) -> Regex<Output> {
    makeFactory().debuggable(component.regex, debugInfoProvider)
  }

  // TODO: ApolloZhu @available(SwiftStdlib 5.8, *)
  public static func buildDebuggable<Output>(
    finalResult: Regex<Output>,
    debugInfoProvider: DSLDebugInfoProvider
  ) -> Regex<Output> {
    makeFactory()
      .debuggableFinalResult(finalResult.regex, debugInfoProvider)
  }
}
