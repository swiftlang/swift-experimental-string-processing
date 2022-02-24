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
  let input: String
  public let range: Range<String.Index>
  let rawCaptures: [StructuredCapture]
  let referencedCaptureOffsets: [ReferenceID: Int]

  public var match: Match {
    if Match.self == (Substring, DynamicCaptures).self {
      let dynCaps = rawCaptures.map { StoredDynamicCapture($0, in: input) }
      return (input[range], dynCaps) as! Match
    } else if Match.self == Substring.self {
      // FIXME: Plumb whole match (`.0`) through the matching engine.
      return input[range] as! Match
    } else {
      let typeErasedMatch = rawCaptures.existentialMatch(from: input[range])
      return typeErasedMatch as! Match
    }
  }

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

  public subscript<Capture>(_ reference: Reference<Capture>) -> Capture {
    guard let offset = referencedCaptureOffsets[reference.id] else {
      preconditionFailure(
        "Reference did not capture any match in the regex")
    }
    return rawCaptures[offset].existentialMatchComponent(from: input[...])
      as! Capture
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
    guard let (range, captures, captureOffsets) = executor.execute(
      input: input, in: inputRange, mode: mode
    )?.destructure else {
      return nil
    }
    return RegexMatch(
      input: input,
      range: range,
      rawCaptures: captures,
      referencedCaptureOffsets: captureOffsets)
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
