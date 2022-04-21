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
public protocol CustomMatchingRegexComponent: RegexComponent {
  func match(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: RegexOutput)?
}

@available(SwiftStdlib 5.7, *)
extension CustomMatchingRegexComponent {
  public var regex: Regex<RegexOutput> {

    let node: DSLTree.Node = .matcher(.init(RegexOutput.self), { input, index, bounds in
      try match(input, startingAt: index, in: bounds)
    })
    return Regex(node: node)
  }
}
