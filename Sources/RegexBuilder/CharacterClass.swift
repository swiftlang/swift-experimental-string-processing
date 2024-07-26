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

/// A class of characters that match in a regex.
///
/// A character class can represent individual characters, a group of
/// characters, the set of character that match some set of criteria, or
/// a set algebraic combination of all of the above.
@available(SwiftStdlib 5.7, *)
public struct CharacterClass {
  internal var ccc: DSLTree.CustomCharacterClass
  /// The builtin character class, if this CharacterClass is representable by one
  internal var builtin: DSLTree.Atom.CharacterClass?
  
  init(_ ccc: DSLTree.CustomCharacterClass) {
    self.ccc = ccc
    self.builtin = nil
  }
  
  init(builtin: DSLTree.Atom.CharacterClass) {
    self.ccc = .init(members: [.atom(.characterClass(builtin))])
    self.builtin = builtin
  }
}

@available(SwiftStdlib 5.7, *)
extension CharacterClass: RegexComponent {
  public var regex: Regex<Substring> {
    if let cc = builtin {
      return _RegexFactory().characterClass(cc)
    } else {
      return _RegexFactory().customCharacterClass(ccc)
    }
  }
}

@available(SwiftStdlib 5.7, *)
extension CharacterClass {
  /// A character class that matches any character that does not match this
  /// character class.
  ///
  /// For example, you can use the `inverted` property to create a character
  /// class that excludes a specific group of characters:
  ///
  ///     let validCharacters = CharacterClass("a"..."z", .anyOf("-_"))
  ///     let invalidCharacters = validCharacters.inverted
  ///
  ///     let username = "user123"
  ///     if username.contains(invalidCharacters) {
  ///         print("Invalid username: '\(username)'")
  ///     }
  ///     // Prints "Invalid username: 'user123'"
  public var inverted: CharacterClass {
    if let inv = builtin?.inverted {
      return CharacterClass(builtin: inv)
    } else {
      return CharacterClass(ccc.inverted)
    }
  }
}

@available(SwiftStdlib 5.7, *)
extension RegexComponent where Self == CharacterClass {
  /// A character class that matches any element.
  ///
  /// This character class is unaffected by the `dotMatchesNewlines()` method.
  /// To match any character that isn't a newline, see
  /// ``anyNonNewline``.
  ///
  /// This character class is equivalent to the regex syntax "dot"
  /// metacharacter in single-line mode: `(?s:.)`.
  public static var any: CharacterClass {
    .init(DSLTree.CustomCharacterClass(members: [.atom(.any)]))
  }

  /// A character class that matches any element that isn't a newline.
  ///
  /// This character class is unaffected by the `dotMatchesNewlines()` method.
  /// To match any character, including newlines, see ``any``.
  ///
  /// This character class is equivalent to the regex syntax "dot"
  /// metacharacter with single-line mode disabled: `(?-s:.)`.
  public static var anyNonNewline: CharacterClass {
    .init(DSLTree.CustomCharacterClass(members: [.atom(.anyNonNewline)]))
  }

  /// A character class that matches any single `Character`, or extended
  /// grapheme cluster, regardless of the current semantic level.
  ///
  /// This character class is equivalent to `\X` in regex syntax.
  public static var anyGraphemeCluster: CharacterClass {
    .init(builtin: .anyGrapheme)
  }
  
  /// A character class that matches any digit.
  ///
  /// This character class is equivalent to `\d` in regex syntax.
  public static var digit: CharacterClass {
    .init(builtin: .digit)
  }
  
  /// A character class that matches any hexadecimal digit.
  ///
  /// `hexDigit` matches the ASCII characters `0` through `9`, and upper- or
  /// lowercase `a` through `f`. The corresponding characters in the "Halfwidth
  /// and Fullwidth Forms" Unicode block are not matched by this character
  /// class.
  public static var hexDigit: CharacterClass {
    .init(DSLTree.CustomCharacterClass(members: [
      .range(.char("A"), .char("F")),
      .range(.char("a"), .char("f")),
      .range(.char("0"), .char("9")),
    ]))
  }

  /// A character class that matches any element that is a "word character".
  ///
  /// This character class is equivalent to `\w` in regex syntax.
  public static var word: CharacterClass {
    .init(builtin: .word)
  }

  /// A character class that matches any element that is classified as
  /// whitespace.
  ///
  /// This character class is equivalent to `\s` in regex syntax.
  public static var whitespace: CharacterClass {
    .init(builtin: .whitespace)
  }

  /// A character class that matches any element that is classified as
  /// horizontal whitespace.
  ///
  /// This character class is equivalent to `\h` in regex syntax.
  public static var horizontalWhitespace: CharacterClass {
    .init(builtin: .horizontalWhitespace)
  }

  /// A character class that matches any newline sequence.
  ///
  /// This character class is equivalent to `\R` or `\n` in regex syntax.
  public static var newlineSequence: CharacterClass {
    .init(builtin: .newlineSequence)
  }

  /// A character class that matches any element that is classified as
  /// vertical whitespace.
  ///
  /// This character class is equivalent to `\v` in regex syntax.
  public static var verticalWhitespace: CharacterClass {
    .init(builtin: .verticalWhitespace)
  }
}

@available(SwiftStdlib 5.7, *)
extension RegexComponent where Self == CharacterClass {
  /// Returns a character class that matches any character in the given string
  /// or sequence.
  ///
  /// Calling this method with a group of characters is equivalent to listing
  /// those characters in a custom character class in regex syntax. For example,
  /// the two regexes in this example are equivalent:
  ///
  ///     let regex1 = /[abcd]+/
  ///     let regex2 = OneOrMore(.anyOf("abcd"))
  public static func anyOf<S: Sequence>(_ s: S) -> CharacterClass
    where S.Element == Character
  {
    CharacterClass(DSLTree.CustomCharacterClass(
      members: s.map { .atom(.char($0)) }))
  }
  
  /// Returns a character class that matches any Unicode scalar in the given
  /// sequence.
  ///
  /// Calling this method with a group of Unicode scalars is equivalent to
  /// listing them in a custom character class in regex syntax.
  public static func anyOf<S: Sequence>(_ s: S) -> CharacterClass
    where S.Element == UnicodeScalar
  {
    CharacterClass(DSLTree.CustomCharacterClass(
      members: s.map { .atom(.scalar($0)) }))
  }
}

// Unicode properties
@available(SwiftStdlib 5.7, *)
extension CharacterClass {
  /// Returns a character class that matches any element with the given Unicode
  /// general category.
  ///
  /// For example, when passed `.uppercaseLetter`, this method is equivalent to
  /// `/\p{Uppercase_Letter}/` or `/\p{Lu}/`.
  public static func generalCategory(_ category: Unicode.GeneralCategory) -> CharacterClass {
    return CharacterClass(.generalCategory(category))
  }
}

/// Returns a character class that includes the characters in the given range.
@available(SwiftStdlib 5.7, *)
public func ...(lhs: Character, rhs: Character) -> CharacterClass {
  let range: DSLTree.CustomCharacterClass.Member = .range(.char(lhs), .char(rhs))
  let ccc = DSLTree.CustomCharacterClass(members: [range], isInverted: false)
  return CharacterClass(ccc)
}

/// Returns a character class that includes the Unicode scalars in the given range.
@_disfavoredOverload
@available(SwiftStdlib 5.7, *)
public func ...(lhs: UnicodeScalar, rhs: UnicodeScalar) -> CharacterClass {
  let range: DSLTree.CustomCharacterClass.Member = .range(.scalar(lhs), .scalar(rhs))
  let ccc = DSLTree.CustomCharacterClass(members: [range], isInverted: false)
  return CharacterClass(ccc)
}

// MARK: - Set algebra methods

@available(SwiftStdlib 5.7, *)
extension RegexComponent where Self == CharacterClass {
  /// Creates a character class that combines the given classes in a union.
  public init(_ first: CharacterClass, _ rest: CharacterClass...) {
    if rest.isEmpty {
      self.init(first.ccc)
    } else {
      let members: [DSLTree.CustomCharacterClass.Member] =
        (CollectionOfOne(first) + rest).map { .custom($0.ccc) }
      self.init(.init(members: members))
    }
  }
}

@available(SwiftStdlib 5.7, *)
extension CharacterClass {
  /// Returns a character class from the union of this class and the given class.
  public func union(_ other: CharacterClass) -> CharacterClass {
    CharacterClass(.init(members: [
      .custom(self.ccc),
      .custom(other.ccc)]))
  }
  
  /// Returns a character class from the intersection of this class and the given class.
  public func intersection(_ other: CharacterClass) -> CharacterClass {
    CharacterClass(.init(members: [
      .intersection(self.ccc, other.ccc)
    ]))
  }
  
  /// Returns a character class by subtracting the given class from this class.
  public func subtracting(_ other: CharacterClass) -> CharacterClass {
    CharacterClass(.init(members: [
      .subtraction(self.ccc, other.ccc)
    ]))
  }
  
  /// Returns a character class matching elements in one or the other, but not both,
  /// of this class and the given class.
  public func symmetricDifference(_ other: CharacterClass) -> CharacterClass {
    CharacterClass(.init(members: [
      .symmetricDifference(self.ccc, other.ccc)
    ]))
  }
}
