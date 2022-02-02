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

  // FIXME: This is mostly hacky because we go down two different paths based on
  // whether there are captures. This will be cleaned up once we deprecate the
  // legacy virtual machines.
  func _match(
    _ input: String,
    in inputRange: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> RegexMatch<Match>? {
    // TODO: Remove this branch when the matching engine supports captures.
    if regex.hasCapture {
      let vm = HareVM(program: regex.program.legacyLoweredProgram)
      guard let (range, captures) = vm.execute(
        input: input, in: inputRange, mode: mode
      )?.destructure else {
        return nil
      }
      let convertedMatch: Match
      if Match.self == (Substring, DynamicCaptures).self {
        convertedMatch = (input[range], DynamicCaptures(captures)) as! Match
      } else {
        let typeErasedMatch = captures.matchValue(
          withWholeMatch: input[range]
        )
        convertedMatch = typeErasedMatch as! Match
      }
      return RegexMatch(range: range, match: convertedMatch)
    }

    let executor = Executor(program: regex.program.loweredProgram)
    guard let result = executor.execute(
      input: input, in: inputRange, mode: mode
    ) else {
      return nil
    }
    let convertedMatch: Match
    if Match.self == (Substring, DynamicCaptures).self {
      convertedMatch = (input[result.range], DynamicCaptures.empty) as! Match
    } else {
      assert(Match.self == Substring.self)
      convertedMatch = input[result.range] as! Match
    }
    return RegexMatch(range: result.range, match: convertedMatch)
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
