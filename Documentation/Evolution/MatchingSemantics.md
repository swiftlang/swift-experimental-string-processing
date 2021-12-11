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

Many string processing tasks, like the example in the [overview][declarative-string-processing-overview] of processing a Unicode data table, operate on ASCII-only input data. It should be simple and easy to use Swift regular expressions to match and extract captures from such data.

For more sophisticated tasks, Swift regular expressions also need to support controlling:

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

These are good defaults for the kinds of tasks that qualify as "string processing"—processing Unicode-rich, and especially user-generated, content. An example of such a task would be eliminating duplicate words:

```swift
let duplicateWords = /\b(\w+)\s+\1\b/
// => Regex<(Substring, Substring)>

// Equivalent result builder syntax:
//     struct DuplicateWords: Pattern {
//       @Backreference word: Substring
//     
//       var body: some Pattern {
//         CharacterClass.wordBoundary
//         OneOrMore(.word).capture($word)
//         OneOrMore(.space)
//         word
//         CharacterClass.wordBoundary
//       }
//     }
//     let duplicateWords = DuplicateWords()

let content = "Meet me at the café cafe\u{301} on the corner."
content.replaceAll(duplicateWords, with: { $1 })
// => "Meet me at the café on the corner"
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
cafe == "Café"             // true
cafe.contains(/Café/)       // true
cafe.contains(/Caf[åéîòü]/) // true
```

Notably, a wildcard (`.`) in the default semantic mode matches any `Character` that isn't a new line. Regular expressions can match strings with a specific number of characters, but don't delve into the constitutive parts of a character to match individual Unicode scalars. In this example, the four `.` elements match all four characters of the `cafe` string, leaving nothing left for the custom character class to match:

```swift
cafe.contains(/..../)    // true
cafe.contains(/....[\u{300}-\u{314}]/) // false
```

By moving into Unicode scalar semantics, we can use a regular expression to match specific Unicode scalar sequences and patterns. With this regular expression, each `.` or character class matches a single Unicode scalar, not an entire character:

```swift
let adornedLetterRegex = /(?u)\w[\u{300}-\u{314}]/
if let lastLetter = cafe.firstMatch(of: adornedLetterRegex) {
    print("Last letter: \(lastLetter.match)")
}
// Prints "Last letter: é"
```

When a regular expression employs byte semantics, the `.` and character classes match only a single byte, not a Unicode scalar or a `Character`. When applied to a `String`, which is guaranteed to be valid UTF-8, this is only provides a moderate increase in functionality. With other collection of bytes, however, you can use a regular expression in byte semantic mode to parse arbitrary binary data. And because you can switch between modes mid-stream, you can write patterns that read stretches of Unicode scalar data between binary delimiters.

In this example, the `elementName` capture group is inside a Unicode scalar semantic mode, so the `.` matches only valid UTF-8 code sequences that represent Unicode scalar values, ensuring that it is safe to later convert to a string. The `value` capture group, on the other hand, has byte semantics, so it simply matches the next four bytes without checking for an encoding.

```swift
let bsonInt32Regex = /\x10(?u:(?<elementName>:.+\x00))(?b:(?<value>:.{4}))/
let source = [0x10, 0x63, 0x6f, 0x75, 0x6e, 0x74, 0x00,
              0x10, 0x00, 0x00, 0x00, 0x02, ...]
if let element = source.firstMatch(of: bsonInt32Regex) {
    print(String(cString: element.elementName), element.value)
}
// Prints "age [0x2c, 0x00, 0x00, 0x00]"
```

The example above shows another aspect of mode-switching, which is that some metacharacters carry an implicit mode. The initial byte literal, expressed as `\x10`, can only match that exact byte in the input collection, no matter what semantic mode the regular expression is executed in. Similarly, a Unicode property metacharacter such as `\p{Letter}` always matches at the Unicode scalar value level, even if the regular expression is using byte semantics at the time.

You can also use specific wildcard metacharacters to match an element at a specific level, even when matching in a different mode:

- `\X` matches a single `Character`
- `\U` matches a single Unicode scalar
- `\C` matches a single byte

The last lever available is to turn off Unicode support within metacharacters like `\d` and `\w`. After specifying the `a` flag (tbd), these metacharacters will only match the ASCII subset of their more general character class. For more detail, see [Character Classes for String Processing][character-classes-for-string-processing].

## Detailed Design

The standard library should include a single `Regex` type, which by default matches at the `Character` level, using the same semantics as `String` equality comparisons. The `Regex` type provides API for changing those defaults, or you can use modifiers within a regular expression literal to change the matching semantics for portions of the expression. Swift regular expresssions have three modes that affect the matching semantics:

- `Character` semantics (`X`)
- Unicode scalar semantics (`u`)
- Byte semantics (`b`)

Enabling and disabling these modes have the behavior of pushing and popping from a stack. The compiler will warn when a mode has been ended (e.g. `(?-b)`) before it has been enabled.

You can use any of these modes when applying a regular expression to a `String`, a `Substring`, or any collection of `UInt8`. When applied to any of these types, the collection will be interpreted at the specified semantic level, allowing a `String` to be interpreted as binary data, and allow grapheme-breaking and canonical equivalence algorithms to be applied to UTF-8 encoded bytes in a `Data` instance.

Because the compiler determines the capture types of a regular epxression while parsing, we can preserve the ergonomics of captures that guarantee UTF-8 correctness. When a capture appears in a section of a regular expression literal that uses either `Character` or `UnicodeScalar` semantics, and that regular expression is applied to a `String` or `Substring`, the capture group is captured as a substring. However, if a capture includes any portion of a regular expression with byte semantics, or if a regular expression is applied to a non-string collection, then the capture group is captured as a collection that does not provide a UTF-8 correctness guarantee. See "Byte Semantics" for more detail.

#### `Character` Semantics

`Character`-based semantics mean that matching with a regular expression yields the same results as comparing for `String` equality. When matching with the default `Character`-level semantics, a "dot" or character class matches a single Swift `Character` and canonical equivalence is used when comparing:

```swift
let cafe = "Cafe\u{301}"      // "Café"
cafe == "Café"                // true: String equality comparison
cafe.matches(/Café/)          // true: canonical equivalence
cafe.matches(/Cafe\u{301}/)   // true: character recognition in regex literals
cafe.matches(/Caf./)          // true: dot matches a character
cafe.matches(/Caf[åéîøü]/)    // true: canonical equivalence within custom classes
cafe.matches(/Caf\w/)         // true: character class matches a character
cafe.matches(/Caf\p{Letter}/) // true: Unicode property matches a character

cafe.count == 4               // true
cafe.matches(/.{4}/)          // true: dot matches a character

// false: the fourth `.` matches the whole `"e\u{301}"` character
cafe.matches(/....\u{301}/)
```

You can turn on `Character` semantics by using the `X` flag in a regular expression literal or the `characterSemantics` property on a regular expression instance.

```swift
cafe.matches(/(?X)Café/)                // This is the default behavior...
cafe.matches(/Café/.characterSemantics) // ...as is this
```

#### `UnicodeScalar` Semantics

`UnicodeScalar`-based semantics mean that matching with a regular expression operates directly on the Unicode scalar values that comprise a string, matching many other regular expression engines. At this semantic level, a "dot" or character class matches a single Unicode scalar value, and canonical equivalence is _not_ used when comparing:

```swift
let cafe = "Cafe\u{301}"           // "Café"
// false: The two strings have different Unicode scalar sequences
cafe.unicodeScalars.elementsEqual("Café".unicodeScalars)
cafe.matches(/(?u)Cafe\u{301}$/)   // true: matches original Unicode scalar sequence
cafe.matches(/(?u)Café$/)          // false: no canonical equivalence
cafe.matches(/(?u)Caf.$/)          // false: dot matches a scalar value, not a character
cafe.matches(/(?u)Caf[åéîøü]$/)    // false: no canonical equivalence
cafe.matches(/(?u)Caf\w$/)         // false: a character class matches only a single Unicode scalar
cafe.matches(/(?u)Caf[aeiou][\u{300}-\u{305}]$/) // true: custom character class matches a scalar

// Unicode property class matches only a single Unicode scalar
cafe.matches(/(?u)Caf\p{Letter}$/)                    // false
cafe.matches(/(?u)Caf\p{Letter}\p{Nonspacing_Mark}$/) // true

cafe.unicodeScalars.count == 5     // true
cafe.matches(/(?u).{5}/)           // true: dot matches a Unicode scalar

// true: the fourth `.` matches only the letter `"e"`
cafe.matches(/(?u)....\u{301}/)
```

Using `UnicodeScalar` semantics, you could safely process the CSV mentioned above:

```swift
let csv = "...,\u{300},\u{301},\u{302},..."
csv.contains(/\u{301}/)           // false: no `Character` equal to `\u{301}`
csv.contains(/(?u)\u{301}/)       // true: Unicode scalar value `\u{301}` exists
csv.split(separator: /(?u),/)     // splits on every comma, as required:
                                  // ["...", "\u{300}", "\u{301}", "\u{302}", "..."]
```

You can turn on `UnicodeScalar` semantics by using the `u` flag in a regular expression literal or the `unicodeScalarSemantics` property on a regular expression instance.

```swift
cafe.matches(/(?u)Café/)
cafe.matches(/Café/.unicodeScalarSemantics)
```

#### Byte Semantics

When using byte semantics, a dot or character class matches only a single byte, allowing processing of binary data that may or may not be encoded as valid UTF-8. Because each character class can only match a single byte, this mode limits character classes to only match their ASCII members. For example, `\d` only matches the digits `0` through `9`. You can use byte literals to match individual bytes, even in a different semantic mode

```swift
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
| Unicode scalar semantics | Submatch       | Substring              | Slice <Collection>             |
| Byte semantics           | Submatch.Bytes | Slice<String.UTF8View> | Slice <Collection>             |
| Includes byte literal    | Submatch.Bytes | Slice<String.UTF8View> | Slice <Collection>             |

## Alternatives Considered

### Match Unicode values with metacharacters by default

When matching character classes like `\d` and `\w`, a regular expression could only match ASCII values by default, instead of the broader set of Unicode values. Since regular expressions are frequently only one part of a multi-step text processing chain, this constrained matching behavior would help ensure that a regex doesn't match substring that an author doesn't expect.

In this example, the `intRegex` expression matches up to six digits, then converts the result to an integer. This is only safe if the matched digits are ASCII — with more expansive matching behavior of `\d`, the expression would match characters that can't be handled by the downstream `Int` converting initializer.

```swift
let intRegex = /\d{,6}/
let allIntegers = text.allMatches(of: intRegex).map { Int($0)! }
```

Our opinion is that it is preferable to have metacharacter matching follow the current semantic level within the regular expression. Users that need to match only ASCII characters can opt into that mode explicitly using the `a` flag, or can use custom character classes such as `[0-9]` instead.

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
