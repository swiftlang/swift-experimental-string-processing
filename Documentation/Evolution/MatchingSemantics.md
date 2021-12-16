# Regex Matching Semantics

## Introduction

This pitch discusses using regular expressions for processing data at different semantic levels, syntax for controlling matching semantics, and how these levers effect the capture types.

The signature of generic algorithms and the result builder syntax will be discussed in future pitches.

For background see these previous pitches:

- [Declarative String Processing Overview][declarative-string-processing-overview] presents regex-powered matching broadly, without details concerning syntax and semantics.
- [Regular Expression Literals][regular-expression-literals] presents more details on regex syntax such as delimiters and PCRE-syntax innards.
- [Character Classes for String Processing][character-classes-for-string-processing] presents definitions of regex character classes at three different semantics levels (Character, Unicode, and POSIX).
- [Strongly Typed Regex Captures][strongly-typed-regex-captures] presents mappings from regex syntax such as capturing groups and quantifiers to a strongly typed match result of tuples and arrays.

## Motivation

Many string processing tasks, like the example in the [overview][declarative-string-processing-overview] of processing a Unicode data table, operate only on the ASCII portions of their input data. It should be simple and easy to use regular expressions to match and extract captures from such data in Swift.

At the same time, Swift's String API provides multiple views of a string's components, from grapheme clusters (`Character`s) down to the UTF-8 code units that represent the string's underlying data, and a rich Unicode feature set. With these features in mind, regular expressions should also support controlling:

- Whether `.` matches a byte, a code point, or a grapheme cluster
- The semantic level of character classes
- If comparison honors [Unicode canonical equivalence][canonical-equivalence]

The design should strike a balance between what users will expect of Swift (especially `String`) and what they've learned to expect of regular expressions from other tools and languages. Compile time checking and strong typing should be leveraged to prevent programmer errors, like capturing a `Substring` over a range of bytes that isn't valid UTF-8.

### Levels of data processing

When only considering ASCII data, it's easy to conflate string processing, textual data processing, and binary data processing, but these are distinct tasks with unique requirements.

#### String processing

Swift `String`s are presented as a collection of `Character`s, or [extended grapheme clusters][grapheme-cluster] whose comparison honors [Unicode canonical equivalence][canonical-equivalence]. Even when a character is composed of multiple Unicode scalar values, the presentation to a user is a single `Character`:

```swift
let cafe = "Cafe\u{301}" // "Café"
cafe == "Café"           // true
cafe.dropLast()          // "Caf"
cafe.last == "é"         // true (precomposed e with acute accent)
cafe.last == "e\u{301}"  // true (e followed by composing acute accent)
```

These are good defaults for the kinds of tasks that qualify as "string processing"—processing Unicode-rich, and especially user-generated, content. An example of such a task would be eliminating duplicated identifiers in a whitespace-delimited list:

```swift
let duplicateIdentifiers = /\b(\w+)\s+\1\b/
// => Regex<(Substring, Substring)>

// Equivalent result builder syntax:
//     struct DuplicateIdentifiers: Pattern {
//       @Backreference var word: Substring
//     
//       var body: some Pattern {
//         CharacterClass.wordBoundary
//         OneOrMore(.word).capture($word)
//         OneOrMore(.space)
//         word
//         CharacterClass.wordBoundary
//       }
//     }
//     let duplicateIdentifiers = DuplicateIdentifiers()

let content = "all count count countAll every every oneOf some"
content.replaceAll(duplicateIdentifiers, with: { $1 })
// => "all count countAll every oneOf some"
```

#### Textual data processing

Many tasks that at first appear to be string processing are actually "textual data processing." Formats such as JSON, plists, and source code have a textual presentation and may include Unicode-rich content, but they should be processed at the `Unicode.Scalar` level.

An example is a CSV file that enumerates all defined Unicode scalars. Such a document would include the field-separator `,` followed by a `U+0301` (Combining Acute Accent). If it were processed `Character` by `Character`, the comma would combine with the accent into a single ([degenerate][degenerates]) grapheme cluster `,́` that wouldn't compare equal to either independent piece:

```swift
let csv = "\u{300},\u{301},\u{302}" // "̀,́,̂"
csv.contains(",")                   // false
csv.contains("\u{301}")             // false
csv.split(separator: ",")           // ["̀,́,̂"]
```

Instead, it should be processed one Unicode code point at a time by comparing the scalar values:

```swift
let csv = "\u{300},\u{301},\u{302}"       // "̀,́,̂"
csv.unicodeScalars.contains(",")          // true
csv.unicodeScalars.contains("\u{301}")    // true
csv.unicodeScalars.split(separator: ",") // ["̀", "́", "̂"]
```

#### Binary data processing

Unlike textual data, binary data does not have a textual presentation and can't be stored in `String`, which enforces its contents be valid UTF-8. Image, video, and archive formats are examples of binary data formats.

An example is an image saved in the [JPEG File Interchange Format][jfif-format]. Each JFIF file starts with a sequence of unique bytes: the start of image marker (`0xFF`, `0xD8`), the `APP0` marker (`0xFF`, `0xE0`), two bytes to specify the length of the `APP0` segment, and a null-terminated `"JFIF"` identifier.

Try to create a String from this data and it'll replace the ill-formed UTF-8 sequences with the Unicode replacement character:

```swift
let imageData = Data(contentsOf: imageURL)
// => [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, ...]
let string = String(decoding: imageData, as: UTF8.self)
// => "\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\0\u{10}JFIF\0"
```

We can use a pattern to check if the image is a JFIF file by matching against the raw bytes instead:

```swift
let imageData = Data(contentsOf: imageURL)
// => [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, ...]

let jfifHeader = /\xFF\xD8\xFF\xE0..JFIF/
// Equivalent result builder syntax:
//     let jfifHeader = Pattern {
//       [0xFF, 0xD8, 0xFF, 0xE0] as [UInt8]
//       repeatElement(CharacterClass.anyByte, count: 2)
//       "JFIF"
//     }

imageData.contains(jfifHeader)
// => true
```

### Moving between levels

In practice, many tasks require moving between these different processing levels. For many textual formats, while the delimiters should be processed as "textual data," the field content should be processed as strings. Also, many binary data formats have segments that include filename, title, or comment strings amid all the other binary data. Therefore, Swift should support modes that can be turned on and off within the regular expression in order to switch processing levels.

## Proposed Solution

To meet user expectations, regular expression matching in Swift should start by operating at the `Character` level, the same as working with `String`'s equality or `Collection` conformance. With that semantic approach as the default, regular expressions made up of literal characters match their equivalent strings without issue.

```swift
let cafe = "Cafe\u{301}"
cafe == "Café"              // true
cafe.contains(/Café/)       // true
```

Notably, a wildcard (`.`) in the default semantic mode matches any `Character` that isn't a new line. Regular expressions with character semantics can match strings with a specific number of characters, but don't delve into the constitutive parts of a character to match individual Unicode scalars. In this example, the four `.` elements match all four characters of the `cafe` string, leaving nothing left for the custom character class to match:

```swift
cafe.contains(/..../)    // true
cafe.contains(/....[\u{300}-\u{314}]/) // false
```

By moving to Unicode scalar semantics, we can use a regular expression to match specific Unicode scalar sequences and patterns. With this regular expression, each `.` or character class matches a single Unicode scalar, not an entire character:

```swift
let adornedLetter = /(?u)\w[\u{300}-\u{314}]/
// Equivalent result builder syntax:
//     let adornedLetter = Pattern(semantics: .unicodeScalar) {
//       CharacterClass.wordCharacter
//       AnyOf("\u{300}"..."\u{314}")
//     }

if let lastLetter = cafe.firstMatch(of: adornedLetter) {
    print("Last letter: \(lastLetter.match)")
}
// Prints "Last letter: é"
```

When a regular expression employs byte semantics, the `.` and character classes match only a single byte, not a Unicode scalar or a `Character`. When applied to a `String`, which is guaranteed to be valid UTF-8, this is only provides a moderate increase in functionality. With other collection of bytes, however, you can use a regular expression in byte semantic mode to parse arbitrary binary data. And because you can switch between modes mid-stream, you can write patterns that read stretches of Unicode scalar data between binary delimiters.

In this example, the `elementName` capture group is inside a Unicode scalar semantic mode, so `.` matches only valid UTF-8 code sequences that represent Unicode scalar values. With the terminating null byte (`\x00`), the capture value is safe to convert to a string. The `value` capture group, on the other hand, has byte semantics, so it simply matches the next four bytes without checking for an encoding.

```swift
let bsonInt32 = /\x10(?u:(?<elementName>:.+\x00))(?b:(?<value>:.{4}))/
// Equivalent result builder syntax:
//     struct BSONInt32: Pattern {
//       @Backreference var elementName: Substring
//       @Backreference var value: Substring
//
//       var body: some Pattern {
//         0x10 as UInt8
//         Pattern(semantics: .unicodeScalar) {
//           OneOrMore(.any)
//           0x00 as UInt8
//         }.capture($elementName)
//         repeatElement(CharacterClass.anyByte, count: 4).capture($value)
//       }
//     }
//     let bsonInt32 = BSONInt32()

let source = [0x10, 0x63, 0x6f, 0x75, 0x6e, 0x74, 0x00,
              0x10, 0x00, 0x00, 0x00, 0x02, ...]
if let element = source.firstMatch(of: bsonInt32Regex) {
    print(String(cString: element.elementName), element.value)
}
// Prints "age [0x2c, 0x00, 0x00, 0x00]"
```

The example above shows another aspect of mode-switching, which is that some metacharacters carry an implicit mode. The initial byte literal, expressed as `\x10`, can only match that exact byte in the input collection, no matter what semantic mode the regular expression is executed in.

You can also use specific wildcard metacharacters to match an element at a specific level, even when matching in a different mode:

- `\X` matches a single `Character`
- `\U` matches a single Unicode scalar
- `\C` matches a single byte (spelling tbd)

The last lever available is to turn off Unicode support within metacharacters like `\d` and `\w`. After specifying the `P` flag, these metacharacters will only match the ASCII subset of their more general character class. For more detail, see [Character Classes for String Processing][character-classes-for-string-processing].

## Detailed Design

Swift regular expressions will by default match at the `Character` level, using the same semantics as `String` equality comparisons. The regular expression type provides API for changing those defaults, or you can use modifiers within a regular expression literal to change the matching semantics for portions of the expression. Regular expresssions have three modes that affect the matching semantics:

- `Character` semantics (`X`)
- Unicode scalar semantics (`u`)
- Byte semantics (`b`)

Enabling and disabling these modes have the behavior of pushing and popping from a stack. The compiler will warn when a mode has been ended (e.g. `(?-b)`) before it has been enabled.

You can use any of these modes when applying a regular expression to a `String`, a `Substring`, or any collection of `UInt8`. When applied to any of these types, the collection will be interpreted at the specified semantic level, allowing a `String` to be interpreted as binary data, or alternatively, allowing grapheme-breaking and canonical equivalence algorithms to be applied to UTF-8 encoded bytes in a `Data` instance.

Because the compiler determines the capture types of a regular epxression while parsing, we can preserve the ergonomics of captures that guarantee UTF-8 correctness. When a capture appears in a section of a regular expression literal that uses either `Character` or `UnicodeScalar` semantics, and that regular expression is applied to a `String` or `Substring`, the capture group is captured as a substring. However, if a capture includes any portion of a regular expression with byte semantics, or if a regular expression is applied to a non-string collection, then the capture group is captured as a collection that does not provide a UTF-8 correctness guarantee. See "Byte Semantics" for more detail.

#### `Character` Semantics

When using character semantics, `.` and the built-in or custom character classes match a grapheme cluster. This semantic level is analogous to comparing individual `Character`s while iterating over a `String`.

```swift
let cafe1 = "Cafe\u{301}"
cafe1.matches(/Caf./)          // true: `.` matches the last character
```

Grapheme clusters that are written with Unicode literals in the non-custom character class portions of a regular expression are recognized just as they are in string literals. That is, both `cafe` string variations are matched by both regular expressions in character semantic mode:

```swift
let cafe2 = "Café"
let regex1 = /Café/
let regex2 = /Cafe\u{301}/
```

The metacharacter classes `\w`, `\d`, and `\s`, the Unicode classes specified as `\p{...}`, and POSIX character class all match at the character level when in this semantic mode. For a grapheme cluster to match a character class, all Unicode scalars that constitute the grapheme cluster must belong to the requisite Unicode categories.

```swift
cafe1.matches(/Caf\w/)         // true: `\w` matches the last character because
                               //       `e` is in Unicode category `Letter` and
                               //       `\u{301}` is in Unicode category `Mark`
"Caf1\u{301}".matches(/Caf\d/) // false: `\d` requires all parts of the character
                               //        to be in Unicode category `Digit`
```

Within a custom character class (CCC, written as `[...]`), each character literal or Unicode scalar literal are treated as separate entities. In this way, `[e\u{301}]` is interpreted as a set that matches either `e` or `\u{301}` in a string, but not the `e\{301}` character. To match specific multi-scalar characters, you can specify a Unicode scalar sequence instead. Canonical equivalence is still used when matching the elements and ranges defined in a custom character class.

```swift
cafe1.matches(/Caf[é]/)           // true: CCC elements use canonical equivalence
cafe1.matches(/Caf[e\u{301}]/)    // false: `e` and `\u{301}` are separate elements
cafe1.matches(/Caf[\u{65 301}]/)  // true: Unicode scalar sequence is equivalent
```

Grapheme recognition does not apply across custom character class definitions, so attempting to match the individual parts of a decomposed character does not succeed in character semantic mode. In this example, the author is trying to match a vowel that has a diacritic attached, but the `[aeiou]` custom character class does not match the first element of `e\u{301}`:

```swift
cafe1.matches(/Caf[aeiou][\u{300}-\u{314}]/)  // false: A custom character class must
                                              //        match an entire character
```

For control over the specific Unicode scalar spelling within a target string, use Unicode scalar semantics instead.


#### `UnicodeScalar` Semantics

`UnicodeScalar`-based semantics mean that matching with a regular expression operates directly on the Unicode scalar values that comprise a string; analogous to comparing `UnicodeScalar` values while iterating over a string's `unicodeScalars` view. At this semantic level, a dot `.` or character class matches a single Unicode scalar value, and canonical equivalence is _not_ used, matching many other regular expression engines.

```swift
let cafe1 = "Cafe\u{301}"           // "Café"
cafe1.matches(/(?u)Cafe\u{301}$/)   // true: matches original Unicode scalar sequence
cafe1.matches(/(?u)Café$/)          // false: no canonical equivalence
cafe1.matches(/(?u)Caf.$/)          // false: dot matches a scalar value, not a character
cafe1.matches(/(?u)Caf[åéîøü]$/)    // false: no canonical equivalence
cafe1.matches(/(?u)Caf\w$/)         // false: a character class matches only a single Unicode scalar
cafe1.matches(/(?u)Caf[aeiou][\u{300}-\u{314}]$/) // true: custom character class matches a scalar
```

Using `UnicodeScalar` semantics, you can safely process the CSV mentioned above:

```swift
let csv = "...,\u{300},\u{301},\u{302},..."
csv.contains(/\u{301}/)           // false: no `Character` equal to `\u{301}`
csv.contains(/(?u)\u{301}/)       // true: Unicode scalar value `\u{301}` exists
csv.split(separator: /(?u),/)     // splits on every comma, as required:
                                  // ["...", "\u{300}", "\u{301}", "\u{302}", "..."]
```

All character classes match at the Unicode scalar level when in this semantic mode.

```swift
cafe1.matches(/(?u)Caf\p{Letter}$/)          // false: `\p{Letter}` only matches the `e`
cafe1.matches(/(?u)Caf\p{Letter}\p{Mark}$/)  // true: each scalar is properly matched by category
```

In this semantic mode, custom character classes match individual Unicode scalars, which lets you match particular grapheme clusters that are constructed from multiple codepoints. This example shows regular expressions that could be useful when performing content analysis: `flags` matches a flag emoji composed of two regional indicator codepoints, while `familyEmoji` matches a composed emoji codepoint sequence:

```swift
let flags = /(?u)[\u{1F1E6}-\u{1F1FF}]{2}/
let familyEmoji = / ... /
```


#### Byte Semantics

When using byte semantics, a dot or character class matches only a single byte, allowing processing of binary data that may or may not be encoded as valid UTF-8. Because each character class can only match a single byte, this mode limits character classes to only match their ASCII members. For example, `\d` only matches the digits `0` through `9`. You can use byte literals to match individual bytes, even in a different semantic mode

```swift
let data = 
cafe.matches(/(?b)Café/)               // false: no canonical equivalence
cafe.matches(/(?b)Cafe\xCC\x81/)       // true: bytes match

// TODO: a more appropriate example than "Café"
```

You can turn on binary semantics by using the `b` flag in a regular expression literal or the `binarySemantics` property on a regular expression instance.

```swift
cafe.matches(/(?b)Cafe\xCC\x81/)
cafe.matches(/Cafe\xCC\x81/.binarySemantics)
```

### Capture groups

As described in [Strongly Typed Regex Captures][strongly-typed-regex-captures], the capture groups within a regular expression are identified at compile time. Whether a capture group is optional or can be repeated is reflected in that particular group's captured type. As an example, the regular expression defined below has three captures:

```swift
let regex = /(ab.)?(de.)+/
// - regex.Match.0: the entire matched range
// - regex.Match.1: the first (optional) capture group
// - regex.Match.2: the second (repeated) capture group
```

In addition to taking quantification into account, the compiler must also use the semantic mode to determine what kind of capture type is safe to provide. Whenever possible, capturing each submatch as a `Substring` has multiple benefits:

- A `Substring` instance represents both the matched substring and the range of that substring in the original string.
- `Substring` includes the entire `StringProtocol` API interface.
- `Substring` includes a guarantee that its contents are valid UTF-8.

Whenever a capture group includes only `Character` or Unicode scalar mode, and excludes byte literals, the resulting type is eligible to be a `Substring`. When a capture group includes portions which are in byte semantic mode, or contains byte literals, then the capture type must be a collection of `UInt8` instead of `Substring`.

```swift
let substringMatch = cafe.firstMatch(of: /[a-z]+(.)/)
// type(of: substringMatch.captures) == (Substring, Substring)

let utf8Match = cafe.firstMatch(of: /(?b)[a-z]+(.)/)
// type(of: utf8Match.captures) == (Slice<String.UTF8View>, Slice<String.UTF8View>)
```

This table summarizes the capture types depending on the matching semantics and the type of the collection that the regular expression is applied to.

| When matching...         | Unapplied      | Matching a string      | Matching a  `UInt8` collection |
|--------------------------|----------------|------------------------|--------------------------------|
| Character semantics      | Submatch       | Substring              | Slice<Collection>              |
| Unicode scalar semantics | Submatch       | Substring              | Slice<Collection>              |
| Byte semantics           | Submatch.Bytes | Slice<String.UTF8View> | Slice<Collection>              |
| Includes byte literal    | Submatch.Bytes | Slice<String.UTF8View> | Slice<Collection>              |

## Alternatives Considered

### ASCII metacharacters by default

When matching character classes like `\d` and `\w`, a regular expression could only match ASCII values by default, instead of the broader set of Unicode values. Since regular expressions are frequently only one part of a multi-step text processing chain, this constrained matching behavior would help ensure that a regex doesn't match substring that an author doesn't expect.

In this example, the `intRegex` expression matches up to six digits, then converts the result to an integer. This is only safe if the matched digits are ASCII — with more expansive matching behavior of `\d`, the expression would match characters that can't be handled by the downstream `Int` converting initializer.

```swift
let intRegex = /\d{,6}/
let allIntegers = text.allMatches(of: intRegex).map { Int($0)! }
```

Our opinion is that it is preferable to have metacharacter matching follow the current semantic level within the regular expression. Users that need to match only ASCII characters can opt into that mode explicitly using the `a` flag, or can use custom character classes such as `[0-9]` instead.

### Semantic mode pushing / popping

As an alternative to allowing pushing and popping of the semantic mode, we could instead only allow "setting" the current mode. With this approach, `-X`, `-u` and `-C` would be disallowed flags, and the current semantic mode would continue until going out of scope or being changed.

## Future Directions

// TODO: What should we include here?


[declarative-string-processing-overview]: https://forums.swift.org/t/declarative-string-processing-overview/52459
[regular-expression-literals]: https://forums.swift.org/t/pitch-regular-expression-literals/52820
[character-classes-for-string-processing]: https://forums.swift.org/t/pitch-character-classes-for-string-processing/52920
[strongly-typed-regex-captures]: https://forums.swift.org/t/pitch-strongly-typed-regex-captures/53391
[grapheme-cluster]: https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries
[canonical-equivalence]: https://www.unicode.org/reports/tr15/#Canon_Compat_Equivalence
[degenerates]: https://www.unicode.org/reports/tr29/#Rule_Constraints
[jfif-format]: https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
