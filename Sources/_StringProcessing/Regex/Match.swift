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
extension Regex {
  /// The result of matching a regex against a string.
  ///
  /// A `Match` forwards API to the `Output` generic parameter,
  /// providing direct access to captures.
  @dynamicMemberLookup
  public struct Match {
    let input: String

    /// The range of the overall match
    public let range: Range<String.Index>

    let rawCaptures: [StructuredCapture]

    let referencedCaptureOffsets: [ReferenceID: Int]

    let namedCaptureOffsets: [String: Int]

    let value: Any?
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match {
  /// The produced output from the match operation
  public var output: Output {
    if Output.self == AnyRegexOutput.self {
      let wholeMatchAsCapture = StructuredCapture(
        optionalCount: 0,
        storedCapture: StoredCapture(range: range, value: nil))
      let output = AnyRegexOutput(
        input: input,
        namedCaptureOffsets: namedCaptureOffsets,
        elements: [wholeMatchAsCapture] + rawCaptures)
      return output as! Output
    } else if Output.self == Substring.self {
      // FIXME: Plumb whole match (`.0`) through the matching engine.
      return input[range] as! Output
    } else if rawCaptures.isEmpty, value != nil {
      // FIXME: This is a workaround for whole-match values not
      // being modeled as part of captures. We might want to
      // switch to a model where results are alongside captures
      return value! as! Output
    } else {
      guard value == nil else {
        fatalError("FIXME: what would this mean?")
      }
      let typeErasedMatch = rawCaptures.existentialOutput(from: input[range])
      return typeErasedMatch as! Output
    }
  }

  /// Lookup a capture by name or number
  public subscript<T>(dynamicMember keyPath: KeyPath<Output, T>) -> T {
    output[keyPath: keyPath]
  }

  // Allows `.0` when `Match` is not a tuple.
  @_disfavoredOverload
  public subscript(
    dynamicMember keyPath: KeyPath<(Output, _doNotUse: ()), Output>
  ) -> Output {
    output
  }

  @_spi(RegexBuilder)
  public subscript<Capture>(_ id: ReferenceID) -> Capture {
    guard let offset = referencedCaptureOffsets[id] else {
      preconditionFailure(
        "Reference did not capture any match in the regex")
    }
    return rawCaptures[offset].existentialOutputComponent(from: input[...])
      as! Capture
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Match a string in its entirety.
  ///
  /// Returns `nil` if no match and throws on abort
  public func wholeMatch(in s: String) throws -> Regex<Output>.Match? {
    try _match(s, in: s.startIndex..<s.endIndex, mode: .wholeString)
  }

  /// Match part of the string, starting at the beginning.
  ///
  /// Returns `nil` if no match and throws on abort
  public func prefixMatch(in s: String) throws -> Regex<Output>.Match? {
    try _match(s, in: s.startIndex..<s.endIndex, mode: .partialFromFront)
  }

  /// Find the first match in a string
  ///
  /// Returns `nil` if no match is found and throws on abort
  public func firstMatch(in s: String) throws -> Regex<Output>.Match? {
    try _firstMatch(s, in: s.startIndex..<s.endIndex)
  }

  /// Match a substring in its entirety.
  ///
  /// Returns `nil` if no match and throws on abort
  public func wholeMatch(in s: Substring) throws -> Regex<Output>.Match? {
    try _match(s.base, in: s.startIndex..<s.endIndex, mode: .wholeString)
  }

  /// Match part of the string, starting at the beginning.
  ///
  /// Returns `nil` if no match and throws on abort
  public func prefixMatch(in s: Substring) throws -> Regex<Output>.Match? {
    try _match(s.base, in: s.startIndex..<s.endIndex, mode: .partialFromFront)
  }

  /// Find the first match in a substring
  ///
  /// Returns `nil` if no match is found and throws on abort
  public func firstMatch(in s: Substring) throws -> Regex<Output>.Match? {
    try _firstMatch(s.base, in: s.startIndex..<s.endIndex)
  }

  func _match(
    _ input: String,
    in inputRange: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) throws -> Regex<Output>.Match? {
    let executor = Executor(program: regex.program.loweredProgram)
    return try executor.match(input, in: inputRange, mode)
  }

  func _firstMatch(
    _ input: String,
    in inputRange: Range<String.Index>
  ) throws -> Regex<Output>.Match? {
    // FIXME: Something more efficient, likely an engine interface, and we
    // should scrap the RegexConsumer crap and call this

    var low = inputRange.lowerBound
    let high = inputRange.upperBound
    while low < high {
      if let m = try _match(input, in: low..<high, mode: .partialFromFront) {
        return m
      }
      input.formIndex(after: &low)
    }
    return nil
  }
}

@available(SwiftStdlib 5.7, *)
extension String {
  public func wholeMatch<R: RegexComponent>(
    of r: R
  ) -> Regex<R.RegexOutput>.Match? {
    try? r.regex.wholeMatch(in: self)
  }

  public func prefixMatch<R: RegexComponent>(
    of r: R
  ) -> Regex<R.RegexOutput>.Match? {
    try? r.regex.prefixMatch(in: self)
  }
}

@available(SwiftStdlib 5.7, *)
extension Substring {
  public func wholeMatch<R: RegexComponent>(
    of r: R
  ) -> Regex<R.RegexOutput>.Match? {
    try? r.regex.wholeMatch(in: self)
  }

  public func prefixMatch<R: RegexComponent>(
    of r: R
  ) -> Regex<R.RegexOutput>.Match? {
    try? r.regex.prefixMatch(in: self)
  }
}
