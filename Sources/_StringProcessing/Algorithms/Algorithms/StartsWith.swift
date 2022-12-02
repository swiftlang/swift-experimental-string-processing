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

// MARK: Regex algorithms

@available(SwiftStdlib 5.7, *)
extension BidirectionalCollection where SubSequence == Substring {
  /// Returns a Boolean value indicating whether the initial elements of the
  /// sequence are the same as the elements in the specified regex.
  ///
  /// - Parameter regex: A regex to compare to this sequence.
  /// - Returns: `true` if the initial elements of the sequence matches the
  ///   beginning of `regex`; otherwise, `false`.
  public func starts(with regex: some RegexComponent) -> Bool {
    let s = self[...]
    return (try? regex.regex.prefixMatch(in: s)) != nil
  }
}
