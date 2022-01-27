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

import _MatchingEngine

// NOTE: This is a model type. We want to be able to get one from
// an AST, but this isn't a natural thing to produce in the context
// of parsing or to store in an AST

public struct CharacterClass: Hashable {
  /// The actual character class to match.
  var cc: Representation
  
  /// The level (character or Unicode scalar) at which to match.
  var matchLevel: MatchLevel

  /// Whether this character class matches against an inverse,
  /// e.g \D, \S, [^abc].
  var isInverted: Bool = false

  // TODO: Split out builtin character classes into their own type?
  public enum Representation: Hashable {
    /// Any character
    case any
    /// Any grapheme cluster
    case anyGrapheme
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
    /// One of the custom character set.
    case custom([CharacterSetComponent])
  }

  public typealias SetOperator = AST.CustomCharacterClass.SetOp

  /// A binary set operation that forms a character class component.
  public struct SetOperation: Hashable {
    var lhs: CharacterSetComponent
    var op: SetOperator
    var rhs: CharacterSetComponent

    public func matches(_ c: Character) -> Bool {
      switch op {
      case .intersection:
        return lhs.matches(c) && rhs.matches(c)
      case .subtraction:
        return lhs.matches(c) && !rhs.matches(c)
      case .symmetricDifference:
        return lhs.matches(c) != rhs.matches(c)
      }
    }
  }

  public enum CharacterSetComponent: Hashable {
    case character(Character)
    case range(ClosedRange<Character>)

    /// A nested character class.
    case characterClass(CharacterClass)

    /// A binary set operation of character class components.
    indirect case setOperation(SetOperation)

    public static func setOperation(
      lhs: CharacterSetComponent, op: SetOperator, rhs: CharacterSetComponent
    ) -> CharacterSetComponent {
      .setOperation(.init(lhs: lhs, op: op, rhs: rhs))
    }

    public func matches(_ character: Character) -> Bool {
      switch self {
      case .character(let c): return c == character
      case .range(let range): return range.contains(character)
      case .characterClass(let custom):
        let str = String(character)
        return custom.matches(in: str, at: str.startIndex) != nil
      case .setOperation(let op): return op.matches(character)
      }
    }
  }

  public enum MatchLevel {
    /// Match at the extended grapheme cluster level.
    case graphemeCluster
    /// Match at the Unicode scalar level.
    case unicodeScalar
  }

  public var scalarSemantic: Self {
    var result = self
    result.matchLevel = .unicodeScalar
    return result
  }
  
  public var graphemeClusterSemantic: Self {
    var result = self
    result.matchLevel = .graphemeCluster
    return result
  }

  /// Returns an inverted character class if true is passed, otherwise the
  /// same character class is returned.
  public func withInversion(_ invertion: Bool) -> Self {
    var copy = self
    if invertion {
      copy.isInverted.toggle()
    }
    return copy
  }

  /// Returns the inverse character class.
  public var inverted: Self {
    return withInversion(true)
  }
  
  /// Returns the end of the match of this character class in `str`, if
  /// it matches.
  public func matches(in str: String, at i: String.Index) -> String.Index? {
    switch matchLevel {
    case .graphemeCluster:
      let c = str[i]
      var matched: Bool
      switch cc {
      case .any, .anyGrapheme: matched = true
      case .digit: matched = c.isNumber
      case .hexDigit: matched = c.isHexDigit
      case .horizontalWhitespace: fatalError("Not implemented")
      case .newlineSequence: matched = c.isNewline
      case .verticalWhitespace: fatalError("Not implemented")
      case .whitespace: matched = c.isWhitespace
      case .word: matched = c.isWordCharacter
      case .custom(let set): matched = set.any { $0.matches(c) }
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? str.index(after: i) : nil
    case .unicodeScalar:
      let c = str.unicodeScalars[i]
      var matched: Bool
      switch cc {
      case .any: matched = true
      case .anyGrapheme: fatalError("Not matched in this mode")
      case .digit: matched = c.properties.numericType != nil
      case .hexDigit: matched = Character(c).isHexDigit
      case .horizontalWhitespace: fatalError("Not implemented")
      case .newlineSequence: fatalError("Not implemented")
      case .verticalWhitespace: fatalError("Not implemented")
      case .whitespace: matched = c.properties.isWhitespace
      case .word: matched = c.properties.isAlphabetic || c == "_"
      case .custom: fatalError("Not supported")
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? str.unicodeScalars.index(after: i) : nil
    }
  }
}

extension CharacterClass {
  public static var any: CharacterClass {
    .init(cc: .any, matchLevel: .graphemeCluster)
  }

  public static var anyGrapheme: CharacterClass {
    .init(cc: .anyGrapheme, matchLevel: .graphemeCluster)
  }

  public static var whitespace: CharacterClass {
    .init(cc: .whitespace, matchLevel: .graphemeCluster)
  }
  
  public static var digit: CharacterClass {
    .init(cc: .digit, matchLevel: .graphemeCluster)
  }
  
  public static var hexDigit: CharacterClass {
    .init(cc: .hexDigit, matchLevel: .graphemeCluster)
  }

  public static var horizontalWhitespace: CharacterClass {
    .init(cc: .horizontalWhitespace, matchLevel: .graphemeCluster)
  }

  public static var newlineSequence: CharacterClass {
    .init(cc: .newlineSequence, matchLevel: .graphemeCluster)
  }

  public static var verticalWhitespace: CharacterClass {
    .init(cc: .verticalWhitespace, matchLevel: .graphemeCluster)
  }

  public static var word: CharacterClass {
    .init(cc: .word, matchLevel: .graphemeCluster)
  }

  public static func custom(
    _ components: [CharacterSetComponent]
  ) -> CharacterClass {
    .init(cc: .custom(components), matchLevel: .graphemeCluster)
  }
}

extension CharacterClass.CharacterSetComponent: CustomStringConvertible {
  public var description: String {
    switch self {
    case .range(let range): return "<range \(range)>"
    case .character(let character): return "<character \(character)>"
    case .characterClass(let custom): return "\(custom)"
    case .setOperation(let op): return "<\(op.lhs) \(op.op) \(op.rhs)>"
    }
  }
}

extension CharacterClass.Representation: CustomStringConvertible {
  public var description: String {
    switch self {
    case .any: return "<any>"
    case .anyGrapheme: return "<any grapheme>"
    case .digit: return "<digit>"
    case .hexDigit: return "<hex digit>"
    case .horizontalWhitespace: return "<horizontal whitespace>"
    case .newlineSequence: return "<newline sequence>"
    case .verticalWhitespace: return "vertical whitespace"
    case .whitespace: return "<whitespace>"
    case .word: return "<word>"
    case .custom(let set): return "<custom \(set)>"
    }
  }
}

extension CharacterClass: CustomStringConvertible {
  public var description: String {
    return "\(isInverted ? "not " : "")\(cc)"
  }
}

extension CharacterClass {
  public func makeAST() -> AST? {
    let inv = isInverted

    func esc(_ b: AST.Atom.EscapedBuiltin) -> AST {
      escaped(b)
    }

    switch cc {
    case .any: return atom(.any)

    case .digit:
      return esc(inv ? .notDecimalDigit : .decimalDigit)

    case .horizontalWhitespace:
      return esc(
        inv ? .notHorizontalWhitespace : .horizontalWhitespace)

    // FIXME: newline sequence is not same as \n
    case .newlineSequence:
      return esc(inv ? .notNewline : .newline)

    case .whitespace:
      return esc(inv ? .notWhitespace : .whitespace)

    case .verticalWhitespace:
      return esc(inv ? .notVerticalTab : .verticalTab)

    case .word:
      return esc(inv ? .notWordCharacter : .wordCharacter)

    case .anyGrapheme:
      return esc(.graphemeCluster)

    case .hexDigit:
      let members: [AST.CustomCharacterClass.Member] = [
        range_m(.char("a"), .char("f")),
        range_m(.char("A"), .char("F")),
        range_m(.char("0"), .char("9")),
      ]
      let ccc = AST.CustomCharacterClass(
        .init(faking: inv ? .inverted : .normal),
        members,
        .fake)

      return .customCharacterClass(ccc)

    default: return nil
    }
  }
}

extension AST {
  /// If this has a character class representation, whether built-in or custom, return it.
  ///
  /// TODO: Not sure if this the right model type, but I suspect we'll want to produce
  /// something like this on demand
  var characterClass: CharacterClass? {
    switch self {
    case let .customCharacterClass(cc): return cc.modelCharacterClass
    case let .atom(a): return a.characterClass

    default: return nil
    }
  }
}

extension CharacterClass {
  public func withMatchLevel(
    _ level: CharacterClass.MatchLevel
  ) -> CharacterClass {
    var cc = self
    cc.matchLevel = level
    return cc
  }
}

extension AST.Atom {
  var characterClass: CharacterClass? {
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
      return nil

    default: return nil

    }
  }

}

extension AST.Atom.EscapedBuiltin {
  var characterClass: CharacterClass? {
    switch self {
    case .decimalDigit:    return .digit
    case .notDecimalDigit: return .digit.inverted

    case .horizontalWhitespace: return .horizontalWhitespace
    case .notHorizontalWhitespace:
      return .horizontalWhitespace.inverted

    case .notNewline: return .newlineSequence.inverted
    case .newlineSequence: return .newlineSequence

    case .whitespace:    return .whitespace
    case .notWhitespace: return .whitespace.inverted

    case .verticalTab:    return .verticalWhitespace
    case .notVerticalTab: return .verticalWhitespace.inverted

    case .wordCharacter:    return .word
    case .notWordCharacter: return .word.inverted

    case .graphemeCluster: return .anyGrapheme

    default:
      return nil
    }
  }
}

extension AST.CustomCharacterClass {
  /// The model character class for this custom character class.
  var modelCharacterClass: CharacterClass? {
    typealias Component = CharacterClass.CharacterSetComponent
    func getComponents(_ members: [Member]) -> [Component]? {
      var result = Array<Component>()
      for m in members {
        switch m {
        case .custom(let cc):
          guard let cc = cc.modelCharacterClass else {
            return nil
          }
          result.append(.characterClass(cc))
        case .range(let r):
          result.append(.range(
            r.lhs.literalCharacterValue! ...
            r.rhs.literalCharacterValue!))

        case .atom(let a):
          if let cc = a.characterClass {
            result.append(.characterClass(cc))
          } else if let lit = a.literalCharacterValue {
            result.append(.character(lit))
          } else {
            return nil
          }

        case .quote(let q):
          // Decompose quoted literal into literal characters.
          result += q.literal.map { .character($0) }

        case .setOperation(let lhs, let op, let rhs):
          // FIXME: CharacterClass wasn't designed for set operations with
          // multiple components in each operand, we should fix that. For now,
          // just produce custom components.
          guard let lhs = getComponents(lhs),
                let rhs = getComponents(rhs)
          else {
            return nil
          }
          result.append(.setOperation(.init(
            lhs: .characterClass(.custom(lhs)),
            op: op.value,
            rhs: .characterClass(.custom(rhs)))))
        }
      }
      return result
    }
    guard let comps = getComponents(members) else {
      return nil
    }
    let cc = CharacterClass.custom(comps)
    return self.isInverted ? cc.inverted : cc
  }
}

extension CharacterClass {
  // FIXME: Calling on inverted sets wont be the same as the
  // inverse of a boundary if at the start or end of the
  // string. (Think through what we want: do it ourselves or
  // give the caller both options).
  func isBoundary(
    _ input: String,
    at pos: String.Index,
    bounds: Range<String.Index>
  ) -> Bool {
    // FIXME: How should we handle bounds?
    // We probably need two concepts
    if input.isEmpty { return false }
    if pos == input.startIndex {
      return self.matches(in: input, at: pos) != nil
    }
    let priorIdx = input.index(before: pos)
    if pos == input.endIndex {
      return self.matches(in: input, at: priorIdx) != nil
    }

    let prior = self.matches(in: input, at: priorIdx) != nil
    let current = self.matches(in: input, at: pos) != nil
    return prior != current
  }

}
