/// A lexically-rich token from a regex literal.
///
/// Note: This is a Swifty, nested, non-trivial projection of `TokenStorage`.
/// Store and traffic in that instead.
enum NewToken {
  // Just a character
  //
  // A, \*, \\, ...
  case char(Character)

  // A single escaped character
  //
  // \n, \s, \Q, \b, \A, \K, ...
  case escaped(EscapedSingle)

  // A Unicode scalar value written as a literal
  //
  // \u{...}, \0dd, \x{...}, ...
  case scalar(Unicode.Scalar)

  // A Unicode property, category, or script
  //
  // \p{...}, \p{^...}, \P
  case property(Prop, inverted: Bool)

  // A control character
  //
  // \cx, \C-x, \M-x, \M-\C-x, ...
  case control(Character)
  case keyboardMeta(Character, alsoControl: Bool) // Oniguruma

  // Post-fix quantification
  case quantifier(Quantifier)

  // A named set (using POSIX syntax)
  //
  // [[:...:]], [[:^...:]]
  case named(POSIXSet, inverted: Bool)

  // [, [^
  case startCustomCharacterClass(inverted: Bool)

  // ]
  case endCustomCharacterClass

  // The start of a group
  case startGroup(GroupStart)

  // )
  case endGroup

  // .
  case any

  // ^
  case startOfLine

  // $
  case endOfLine

  // |
  case alternation

  // References
  case backreference(Reference)
  case subpattern(Reference)
  case condition(Reference)

  //
  // Below only present in custom character classes
  //

  // `-`, sometimes the range binary operator
  //
  // Lexer knows to emit .char("-") outside of custom char class.
  //
  // TODO: can lexer check positioning easily?
  //
  case minus

  // &&, ~~, --, ||
  case setOperator(SetOperator)

}

import Util

extension NewToken {
  typealias POSIXSet = Unicode.POSIXCharacterSet

  // Characters, character types, literals, etc., derived from an escape
  // sequence.
  enum EscapedSingle: Character {
    // Literal single characters
    case alarm         = "a"
    case escape        = "e"
    case formfeed      = "f"
    case newline       = "n"
    case cariageReturn = "r"
    case tab           = "t"

    // Character types
    case singleDataUnit          = "C"
    case decimalDigit            = "d"
    case notDecimalDigit         = "D"
    case horizontalWhitespace    = "h"
    case notHorizontalWhitespace = "H"
    case notNewline              = "N"
    case newlineSequence         = "R"
    case whitespace              = "s"
    case notWhitespace           = "S"
    case verticalTab             = "v"
    case notVerticalTab          = "V"
    case wordCharacter           = "w"
    case notWordCharacter        = "W"
    case graphemeCluster         = "X"

    // Quoting
    case startQuote = "Q"
    case endQuote   = "E"

    // Assertions
    case wordBoundary    = "b"
    case notWordBoundary = "B"

    // Anchors
    case startOfSubject                 = "A"
    case endOfSubjectBeforeNewline      = "Z"
    case endOfSubject                   = "z"
    case firstMatchingPositionInSubject = "G"

    // Other
    case resetStartOfMatch = "K"

    // Oniguruma
    case trueAnychar = "O"
    case textSegnemt = "y"
    case notTextSegment = "Y"

  }

  enum Prop {
    case gc(Unicode.GeneralCategory)
    case pcreSpecial(PCRESpecialCategory)
    case script(Unicode.Script)
    // ... normal properties?

    case oniguruma(FlattendedOnigurumaUnicodeProperty)

    enum PCRESpecialCategory: String {
      case alphanumeric = "Xan"
      case posixSpace = "Xps"
      case perlSpace = "Xsp"
      case universallyNamedCharacter = "Xuc"
      case perlWord = "Xwd"
    }
  }
}

extension NewToken {
  // TODO: how much sharing should we do with AST, etc?
  enum Quantifier {
    case zeroOrMore(Kind)   // *,     *?,     *+
    case oneOrMore(Kind)    // +,     +?,     ++
    case zeroOrOne(Kind)    // ?,     ??,     ?+
    case exactly(Int, Kind) // {n},   {n}?,   {n}+
    case nOrMore(Int, Kind) // {n,},  {n,}?,  {n,}+
    case upToN(Int, Kind)   // {,n},  {,n}?,  {,n}+
    case range(             // {n,m}, {n,m}?, {n,m}+
      atLeast: Int, atMost: Int, Kind)

    enum Kind {
      case greedy     //
      case reluctant  // ?
      case possessive // +
    }
  }

  enum SetOperator: String {
    case intersection        = "&&"

    // The following are mentioned in UTS #18
    case symmetricDifference = "~~"
    case union               = "||"
    case difference          = "--"
  }

  enum GroupStart {
    // (...)
    case capture

    // (?<name>...) (?'name'...) (?P<name>...)
    case namedCapture(String)

    // (?:...) (?|...)
    case nonCapture(resetNumbersForAlternations: Bool)

    // (?>...)
    case atomicNonCapturing // TODO: is Oniguruma capturing?

    // (?#....)
    case comment

    // (?=...) (?!...)
    case lookahead(inverted: Bool)

    // (?<=...) (?<!...)
    case lookbehind(inverted: Bool)
  }

  enum Reference {
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

    // ?(R) (?(R)...
    case recurseWholePattern
  }

  /*

   TODO: finish PCRE and Oniguruma

   - conditional patterns
   - options
   - callouts
   - absent functions
   - recursion levels
   - subexp calls
   - outer options

   */
}

typealias OldToken = Token

/// The stored representation of a token. This is more efficiently stored, passed around,
/// and has access to original source locations.
struct TokenStorage {
  // Bootstrapping ourselves a bit. We will just want a flat
  // trivial enum and source locations
  var oldTokenKind: OldToken.Kind

  /// The source location span of the token itself
  let loc: Range<Source.Location>

  /// Whether this token was found in a custom character class
  let fromCustomCharacterClass: Bool
}

extension TokenStorage {

  var token: NewToken {
    projectToken(
      oldTokenKind,
      inCustomCharacterClass: fromCustomCharacterClass)
  }

  func prettyPrint() -> String {
    fatalError()
  }
}

// TODO: Better name than "storage". It's the storage form, but also
// the exchange form, has access to source information, original,
// spelling, etc.
//
// The enum can't be RawRepresentable, and there is no
// RawStorage feature.

private func projectToken(
  _ token: OldToken.Kind, inCustomCharacterClass: Bool
) -> NewToken {
  fatalError()
}

