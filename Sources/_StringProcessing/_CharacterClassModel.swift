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

// NOTE: This is a model type. We want to be able to get one from
// an AST, but this isn't a natural thing to produce in the context
// of parsing or to store in an AST

struct _CharacterClassModel: Hashable {
  /// The actual character class to match.
  var cc: Representation
  
  /// The level (character or Unicode scalar) at which to match.
  var matchLevel: MatchLevel

  /// Whether this character class matches against an inverse,
  /// e.g \D, \S, [^abc].
  var isInverted: Bool = false

  // TODO: Split out builtin character classes into their own type?
  enum Representation: Hashable {
    /// Any character
    case any
    /// Any grapheme cluster
    case anyGrapheme
    /// Any Unicode scalar
    case anyScalar
    /// Character.isDigit
    case digit
    /// Character.isHexDigit
    case hexDigit
    /// Horizontal whitespace: `[:blank:]`, i.e
    /// `[\p{gc=Space_Separator}\N{CHARACTER TABULATION}]
    case horizontalWhitespace
    /// Character.isNewline
    case newlineSequence
    /// Vertical whitespace: `[\u{0A}-\u{0D}\u{85}\u{2028}\u{2029}]`
    case verticalWhitespace
    /// Character.isWhitespace
    case whitespace
    /// Character.isLetter or Character.isDigit or Character == "_"
    case word
  }

  enum MatchLevel: Hashable {
    /// Match at the extended grapheme cluster level.
    case graphemeCluster
    /// Match at the Unicode scalar level.
    case unicodeScalar
  }

  var scalarSemantic: Self {
    var result = self
    result.matchLevel = .unicodeScalar
    return result
  }
  
  var graphemeClusterSemantic: Self {
    var result = self
    result.matchLevel = .graphemeCluster
    return result
  }

  /// Conditionally inverts a character class.
  ///
  /// - Parameter inversion: Indicates whether to invert the character class.
  /// - Returns: The inverted character class if `inversion` is `true`;
  ///   otherwise, the same character class.
  func withInversion(_ inversion: Bool) -> Self {
    var copy = self
    if inversion {
      copy.isInverted.toggle()
    }
    return copy
  }

  /// Inverts a character class.
  var inverted: Self {
    return withInversion(true)
  }
  
  /// Returns the end of the match of this character class in the string.
  ///
  /// - Parameter str: The string to match against.
  /// - Parameter at: The index to start matching.
  /// - Parameter options: Options for the match operation.
  /// - Returns: The index of the end of the match, or `nil` if there is no match.
  func matches(in str: String, at i: String.Index, with options: MatchingOptions) -> String.Index? {
    switch matchLevel {
    case .graphemeCluster:
      let c = str[i]
      var matched: Bool
      var next = str.index(after: i)
      switch cc {
      case .any, .anyGrapheme: matched = true
      case .anyScalar:
        matched = true
        next = str.unicodeScalars.index(after: i)
      case .digit:
        matched = c.isNumber && (c.isASCII || !options.usesASCIIDigits)
      case .hexDigit:
        matched = c.isHexDigit && (c.isASCII || !options.usesASCIIDigits)
      case .horizontalWhitespace:
        matched = c.unicodeScalars.first?.isHorizontalWhitespace == true
          && (c.isASCII || !options.usesASCIISpaces)
      case .newlineSequence, .verticalWhitespace:
        matched = c.unicodeScalars.first?.isNewline == true
          && (c.isASCII || !options.usesASCIISpaces)
      case .whitespace:
        matched = c.isWhitespace && (c.isASCII || !options.usesASCIISpaces)
      case .word:
        matched = c.isWordCharacter && (c.isASCII || !options.usesASCIIWord)
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? next : nil
    case .unicodeScalar:
      let c = str.unicodeScalars[i]
      var nextIndex = str.unicodeScalars.index(after: i)
      var matched: Bool
      switch cc {
      case .any: matched = true
      case .anyScalar: matched = true
      case .anyGrapheme:
        matched = true
        nextIndex = str.index(after: i)
      case .digit:
        matched = c.properties.numericType != nil && (c.isASCII || !options.usesASCIIDigits)
      case .hexDigit:
        matched = Character(c).isHexDigit && (c.isASCII || !options.usesASCIIDigits)
      case .horizontalWhitespace:
        matched = c.isHorizontalWhitespace && (c.isASCII || !options.usesASCIISpaces)
      case .verticalWhitespace:
        matched = c.isNewline && (c.isASCII || !options.usesASCIISpaces)
      case .newlineSequence:
        matched = c.isNewline && (c.isASCII || !options.usesASCIISpaces)
        if c == "\r" && nextIndex != str.endIndex && str.unicodeScalars[nextIndex] == "\n" {
          str.unicodeScalars.formIndex(after: &nextIndex)
        }
      case .whitespace:
        matched = c.properties.isWhitespace && (c.isASCII || !options.usesASCIISpaces)
      case .word:
        matched = (c.properties.isAlphabetic || c == "_") && (c.isASCII || !options.usesASCIIWord)
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? nextIndex : nil
    }
  }
}

extension _CharacterClassModel {
  static var any: _CharacterClassModel {
    .init(cc: .any, matchLevel: .graphemeCluster)
  }

  static var anyGrapheme: _CharacterClassModel {
    .init(cc: .anyGrapheme, matchLevel: .graphemeCluster)
  }

  static var anyUnicodeScalar: _CharacterClassModel {
    .init(cc: .any, matchLevel: .unicodeScalar)
  }

  static var whitespace: _CharacterClassModel {
    .init(cc: .whitespace, matchLevel: .graphemeCluster)
  }
  
  static var digit: _CharacterClassModel {
    .init(cc: .digit, matchLevel: .graphemeCluster)
  }
  
  static var hexDigit: _CharacterClassModel {
    .init(cc: .hexDigit, matchLevel: .graphemeCluster)
  }

  static var horizontalWhitespace: _CharacterClassModel {
    .init(cc: .horizontalWhitespace, matchLevel: .graphemeCluster)
  }

  static var newlineSequence: _CharacterClassModel {
    .init(cc: .newlineSequence, matchLevel: .graphemeCluster)
  }

  static var verticalWhitespace: _CharacterClassModel {
    .init(cc: .verticalWhitespace, matchLevel: .graphemeCluster)
  }

  static var word: _CharacterClassModel {
    .init(cc: .word, matchLevel: .graphemeCluster)
  }
}

extension _CharacterClassModel.Representation: CustomStringConvertible {
  var description: String {
    switch self {
    case .any: return "<any>"
    case .anyGrapheme: return "<any grapheme>"
    case .anyScalar: return "<any scalar>"
    case .digit: return "<digit>"
    case .hexDigit: return "<hex digit>"
    case .horizontalWhitespace: return "<horizontal whitespace>"
    case .newlineSequence: return "<newline sequence>"
    case .verticalWhitespace: return "vertical whitespace"
    case .whitespace: return "<whitespace>"
    case .word: return "<word>"
    }
  }
}

extension _CharacterClassModel: CustomStringConvertible {
  var description: String {
    return "\(isInverted ? "not " : "")\(cc)"
  }
}

extension _CharacterClassModel {
  func withMatchLevel(
    _ level: _CharacterClassModel.MatchLevel
  ) -> _CharacterClassModel {
    var cc = self
    cc.matchLevel = level
    return cc
  }
}

extension AST.Atom {
    var characterClass: _CharacterClassModel? {
    switch kind {
    case let .escaped(b): return b.characterClass

    case .property:
      // TODO: Would our model type for character classes include
      // this? Or does grapheme-semantic mode complicate that?
      return nil
      
    case .any:
      // `.any` is handled in the matching engine by Compiler.emitAny() and in
      // the legacy compiler by the `.any` instruction, which can provide lower
      // level instructions than the CharacterClass-generated consumer closure
      //
      // FIXME: We shouldn't be returning `nil` here, but instead fixing the call
      // site to check for any before trying to construct a character class.
      return nil

    default: return nil

    }
  }

}

extension AST.Atom.EscapedBuiltin {
    var characterClass: _CharacterClassModel? {
    switch self {
    case .decimalDigit:    return .digit
    case .notDecimalDigit: return .digit.inverted

    case .horizontalWhitespace: return .horizontalWhitespace
    case .notHorizontalWhitespace:
      return .horizontalWhitespace.inverted

    case .newlineSequence: return .newlineSequence

    // FIXME: This is more like '.' than inverted '\R', as it is affected
    // by e.g (*CR). We should therefore really be emitting it through
    // emitAny(). For now we treat it as semantically invalid.
    case .notNewline: return .newlineSequence.inverted

    case .whitespace:    return .whitespace
    case .notWhitespace: return .whitespace.inverted

    case .verticalTab:    return .verticalWhitespace
    case .notVerticalTab: return .verticalWhitespace.inverted

    case .wordCharacter:    return .word
    case .notWordCharacter: return .word.inverted

    case .graphemeCluster: return .anyGrapheme
    case .trueAnychar: return .anyUnicodeScalar

    default:
      return nil
    }
  }
}

extension _CharacterClassModel {
  // FIXME: Calling on inverted sets wont be the same as the
  // inverse of a boundary if at the start or end of the
  // string. (Think through what we want: do it ourselves or
  // give the caller both options).
  func isBoundary(
    _ input: String,
    at pos: String.Index,
    bounds: Range<String.Index>,
    with options: MatchingOptions
  ) -> Bool {
    // FIXME: How should we handle bounds?
    // We probably need two concepts
    if bounds.isEmpty { return false }
    if pos == bounds.lowerBound {
      return self.matches(in: input, at: pos, with: options) != nil
    }
    let priorIdx = input.index(before: pos)
    if pos == bounds.upperBound {
      return self.matches(in: input, at: priorIdx, with: options) != nil
    }

    let prior = self.matches(in: input, at: priorIdx, with: options) != nil
    let current = self.matches(in: input, at: pos, with: options) != nil
    return prior != current
  }

}
