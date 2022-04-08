# Unicode for String Processing

Proposal: [SE-NNNN](NNNN-filename.md)  
Authors: [Nate Cook](https://github.com/natecook1000), [Michael Ilseman](https://github.com/milseman)  
Review Manager: TBD  
Implementation: [apple/swift-experimental-string-processing][repo]  
Status: **Draft**


## Introduction

This proposal describes `Regex`'s rich Unicode support during regular expression matching, along with the character classes and options and that define that behavior.

## Motivation

Character classes in regular expressions include metacharacters like `\d` to match a digit, `\s` to match whitespace, and `.` to match any character. Individual literal characters can also be thought of as character classes, as they at least match themselves, and, in case-insensitive matching, their case-toggled counterpart. For the purpose of this work, then, we consider a *character class* to be any part of a regular expression literal that can match an actual component of a string.

Operating over classes of characters is a vital component of string processing. Swift's `String` provides, by default, a view of `Character`s or [extended grapheme clusters][graphemes] whose comparison honors [Unicode canonical equivalence][canoneq].

```swift
let str = "Cafe\u{301}" // "Café"
str == "Café"           // true
str.dropLast()          // "Caf"
str.last == "é"         // true (precomposed e with acute accent)
str.last == "e\u{301}"  // true (e followed by composing acute accent)
```

At a regular expression's simplest, without metacharacters or special features, matching should behave like a test for equality. A string should always match a regular expression that simply contains the same characters.

```swift
str.contains(/Café/)        // true
```

And from there, small changes should continue to comport with the element counting and comparison expectations set by `String`:

```swift
str.contains(/Caf./)        // true
str.contains(/.+é/)         // true
str.contains(/.+e\u{301}/)  // true
str.contains(/\w+é/)        // true
```

With these initial principles in hand, we can look at how character classes should behave with Swift strings. Unicode leaves all interpretation of grapheme clusters up to implementations, which means that Swift needs to define any semantics for its own usage. Since other regex engines operate, at most, at the semantics level of Unicode scalar values, there is little to no prior art to consult.

<details><summary>Other engines</summary>

Character classes in other languages match at either the Unicode scalar value level, or even the code unit level, instead of recognizing grapheme clusters as characters. When matching the `.` character class, other languages will only match the first part of an `"e\u{301}"` grapheme cluster. Some languages, like Perl, Ruby, and Java, support an additional `\X` metacharacter, which explicitly represents a single grapheme cluster.

| Matching  `"Cafe\u{301}"` | Pattern: `^Caf.` | Remaining | Pattern:  `^Caf\X` | Remaining |
|---|---|---|---|---|
| C#, Rust, Go | `"Cafe"` | `"´"` | n/a | n/a |
| NSString, Java, Ruby, Perl | `"Cafe"` | `"´"` | `"Café"` | `""` |

Other than Java's `CANON_EQ` option, the vast majority of other languages and engines are not capable of comparing with canonical equivalence.

</details>

## Proposed solution

TK: semantic levels, options for controlling, canonical equivalence, Unicode properties

## Detailed design

First, we'll discuss the options that let you control a regex's behavior, and then explore the character classes that define the your pattern.

### Options

Options can be declared in two different ways: as part of [regular expression literal syntax][literals], or applied as methods when declaring a `Regex`. For example, both of these `Regex`es are declared with case insensitivity:

```swift
let regex1 = /(?i)label/
let regex2 = Regex {
    "label"
}.ignoringCase()`
```

Note that the `ignoringCase()` is available on any type conforming to `RegexComponent`, which means that you can use the more readable option-setting interface in conjunction with literals:

```swift
let regex3 = /label/.ignoringCase()
```

Calling option-setting methods like `ignoringCase(_:)` acts like wrapping the regex in a option-setting group. That is, while it sets the *default* behavior for the callee, it doesn’t override options that are applied to more specific regions. In this example, the `"b"` in `"label"` matches case-sensitively, despite the outer call to `ignoringCase()`:

```swift
let regex4 = Regex {
    "la"
    "b".ignoringCase(false)
    "el"
}
.ignoringCase()
	
"label".contains(regex4)     // true
"LAbEL".contains(regex4)     // true
"LABEL".contains(regex4)     // false
```

Option scoping in literals is discussed in the [Run-time Regex Construction proposal][option-scoping].

#### Case insensitivity

Regular expressions perform case sensitive comparisons by default. The `i` option or the `ignoringCase(_:)` method enables case insensitive comparison.

```swift
let str = "Café"
	
str.firstMatch(of: /CAFÉ/)          // nil
str.firstMatch(of: /(?i)CAFÉ/)      // "Café"
str.firstMatch(of: /(?i)cAfÉ/)      // "Café"
```

Case insensitive matching uses case folding to ensure that canonical equivalence continues to operate as expected.

*Regex literal syntax:* `/(?i).../` or `/(?i...)/`

*Regex builder syntax:*

```swift
extension RegexComponent {
    /// Returns a regular expression that ignores casing when matching.
    public func ignoringCase(_ ignoreCase: Bool = true) -> Regex<Output>
}
```

#### Single line mode (`.` matches newlines)

The "any" metacharacter (`.`) matches any character in a string *except* newlines by default. With the `s` option enabled, `.` matches any character including newlines.

```swift
let str = """
    <<This string
    uses double-angle-brackets
    to group text.>>
    """
    
str.firstMatch(of: /<<.+>>/)        // nil
str.firstMatch(of: /(?s)<<.+>>/)    // "This string\nuses double-angle-brackets\nto group text."
```

This option also affects the behavior of `CharacterClass.any`, which is designed to match the behavior of the `.` regex literal component.

*Regex literal syntax:* `/(?s).../` or `/(?s...)/`

*Regex builder syntax:*

```swift
extension RegexComponent {
  /// Returns a regular expression where the start and end of input
  /// anchors (`^` and `$`) also match against the start and end of a line.
  public func dotMatchesNewlines(_ dotMatchesNewlines: Bool = true) -> Regex<Output>
}
```

#### Reluctant quantification by default

Regular expression quantifiers (`+`, `*`, and `?`) match eagerly by default, such that they match the longest possible substring. Appending `?` to a quantifier makes it reluctant, instead, so that it matches the shortest possible substring.

```swift
let str = "<token>A value.</token>"
	
// By default, the '+' quantifier is eager, and consumes as much as possible.
str.firstMatch(of: /<.+>/)          // "<token>A value.</token>"
	
// Adding '?' makes the '+' quantifier reluctant, so that it consumes as little as possible.
str.firstMatch(of: /<.+?>/)         // "<token>"
```

The `U` option toggles the "eagerness" of quanitifiers, so that quantifiers are reluctant by default, and only become eager when `?` is added to the quantifier.

```swift
// '(?U)' toggles the eagerness of quantifiers:
str.firstMatch(of: /(?U)<.+>/)      // "<token>"
str.firstMatch(of: /(?U)<.+?>/)     // "<token>A value.</token>"
```

*Regex literal syntax:* `/(?U).../` or `/(?U...)/`

*Regex builder syntax:*

```swift
extension RegexComponent {
  /// Returns a regular expression where quantifiers are reluctant by default
  /// instead of eager.
  public func reluctantCaptures(_ useReluctantCaptures: Bool = true) -> Regex<Output>
}
```

#### Use ASCII-only character classes

With one or more of these options enabled, the default character classes match only ASCII values instead of the full Unicode range of characters. Four options are included in this group:

* `D`: Match only ASCII members for `\d`, `\p{Digit}`, `[:digit:]`, and the `CharacterClass.digit`.
* `S`: Match only ASCII members for `\s`, `\p{Space}`, `[:space:]`.
* `W`: Match only ASCII members for `\w`, `\p{Word}`, `[:word:]`, `\b`, `CharacterClass.word`, and `Anchor.wordBoundary`.
* `P`: Match only ASCII members for all POSIX properties (including `digit`, `space`, and `word`).

*Regex literal syntax:* `/(?DSWP).../` or `/(?DSWP...)/`

*Regex builder syntax:*

```swift
extension RegexComponent {
  /// Returns a regular expression that only matches ASCII characters as "word
  /// characters".
  public func usingASCIIWordCharacters(_ useASCII: Bool = true) -> Regex<Output>
	
  /// Returns a regular expression that only matches ASCII characters as digits.
  public func usingASCIIDigits(_ useASCII: Bool = true) -> Regex<Output>
	
  /// Returns a regular expression that only matches ASCII characters as space
  /// characters.
  public func usingASCIISpaces(_ useASCII: Bool = true) -> Regex<Output>
	
  /// Returns a regular expression that only matches ASCII characters when
  /// matching character classes.
  public func usingASCIICharacterClasses(_ useASCII: Bool = true) -> Regex<Output>
}
```

#### Use Unicode word boundaries

By default, matching uses the Unicode specification for finding word boundaries for the `\b` and `Anchor.wordBoundary` anchors. Disabling the `w` option switches to finding word boundaries at points in the input where `\b\B` or `\B\b` match, given the other matching options that are enabled, which may be more compatible with other regular expression engines.

In this example, the default matching behavior find the whole first word of the string, while the match with Unicode word boundaries disabled stops at the apostrophe:

```swift
let str = "Don't look down!"
	
str.firstMatch(of: /D\S+\b/)        // "Don't"
str.firstMatch(of: /(?-w)D\S+\b/)   // "Don"
```

*Regex literal syntax:* `/(?-w).../` or `/(?-w...)/`

*Regex builder syntax:*

```swift
extension RegexComponent {
  /// Returns a regular expression that uses the Unicode word boundary
  /// algorithm.
  ///
  /// This option is enabled by default; pass `false` to disable use of
  /// Unicode's word boundary algorithm.
  public func usingUnicodeWordBoundaries(_ useUnicodeWordBoundaries: Bool = true) -> Regex<Output>
}
```

### Matching semantic level

When matching with grapheme cluster semantics (the default), metacharacters like `.` and `\w`, custom character classes, and character class instances like `.any` match a grapheme cluster when possible, corresponding with the default string representation. In addition, matching with grapheme cluster semantics compares characters using their canonical representation, corresponding with the way comparing strings for equality works.

When matching with Unicode scalar semantics, metacharacters and character classes always match a single Unicode scalar value, even if that scalar comprises part of a grapheme cluster.

These semantic levels can lead to different results, especially when working with strings that have decomposed characters. In the following example, `queRegex` matches any 3-character string that begins with `"q"`.

```swift
let composed = "qué"
let decomposed = "que\u{301}"
	
let queRegex = /^q..$/
	
print(composed.contains(queRegex))
// Prints "true"
print(decomposed.contains(queRegex))
// Prints "true"
```

When using Unicode scalar semantics, however, the regular expression only matches the composed version of the string, because each `.` matches a single Unicode scalar value.

```swift
let queRegexScalar = queRegex.matchingSemantics(.unicodeScalar)
print(composed.contains(queRegexScalar))
// Prints "true"
print(decomposed.contains(queRegexScalar))
// Prints "false"
```

*Regex literal syntax:* `(?X)...` or `(?X...)` for grapheme cluster semantics, `(?u)...` or `(?u...)` for Unicode scalar semantics.

*Regex builder syntax:*

```swift
extension RegexComponent {
  /// Returns a regular expression that matches with the specified semantic
  /// level.
  public func matchingSemantics(_ semanticLevel: RegexSemanticLevel) -> Regex<Output>
}
	
public struct RegexSemanticLevel: Hashable {
  /// Match at the default semantic level of a string, where each matched
  /// element is a `Character`.
  public static var graphemeCluster: RegexSemanticLevel
  
  /// Match at the semantic level of a string's `UnicodeScalarView`, where each
  /// matched element is a `UnicodeScalar` value.
  public static var unicodeScalar: RegexSemanticLevel
}
```

#### Multiline mode

By default, the start and end anchors (`^` and `$`) match only the beginning and end of a string. With the `m` or the option, they also match the beginning and end of each line.

```swift
let str = """
    abc
    def
    ghi
    """
	
str.firstMatch(of: /^abc/)          // "abc"
str.firstMatch(of: /^abc$/)         // nil
str.firstMatch(of: /(?m)^abc$/)     // "abc"
	
str.firstMatch(of: /^def/)          // nil
str.firstMatch(of: /(?m)^def$/)     // "def"
```

This option applies only to anchors used in a regex literal. The anchors defined in `RegexBuilder` are specific about matching at the start/end of the input or the line, and therefore do not correspond directly with the `^` and `$` literal anchors.

```swift
str.firstMatch(of: Regex { Anchor.startOfInput ; "def" }) // nil
str.firstMatch(of: Regex { Anchor.startOfLine  ; "def" }) // "def"
```

*Regex literal syntax:* `/(?m).../` or `/(?m...)/`

*Regex builder syntax:*

```swift
extension RegexComponent {
  /// Returns a regular expression where the start and end of input
  /// anchors (`^` and `$`) also match against the start and end of a line.
  public func anchorsMatchLineEndings(_ matchLineEndings: Bool = true) -> Regex<Output>
}
```

---

### Character Classes

We propose the following definitions for regex character classes, along with a `CharacterClass` type as part of the `RegexBuilder` module, to encapsulate and simplify character class usage within builder-style regexes.

The two regular expressions defined in this example will match the same inputs, looking for one or more word characters followed by up to three digits, optionally separated by a space:

```swift
let regex1 = /\w+\s?\d{,3}/
let regex2 = Regex {
    OneOrMore(.word)
    Optionally(.whitespace)
    Repeat(.decimalDigit, ...3)
}
```

You can build custom character classes by combining regex-defined classes with individual characters or ranges, or by performing common set operations such as subtracting or negating a character class.


#### “Any”

The simplest character class, representing **any character**, is written as `.` or `CharacterClass.any` and is also referred to as the "dot" metacharacter. This  class always matches a single `Character` or Unicode scalar value, depending on the matching semantic level. This class excludes newlines, unless "single line mode" is enabled (see section above).

In the following example, using grapheme cluster semantics, a dot matches a grapheme cluster, so the decomposed é is treated as a single value:

```swift
"Cafe\u{301}".contains(/C.../)
// true
```

For this example, using Unicode scalar semantics, a dot matches only a single Unicode scalar value, so the combining marks don't get grouped with the commas before them:

```swift
let data = "\u{300},\u{301},\u{302},\u{303},..."
for match in data.matches(of: /(.),/.matchingSemantics(.unicodeScalar)) {
    print(match.1)
}
// Prints:
//  ̀
//  ́
//  ̂
// ...
```

`Regex` also provides ways to select a specific level of "any" matching, without needing to change semantic levels.

- The **any grapheme cluster** character class is written as `\X` or `CharacterClass.anyGraphemeCluster`, and matches from the current location up to the next grapheme cluster boundary.
- The **any Unicode scalar** character class is written as `\O` or `CharacterClass.anyUnicodeScalar`, and matches exactly one Unicode scalar value at the current location.

#### Decimal and hexadecimal digits

The **decimal digit** character class is matched by `\d` or `CharacterClass.decimalDigit`. Both regexes in this example match one or more decimal digits followed by a colon:

```swift
let regex1 = /\d+:/
let regex2 = Regex {
    OneOrMore(.decimalDigit)
    ":"
}
```

_Unicode scalar semantics:_ Matches a Unicode scalar that has a `numericType` property equal to `.decimal`. This includes the digits from the ASCII range, from the _Halfwidth and Fullwidth Forms_ Unicode block, as well as digits in some scripts, like `DEVANAGARI DIGIT NINE` (U+096F). This corresponds to the general category `Decimal_Number`.

_Grapheme cluster semantics:_ Matches a character made up of a single Unicode scalar that fits the decimal digit criteria above.

_ASCII mode_: Matches a Unicode scalar in the range `0` to `9`.


To invert the decimal digit character class, use `\D` or `CharacterClass.decimalDigit.inverted`.


The **hexadecimal digit** character class is matched by  `CharacterClass.hexDigit`.

_Unicode scalar semantics:_ Matches a decimal digit, as described above, or an uppercase or small `A` through `F` from the _Halfwidth and Fullwidth Forms_ Unicode block. Note that this is a broader class than described by the `UnicodeScalar.properties.isHexDigit` property, as that property only include ASCII and fullwidth decimal digits.

_Grapheme cluster semantics:_ Matches a character made up of a single Unicode scalar that fits the hex digit criteria above.

_ASCII mode_: Matches a Unicode scalar in the range `0` to `9`, `a` to `f`, or `A` to `F`.

To invert the hexadecimal digit character class, use `CharacterClass.hexDigit.inverted`.

*<details><summary>Rationale</summary>*

Unicode's recommended definition for `\d` is its [numeric type][numerictype] of "Decimal" in contrast to "Digit". It is specifically restricted to sets of ascending contiguously-encoded scalars in a decimal radix positional numeral system. Thus, it excludes "digits" such as superscript numerals from its [definition][derivednumeric] and is a proper subset of `Character.isWholeNumber`. 

We interpret Unicode's definition of the set of scalars, especially its requirement that scalars be encoded in ascending chains, to imply that this class is restricted to scalars which meaningfully encode base-10 digits. Thus, we choose to make the grapheme cluster interpretation *restrictive*.

</details>


#### "Word" characters

The **word** character class is matched by `\w` or `CharacterClass.word`. This character class and its name are essentially terms of art within regular expressions, and represents part of a notional "word". Note that, by default, this is distinct from the algorithm for identifying word boundaries.

_Unicode scalar semantics:_ Matches a Unicode scalar that has one of the Unicode properties `Alphabetic`, `Digit`, or `Join_Control`, or is in the general category `Mark` or `Connector_Punctuation`. 

_Grapheme cluster semantics:_ Matches a character that begins with a Unicode scalar value that fits the criteria above.

_ASCII mode_: Matches the numbers `0` through `9`, lowercase and uppercase `A` through `Z`, and the underscore (`_`).

To invert the word character class, use `\W` or `CharacterClass.word.inverted`.

*<details><summary>Rationale</summary>*

Word characters include more than letters, and we went with Unicode's recommended scalar semantics. Following the Unicode recommendation that nonspacing marks remain with their base characters, we extend to grapheme clusters similarly to `Character.isLetter`. That is, combining scalars do not change the word-character-ness of the grapheme cluster.

</details>


#### Whitespace and newlines

The **whitespace** character class is matched by `\s` and `CharacterClass.whitespace`.

_Unicode scalar semantics:_ Matches a Unicode scalar that has the Unicode properties `Whitespace`, including a space, a horizontal tab (U+0009), `LINE FEED (LF)` (U+000A), `LINE TABULATION` (U+000B), `FORM FEED (FF)` (U+000C), `CARRIAGE RETURN (CR)` (U+000D), and `NEWLINE (NEL)` (U+0085). Note that under Unicode scalar semantics, `\s` only matches the first scalar in a `CR`+`LF` pair.

_Grapheme cluster semantics:_ Matches a character that begins with a `Whitespace` Unicode scalar value. This includes matching a `CR`+`LF` pair.

_ASCII mode_: Matches characters that both ASCII and fit the criteria given above. The current matching semantics dictate whether a `CR`+`LF` pair is matched in ASCII mode.

The **horizontal whitespace** character class is matched by `\h` and `CharacterClass.horizontalWhitespace`.

_Unicode scalar semantics:_ Matches a Unicode scalar that has the Unicode general category `Zs`/`Space_Separator` as well as a horizontal tab (U+0009).

_Grapheme cluster semantics:_ Matches a character that begins with a Unicode scalar value that fits the criteria above.

_ASCII mode_: Matches either a space (`" "`) or a horizontal tab.

The **vertical whitespace** character class is matched by `\v` and `CharacterClass.verticalWhitespace`. Additionally, `\R` and `CharacterClass.newline` provide a way to include the `CR`+`LF` pair, even when matching with Unicode scalar semantics.

_Unicode scalar semantics:_ Matches a Unicode scalar that has the Unicode general category `Zl`/`Line_Separator` as well as any of the following control characters: `LINE FEED (LF)` (U+000A), `LINE TABULATION` (U+000B), `FORM FEED (FF)` (U+000C), `CARRIAGE RETURN (CR)` (U+000D), and `NEWLINE (NEL)` (U+0085). Only when specified as `\R` or `CharacterClass.newline` does this match the whole `CR`+`LF` pair.

_Grapheme cluster semantics:_ Matches a character that begins with a Unicode scalar value that fits the criteria above.

_ASCII mode_: Matches any of the four ASCII control characters listed above. The current matching semantics dictate whether a `CR`+`LF` pair is matched in ASCII mode.

To invert these character classes, use `\S`, `\H`, and `\V`, respectively, or the `inverted` property on a `CharacterClass` instance.

<details><summary>Rationale</summary>

Note that "whitespace" is a term-of-art and is not correlated with visibility, which is a completely separate concept.

We use Unicode's recommended scalar semantics for horizontal and vertical whitespace, extended to grapheme clusters as in the existing `Character.isWhitespace` property.

</details>


#### Unicode properties

Character classes that match **Unicode properties** are written as `\p{PROPERTY}` or `\p{PROPERTY=VALUE}`, as described in the [Run-time Regex Construction proposal][literal-properties].

While most Unicode properties are only defined at the scalar level, some are defined to match an extended grapheme cluster. For example, `\p{RGI_Emoji_Flag_Sequence}` will match any flag emoji character, which are composed of two Unicode scalar values. Such property classes will match multiple scalars, even when matching with Unicode scalar semantics.

Unicode property matching is extended to `Character`s with a goal of consistency with other regex character classes. For `\p{Decimal}` and `\p{Hex_Digit}`, only single-scalar `Character`s can match, for the reasons described in that section, above. For all other Unicode property classes, matching `Character`s can comprise multiple scalars, as long as the first scalar matches the property.

To invert a Unicode property character class, use `\P{...}`.


#### POSIX character classes: `[:NAME:]`

**POSIX character classes** represent concepts that we'd like to define at all semantic levels. We propose the following definitions, some of which have been described above. When matching with grapheme cluster semantics, Unicode properties are extended to `Character`s as descrived in the rationale above, and as shown in the table below. That is, for POSIX class `[:word:]`, any `Character` that starts with a matching scalar is a match, while for `[:digit:]`, a matching `Character` must only comprise a single Unicode scalar value.

| POSIX class  | Unicode property class            | Character behavior   | ASCII mode value              |
|--------------|-----------------------------------|----------------------|-------------------------------|
| `[:lower:]`  | `\p{Lowercase}`                   | starts-with          | `[a-z]`                       |
| `[:upper:]`  | `\p{Uppercase}`                   | starts-with          | `[A-Z]`                       |
| `[:alpha:]`  | `\p{Alphabetic}`                  | starts-with          | `[A-Za-z]`                    |
| `[:alnum:]`  | `[\p{Alphabetic}\p{Decimal}]`     | starts-with          | `[A-Za-z0-9]`                 |
| `[:word:]`   | See \* below                      | starts-with          | `[[:alnum:]_]`                |
| `[:digit:]`  | `\p{DecimalNumber}`               | single-scalar        | `[0-9]`                       |
| `[:xdigit:]` | `\p{Hex_Digit}`                   | single-scalar        | `[0-9A-Fa-f]`                 |
| `[:punct:]`  | `\p{Punctuation}`                 | starts-with          | `[-!"#%&'()*,./:;?@[\\\]{}]`  |
| `[:blank:]`  | `[\p{Space_Separator}\u{09}]`     | starts-with          | `[ \t]`                       |
| `[:space:]`  | `\p{Whitespace}`                  | starts-with          | `[ \t\n\r\f\v]`               |
| `[:cntrl:]`  | `\p{Control}`                     | starts-with          | `[\x00-\x1f\x7f]`             |
| `[:graph:]`  | See \*\* below                    | starts-with          | `[^ [:cntrl:]]`               |
| `[:print:]`  | `[[:graph:][:blank:]--[:cntrl:]]` | starts-with          | `[[:graph:] ]`                |

\* The Unicode scalar property definition for `[:word:]` is `[\p{Alphanumeric}\p{Mark}\p{Join_Control}\p{Connector_Punctuation}]`.  
\*\* The Unicode scalar property definition for `[:cntrl:]` is `[^\p{Space}\p{Control}\p{Surrogate}\p{Unassigned}]`.

#### Custom classes

Custom classes function as the set union of their individual components, whether those parts are individual characters, individual Unicode scalar values, ranges, Unicode property classes or POSIX classes, or other custom classes.

- Individual characters and scalars will be tested using the same behavior as if they were listed in an alternation. That is, a custom character class like `[abc]` is equivalent to `(a|b|c)` under the same options and modes.
- When in grapheme cluster semantic mode, ranges of characters will test for membership using NFD form (or NFKD when performing caseless matching). This differs from how a `ClosedRange<Character>` would operate its `contains` method, since that depends on `String`'s `Comparable` conformance, but the decomposed comparison better aligns with the canonical equivalence matching used elsewhere in `Regex`.
- A custom character class will match a maximum of one `Character` or `UnicodeScalar`, depending on the matching semantic level. This means that a custom character class with extended grapheme cluster members may not match anything while using scalar semantics.

In regex literals, custom classes are enclosed in square brackets `[...]`, and can be nested or combined using set operators like `&&`. For more detail, see the [literal syntax proposal][literal-charclass].

With the `RegexBuilder`'s `CharacterClass` type, you can use built-in character classes with ranges and groups of characters. For example, to parse a valid octodecimal number, you could define a custom character class that combines `.decimalDigit` with a range of characters.

```swift
let octoDecimalRegex: Regex<Substring, Int> = Regex {
    let charClass = CharacterClass(.decimalDigit, "a"..."h").ignoringCase()
    Capture(OneOrMore(charClass))
        transform: { Int($0, radix: 18) }
}
```

The full `CharacterClass` API is as follows:

```swift
public struct CharacterClass: RegexComponent {
  public var regex: Regex<Substring> { get }

  public var inverted: CharacterClass { get }
}

extension RegexComponent where Self == CharacterClass {
  public static var any: CharacterClass { get }

  public static var anyGraphemeCluster: CharacterClass { get }

  public static var anyUnicodeScalar: CharacterClass { get }

  public static var decimalDigit: CharacterClass { get }
  
  public static var hexDigit: CharacterClass { get }

  public static var word: CharacterClass { get }

  public static var whitespace: CharacterClass { get }
  
  public static var horizontalWhitespace: CharacterClass { get }

  public static var newlineSequence: CharacterClass { get }

  public static var verticalWhitespace: CharacterClass { get }
}

extension RegexComponent where Self == CharacterClass {
  /// Returns a character class that matches any character in the given string
  /// or sequence.
  public static func anyOf<S: Sequence>(_ s: S) -> CharacterClass
    
  /// Returns a character class that matches any unicode scalar in the given
  /// sequence.
  public static func anyOf<S: Sequence>(_ s: S) -> CharacterClass
}

// Unicode properties
extension CharacterClass {
  public static func generalCategory(_ category: Unicode.GeneralCategory) -> CharacterClass
}

// Set algebra methods
extension CharacterClass {
  public init(_ first: CharacterClass, _ rest: CharacterClass...)
  
  public func union(_ other: CharacterClass) -> CharacterClass
  
  public func intersection(_ other: CharacterClass) -> CharacterClass
  
  public func subtracting(_ other: CharacterClass) -> CharacterClass
  
  public func symmetricDifference(_ other: CharacterClass) -> CharacterClass
}

/// Range syntax for characters in `CharacterClass`es.
public func ...(lhs: Character, rhs: Character) -> CharacterClass

/// Range syntax for unicode scalars in `CharacterClass`es.
@_disfavoredOverload
public func ...(lhs: UnicodeScalar, rhs: UnicodeScalar) -> CharacterClass
```

## Source compatibility

Everything in this proposal is additive, and has no compatibility effect on existing source code.


## Effect on ABI stability

Everything in this proposal is additive, and has no effect on existing stable ABI.


## Effect on API resilience

TBD


## Future directions

### Expanded options

The initial version of `Regex` includes only the options described above. Filling out the remainder of options described in the [Run-time Regex Construction proposal][literals] could be completed as future work.

### Extensions to Character and Unicode Scalar APIs

An earlier version of this pitch described adding standard library APIs to `Character` and `UnicodeScalar` for each of the supported character classes, as well as convenient static members for control characters. In addition, regex literals support Unicode property features that don’t currently exist in the standard library, such as a scalar’s script or extended category, or creating a scalar by its Unicode name instead of its scalar value. These kinds of additions are 

## Alternatives considered

### Operate on String.UnicodeScalarView instead of using semantic modes

Instead of providing APIs to select whether `Regex` matching is `Character`-based vs. `UnicodeScalar`-based, we could instead provide methods to match against the different views of a string. This different approach has multiple drawbacks:

* As the scalar level used when matching changes the behavior of individual components of a `Regex`, it’s more appropriate to specify the semantic level at the declaration site than the call site.
* With the proposed options model, you can define a Regex that includes different semantic levels for different portions of the match, which would be impossible with a call site-based approach.




[repo]: https://github.com/apple/swift-experimental-string-processing/
[option-scoping]: https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/RegexSyntax.md#matching-options
[literals]: https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/RegexSyntax.md
[literal-properties]: https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/RegexSyntax.md#character-properties
[literal-charclass]: https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/RegexSyntax.md#custom-character-classes

[overview]: https://forums.swift.org/t/declarative-string-processing-overview/52459
[charprops]: https://github.com/apple/swift-evolution/blob/master/proposals/0221-character-properties.md
[charpropsrationale]: https://github.com/apple/swift-evolution/blob/master/proposals/0221-character-properties.md#detailed-semantics-and-rationale
[canoneq]: https://www.unicode.org/reports/tr15/#Canon_Compat_Equivalence
[graphemes]: https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries
[meaningless]: https://forums.swift.org/t/declarative-string-processing-overview/52459/121
[scalarprops]: https://github.com/apple/swift-evolution/blob/master/proposals/0211-unicode-scalar-properties.md
[ucd]: https://www.unicode.org/reports/tr44/tr44-28.html
[numerictype]: https://www.unicode.org/reports/tr44/#Numeric_Type
[derivednumeric]: https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedNumericType.txt


[uts18]: https://unicode.org/reports/tr18/
[proplist]: https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt
[pcre]: https://www.pcre.org/current/doc/html/pcre2pattern.html
[perl]: https://perldoc.perl.org/perlre
[raku]: https://docs.raku.org/language/regexes
[rust]: https://docs.rs/regex/1.5.4/regex/
[python]: https://docs.python.org/3/library/re.html
[ruby]: https://ruby-doc.org/core-2.4.0/Regexp.html
[csharp]: https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
[icu]: https://unicode-org.github.io/icu/userguide/strings/regexp.html
[posix]: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html
[oniguruma]: https://www.cuminas.jp/sdk/regularExpression.html
[go]: https://pkg.go.dev/regexp/syntax@go1.17.2
[cplusplus]: https://www.cplusplus.com/reference/regex/ECMAScript/
[ecmascript]: https://262.ecma-international.org/12.0/#sec-pattern-semantics
[re2]: https://github.com/google/re2/wiki/Syntax
[java]: https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html
