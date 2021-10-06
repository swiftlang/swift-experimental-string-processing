# Regular Expression Literals: Character Classes

- **Author:** [Nate Cook](https://github.com/natecook1000)
- **Status:** Pre-pitch draft

## Introduction

Regular expressions use particular sequences of characters to concisely represent classes of characters to match. This proposal details these character classes, their denoting sequences in Swift regular expression literals, and describes their matching semantics.

## Motivation

Strings in Swift are designed to provide Unicode correctness to users by default. In particular, the default view of a string uses canonical equivalence during comparisons, and recognizes extended grapheme clusters when viewing a string as a series of characters. In this example, the `cafe` string include the character `"é"`, which is formed in the string literal by `"e\u{0300}"` — the ASCII letter `"e"` followed by a combining grave accent (U+0300).

```swift
let cafe = "Cafe\u{301}"
print(cafe.last)
// Prints "é"

let composedAccentedE = "é"
print(cafe.contains(composedAccentedE))
// Prints "true"
```

This example shows that even when a character is composed of multiple Unicode scalar values, the presentation to a user is a single `Character`.

### Regular expressions

- Given their history, regular expressions don't always connect well with Unicode concepts
- Regular expression matching in other libraries happens at different levels: sometimes at the Unicode scalar level, sometimes in ASCII, sometimes only at the level of the encoding (e.g. UTF-16)
- With strings in Swift, we have the expectation of Unicode-correctness, including things like canonical equivalence when testing for string equality and grapheme cluster recognition when working with the characters in a string

## Proposed Solution

When matching strings with both patterns and regular expressions, matching always happens at the level of the targeted view's element type. Unicode canonical equivalence and extended grapheme cluster recognition apply only when matching against `String`, `Substring`, or another `Character`-based collection. When matching against string views that use Unicode scalars or encoding units as elements, individual values are interpreted as is.

- **To do:** Example using `.`



- We want default semantics to correspond to Character properties
	+ We should feel free (and strongly encouraged) to add more properties to Character
	+ We should feel free (and strongly encouraged) to add corresponding properties directly to Unicode.Scalar
- We want semantics to be configurable (e.g. POSIX, old Unicode style, or fully custom)
	+ It would be interesting to see how we could inline custom character classes when we have compiler visibility
	+ Class assignment may be contextual or even post-hoc modify-able, TBD
- We will need to reject certain features depending on use
	+ E.g. scalar attributes when applied to grapheme clusters, unless semantics are obvious or explicitly chosen
	+ This means we might need some (even ad-hoc) encoding of capabilities
	+ Would we reject captures when applied to non-match API? Or, surface them through a dynamic environment, or opt-in, or what?
- We need to sample broadly to avoid pitfalls in designing this in isolation
	+ We want to survey regex engines broadly (PCRE, .NET, JS, ICU, Rust, C++, RE2, POSIX, perl, python)
	+ We want to survey API use sites broady, certain things just don't always make sense (e.g. multi-line matching against str.lines())
	+ We may want to parse a full set, even if not fully implemented (see musings on Regex literal) (edited) 


---

### Literal characters

A literal character (such as `a`, `é`, or `한`) in a regex literal matches that particular character or code sequence. When matching against `Character`s, the comparison uses Unicode canonical equivalence. For other string element types, the values must be an exact match.

| Matching against `"e\u{301}"` | Pattern | Result |
|-------------------------------|---------|--------|
| String | `é` | *match* |
| | `e\u{301}` | *match* |
| | `e` | *no match* |
| String.UnicodeScalarView | `é` | *no match* |
| | `e\u{301}` | *match* |
| | `e` | *match* (`"\u{301}"` remaining) |

**DSL:** Literal characters are represented by string literals.

```swift
Pattern {
    "abc"
}
```

### Dot: `.`

The dot metacharacter matches any single character or element except for a newline, where a "newline" is defined differently for different element types:

| Element | Note |
|-------------------------------|---------|
| Character | any character where `isNewline` is true |
| UnicodeScalar | *matches Character definition* <br> ***Why isn't `isNewline` also available here?*** |
| UTF16 | *matches Character definition* ***?*** |
| UTF8 | *matches Character definition, excluding PS and LS* ***?***|

In "dot matches all" mode, newlines are treated like any other character. See [Flags & Modes](#) for more.

**DSL:** The "matches anything" pattern is spelled `.anyCharacter`. This has the unfortunate side effect of importing regular expression's funny behavior into the DSL, since the semantics of `.anyCharacter` change depending on the mode the pattern is used in.

```swift
Pattern {
    OneOrMore(.anyCharacter)
}
```

> ***TBD:*** ICU includes a `\X` metacharacter that matches an extended grapheme cluster within its typically UTF16-bound semantics — do we want to include something like this, which would bounce up to the `Character` level when matching against e.g. `String.UTF8View`?

### Digits: `\d`,`\D`

`\d` matches a "digit", which is any `Character` or Unicode scalar with the Unicode general category `Decimal_Number`.

| Element | Note |
|-------------------------------|---------|
| Character | any character where the general category of the first unicode scalar is `Decimal_Number` |
| UnicodeScalar | any scalar where the general category is `Decimal_Number`, not including any combining marks |
| UTF16 | digits as above, limited to those that are encoded in a single UTF16 value |
| UTF8 | `[0-9]` (digits that are encoded as a single byte) |

`\D` matches the inverse set of characters/elements.

**DSL:** The corresponding pattern is called `.digitCharacter`:

```swift
Pattern {
    OneOrMore(.digitCharacter)
}
```

> ***Note:*** For the DSL, there will be some tension/possible misunderstanding between matching digits and matching numeric values (i.e. match the next `Int`). Our API naming should help with that kind of tension where possible.

> ***Note:*** There are still "digits" that are excluded from this definition, such as superscript (`"¹"`) or circled (`"①"`) digits. These are in the "Other_Number" category, and are thus excluded from this character class.

<details>
  <summary>Swift equivalent of `\d`</summary>
<pre><code>// Character
$0.unicodeScalars.first!.properties.generalCategory == .decimalNumber
// UnicodeScalar
$0.properties.generalCategory == .decimalNumber
// UTF16
UnicodeScalar($0)?.properties.generalCategory == .decimalNumber
// UTF8
(UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0)
</code></pre>
</details>


### Word Characters: `\w`, `\W`

`\w` matches any letter or decimal number, as indicated by the Unicode general categories:

- `Uppercase_Letter`
- `Lowercase_Letter`
- `Titlecase_Letter`
- `Other_Letter`
- `Decimal_Number`

| Element | Note |
|-------------------------------|---------|
| Character | any character where the general category of the first unicode scalar is in the above list |
| UnicodeScalar | any scalar where the general category is in the above list |
| UTF16 | as above, limited to those that are encoded in a single UTF16 value |
| UTF8 | `[a-zA-Z0-9]` (letters and digits that are encoded as a single byte) |

`\W` matches the inverse set of characters/elements.

**DSL:** The corresponding pattern is called `.wordCharacter`:

```swift
Pattern {
    OneOrMore(.wordCharacter)
}
```

<details>
  <summary>Swift equivalent of `\w`</summary>
<pre><code>// Character
$0.unicodeScalars.first!.properties.generalCategory == .decimalNumber
// UnicodeScalar
$0.properties.generalCategory == .decimalNumber
// UTF16
UnicodeScalar($0)?.properties.generalCategory == .decimalNumber
// UTF8
(UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0)
</code></pre>
</details>


### Whitespace: `\s`, `\S` (plus `\h`, `\H`, `\v`, `\V`, and `\R`)

`\s` matches any single, non-zero width whitespace character, as denoted by the following list. When matching a `Character`-based collection, `\s` also matches the CR/LF sequence.

- `CHARACTER TABULATION` (U+0009)
- `LINE FEED (LF)` (U+000A)*
- `LINE TABULATION` (U+000B)*
- `FORM FEED (FF)` (U+000C)*
- `CARRIAGE RETURN (CR)` (U+000D)*
- `NEWLINE (NEL)` (U+0085)*
- any character in the Unicode general category `Z`/`Separator`

`\h` matches the tab character (U+0009) or any character in the Unicode general category `Space_Separator`.

`\v` matches the five line separator characters above, marked with *, as well as (U+2028) and (U+2029), not including the CR/LF sequence.

`\R` matches the same characters as `\v`, and in addition matches the CR/LF sequence.

| Element | Note |
|-------------------------------|---------|
| Character | any character where the general category of the first unicode scalar is in the above list |
| UnicodeScalar | any scalar where the general category is in the above list |
| UTF16 | as above, limited to those that are encoded in a single UTF16 value |
| UTF8 | whitespace characters that are encoded as a single byte) |

`\S`, `\H`, and `\V` match the inverse set of characters/elements as their lowercase respective character classes.

**DSL:** The corresponding pattern is called `.whitespaceOrNewline`. Additional patterns for `.whitespace` and `.newline` are also available.

```swift
Pattern {
    "abc"
    OneOrMore(.whitespace)
    "def"
    OneOrMore(.whitespaceOrNewline)
}
```


### Control characters: `\t`, `\r`, `\n`, `\f`, `\0`, `\e`, `\a`, `\b`, `\cX`

These escaped literal characters represent specific control characters only.

- `\t`: `CHARACTER TABULATION` (U+0009)
- `\r`: `CARRIAGE RETURN (CR)` (U+000D)
- `\n`: `LINE FEED (LF)` (U+000A)
- `\f`: `FORM FEED (FF)` (U+000C)
- `\0`: `NUL` (U+0000)
- `\e`: `ESCAPE` (U+001B)
- `\a`: `BELL` (U+0007)
- `\b`: `BACKSPACE` (U+0008) (within a character set only)
- `\cX`: The control character indicated by Control-`X`; in the code point range `0..<32`.

**DSL:** The corresponding patterns are available as named patterns, or alternatively as character literals.

- `\t`: `.tabCharacter` or `"\u{09}"`
- `\r`: `.carriageReturn` or `"\u{0d}"`
- `\n`: `.lineFeed` or `"\u{0a}"`
- `\f`: `.formFeed` or `"\u{0c}"`
- `\0`: `.nul` or `"\u{0}"`
- `\e`: `.escape` or `"\u{1b}"`
- `\a`: `.bell` or `"\u{07}"`
- `\b`: `.backspace` or `"\u{08}"`
- `\cX`: `.control(_: UnicodeScalar)`


### Unicode values: `\u`, `\U`, `\x`

Metacharacters that begin with `\u`, `\U`, or `\x` match a character with the specified Unicode scalar values. The format used by Swift string literals (`\u{hhh...}`) and several other legacy regular expression formats are all supported.

- `\u{hhh...}` *(preferred)*: Can use 1 or more hexidecimal digits.
- `\xhh`: Must use 2 hexidecimal digits.
- `\uhhhh`: Must use 4 hexidecimal digits.

> **To do:** These formats could be supported for ICU/NSRegularExpression compatibility, or not. Unicode scalar value syntax is fairly niche and varies across languages/implementations.
> 
> - `\x{hhh...}`: Can use 1 or more hexidecimal digits.
> - `\Uhhhhhhhh`: Must use 8 hexidecimal digits.

**DSL:** This functionality is supported through the DSL's use of string literals.

```swift
Pattern {
    "abc"
    "\u{032}"
    "def"
}
```

### Unicode named values and properties: `\N`, `\p`, `\P`

`\N{NAME}` matches a character with the specified Unicode name.
`\p{PROPERTY}` and `\p{PROPERTY=VALUE}` matches a character with the given Unicode property, or the specified value for the property, respectively.

**To do:** Can these be exhaustively listed?

**DSL:** This functionality is supported through Unicode scalar-focused predicate matcher.

```swift
Pattern {
    "abc"
    OneOrMore(.unicodeProperty(where: \.isAlphabetic))
    "def"
}
```

### Custom classes: `[...]`

Users can create custom character classes by using literal characters and most predefined character classes within square brackets.