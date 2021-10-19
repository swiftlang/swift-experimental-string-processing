# Character Classes for String Processing

- **Authors:** [Nate Cook](https://github.com/natecook1000), [Michael Ilseman](https://github.com/milseman)
- **Status:** Draft pitch

## Introduction

[Declarative String Processing Overview][overview] presents regex-powered matching broadly, without details concerning syntax and semantics, leaving clarification to subsequent pitches. [Regular Expression Literals][literals] presents more details on regex _syntax_ such as delimiters and PCRE-syntax innards, but explicitly excludes discussion of regex _semantics_. This pitch and discussion aims to address a targeted subset of regex semantics: definitions of character classes. We propose a comprehensive treatment of regex character class semantics in the context of existing and newly proposed API directly on `Character` and `Unicode.Scalar`.

Character classes in regular expressions include metacharacters like `\d` to match a digit, `\s` to match whitespace, and `.` to match any character. Individual literal characters can also be thought of as character classes, as they at least match themselves, and, in case-insensitive matching, their case-toggled counterpart. For the purpose of this work, then, we consider a *character class* to be any part of a regular expression literal that can match an actual component of a string.

## Motivation

Operating over classes of characters is a vital component of string processing. Swift's `String` provides, by default, a view of `Character`s or [extended grapheme clusters][graphemes] whose comparison honors [Unicode canonical equivalence][canoneq].

```swift
let str = "Cafe\u{301}" // "Café"
str == "Café"           // true
str.dropLast()          // "Caf"
str.last == "é"         // true (precomposed e with acute accent)
str.last == "e\u{301}"  // true (e followed by composing acute accent)
```

Unicode leaves all interpretation of grapheme clusters up to implementations, which means that Swift needs to define any semantics for its own usage. Since other regex engines operate, at most, at the semantics level of Unicode scalar values, there is little to no prior art to consult.

<details><summary>Other engines</summary>

Character classes in other languages match at either the Unicode scalar value level, or even the code unit level, instead of recognizing grapheme clusters as characters. When matching the `.` character class, other languages will only match the first part of an `"e\u{301}"` grapheme cluster. Some languages, like Perl, Ruby, and Java, support an additional `\X` metacharacter, which explicitly represents a single grapheme cluster.

| Matching  `"Cafe\u{301}"` | Pattern: `^Caf.` | Remaining | Pattern:  `^Caf\X` | Remaining |
|---|---|---|---|---|
| C#, Rust, Go | `"Cafe"` | `"´"` | n/a | n/a |
| NSString, Java, Ruby, Perl | `"Cafe"` | `"´"` | `"Café"` | `""` |

Other than Java's `CANON_EQ` option, the vast majority of other languages and engines are not capable of comparing with canonical equivalence.

</details>

[SE-0211 Unicode Scalar Properties][scalarprops] added basic building blocks for classification of scalars by surfacing Unicode data from the [UCD][ucd]. [SE-0221: Character Properties][charprops] defined grapheme-cluster semantics for Swift for a subset of these. But, many classifications used in string processing are combinations of scalar properties or ad-hoc listings, and as such are not present today in Swift.

Regardless of any syntax or underlying formalism, classifying characters is a worthy and much needed addition to the Swift standard library. We believe our thorough treatment of every character class found across many popular regex engines gives Swift a solid semantic basis.

## Proposed Solution

This pitch is narrowly scoped to Swift definitions of character classes found in regexes. For each character class, we propose:

- A name for use in API
- A `Character` API, by extending Unicode scalar definitions to grapheme clusters
- A `Unicode.Scalar` API with modern Unicode definitions
- If applicable, a `Unicode.Scalar` API for notable standards like POSIX (or JS?)

We're proposing what we believe to be the Swiftiest definitions, referencing Unicode's [UTS\#18][uts18], [PCRE][pcre], [perl][perl], [Raku][raku], [Rust][rust], [Python][python], [C\#][csharp], [`NSRegularExpression` / ICU][icu], [POSIX][posix], [Oniguruma][oniguruma], (grep?), [Go][go], [C++][cplusplus], [RE2][re2], [Java][java], and [ECMAScript][ecmascript].

To extend scalar semantics to grapheme clusters, we're using algebra and rationale from [SE-0221: Character Properties][charpropsrationale].

## Detailed Design

In general, we choose the Unicode recommendations in [UTS\#18][uts18] as the basis for matching character classes to `Unicode.Scalar`s. This is similar to the behavior of several languages' regular expressions when in Unicode mode (such as Perl and Python), as well as ICU-based regular expressions like `NSRegularExpression`.

To extend this matching behavior to `Character`s, we treat a `Character` as belonging to a character class if its leading Unicode scalar belongs to that class.

### Literal characters

A literal character (such as `a`, `é`, or `한`) in a regex literal matches that particular character or code sequence. When matching at the semantic level of `Unicode.Scalar`, it should match the literal sequence of scalars. When matching at the semantic level of `Character`, it should match `Character`-by-`Character`, honoring Unicode canonical equivalence.

We are not proposing new API here as this is already handled by `String` and `String.UnicodeScalarView`'s conformance to `Collection`.

### Unicode values: `\u`, `\U`, `\x`

Metacharacters that begin with `\u`, `\U`, or `\x` match a character with the specified Unicode scalar values. We propose these be treated exactly the same as literals.

### Match any: `.`, `\X`

The dot metacharacter matches any single character or element. Depending on options and modes (i.e. API), it may exclude newlines.

`\X` matches any grapheme cluster (`Character`), even when the regular expression is otherwise matching at semantic level of `Unicode.Scalar`.

We are not proposing new API here as this is already handled by collection conformances.

While we would like for the stdlib to have grapheme-breaking API over collections of `Unicode.Scalar`, that is a separate discussion and out-of-scope for this pitch.

### Digits: `\d`,`\D`

We propose `\d` be named "digit" with the following definitions:

```swift
extension Character {
  /// A Boolean value indicating whether this character is considered 
  /// a digit.
  ///
  /// All characters with an initial Unicode scalar that has a 
  /// `numericType` property equal to `.decimal` are considered digits.
  /// This includes the digits from the ASCII range, from the _Halfwidth
  /// and Fullwidth Forms_ Unicode block, as well as digits in some
  /// scripts, like `DEVANAGARI DIGIT NINE` (U+096F).
  public var isDigit: Bool { get }
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered 
  /// a digit.
  ///
  /// Any Unicode scalar that has a `numericType` property equal to
  /// `.decimal` is considered a digit. This includes the digits from
  /// the ASCII range, from the _Halfwidth and Fullwidth Forms_ 
  /// Unicode block, as well as digits in some scripts, like
  /// `DEVANAGARI DIGIT NINE` (U+096F).
  public var isDigit: Bool { get }
}
```

`\D` matches the inverse of `\d`.

_<details><summary>Rationale</summary>_

The Unicode recommendation is to base digit matching on the derived Unicode numeric type. For details, see [Unicode derived numeric types][derivednumeric].

We chose to treat any grapheme cluster that leads with a Unicode scalar "digit" as a digit as well. This is compatible with the existing `Character.isNumber` property, which only checks the first scalar's numeric type. It does, on the other hand, diverge from the `isWholeNumber` and `isHexDigit` properties, which require that the `Character` comprises a single Unicode scalar.

</details>

### Word characters: `\w`, `\W`

We propose `\w` be named "word character" with the following definitions:

```swift
extension Character {
  /// A Boolean value indicating whether this scalar is considered 
  /// a "word" character.
  ///
  /// All characters with an initial Unicode scalar that is considered a
  /// word character are considered word character.
  public var isWordCharacter: Bool { get }    
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered 
  /// a "word" character.
  ///
  /// Any Unicode scalar that has one of the Unicode properties
  /// `Alphabetic`, `Digit`, or `Join_Control`, or is in the 
  /// general category `Mark` or `Connector_Punctuation`.
  public var isWordCharacter: Bool { get }
}
```

`\W` matches the inverse of `\w`.

_<details><summary>Rationale</summary>_

The Unicode recommendation is to derive word character matching from Unicode properties and general categories as described above

We chose to treat any grapheme cluster that leads with a Unicode scalar word character as a word character as well.

</details>

### Whitespace and newlines: `\s`, `\S` (plus `\h`, `\H`, `\v`, `\V`, and `\R`)

We propose `\s` be named "whitespace" with the following definitions:

```swift
extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered 
  /// whitespace.
  ///
  /// All Unicode scalars with the derived `White_Space` property are 
  /// considered whitespace, including:
  ///
  /// - `CHARACTER TABULATION` (U+0009)
  /// - `LINE FEED (LF)` (U+000A)
  /// - `LINE TABULATION` (U+000B)
  /// - `FORM FEED (FF)` (U+000C)
  /// - `CARRIAGE RETURN (CR)` (U+000D)
  /// - `NEWLINE (NEL)` (U+0085)
  public var isWhitespace: Bool { get }
}
```

This definition matches the value of the existing `Unicode.Scalar.Properties.isWhitespace` property. Note that `Character.isWhitespace` already exists with the desired semantics, which is a grapheme cluster that begins with a whitespace Unicode scalar.

We propose `\h` be named "horizontalWhitespace" with the following definitions:

```swift
extension Character {
  /// A Boolean value indicating whether this character is considered 
  /// horizontal whitespace.
  ///
  /// All characters with an initial Unicode scalar in the general 
  /// category `Zs`/`Space_Separator`, or the control character 
  /// `CHARACTER TABULATION` (U+0009), are considered horizontal 
  /// whitespace.
  public var isHorizontalWhitespace: Bool { get }    
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered 
  /// horizontal whitespace.
  ///
  /// All Unicode scalars with the general category 
  /// `Zs`/`Space_Separator`, along with the control character 
  /// `CHARACTER TABULATION` (U+0009), are considered horizontal 
  /// whitespace.
  public var isHorizontalWhitespace: Bool { get }
}
```

We propose `\v` be named "verticalWhitespace" with the following definitions:


```swift
extension Character {
  /// A Boolean value indicating whether this scalar is considered 
  /// vertical whitespace.
  ///
  /// All characters with an initial Unicode scalar in the general 
  /// category `Zl`/`Line_Separator`, or the following control
  /// characters, are considered vertical whitespace (see below)
  public var isVerticalWhitespace: Bool { get }    
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered 
  /// vertical whitespace.
  ///
  /// All Unicode scalars with the general category 
  /// `Zl`/`Line_Separator`, along with the following control
  /// characters, are considered vertical whitespace:
  ///
  /// - `LINE FEED (LF)` (U+000A)
  /// - `LINE TABULATION` (U+000B)
  /// - `FORM FEED (FF)` (U+000C)
  /// - `CARRIAGE RETURN (CR)` (U+000D)
  /// - `NEWLINE (NEL)` (U+0085)
  public var isVerticalWhitespace: Bool { get }
}
```

`\S`, `\H`, and `\V` match the inverse of `\s`, `\h`, and `\v`, respectively.

We propose `\R` include "verticalWhitespace" above with detection (and consumption) of the CR-LF sequence when applied to `Unicode.Scalar`. It is equivalent to `Character.isVerticalWhitespace` when applied to `Character`s.

We are similarly not proposing any new API for `\R` until the stdlib has grapheme-breaking API over `Unicode.Scalar`.

_<details><summary>Rationale</summary>_

We chose the Unicode recommendation as the basis for `Unicode.Scalar`, which is to derive whitespace matching from Unicode properties and general categories as described above. For details, see the [Unicode property list][proplist].

We chose to leave the existing `Character.isWhitespace` intact and extend its reasoning to vertical and horizontal whitespace.

</details>

### Control characters: `\t`, `\r`, `\n`, `\f`, `\0`, `\e`, `\a`, `\b`, `\cX`

We propose the following names and meanings for these escaped literals representing specific control characters:

```swift
extension Character {
  /// A horizontal tab character, `CHARACTER TABULATION` (U+0009).
  public static var tab: Character { get }

  /// A carriage return character, `CARRIAGE RETURN (CR)` (U+000D).
  public static var carriageReturn: Character { get }

  /// A line feed character, `LINE FEED (LF)` (U+000A).
  public static var lineFeed: Character { get }

  /// A form feed character, `FORM FEED (FF)` (U+000C).   
  public static var formFeed: Character { get }

  /// A NULL character, `NUL` (U+0000).   
  public static var nul: Character { get }

  /// An escape control character, `ESC` (U+001B).
  public static var escape: Character { get }

  /// A bell character, `BEL` (U+0007).
  public static var bell: Character { get }

  /// A backspace character, `BS` (U+0008).
  public static var backspace: Character { get }

  /// Returns a control character with the given value, Control-`x`.
  ///
  /// This method returns a value only when you pass a letter in 
  /// the ASCII range as `x`:
  ///
  ///     if let ch = Character.control("G") {
  ///         print("'ch' is a bell character", ch == Character.bell)
  ///     } else {
  ///         print("'ch' is not a control character")
  ///     }
  ///     // Prints "'ch' is a bell character: true"
  ///
  /// - Parameter x: An upper- or lowercase letter to derive
  ///   the control character from.
  /// - Returns: Control-`x` if `x` is in the pattern `[a-zA-Z]`;
  ///   otherwise, `nil`.
  public static func control(_ x: Unicode.Scalar) -> Character?
}

extension Unicode.Scalar {
  /// Same as above...
}
```

**TODO**: What about `\r\n` in grapheme semantic mode?

_<details><summary>Rationale</summary>_

This approach simplifies the use of some common control characters, while making the rest available through a method call.

</details>



### Unicode named values and properties: `\N`, `\p`, `\P`

`\N{NAME}` matches a Unicode scalar value with the specified name. `\p{PROPERTY}` and `\p{PROPERTY=VALUE}` match a Unicode scalar value with the given Unicode property (and value, if given). 

While most Unicode-defined properties can only match at the Unicode scalar level, some are defined to match an extended grapheme cluster. For example, `/\p{RGI_Emoji_Flag_Sequence}/` will match any flag emoji character, which are composed of two Unicode scalar values.

`\P{...}` matches the inverse of `\p{...}`.

Most of this functionality is already provided inside `Unicode.Scalar.Properties`, and we propose to round out Swift's current support with API to access the Unicode script(s) for a `Unicode.Scalar` or `Character`. (API TBD)

**TODO**: Check with Alejandro that the code size impact is reasonable

Even though we are not proposing any `Character`-based API, we'd like to discuss with the community whether or how to extend them to grapheme clusters. Some options:

- Forbid in any grapheme-cluster semantic mode
- Match only single-scalar grapheme clusters with the given property
- Match any grapheme cluster that starts with the given property
- Something more-involved such as per-property reasoning


### POSIX character classes: `[:NAME:]`

We propose that POSIX character classes be named "posixName" with APIs for testing membership of `Character`s and `Unicode.Scalar`s. `Unicode.Scalar.isASCII` and `Character.isASCII` already exist and can satisfy `[:ascii:]`, and can be used in combination with new members like `isDigit` to represent individual POSIX character classes.

Alternatively, we could introduce an option-set-like `POSIXCharacterClass` and `func isPOSIX(_:POSIXCharacterClass)` since POSIX is a fully defined standard. This would cut down on the amount of API noise directly visible on `Character` and `Unicode.Scalar` significantly.

We'd like some more discussion with the community here, and it's possible this will become clearer as more of the string processing story takes shape.


### Custom classes: `[...]`

We propose that custom classes function just like set union. We propose that ranged-based custom character classes function just like `ClosedRange`. Thus, we are not proposing any additional API.

That being said, providing grapheme cluster semantics is simultaneously obvious and tricky. A direct extension treats `[a-f]` as equivalent to `("a"..."f").contains()`. Strings (and thus Characters) are ordered for the purposes of efficiently maintaining programming invariants while honoring Unicode canonical equivalence. This ordering is _consistent_ but [linguistically meaningless][meaningless] and subject to implementation details such as whether we choose to normalize under NFC or NFD.

```swift
let c: ClosedRange<Character> = "a"..."f"
c.contains("e") // true
c.contains("g") // false
c.contains("e\u{301}") // false, NFC uses precomposed é
c.contains("e\u{305}") // true, there is no precomposed e̅
```

We will likely want corresponding `RangeExpression`-based API in the future and keeping consistency with ranges is important. 

We would like to discuss this problem with the community here. Even though we are not addressing regex literals specifically in this thread, it makes sense to produce suggestions for compilation errors or warnings.

Some options:

- Do nothing, embrace emergent behavior
- Warn/error for _any_ character class ranges
- Warn/error for character class ranges outside of a quasi-meaningful subset (e.g. ACII, albeit still has issues above)
- Warn/error for multiple-scalar grapheme clusters (albeit still has issues above)



## Future Directions

### Future API

Library-extensible pattern matching will necessitate more types, protocols, and API in the future, many of which may involve character classes. This pitch aims to define names and semantics for exactly these kinds of API now, so that they can slot in naturally.

### More classes or custom classes

Future API might express custom classes or need more built-in classes. This pitch aims to establish rationale and precedent for a large number of character classes in Swift, serving as a basis that can be extended.

### More lenient conversion APIs

The proposed semantics for matching "digits" are broader than what the existing `Int(_:radix:)?` initializer accepts. It may be useful to provide additional initializers that can understand the whole breadth of characters matched by `\d`, or other related conversions.




[literals]: https://forums.swift.org/t/pitch-regular-expression-literals/52820
[overview]: https://forums.swift.org/t/declarative-string-processing-overview/52459
[charprops]: https://github.com/apple/swift-evolution/blob/master/proposals/0221-character-properties.md
[charpropsrationale]: https://github.com/apple/swift-evolution/blob/master/proposals/0221-character-properties.md#detailed-semantics-and-rationale
[canoneq]: https://www.unicode.org/reports/tr15/#Canon_Compat_Equivalence
[graphemes]: https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries
[meaningless]: https://forums.swift.org/t/declarative-string-processing-overview/52459/121
[scalarprops]: https://github.com/apple/swift-evolution/blob/master/proposals/0211-unicode-scalar-properties.md
[ucd]: https://www.unicode.org/reports/tr44/tr44-28.html

[uts18]: https://unicode.org/reports/tr18/
[proplist]: https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt
[derivednumeric]: https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedNumericType.txt
[pcre]: https://www.pcre.org/current/doc/html/pcre2pattern.html
[perl]: https://perldoc.perl.org/perlre
[raku]: https://docs.raku.org/language/regexes
[rust]: https://docs.rs/regex/1.5.4/regex/
[python]: https://docs.python.org/3/library/re.html
[csharp]: https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
[icu]: https://unicode-org.github.io/icu/userguide/strings/regexp.html
[posix]: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html
[oniguruma]: https://www.cuminas.jp/sdk/regularExpression.html
[go]: https://pkg.go.dev/regexp/syntax@go1.17.2
[cplusplus]: https://www.cplusplus.com/reference/regex/ECMAScript/
[ecmascript]: https://262.ecma-international.org/12.0/#sec-pattern-semantics
[re2]: https://github.com/google/re2/wiki/Syntax
[java]: https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html
