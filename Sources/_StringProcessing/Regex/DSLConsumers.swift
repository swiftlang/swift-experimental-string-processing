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
public protocol CustomRegexComponent: RegexComponent {
  func match(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) -> (upperBound: String.Index, output: RegexOutput)?
}

extension CustomRegexComponent {
  public var regex: Regex<RegexOutput> {
    Regex(node: .matcher(.init(RegexOutput.self), { input, index, bounds in
      match(input, startingAt: index, in: bounds)
    }))
  }
}
