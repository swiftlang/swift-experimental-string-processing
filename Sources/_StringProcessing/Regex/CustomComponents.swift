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
/// A protocol allowing custom types to function as regex components by
/// providing the raw functionality backing `prefixMatch`.
public protocol CustomConsumingRegexComponent: RegexComponent {
  /// Process the input string within the specified bounds, beginning at the given index, and return
  /// the end position (upper bound) of the match and the produced output.
  /// - Parameters:
  ///   - input: The string in which the match is performed.
  ///   - index: An index of `input` at which to begin matching.
  ///   - bounds: The bounds in `input` in which the match is performed.
  /// - Returns: The upper bound where the match terminates and a matched instance, or `nil` if
  ///   there isn't a match.
  func consuming(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: RegexOutput)?
}

@available(SwiftStdlib 5.7, *)
extension CustomConsumingRegexComponent {
  public var regex: Regex<RegexOutput> {
    let node: DSLTree.Node = .matcher(.init(RegexOutput.self), { input, index, bounds in
      try consuming(input, startingAt: index, in: bounds)
    })
    return Regex(node: node)
  }
}
