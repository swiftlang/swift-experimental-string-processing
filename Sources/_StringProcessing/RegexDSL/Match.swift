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

@dynamicMemberLookup
public struct RegexMatch<Match> {
  public let range: Range<String.Index>
  public let match: Match

  public subscript<T>(dynamicMember keyPath: KeyPath<Match, T>) -> T {
    match[keyPath: keyPath]
  }

  // Allows `.0` when `Match` is not a tuple.
  @_disfavoredOverload
  public subscript(
    dynamicMember keyPath: KeyPath<(Match, _doNotUse: ()), Match>
  ) -> Match {
    match
  }
}

extension RegexProtocol {
  public func match(in input: String) -> RegexMatch<Match>? {
    _match(
      input, in: input.startIndex..<input.endIndex)
  }
  public func match(in input: Substring) -> RegexMatch<Match>? {
    _match(
      input.base, in: input.startIndex..<input.endIndex)
  }

  func _match(
    _ input: String,
    in inputRange: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> RegexMatch<Match>? {
    let executor = Executor(program: regex.program.loweredProgram)
    guard let (range, captures) = executor.execute(
      input: input, in: inputRange, mode: mode
    )?.destructure else {
      return nil
    }
    let convertedMatch: Match
    if Match.self == (Substring, DynamicCaptures).self {
      convertedMatch = (input[range], DynamicCaptures(captures)) as! Match
    } else if Match.self == Substring.self {
      convertedMatch = input[range] as! Match
    } else {
      let typeErasedMatch = captures.matchValue(
        withWholeMatch: input[range]
      )
      convertedMatch = typeErasedMatch as! Match
    }
    return RegexMatch(range: range, match: convertedMatch)
  }
}

extension String {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Match>? {
    regex.match(in: self)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Match>? {
    match(content())
  }
}
extension Substring {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Match>? {
    regex.match(in: self)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Match>? {
    match(content())
  }
}
