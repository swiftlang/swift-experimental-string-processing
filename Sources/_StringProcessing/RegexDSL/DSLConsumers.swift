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

public protocol CustomRegexComponent: RegexProtocol {
  func match(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) -> (upperBound: String.Index, match: Match)?
}

extension CustomRegexComponent {
  public var regex: Regex<Match> {
    Regex(node: .matcher(.init(Match.self), { input, index, bounds in
      match(input, startingAt: index, in: bounds)
    }))
  }
}
