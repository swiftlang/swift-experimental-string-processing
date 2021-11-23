import Util

public enum Atom: Hashable {
  /// Just a character
  ///
  /// A, \*, \\, ...
  case char(Character)

  /// A Unicode scalar value written as a literal
  ///
  /// \u{...}, \0dd, \x{...}, ...
  case scalar(Unicode.Scalar)

  /// A Unicode property, category, or script
  ///
  /// \p{...}, \p{^...}, \P
  case property(Prop, inverted: Bool)

  /// A built-in escaped character
  ///
  /// Literal escapes: \n, \t ...
  /// Character classes: \s, \w ...
  /// \n, \s, \Q, \b, \A, \K, ...
  case escaped(EscapedBuiltin) // TODO: expand this out

  /// A control character
  ///
  /// \cx, \C-x, \M-x, \M-\C-x, ...
  case keyboardControl(Character)
  case keyboardMeta(Character)        // Oniguruma
  case keyboardMetaControl(Character) // Oniguruma

  /// TODO: does this go here?
  ///
  /// A named set (using POSIX syntax)
  ///
  /// [[:...:]], [[:^...:]]
  case named(POSIXSet, inverted: Bool)

  /// .
  case any

  /// ^
  case startOfLine

  /// $
  case endOfLine

  // References
  //
  // TODO: Haven't thought through these a ton
  case backreference(Reference)
  case subpattern(Reference)
  case condition(Reference)

  /// Meaningless, used for e.g. non-semantic whitespace
  ///
  /// TODO: Does this mean we can't be quantified? we should check sooner...
  case trivia
}

extension Atom {
  struct Storage: Hashable {
    let kind: Atom
    let loc: SourceRange

    // TODO: would this be useful to anyone?
    let fromCustomCharacterClass: Bool
  }
}

extension Atom {

  // TODO: We might scrap this and break out a few categories so
  // we can pull in `^`, `$`, and `.`, but we probably want to
  // just provide API instead, since that can transcend
  // taxonomies.

  // Characters, character types, literals, etc., derived from
  // an escape sequence.
  public enum EscapedBuiltin: Hashable {
    // TOOD: better doc comments

    // Literal single characters

    /// \a
    case alarm

    /// \e
    case escape

    /// \f
    case formfeed

    /// \n
    case newline

    /// \r
    case carriageReturn

    /// \t
    case tab

    // Character types

    /// \C
    case singleDataUnit

    /// \d
    case decimalDigit

    /// \D
    case notDecimalDigit

    /// \h
    case horizontalWhitespace

    /// \H
    case notHorizontalWhitespace

    /// \N
    case notNewline

    /// \R
    case newlineSequence

    /// \s
    case whitespace

    /// \S
    case notWhitespace

    /// \v
    case verticalTab

    /// \V
    case notVerticalTab

    /// \w
    case wordCharacter

    /// \W
    case notWordCharacter

    /// \b (from within a custom character class)
    case backspace

    // Consumers?

    /// \X
    case graphemeCluster

    // Assertions

    /// \b (from outside a custom character class)
    case wordBoundary

    /// \B
    case notWordBoundary

    // Anchors

    /// \A
    case startOfSubject

    /// \Z
    case endOfSubjectBeforeNewline

    /// \z
    case endOfSubject

    /// \G
    case firstMatchingPositionInSubject

    // Other

    /// \K
    case resetStartOfMatch

    // Oniguruma

    /// \O
    case trueAnychar

    /// \y
    case textSegment

    /// \Y
    case notTextSegment
  }
}

extension Atom.EscapedBuiltin {
  public var character: Character {
    switch self {
    // Literal single characters
    case .alarm:          return "a"
    case .escape:         return "e"
    case .formfeed:       return "f"
    case .newline:        return "n"
    case .carriageReturn: return "r"
    case .tab:            return "t"

    // Character types
    case .singleDataUnit:          return "C"
    case .decimalDigit:            return "d"
    case .notDecimalDigit:         return "D"
    case .horizontalWhitespace:    return "h"
    case .notHorizontalWhitespace: return "H"
    case .notNewline:              return "N"
    case .newlineSequence:         return "R"
    case .whitespace:              return "s"
    case .notWhitespace:           return "S"
    case .verticalTab:             return "v"
    case .notVerticalTab:          return "V"
    case .wordCharacter:           return "w"
    case .notWordCharacter:        return "W"

    case .graphemeCluster:         return "X"

    // Assertions
    case .backspace:       return "b" // inside custom cc
    case .wordBoundary:    return "b" // outside custom cc
    case .notWordBoundary: return "B"

    // Anchors
    case .startOfSubject:                 return "A"
    case .endOfSubjectBeforeNewline:      return "Z"
    case .endOfSubject:                   return "z"
    case .firstMatchingPositionInSubject: return "G"

    // Other
    case .resetStartOfMatch: return "K"

    // Oniguruma
    case .trueAnychar: return "O"
    case .textSegment: return "y"
    case .notTextSegment: return "Y"
    }
  }
  private static func fromCharacter(
    _ c: Character, inCustomCharacterClass customCC: Bool
  ) -> Self? {
    // Valid both inside and outside custom character classes.
    switch c {
    // Literal single characters
    case "a": return .alarm
    case "e": return .escape
    case "f": return .formfeed
    case "n": return .newline
    case "r": return .carriageReturn
    case "t": return .tab

    // Character types
    case "d": return .decimalDigit
    case "D": return .notDecimalDigit
    case "h": return .horizontalWhitespace
    case "H": return .notHorizontalWhitespace
    case "s": return .whitespace
    case "S": return .notWhitespace
    case "v": return .verticalTab
    case "V": return .notVerticalTab
    case "w": return .wordCharacter
    case "W": return .notWordCharacter

    // Assertions
    case "b": return customCC ? .backspace : .wordBoundary

    default: break
    }

    // The following are only valid outside custom character classes.
    guard !customCC else { return nil }
    switch c {
    // Character types
    case "C": return .singleDataUnit
    case "N": return .notNewline
    case "R": return .newlineSequence

    case "X": return .graphemeCluster

    // Assertions
    case "B": return .notWordBoundary

    // Anchors
    case "A": return .startOfSubject
    case "Z": return .endOfSubjectBeforeNewline
    case "z": return .endOfSubject
    case "G": return .firstMatchingPositionInSubject

    // Other
    case "K": return .resetStartOfMatch

    // Oniguruma
    case "O": return .trueAnychar
    case "y": return .textSegment
    case "Y": return .notTextSegment

    default: return nil
    }
  }
  public init?(_ c: Character, inCustomCharacterClass customCC: Bool) {
    guard let builtin = Self.fromCharacter(c, inCustomCharacterClass: customCC)
      else { return nil }
    self = builtin
  }
}

extension Atom {
  public typealias POSIXSet = Unicode.POSIXCharacterSet

  // TODO: Hamish, I believe you have a formulation of this and have
  // thought through the parsing a whole lot more. This is just what
  // I have at the time, but let's get something better for the AST
  // and parser support.
  public enum Prop: Hashable {
    case gc(Unicode.GeneralCategory)
    case pcreSpecial(PCRESpecialCategory)
    case script(Unicode.Script)

    // TODO: replace me
    case propCheck(PropName, PropValue)

    // TODO: yuk, let's make sure other cases are a superset of this
    case oniguruma(FlattendedOnigurumaUnicodeProperty)

    // TODO: erm, separate out or fold into something? splat it in?
    public enum PCRESpecialCategory: String, Hashable {
      case alphanumeric     = "Xan"
      case posixSpace       = "Xps"
      case perlSpace        = "Xsp"
      case universallyNamed = "Xuc"
      case perlWord         = "Xwd"
    }

    public enum PropName: Hashable {}
    public enum PropValue: Hashable {}
  }
}

// TODO: I haven't thought through this a bunch; this seems like
// a sensible type to have and break down this way. But it could
// easily get folded in with the kind of reference
public enum Reference: Hashable {
  // \n \gn \g{n} \g<n> \g'n' (?n) (?(n)...
  // Oniguruma: \k<n>, \k'n'
  case absolute(Int)

  // \g{-n} \g<+n> \g'+n' \g<-n> \g'-n' (?+n) (?-n)
  // (?(+n)... (?(-n)...
  // Oniguruma: \k<-n> \k<+n> \k'-n' \k'+n'
  case relative(Int)

  // \k<name> \k'name' \g{name} \k{name} (?P=name)
  // \g<name> \g'name' (?&name) (?P>name)
  // (?(<name>)... (?('name')... (?(name)...
  case named(String)

  // TODO: I'm not sure the below goes here
  //
  // ?(R) (?(R)...
  case recurseWholePattern
}

extension Atom: _ASTPrintable {
  public func _print() -> String {
    switch self {
    case .char(let c): return c.halfWidthCornerQuoted
    case .scalar(let s): return s.halfWidthCornerQuoted
    case .property:
      fatalError("TODO")

    case .escaped(let c): return "\\\(c.character)".halfWidthCornerQuoted

    case .keyboardControl(_): fatalError("TODO")

    case .keyboardMeta(_):
      fatalError("TODO")
    case .keyboardMetaControl(_):
      fatalError("TODO")
    case .named:
      fatalError("TODO")
    case .any: return "."
    case .startOfLine: return "^"
    case .endOfLine: return "$"

    case .backreference(_):
      fatalError("TODO")
    case .subpattern(_):
      fatalError("TODO")
    case .condition(_):
      fatalError("TODO")
    case .trivia:
      return ""
    }
  }

  public func _dump() -> String {
    _print()
  }


}

extension Atom.EscapedBuiltin {
  var characterClass: CharacterClass? {
    // TODO: Hamish, can you take over?

    switch self {
    case .singleDataUnit: fatalError("TODO")

    case .decimalDigit:    return .digit
    case .notDecimalDigit: return .digit.inverted

    case .horizontalWhitespace: return .horizontalWhitespace
    case .notHorizontalWhitespace:
      return .horizontalWhitespace.inverted

    case .notNewline: fatalError("TODO")
    case .newlineSequence: return .newlineSequence

    case .whitespace:    return .whitespace
    case .notWhitespace: return .whitespace.inverted

    case .verticalTab:    return .verticalWhitespace
    case .notVerticalTab: return .verticalWhitespace.inverted

    case .wordCharacter:    return .word
    case .notWordCharacter: return .word.inverted

    default:
      return nil
    }
  }
}

extension Atom {
  var characterClass: CharacterClass? {
    switch self {
    case let .escaped(b): return b.characterClass

    case .named: fatalError("TODO")

    case .any: return .any

    case .property:
      // TODO: Would our model type for character classes include
      // this? Or does grapheme-semantic mode complicate that?
      return nil

    default: return nil

    }
  }
}
