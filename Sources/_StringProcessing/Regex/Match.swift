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
  /// The result of matching a regular expression against a string.
  ///
  /// A `Match` forwards API to the `Output` generic parameter,
  /// providing direct access to captures.
  @dynamicMemberLookup
  public struct Match {
    let anyRegexOutput: AnyRegexOutput

    /// The range of the overall match.
    public let range: Range<String.Index>
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match {
  var input: String {
    anyRegexOutput.input
  }

  /// The output produced from the match operation.
  public var output: Output {
    if Output.self == AnyRegexOutput.self {
      return anyRegexOutput as! Output
    }
    let typeErasedMatch = anyRegexOutput.existentialOutput(
      from: anyRegexOutput.input
    )
    return typeErasedMatch as! Output
  }

  /// Accesses a capture by its name or number.
  public subscript<T>(dynamicMember keyPath: KeyPath<Output, T>) -> T {
    // Note: We should be able to get the element offset from the key path
    // itself even at compile time. We need a better way of doing this.
    guard let outputTupleOffset = MemoryLayout.tupleElementIndex(
      of: keyPath, elementTypes: anyRegexOutput.map(\.type)
    ) else {
      return output[keyPath: keyPath]
    }
    return anyRegexOutput[outputTupleOffset].value as! T
  }

  /// Accesses a capture using the `.0` syntax, even when the match isn't a tuple.
  @_disfavoredOverload
  public subscript(
    dynamicMember _keyPath: KeyPath<(Output, _doNotUse: ()), Output>
  ) -> Output {
    output
  }

  // Helper for `subscript(_: Reference<Capture>)`, defined in RegexBuilder.
  @_spi(RegexBuilder)
  public subscript<Capture>(_ id: ReferenceID) -> Capture {
    guard let element = anyRegexOutput.first(
      where: { $0.representation.referenceID == id }
    ) else {
      preconditionFailure("Reference did not capture any match in the regex")
    }
    return element.existentialOutputComponent(
      from: input
    ) as! Capture
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Returns a match if this regex matches the given string in its entirety.
  ///
  /// Call this method if you want the regular expression to succeed only when
  /// it matches the entire string you pass as `string`. The following example
  /// shows matching a regular expression that only matches digits, with
  /// different candidate strings.
  ///
  ///     let digits = /[0-9]+/
  ///
  ///     if let digitsMatch = try digits.wholeMatch(in: "2022") {
  ///         print(digitsMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "2022"
  ///
  ///     if let digitsMatch = try digits.wholeMatch(in: "The year is 2022.") {
  ///         print(digitsMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "No match."
  ///
  /// The `wholeMatch(in:)` method can throw an error if this regex includes
  /// a transformation closure that throws an error.
  ///
  /// - Parameter string: The string to match this regular expression against.
  /// - Returns: The match, if this regex matches the entirety of `string`;
  ///   otherwise, `nil`.
  public func wholeMatch(in string: String) throws -> Regex<Output>.Match? {
    try _match(string, in: string.startIndex..<string.endIndex, mode: .wholeString)
  }

  /// Returns a match if this regex matches the given string at its start.
  ///
  /// Call this method if you want the regular expression to succeed only when
  /// it matches only at the start of the given string. This example uses
  /// `prefixMatch(in:)` and a regex that matches a title-case word to search
  /// for such a word at the start of different strings:
  ///
  ///     let titleCaseWord = /[A-Z][A-Za-z]+/
  ///
  ///     if let wordMatch = try titleCaseWord.prefixMatch(in: "Searching in a Regex") {
  ///         print(wordMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "Searching"
  ///
  ///     if let wordMatch = try titleCaseWord.wholeMatch(in: "title case word at the End") {
  ///         print(wordMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "No match."
  ///
  /// The `prefixMatch(in:)` method can throw an error if this regex includes
  /// a transformation closure that throws an error.
  ///
  /// - Parameter string: The string to match this regular expression against.
  /// - Returns: The match, if this regex matches at the start of `string`;
  ///   otherwise, `nil`.
  public func prefixMatch(in string: String) throws -> Regex<Output>.Match? {
    try _match(string, in: string.startIndex..<string.endIndex, mode: .partialFromFront)
  }

  /// Returns the first match for this regex found in the given string.
  ///
  /// Use the `firstMatch(in:)` method to search for the first occurrence of
  /// this regular expression in `string`. This example searches for the first
  /// sequence of digits that occurs in a string:
  ///
  ///     let digits = /[0-9]+/
  ///
  ///     if let digitsMatch = try digits.firstMatch(in: "The year is 2022; last year was 2021.") {
  ///         print(digitsMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "2022"
  ///
  /// The `firstMatch(in:)` method can throw an error if this regex includes
  /// a transformation closure that throws an error.
  ///
  /// - Parameter string: The string to match this regular expression against.
  /// - Returns: The match, if one is found; otherwise, `nil`.
  public func firstMatch(in string: String) throws -> Regex<Output>.Match? {
    try _firstMatch(string, in: string.startIndex..<string.endIndex)
  }

  /// Returns a match if this regex matches the given substring in its entirety.
  ///
  /// Call this method if you want the regular expression to succeed only when
  /// it matches the entire string you pass as `string`. The following example
  /// shows matching a regular expression that only matches digits, with
  /// different candidate strings.
  ///
  ///     let digits = /[0-9]+/
  ///
  ///     if let digitsMatch = try digits.wholeMatch(in: "2022") {
  ///         print(digitsMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "2022"
  ///
  ///     if let digitsMatch = try digits.wholeMatch(in: "The year is 2022.") {
  ///         print(digitsMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "No match."
  ///
  /// The `wholeMatch(in:)` method can throw an error if this regex includes
  /// a transformation closure that throws an error.
  ///
  /// - Parameter string: The substring to match this regular expression
  ///   against.
  /// - Returns: The match, if this regex matches the entirety of `string`;
  ///   otherwise, `nil`.
  public func wholeMatch(in string: Substring) throws -> Regex<Output>.Match? {
    try _match(string.base, in: string.startIndex..<string.endIndex, mode: .wholeString)
  }

  /// Returns a match if this regex matches the given substring at its start.
  ///
  /// Call this method if you want the regular expression to succeed only when
  /// it matches only at the start of the given string. This example uses
  /// `prefixMatch(in:)` and a regex that matches a title-case word to search
  /// for such a word at the start of different strings:
  ///
  ///     let titleCaseWord = /[A-Z][A-Za-z]+/
  ///
  ///     if let wordMatch = try titleCaseWord.prefixMatch(in: "Searching in a Regex") {
  ///         print(wordMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "Searching"
  ///
  ///     if let wordMatch = try titleCaseWord.wholeMatch(in: "title case word at the End") {
  ///         print(wordMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "No match."
  ///
  /// The `prefixMatch(in:)` method can throw an error if this regex includes
  /// a transformation closure that throws an error.
  ///
  /// - Parameter string: The substring to match this regular expression
  ///   against.
  /// - Returns: The match, if this regex matches at the start of `string`;
  ///   otherwise, `nil`.
  public func prefixMatch(in string: Substring) throws -> Regex<Output>.Match? {
    try _match(string.base, in: string.startIndex..<string.endIndex, mode: .partialFromFront)
  }

  /// Returns the first match for this regex found in the given substring.
  ///
  /// Use the `firstMatch(in:)` method to search for the first occurrence of
  /// this regular expression in `string`. This example searches for the first
  /// sequence of digits that occurs in a string:
  ///
  ///     let digits = /[0-9]+/
  ///
  ///     if let digitsMatch = try digits.firstMatch(in: "The year is 2022; last year was 2021.") {
  ///         print(digitsMatch.0)
  ///     } else {
  ///         print("No match.")
  ///     }
  ///     // Prints "2022"
  ///
  /// The `firstMatch(in:)` method can throw an error if this regex includes
  /// a transformation closure that throws an error.
  ///
  /// - Parameter string: The substring to match this regular expression
  ///   against.
  /// - Returns: The match, if one is found; otherwise, `nil`.
  public func firstMatch(in string: Substring) throws -> Regex<Output>.Match? {
    try _firstMatch(string.base, in: string.startIndex..<string.endIndex)
  }

  func _match(
    _ input: String,
    in subjectBounds: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) throws -> Regex<Output>.Match? {
    let executor = Executor(program: regex.program.loweredProgram)
    return try executor.match(input, in: subjectBounds, mode)
  }

  func _firstMatch(
    _ input: String,
    in subjectBounds: Range<String.Index>
  ) throws -> Regex<Output>.Match? {
    try _firstMatch(input, subjectBounds: subjectBounds, searchBounds: subjectBounds)
  }

  func _firstMatch(
    _ input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>
  ) throws -> Regex<Output>.Match? {
    let executor = Executor(program: regex.program.loweredProgram)
    let graphemeSemantic = regex.initialOptions.semanticLevel == .graphemeCluster
    return try executor.firstMatch(
      input,
      subjectBounds: subjectBounds,
      searchBounds: searchBounds,
      graphemeSemantic: graphemeSemantic)
  }
}

@available(SwiftStdlib 5.7, *)
extension BidirectionalCollection where SubSequence == Substring {
  /// Returns a match if this string is matched by the given regex in its entirety.
  ///
  /// - Parameter regex: The regular expression to match.
  /// - Returns: The match, if one is found. If there is no match, or a
  ///   transformation in `regex` throws an error, this method returns `nil`.
  public func wholeMatch<R: RegexComponent>(
    of regex: R
  ) -> Regex<R.RegexOutput>.Match? {
    try? regex.regex.wholeMatch(in: self[...])
  }

  /// Returns a match if this string is matched by the given regex at its start.
  ///
  /// - Parameter regex: The regular expression to match.
  /// - Returns: The match, if one is found. If there is no match, or a
  ///   transformation in `regex` throws an error, this method returns `nil`.
  public func prefixMatch<R: RegexComponent>(
    of regex: R
  ) -> Regex<R.RegexOutput>.Match? {
    try? regex.regex.prefixMatch(in: self[...])
  }
}
