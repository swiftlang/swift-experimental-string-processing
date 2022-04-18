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

@_implementationOnly import _RegexParser

@available(SwiftStdlib 5.7, *)
extension RegexComponent {
  /// Returns a regular expression that ignores casing when matching.
  public func ignoringCase(_ ignoreCase: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.caseInsensitive, addingIf: ignoreCase)
  }

  /// Returns a regular expression that only matches ASCII characters as "word
  /// characters".
  public func usingASCIIWordCharacters(_ useASCII: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.asciiOnlyDigit, addingIf: useASCII)
  }

  /// Returns a regular expression that only matches ASCII characters as digits.
  public func usingASCIIDigits(_ useASCII: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.asciiOnlyDigit, addingIf: useASCII)
  }

  /// Returns a regular expression that only matches ASCII characters as space
  /// characters.
  public func usingASCIISpaces(_ useASCII: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.asciiOnlySpace, addingIf: useASCII)
  }

  /// Returns a regular expression that only matches ASCII characters when
  /// matching character classes.
  public func usingASCIICharacterClasses(_ useASCII: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.asciiOnlyPOSIXProps, addingIf: useASCII)
  }
  
  /// Returns a regular expression that uses the specified word boundary algorithm.
  public func identifyingWordBoundaries(with wordBoundaryKind: RegexWordBoundaryKind) -> Regex<RegexOutput> {
    wrapInOption(.unicodeWordBoundaries, addingIf: wordBoundaryKind == .unicodeLevel2)
  }
  
  /// Returns a regular expression where the start and end of input
  /// anchors (`^` and `$`) also match against the start and end of a line.
  ///
  /// - Parameter dotMatchesNewlines: A Boolean value indicating whether `.`
  ///   should match a newline character.
  public func dotMatchesNewlines(_ dotMatchesNewlines: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.singleLine, addingIf: dotMatchesNewlines)
  }
  
  /// Returns a regular expression where the start and end of input
  /// anchors (`^` and `$`) also match against the start and end of a line.
  ///
  /// This method corresponds to applying the `m` option in a regular
  /// expression literal. For this behavior in the `RegexBuilder` syntax, see
  /// ``Anchor.startOfLine``, ``Anchor.endOfLine``, ``Anchor.startOfInput``,
  /// and ``Anchor.endOfInput``.
  ///
  /// - Parameter matchLineEndings: A Boolean value indicating whether `^` and
  ///   `$` should match the start and end of lines, respectively.
  public func anchorsMatchLineEndings(_ matchLineEndings: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.multiline, addingIf: matchLineEndings)
  }
  
  /// Returns a regular expression where quantifiers are reluctant by default
  /// instead of eager.
  ///
  /// This method corresponds to applying the `U` option in a regular
  /// expression literal.
  ///
  /// - Parameter useReluctantQuantifiers: A Boolean value indicating whether
  ///   quantifiers should be reluctant by default.
  public func reluctantQuantifiers(_ useReluctantQuantifiers: Bool = true) -> Regex<RegexOutput> {
    wrapInOption(.reluctantByDefault, addingIf: useReluctantQuantifiers)
  }

  /// Returns a regular expression that matches with the specified semantic
  /// level.
  ///
  /// When matching with grapheme cluster semantics (the default),
  /// metacharacters like `.` and `\w`, custom character classes, and character
  /// class instances like `.any` match a grapheme cluster when possible,
  /// corresponding with the default string representation. In addition,
  /// matching with grapheme cluster semantics compares characters using their
  /// canonical representation, corresponding with how strings comparison works.
  ///
  /// When matching with Unicode scalar semantics, metacharacters and character
  /// classes always match a single Unicode scalar value, even if that scalar
  /// comprises part of a grapheme cluster.
  ///
  /// These semantic levels can lead to different results, especially when
  /// working with strings that have decomposed characters. In the following
  /// example, `queRegex` matches any 3-character string that begins with `"q"`.
  ///
  ///     let composed = "qué"
  ///     let decomposed = "que\u{301}"
  ///
  ///     let queRegex = /^q..$/
  ///
  ///     print(composed.contains(queRegex))
  ///     // Prints "true"
  ///     print(decomposed.contains(queRegex))
  ///     // Prints "true"
  ///
  /// When using Unicode scalar semantics, however, the regular expression only
  /// matches the composed version of the string, because each `.` matches a
  /// single Unicode scalar value.
  ///
  ///     let queRegexScalar = queRegex.matchingSemantics(.unicodeScalar)
  ///     print(composed.contains(queRegexScalar))
  ///     // Prints "true"
  ///     print(decomposed.contains(queRegexScalar))
  ///     // Prints "false"
  public func matchingSemantics(_ semanticLevel: RegexSemanticLevel) -> Regex<RegexOutput> {
    switch semanticLevel.base {
    case .graphemeCluster:
      return wrapInOption(.graphemeClusterSemantics, addingIf: true)
    case .unicodeScalar:
      return wrapInOption(.unicodeScalarSemantics, addingIf: true)
    }
  }
}

@available(SwiftStdlib 5.7, *)
/// A semantic level to use during regex matching.
public struct RegexSemanticLevel: Hashable {
  internal enum Representation {
    case graphemeCluster
    case unicodeScalar
  }
  
  internal var base: Representation
  
  /// Match at the default semantic level of a string, where each matched
  /// element is a `Character`.
  public static var graphemeCluster: RegexSemanticLevel {
    .init(base: .graphemeCluster)
  }
  
  /// Match at the semantic level of a string's `UnicodeScalarView`, where each
  /// matched element is a `UnicodeScalar` value.
  public static var unicodeScalar: RegexSemanticLevel {
    .init(base: .unicodeScalar)
  }
}

@available(SwiftStdlib 5.7, *)
/// A word boundary algorithm to use during regex matching.
public struct RegexWordBoundaryKind: Hashable {
  internal enum Representation {
    case unicodeLevel1
    case unicodeLevel2
  }
  
  internal var base: Representation

  /// A word boundary algorithm that implements the "simple word boundary"
  /// Unicode recommendation.
  ///
  /// A simple word boundary is a position in the input between two characters
  /// that match `/\w\W/` or `/\W\w/`, or between the start or end of the input
  /// and a `\w` character. Word boundaries therefore depend on the option-
  /// defined behavior of `\w`.
  public static var unicodeLevel1: Self {
    .init(base: .unicodeLevel1)
  }

  /// A word boundary algorithm that implements the "default word boundary"
  /// Unicode recommendation.
  ///
  /// Default word boundaries use a Unicode algorithm that handles some cases
  /// better than simple word boundaries, such as words with internal
  /// punctuation, changes in script, and Emoji.
  public static var unicodeLevel2: Self {
    .init(base: .unicodeLevel2)
  }
}

// MARK: - Helper method

@available(SwiftStdlib 5.7, *)
extension RegexComponent {
  fileprivate func wrapInOption(
    _ option: AST.MatchingOption.Kind,
    addingIf shouldAdd: Bool) -> Regex<RegexOutput>
  {
    let sequence = shouldAdd
      ? AST.MatchingOptionSequence(adding: [.init(option, location: .fake)])
      : AST.MatchingOptionSequence(removing: [.init(option, location: .fake)])
    return Regex(node: .nonCapturingGroup(
      .changeMatchingOptions(sequence), regex.root))
  }
}
