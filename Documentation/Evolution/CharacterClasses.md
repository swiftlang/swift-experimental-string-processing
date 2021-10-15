# Regular Expression Literals: Character Classes

- **Author:** [Nate Cook](https://github.com/natecook1000)
- **Status:** Draft pitch

## Introduction

A regular expression literal comprises a combination of character classes, quantifiers (e.g. `?` and `+`), assertions, and a few other metacharacters. Character classes include metacharacters like `\d` to match a digit, `\s` to match whitespace, and `.` to match any character. Individual literal characters can also be thought of as character classes, as they at least match themselves, and, in case-insensitive matching, their case-toggled counterpart. 

For the purpose of this work, then, we consider a *character class* to be any part of a regular expression literal that can match an actual component of a string. This proposal details these character classes, their denoting sequences in Swift regular expression literals, and describes their matching semantics.

## Motivation

Strings in Swift are designed to provide a predictable, character-based interface for users by default, regardless of the way a character is composed.

The following small example demonstrates two sides of this predictability. `str` includes an accented character, which is formed in the string literal by `"e\u{301}"` — the letter “e” followed by a combining acute accent (U+0301). Although this accented character is written in the literal as two separate values, the default view of the string consistently presents it as a single character, and considers that single, composite character as equivalent to the accented letter written as  `"é"`, the Unicode scalar value U+00E9.

```swift
let str = "Cafe\u{301}"
for ch in str {
    print(ch)
}
// C
// a
// f
// é

let composedAccentedE = "é"
print(str.contains(composedAccentedE))
// true
```

Instead of treating `“e”` and `"\u{301}"` as separate elements, Swift’s string recognizes the pair as a grapheme cluster, as represented by the `Character` type, and as canonically equivalent to their single Unicode scalar value counterpart. Characters that are made up of multiple Unicode scalars include emoji (flags are usually 2 Unicode scalar values, family groupings can be nearly a dozen), Korean hangeul (1-3 Unicode scalar values per character), and Thai script, among many others.

This is a departure from many other languages and frameworks, such as Python and Foundation's NSString, where individual Unicode scalars, or sometimes their UTF-16 or UTF-8 encoding units, are treated as the elements of a string.

```python
for ch in u'Cafe\u0301':
    print("# " + ch)
# C
# a
# f
# e
#´
```

Just as Python strings are different from Swift's, in these other languages, regular expressions behave in ways that do not match the expectations of a Swift string user.

Character classes in other languages match at the Unicode scalar (or encoded unit) value, instead of recognizing grapheme clusters as characters. When matching the `.` character class, other languages will only match the first part of an `"e\u{301}"` grapheme cluster. Some languages, like Perl, Ruby, and Java, support an additional `\X` metacharacter, which explictly represents a single grapheme cluster.

| Matching  `"Cafe\u{301}"` | Pattern: `^Caf.` | Remaining | Pattern:  `^Caf\X` | Remaining |
|---|---|---|---|---|
| NSString, C#, Rust, Go | `"Cafe"` | `"´"` | n/a | n/a |
| Java, Ruby, Perl | `"Cafe"` | `"´"` | `"Café"` | `""` |

By and large, other languages do not use canonical equivalence when matching characters in regular expressions. Java provides a `CANON_EQ` option when compiling a pattern to opt into such checking.

```java
String cafe = "Cafe\u0301";

Pattern exactPatt = Pattern.compile("é");
exactPatt.matcher(cafe).find()      // false

Pattern equivPatt = Pattern.compile("é", Pattern.CANON_EQ);
equivPatt.matcher(cafe).find()      // true
```

Finally, there is wide variance of the actual definitions of character classes between different languages. As one example, should the `\d` character class, which matches digits, include the digits from the _Halfwidth and Fullwidth Forms_ Unicode block? ICU-based regular expression engines, like those used in Java and Foundation's `NSRegularExpression`, include these extra digits, while other languages do not. Determining exactly what characters are matched by each character class of a particular language or library can be difficult, making it harder to fully understand what kinds of strings a pattern will or will not match.

## Proposed Solution

We propose a treatment of character classes in Swift regular expression that is consistent with the Swift string model, configurable at the point of declaration, and comprehensible for users getting to know Swift regular expressions.

### Consistency

Just as the default view of a string's contents are as a collection of grapheme-cluster characters, with comparisons using canonical equivalence, regular expression matching by default will do the same. This assures that similar code produces predictable results as we add APIs that accept regular expressions and other patterns:

```swift
let str = "Cafe\u{301}"
str.contains("é")       // true
str.contains(/é/)       // true
```

Moreover, in accordance with the [Unicode guidelines for regular expressions](https://www.unicode.org/reports/tr18), we use Unicode property data rather than specific lists of characters whenever possible.


### Configuration

For compatibility with other languages, and in some cases to allow users to opt into higher performance, you can configure the character class matching level of regular expression at the declaration site. For example, you can opt into the Unicode scalar-based matching of other languages by using the `unicodeScalarSemantics` property on a regular expression instance.

This example declares `pattern` with Unicode scalar semantics, instead of the default character semantics. `pattern` doesn't match the string above because `"e"` and `"\u{301}"` are treated as separate values.

```swift
let pattern = /^Caf.$/.unicodeScalarSemantics
str.contains(pattern)   // false
```

Initially, we plan to allow configuration between character, Unicode scalar, and POSIX-compatible character class matching.


### Comprehensibility

For each of the character classes described below, we will base the  also add corresponding Boolean properties on both `Character` and `UnicodeScalar`. These properties will provide multiple valuable benefits:

- they will be accessible from within the regular expression/pattern DSL,
- the characters or values that each class matches can be clearly described in the symbols' documentation, and
- the matched characters can be validated by accessing the properties directly.

For example, the `\w` character class, for "word" characters, will have a matching `matchesAsWordCharacter` property.

```swift
"C".matchesAsWordCharacter  // true
"é".matchesAsWordCharacter  // true
"‡".matchesAsWordCharacter  // false
```

We could further extend the API to allow the redefinition of individual character classes, such as making `\d` match only the characters in the range `0` through `9`.

```swift
let fiveDigits = /\d/.customizingClass(\.matchesAsDigit, toMatch: /[0-9]/)
```

## Detailed Design

The following sections detail the different character classes that will be supported by Swift regular expression literals, along with their proposed counterparts in the regular expression DSL.

### Literal characters

A literal character (such as `a`, `é`, or `한`) in a regex literal matches that particular character or code sequence. When matching in Unicode scalar or POSIX mode, the underlying code sequence must be an exact match.

```swift
let str = "Cafe\u{301}"
str.contains(/e/)                           // false
str.contains(/e/.unicodeScalarSemantics)    //  true
```

**DSL:** Literal characters are represented by string literals.

```swift
Pattern {
    "abc"
}
```

### Match any: `.`, `\X`

The dot metacharacter matches any single character or element except for a newline (see the _Whitespace and Newlines_ section, below). In "dot matches all" mode, newlines are treated like any other character. A future proposal will discuss modes in more detail.

`\X` matches any grapheme cluster (`Character`), even when the regular expression is otherwise matching at the Unicode scalar or POSIX level.

**DSL:** The "match anything" pattern is spelled `.anyCharacter`. `.anyCharacter` will match at the level of the overall pattern unless given a more specific level, so `.anyCharacter.graphemeScalarSemantics` is equivalent to the `\X` metacharacter.

```swift
Pattern {
    OneOrMore(.anyCharacter)
}
```

### Digits: `\d`,`\D`

`\d` matches a "digit", which is any `Character` or Unicode scalar with the Unicode general category `Decimal_Number`.

| Matching Level | Note |
|-------------------------------|---------|
| Character | any character where the general category of the first unicode scalar is `Decimal_Number` |
| Unicode Scalar | any scalar where the general category is `Decimal_Number`, not including any combining marks |
| POSIX | `[0-9]` |

`\D` matches the inverse set of characters/elements.

**DSL:** The corresponding pattern is called `.digitCharacter`:

```swift
Pattern {
    OneOrMore(.digitCharacter)
}
```


### Word Characters: `\w`, `\W`

`\w` matches any letter or decimal number, as indicated by the Unicode general categories:

- `Uppercase_Letter`
- `Lowercase_Letter`
- `Titlecase_Letter`
- `Other_Letter`
- `Decimal_Number`

| Matching Level | Note |
|-------------------------------|---------|
| Character | any character where the general category of the first unicode scalar is in the above list |
| Unicode Scalar | any scalar where the general category is in the above list |
| POSIX | `[A-Za-z0-9_]` |

`\W` matches the inverse set of characters/elements.

**DSL:** The corresponding pattern is called `.wordCharacter`:

```swift
Pattern {
    OneOrMore(.wordCharacter)
}
```


### Whitespace and Newlines: `\s`, `\S` (plus `\h`, `\H`, `\v`, `\V`, and `\R`)

`\s` matches any single, non-zero width whitespace character, as denoted by the following list.

- `CHARACTER TABULATION` (U+0009)
- `LINE FEED (LF)` (U+000A)*
- `LINE TABULATION` (U+000B)*
- `FORM FEED (FF)` (U+000C)*
- `CARRIAGE RETURN (CR)` (U+000D)*
- `NEWLINE (NEL)` (U+0085)*
- any character in the Unicode general category `Z`/`Separator`
- the CR/LF sequence

`\h` matches the tab character (U+0009) or any character in the Unicode general category `Space_Separator`.

`\v` matches the five line separator characters above, marked with *, as well as (U+2028) and (U+2029), not including the CR/LF sequence.

`\R` matches the same characters as `\v`, and in addition matches the CR/LF sequence.

| Matching level | Note |
|-------------------------------|---------|
| Character | any character where the general category of the first unicode scalar is in the above list |
| Unicode Scalar | any scalar where the general category is in the above list |
| POSIX | `[ \t\n\r\f\v]` |

`\S`, `\H`, and `\V` match the inverse set of characters as their lowercase respective character classes.

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
- `\x{hhh...}`: Can use 1 or more hexidecimal digits.
- `\Uhhhhhhhh`: Must use 8 hexidecimal digits.

**DSL:** This functionality is supported through the DSL's use of string literals.

```swift
Pattern {
    "abc"
    "\u{032}"
    "def"
}
```

### Unicode named values and properties: `\N`, `\p`, `\P`

`\N{NAME}` matches a Unicode scalar value with the specified name. For example, `/\p{name=HANGUL SYLLABLE GAG}/` matches the character `"각"`.

`\p{PROPERTY}` and `\p{PROPERTY=VALUE}` match a Unicode scalar value with the given Unicode property (and value, if given). Binary properties (such as `White_Space`) and either full or abbreviated general categories (e.g. `Uppercase_Letter` or `Lu`), can be used without a value. For other properties, provide the property and value to match. For example, `/\p{Numeric_Type=Decimal}+/` matches the full range of the string `"0① ₂³"`.

While most Unicode-defined properties can only match at the Unicode scalar level, some are defined to match an extended grapheme cluster. For example, `/\p{RGI_Emoji_Flag_Sequence}/` will match any flag emoji character, which are composed of two Unicode scalar values.

`\P{...}` matches the inverse of the characters matched by the corresponding `\p{...}` character class.

**DSL:** This functionality is supported through APIs that take a predicate as a parameter, focused either on a `Character` or `UnicodeScalar` instance.

```swift
Pattern {
    "abc"
    OneOrMore(.unicodeProperty(where: \.isAlphabetic))
    "def"
}
```

### POSIX Character Classes: `[:NAME:]`

The following POSIX character classes, of the form `[:NAME:]`, are supported:

| POSIX class  | Matches           |
|--------------|-------------------|
| `[:alnum:]`  | `[A-Za-z0-9]`     |
| `[:alpha:]`  | `[A-Za-z]`        |
| `[:ascii:]`  | `[\x00-\x7F]`     |
| `[:blank:]`  | `[ \t]`           |
| `[:cntrl:]`  | `[\x00-\x1F\x7F]` |
| `[:digit:]`  | `[0-9]`           |
| `[:graph:]`  | `[\x21-\x7E]`     |
| `[:lower:]`  | `[a-z]`           |
| `[:print:]`  | `[[:graph:] ]`    |
| `[:punct:]`  | `[-!"#$%&'()*+,./:;<=>?@[\\\]^_{|}~]` |
| `[:space:]`  | `[ \t\n\r\f\v]`   |
| `[:upper:]`  | `[A-Z]`           |
| `[:word:]`   | `[A-Za-z0-9_]`    |
| `[:xdigit:]` | `[0-9A-Fa-f]`     |

### Custom Classes: `[...]`

Users can create custom character classes by using literal characters and most predefined character classes within square brackets.

- Individual characters and character classes described above can be used as is.
- Ranges of Unicode scalar values can be specified by separating the start and end of the range (inclusive) with a hyphen. Note that because `Character` isn't a `Comparable` type, ranges can only match Unicode scalar values. Crossing the UTF-16 surrogate pair range (U+D800 to U+DFFF) is permitted, but values in that range do not match anything, regardless of the string's encoding.
- Include a literal hyphen by escaping, or by placing it first or last in the custom class.
- Negate a custom class by placing a caret immediately after the opening bracket (e.g. `[^a-zA-Z]`).


## Alternatives Considered

### Applying Regular Expressions to String Views

A prior design allowed a user to choose their desired matching level and semantics by applying a regular expression to a string's `UnicodeScalarView`, `UTF16View`, or `UTF8View`. While initially appealing, this approach posed multiple problems:

- Since we want regular expressions created with a literal to be usable all the same places as those created using the DSL, anything predicate-based needs to have the input type specified at the time of creation. It wouldn't make sense to add a `(Character) -> Bool` predicate to a regular expression, and then apply it to the string's `UTF8View`.
- The matching semantics of a regular expression are closely tied to the way it's composed, so it would likely be unpredictable or even nonsensical to apply a regular expression written for one view of a string to be applied to another view.
- It's unclear whether the two UTF-encoded views would treat their elements as individual `UInt16` or `UInt8` values, or whether they would retain some notion of being encoded Unicode data. If the former, how would character classes like `\u{...}` or `\p{...}` be used by the parser? And if the latter, what purpose does this serve beyond parsing the `UnicodeScalarView`?

For these reasons, regular expressions will target only the `StringProtocol`-conforming types — `String` and `Substring`. The other string views can be parsed using the more general `Collection`-based pattern matching, without the regular expression-specific features described in this proposal.

