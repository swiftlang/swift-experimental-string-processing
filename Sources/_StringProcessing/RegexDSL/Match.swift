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

extension Regex {
  @dynamicMemberLookup
  public struct Match {
    let input: String
    public let range: Range<String.Index>
    let rawCaptures: [StructuredCapture]
    let referencedCaptureOffsets: [ReferenceID: Int]

    let value: Any?
  }
}

extension Regex.Match {
  public var output: Output {
    if Output.self == (Substring, DynamicCaptures).self {
      // FIXME(rdar://89449323): Compiler assertion
      let input = input
      let dynCaps = rawCaptures.map { StoredDynamicCapture($0, in: input) }
      return (input[range], dynCaps) as! Output
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
      let typeErasedMatch = rawCaptures.existentialMatch(from: input[range])
      return typeErasedMatch as! Output
    }
  }

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

  public subscript<Capture>(_ reference: Reference<Capture>) -> Capture {
    guard let offset = referencedCaptureOffsets[reference.id] else {
      preconditionFailure(
        "Reference did not capture any match in the regex")
    }
    return rawCaptures[offset].existentialMatchComponent(from: input[...])
      as! Capture
  }
}

extension RegexComponent {
  public func match(in input: String) -> Regex<Output>.Match? {
    _match(
      input, in: input.startIndex..<input.endIndex)
  }
  public func match(in input: Substring) -> Regex<Output>.Match? {
    _match(
      input.base, in: input.startIndex..<input.endIndex)
  }

  func _match(
    _ input: String,
    in inputRange: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> Regex<Output>.Match? {
    let executor = Executor(program: regex.program.loweredProgram)
    do {
      return try executor.match(input, in: inputRange, mode)
    } catch {
      fatalError(String(describing: error))
    }
  }
}

extension String {
  public func match<R: RegexComponent>(_ regex: R) -> Regex<R.Output>.Match? {
    regex.match(in: self)
  }

  public func match<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) -> Regex<R.Output>.Match? {
    match(content())
  }
}
extension Substring {
  public func match<R: RegexComponent>(_ regex: R) -> Regex<R.Output>.Match? {
    regex.match(in: self)
  }

  public func match<R: RegexComponent>(
    @RegexComponentBuilder _ content: () -> R
  ) -> Regex<R.Output>.Match? {
    match(content())
  }
}
