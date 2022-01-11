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
public enum RegexBuilder {
  public static func buildBlock<R0: RegexProtocol>(_ r0: R0) -> R0 {
    r0
  }
  
  public static func buildEither<R: RegexProtocol>(first component: R) -> R {
    component
  }

  public static func buildEither<R: RegexProtocol>(second component: R) -> R {
    component
  }

  public static func buildLimitedAvailability<R: RegexProtocol>(
    _ component: R
  ) -> Optionally<R> {
    .init(component)
  }
}
