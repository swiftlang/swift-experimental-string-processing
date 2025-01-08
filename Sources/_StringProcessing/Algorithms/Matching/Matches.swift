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
typealias RegexMatchesSequence<Output> = Executor<Output>.Matches

extension BidirectionalCollection where SubSequence == Substring {
  @available(SwiftStdlib 5.7, *)
  @_disfavoredOverload
  func _matches<R: RegexComponent>(
    of regex: R
  ) -> RegexMatchesSequence<R.RegexOutput> {
    RegexMatchesSequence(
      program: regex.regex.program.loweredProgram,
      input: self[...].base,
      subjectBounds: startIndex..<endIndex,
      searchBounds: startIndex..<endIndex)
  }

  // FIXME: Return `some Collection<Regex<R.Output>.Match> for SE-0346
  /// Returns a collection containing all matches of the specified regex.
  /// - Parameter regex: The regex to search for.
  /// - Returns: A collection of matches of `regex`.
  @available(SwiftStdlib 5.7, *)
  public func matches<Output>(
    of r: some RegexComponent<Output>
  ) -> [Regex<Output>.Match] {
    // FIXME: Array init calls count, which double-executes the regex :-(
    // FIXME: just return some Collection<Regex<Output>.Match>
    var result = Array<Regex<Output>.Match>()

    for match in _matches(of: r) {
      result.append(match)
    }
    return result
  }
}
