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

internal import _RegexParser
@_spi(RegexBuilder) import _StringProcessing

/// A regex component that matches a specific condition at a particular position
/// in an input string.
///
/// You can use anchors to guarantee that a match only occurs at certain points
/// in an input string, such as at the beginning of the string or at the end of
/// a line.
@available(SwiftStdlib 5.7, *)
public struct Anchor {
  internal enum Kind {
    case startOfSubject
    case endOfSubjectBeforeNewline
    case endOfSubject
    case firstMatchingPositionInSubject
    case textSegmentBoundary
    case startOfLine
    case endOfLine
    case wordBoundary
  }
  
  var kind: Kind
  var isInverted: Bool = false
}

@available(SwiftStdlib 5.7, *)
extension Anchor: RegexComponent {
  var baseAssertion: DSLTree.Atom.Assertion {
    switch kind {
    case .startOfSubject:
      // FIXME: Inverted?
      return .startOfSubject
    case .endOfSubjectBeforeNewline:
      // FIXME: Inverted?
      return .endOfSubjectBeforeNewline
    case .endOfSubject:
      // FIXME: Inverted?
      return .endOfSubject
    case .firstMatchingPositionInSubject:
      // FIXME: Inverted?
      return .firstMatchingPositionInSubject
    case .textSegmentBoundary:
      return isInverted ? .notTextSegment : .textSegment
    case .startOfLine:
      // FIXME: Inverted?
      return .startOfLine
    case .endOfLine:
      // FIXME: Inverted?
      return .endOfLine
    case .wordBoundary:
      return isInverted ? .notWordBoundary : .wordBoundary
    }
  }
  
  public var regex: Regex<Substring> {
    _RegexFactory().assertion(baseAssertion)
  }
}

// MARK: - Public API

@available(SwiftStdlib 5.7, *)
extension Anchor {
  /// An anchor that matches at the start of the input string.
  ///
  /// This anchor is equivalent to `\A` in regex syntax.
  public static var startOfSubject: Anchor {
    Anchor(kind: .startOfSubject)
  }
  
  /// An anchor that matches at the end of the input string or at the end of
  /// the line immediately before the end of the string.
  ///
  /// This anchor is equivalent to `\Z` in regex syntax.
  public static var endOfSubjectBeforeNewline: Anchor {
    Anchor(kind: .endOfSubjectBeforeNewline)
  }
  
  /// An anchor that matches at the end of the input string.
  ///
  /// This anchor is equivalent to `\z` in regex syntax.
  public static var endOfSubject: Anchor {
    Anchor(kind: .endOfSubject)
  }

  // TODO: Are we supporting this?
//  public static var resetStartOfMatch: Anchor {
//    Anchor(kind: resetStartOfMatch)
//  }

  /// An anchor that matches at the first position of a match in the input
  /// string.
  public static var firstMatchingPositionInSubject: Anchor {
    Anchor(kind: .firstMatchingPositionInSubject)
  }

  /// An anchor that matches at a grapheme cluster boundary.
  ///
  /// This anchor is equivalent to `\y` in regex syntax.
  public static var textSegmentBoundary: Anchor {
    Anchor(kind: .textSegmentBoundary)
  }
  
  /// An anchor that matches at the start of a line, including the start of
  /// the input string.
  ///
  /// This anchor is equivalent to `^` in regex syntax when the `m` option
  /// has been enabled or `anchorsMatchLineEndings(true)` has been called.
  ///
  /// For example, the following regexes are all equivalent:
  ///
  /// - `Regex { Anchor.startOfLine }`
  /// - `/(?m)^/` or `/(?m:^)/`
  /// - `/^/.anchorsMatchLineEndings(true)`
  public static var startOfLine: Anchor {
    Anchor(kind: .startOfLine)
  }

  /// An anchor that matches at the end of a line, including at the end of
  /// the input string.
  ///
  /// This anchor is equivalent to `$` in regex syntax when the `m` option
  /// has been enabled or `anchorsMatchLineEndings(true)` has been called.
  ///
  /// For example, the following regexes are all equivalent:
  ///
  /// - `Regex { Anchor.endOfLine }`
  /// - `/(?m)$/` or `/(?m:$)/`
  /// - `/$/.anchorsMatchLineEndings(true)`
  public static var endOfLine: Anchor {
    Anchor(kind: .endOfLine)
  }

  /// An anchor that matches at a word boundary.
  ///
  /// Word boundaries are identified using the Unicode default word boundary
  /// algorithm by default. To specify a different word boundary algorithm,
  /// use the `wordBoundaryKind(_:)` method.
  ///
  /// This anchor is equivalent to `\b` in regex syntax.
  public static var wordBoundary: Anchor {
    Anchor(kind: .wordBoundary)
  }
  
  /// The inverse of this anchor, which matches at every position that this
  /// anchor does not.
  ///
  /// For the ``wordBoundary`` and ``textSegmentBoundary`` anchors, the inverted
  /// version corresponds to `\B` and `\Y`, respectively.
  public var inverted: Anchor {
    var result = self
    result.isInverted.toggle()
    return result
  }
}

/// A regex component that allows a match to continue only if its contents
/// match at the given location.
///
/// A lookahead is a zero-length assertion that its included regex matches at
/// a particular position. Lookaheads do not advance the overall matching
/// position in the input string — once a lookahead succeeds, matching continues
/// in the regex from the same position.
@available(SwiftStdlib 5.7, *)
public struct Lookahead<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  /// Creates a lookahead from the given regex component.
  public init<R: RegexComponent>(
    _ component: R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().lookaheadNonCapturing(component))
  }
  
  /// Creates a lookahead from the regex generated by the given builder closure.
  public init<R: RegexComponent>(
    @RegexComponentBuilder _ component: () -> R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().lookaheadNonCapturing(component()))
  }
}

/// A regex component that allows a match to continue only if its contents
/// do not match at the given location.
///
/// A negative lookahead is a zero-length assertion that its included regex
/// does not match at a particular position. Lookaheads do not advance the
/// overall matching position in the input string — once a lookahead succeeds,
/// matching continues in the regex from the same position.
@available(SwiftStdlib 5.7, *)
public struct NegativeLookahead<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>
  
  init(_ regex: Regex<Output>) {
    self.regex = regex
  }
  
  /// Creates a negative lookahead from the given regex component.
  public init<R: RegexComponent>(
    _ component: R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().negativeLookaheadNonCapturing(component))
  }
  
  /// Creates a negative lookahead from the regex generated by the given builder
  /// closure.
  public init<R: RegexComponent>(
    @RegexComponentBuilder _ component: () -> R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().negativeLookaheadNonCapturing(component()))
  }
}

/// A regex component that allows a match to continue only if its contents
/// match at the given location.
///
/// A lookbehind is a zero-length assertion that its included regex matches at
/// a particular position. Lookbehinds do not advance the overall matching
/// position in the input string — once a lookbehind succeeds, matching continues
/// in the regex from the same position.
@available(SwiftStdlib 5.7, *) // TODO: How should this be gated?
public struct Lookbehind<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  /// Creates a lookbehind from the given regex component.
  public init<R: RegexComponent>(
    _ component: R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().lookbehindNonCapturing(component))
  }

  /// Creates a lookbehind from the regex generated by the given builder closure.
  public init<R: RegexComponent>(
    @RegexComponentBuilder _ component: () -> R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().lookbehindNonCapturing(component()))
  }
}

/// A regex component that allows a match to continue only if its contents
/// do not match at the given location.
///
/// A negative lookbehind is a zero-length assertion that its included regex
/// does not match at a particular position. Lookbehinds do not advance the
/// overall matching position in the input string — once a lookbehind succeeds,
/// matching continues in the regex from the same position.
@available(SwiftStdlib 5.7, *) // TODO: How should this be gated?
public struct NegativeLookbehind<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  /// Creates a negative lookbehind from the given regex component.
  public init<R: RegexComponent>(
    _ component: R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().negativeLookbehindNonCapturing(component))
  }

  /// Creates a negative lookbehind from the regex generated by the given builder
  /// closure.
  public init<R: RegexComponent>(
    @RegexComponentBuilder _ component: () -> R
  ) where R.RegexOutput == Output {
    self.init(_RegexFactory().negativeLookbehindNonCapturing(component()))
  }
}
