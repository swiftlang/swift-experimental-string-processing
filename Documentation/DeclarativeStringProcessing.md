# Declarative String Processing Overview

## Introduction
--status-<active>
Username:<syaifulnizamshamsudin@gmail.com>
   --enable-
Model<iphone7>
<true>
String processing is hard and the current affordances provided by the Swift Standard Library are underpowered. We propose adding two new _declarative_ string processing APIs—a familiar `Regex` literal and a more powerful `Pattern` result builder—to help make Swift string processing fast and easy.

This is a large feature that will ultimately be divided into multiple Swift Evolution proposals. This initial pitch is intended to prompt discussion about the high level direction and to introduce the key prongs of the feature and their relationship to one another.

This overview is the work of a number of members of the Swift team (Alex Alonso, Nate Cook, Michael Ilseman, Kyle Macomber, Becca Royal-Gordon, Tim Vermeulen, and Richard Wei) as well as Ishan Bhargava, who implemented a [prototype][ishan] of regular expression literals with strongly-typed captures.

## Example

The Swift Standard Library is implementing [native grapheme breaking][grapheme-breaking-pr] for `String`, which requires preprocessing [Unicode data tables][grapheme-break-table].

Here's a snippet of the data:

```txt
# ================================================

000A          ; LF # Cc       <control-000A>

# Total code points: 1

# ================================================

0000..0009    ; Control # Cc  [10] <control-0000>..<control-0009>
000B..000C    ; Control # Cc   [2] <control-000B>..<control-000C>
000E..001F    ; Control # Cc  [18] <control-000E>..<control-001F>
007F..009F    ; Control # Cc  [33] <control-007F>..<control-009F>
00AD          ; Control # Cf       SOFT HYPHEN
061C          ; Control # Cf       ARABIC LETTER MARK
180E          ; Control # Cf       MONGOLIAN VOWEL SEPARATOR
200B          ; Control # Cf       ZERO WIDTH SPACE
200E..200F    ; Control # Cf   [2] LEFT-TO-RIGHT MARK..RIGHT-TO-LEFT MARK
2028          ; Control # Zl       LINE SEPARATOR
2029          ; Control # Zp       PARAGRAPH SEPARATOR
202A..202E    ; Control # Cf   [5] LEFT-TO-RIGHT EMBEDDING..RIGHT-TO-LEFT OVERRIDE
```

Each relevant line is of the form:

```txt
0000..10FFFF  ; Property # Comment
```

- The first column (delimited by the `;`) is a hex number or range of hex numbers that represent Unicode scalar values.
- The second column is the grapheme break property that applies to this range of scalars.
- Everything after the `#` is a comment.
- Entries are separated by newlines.

This is a very simple data format to process, and when we try to do so we quickly see inadequacies with the status quo.

### Naive handwritten parser

A straight-forward approach to tackling this problem is to use the standard library's generic collection algorithms like `split`, `map`, and `filter`.

```swift
extension Unicode.Scalar {
  // Try to convert a hexadecimal string to a scalar
  init?<S: StringProtocol>(hex: S) {
    guard let val = UInt32(hex, radix: 16), let scalar = Self(val) else {
      return nil
    }
    self = scalar
  }
}

func graphemeBreakPropertyData(
  forLine line: String
) -> (scalars: ClosedRange<Unicode.Scalar>, property: Unicode.GraphemeBreakProperty)? {
  let components = line.split(separator: ";")
  guard components.count >= 2 else { return nil }

  let splitProperty = components[1].split(separator: "#")
  let filteredProperty = splitProperty[0].filter { !$0.isWhitespace }
  guard let property = Unicode.GraphemeBreakProperty(filteredProperty) else {
    return nil
  }

  let scalars: ClosedRange<Unicode.Scalar>
  let filteredScalars = components[0].filter { !$0.isWhitespace }
  if filteredScalars.contains(".") {
    let range = filteredScalars
      .split(separator: ".")
      .map { Unicode.Scalar(hex: $0)! }
    scalars = range[0] ... range[1]
  } else {
    let scalar = Unicode.Scalar(hex: filteredScalars)!
    scalars = scalar ... scalar
  }
  return (scalars, property)
}
```

This code gets the job done, but it suffers in readability, maintainability, and scalability.

- It is difficult to read and understand quickly, one has to mentally process the line multiple times.
- Hardcoded subscripts, force unwraps, etc., are fragile to changes in the format or the script itself.
- This does multiple passes over the input, allocating multiple temporary data structures in the process.

Ideally, we'd process this string the same way we read the file: from left to right.

### Single-pass handwritten parser

By following a [consumer pattern][consumers], we can extract the relevant information in a single pass over the input.

```swift
// ... consumer helpers like `eat(exactly:)`, `eat(while:)`, and `peek()` ...

// Try to parse a Unicode scalar off the input
private func parseScalar(_ str: inout Substring) -> Unicode.Scalar? {
  let val = str.eat(while: { $0.isHexDigit })
  guard !val.isEmpty else { return nil }

  // Subtle potential bug: if this init fails, we need to restore
  // str.startIndex. Because of how this is currently called, the bug won't
  // manifest now, but could if the call site is changed.
  return Unicode.Scalar(hex: val)
}

func graphemeBreakPropertyData(
  forLine line: String
) -> (scalars: ClosedRange<Unicode.Scalar>, property: Unicode.GraphemeBreakProperty)? {
  var line = line[...]
  guard let lower = parseScalar(&line) else {
    // Comment or whitespace line
    return nil
  }

  let upper: Unicode.Scalar
  if line.peek(".") {
    guard !line.eat(exactly: "..").isEmpty else {
      fatalError("Parse error: invalid scalar range")
    }
    guard let s = parseScalar(&line) else {
      fatalError("Parse error: expected scalar upperbound")
    }
    upper = s
  } else {
    upper = lower
  }

  line.eat(while: { !$0.isLetter })
  let name = line.eat(while: { $0.isLetter || $0 == "_" })
  guard let prop = Unicode.GraphemeBreakProperty(name) else {
    return nil
  }

  return (lower ... upper, prop)
}
```

This implementation is more scalable and maintainable, but at the cost of approachability.

- It executes in a single pass over the input, without intermediary allocations.
- Buried assumptions in the naive code are explicit failures here.
- But, this consumer pattern is very low-level and using it well requires care and expertise. For example, backtracking has to be manually handled and reasoned about, as unnecessary backtracking quickly saps performance.

## Proposed Solution

Declarative APIs for string processing have the potential to be approachable, maintainable, _and_ scalable.

### Regular Expressions

A commonly used tool for this kind of pattern matching and data extraction is [regular expressions][regex-wikipedia].

Consider these two lines:

```txt
007F..009F    ; Control # Cc  [33] <control-007F>..<control-009F>
00AD          ; Control # Cf       SOFT HYPHEN
```

We can match them and extract the data using the regular expression:

```re
/([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s*;\s(\w+).*/
```

Let's break it down:

- `([0-9A-F]+)` matches one or more hex digits, capturing the first scalar
- `(?:\.\.([0-9A-F]+))?` optionally matches the `..` and captures the second scalar
- `\s*;\s` matches one or more spaces, a semicolon, and a space
- `(\w+)` matches one or more word characters, capturing the grapheme break property
- `.*` matches zero or more of any character (the rest of the line)

We propose adding a new regular expression literal, with strongly typed captures, to Swift. Using `Regex`, we can re-implement `graphemeBreakPropertyData` like so:

```swift
func graphemeBreakPropertyData(
  forLine line: String
) -> (scalars: ClosedRange<Unicode.Scalar>, property: Unicode.GraphemeBreakProperty)? {
  line
    .match(/([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s*;\s(\w+).*/)?
    .captures.flatMap { (l, u, p) in
      guard let property = Unicode.GraphemeBreakProperty(p) else {
        return nil
      }
      let scalars = Unicode.Scalar(hex: l)! ... Unicode.Scalar(hex: u ?? l)!
      return (scalars, property)
    }
}
```

This code reads from left to right and doesn't require any hard-coded indices. `Regex` is generic over its captures, which the compiler infers from the capturing groups in the literal:

```swift
let regex = /([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s*;\s(\w+).*/
print(type(of: regex))
// Prints Regex<(Substring, Substring?, Substring)>
```

> ***Note**: The type of the second capture, the end of the scalar range, is optional. This is because the corresponding capture group in the regex is optional. (If the capturing group was repeated using a `*` or `+` quantifier, it would  correspond to a lazy collection.)*

Strongly typed captures make it more convenient and safer to post-process match results, e.g. enabling the use of tuple destructuring and the nil-coalescing operator in `graphemeBreakPropertyData`.

Regular expressions are compact, powerful, and often fast. Their syntax is _familiar_ and _ubiquitous_. Though regexes come in different flavors, knowledge and patterns acquired in one tool (e.g. Perl) can often be applied in another (e.g. Xcode). An important goal of adding regular expressions to Swift is to facilitate this kind of reuse.

### From `Regex` to `Pattern`

Regular expressions originated for use in Unix command-line arguments and text editor search fields because they are very terse, representing in a single line what otherwise would be an entire program. Due to this lineage, regular expression syntax has a few disadvantages, especially when used within a general-purpose programming language:

- The terse syntax can be hard to remember (does `\w` mean "word" or "whitespace"?) and difficult to read (the `..` and `;` in the example regex are obfuscated by the metacharacters).
- The lack of library support encourages reinventing the wheel—simplistic regexes are commonly misused to parse deceptively complex formats like dates and currency, when rich libraries of sophisticated parsers already exist (e.g. Foundation's `FormatStyle`).
- Regular expressions occupy an awkward middle ground of being too powerful to compose together, but not powerful enough to recognize recursive structures (contrast with [PEGs][peg]). Extensions such as back-references catapult matching to being [NP-complete][regex-np], yet they still cannot be used to write parsers.

Swift prizes clarity over terseness. Regular expressions are great for simple matching, but as they grow in complexity we want to be able to bring the full power of Swift and its libraries to bear.

### `Pattern` Builder

The downsides of regular expressions motivate a more versatile result builder syntax for declaring a `Pattern`:

```swift
func graphemeBreakPropertyData(
  forLine line: String
) -> (scalars: ClosedRange<Unicode.Scalar>, property: Unicode.GraphemeBreakProperty)? {
  line.match {
    OneOrMore(.hexDigit).capture { Unicode.Scalar(hex: $0) }

    Optionally {
      ".."
      OneOrMore(.hexDigit).capture { Unicode.Scalar(hex: $0) }
    }

    OneOrMore(.whitespace)
    ";"
    OneOrMore(.whitespace)

    OneOrMore(.word).capture(GraphemeBreakProperty.init)

    Repeat(.anyCharacter)
  }?.captures.map { (lower, upper, property) in
    let scalars = lower ... (upper ?? lower)
    return (scalars, property)
  }
}
```

- Character classes and quantifiers are spelled out, making them more readable and discoverable via code completion.
- String literals make punctuation matching simple and clear: the two dots and the semicolon are critical parts of our format and they stand out inside literals.
- Capture groups can be processed inline, improving locality and strong typing. Compare `Pattern<(Unicode.Scalar, Unicode.Scalar?, GraphemeBreakProperty)>` vs. `Regex<(Substring, Substring?, Substring)>`. *(Inferring the generic argument of `Pattern` from the capturing groups in the result builder will require language improvements.)*
- Failure to construct a `Unicode.Scalar` or `GraphemeBreakProperty` will exit matching early, just like in consumer-pattern code.

Sophisticated features like inline capture group processing feel right at home with the result builder syntax _because it’s all just regular Swift code_—it isn't nearly as natural to try to force this kind of functionality into the regex literal.

Consider the last capture group that uses `GraphemeBreakProperty.init`. `GraphemeBreakProperty` is defined as:

```swift
enum GraphemeBreakProperty: UInt32 {
  case control = 0
  case extend = 1
  case prepend = 2
  case spacingMark = 3
  case extendedPictographic = 4

  init?(_ str: String) {
    switch str {
    case "Extend":
      self = .extend
    case "Control", "CR", "LF":
      self = .control
    case "Prepend":
      self = .prepend
    case "SpacingMark":
      self = .spacingMark
    case "Extended_Pictographic":
      self = .extendedPictographic
    default:
      return nil
    }
  }
}
```

If `GraphemeBreakProperty.init` returns `nil`, the match fails. This is really convenient, since the table includes property names we want to ignore. To get the same level of checking with a traditional regex, we would have had to duplicate all the property names into an alternation. Since capture processing participates in pattern matching (i.e. it can signal a match failure), it can be used to prune the search space early, which is an advantage over post-processing the results of a traditional regex.

This kind of composition is incredibly powerful. `Pattern` supports the interpolation of a wide variety of sophisticated existing parsers, like [Foundation's `FormatStyle`s][format-style].

Consider parsing an HTTP header:

```http
HTTP/1.1 200 OK
Connection: close
Proxy-Connection: close
Via: HTTP/1.1 localhost (IBM-PROXY-WTE)
Date: Thu, 02 Sep 2021 18:05:45 GMT
Server: Apache
X-Frame-Options: SAMEORIGIN
Strict-Transport-Security: max-age=15768000
Last-Modified: Thu, 02 Sep 2021 17:54:18 GMT
Accept-Ranges: bytes
Content-Length: 6583
Content-Type: text/html; charset=UTF-8
```

We can extract the HTTP status code, date, and content type with the following pattern:

```swift
let match = header.match {
  Group {
    "HTTP/"
    Double.FormatStyle()
    Int.FormatStyle().capture()
    OneOrMore(.letter)
    Newline()
  }
  .skipWhitespace

  Repeating {
    Alternation {
      Group {
        "Date: "
        Date.FormatStyle.rfc1123.capture { HTTPHeaderField.date($0) }
        Newline()
      }
      Group {
        "Content-Type: "
        MimeType.FormatStyle().capture { HTTPHeaderField.contentType($0) }
        Newline()
      }
      Group {
        /[-\w]+: .*/
        Newline()
      }
    }
  }
}
.caseInsensitive

print(type(of: match))
// Prints (Int, [HTTPHeaderField])?
```

### Do we want _both_ `Pattern` and `Regex`?

Yes!

`Pattern` uses a more versatile syntax (just regular Swift code!) and supports matching more complex languages than `Regex`. But `Pattern` can't compete with the familiarity and ubiquity of traditional regular expression syntax. `Regex` literals work especially well in conjunction with API such as collection algorithms presented below.

We think `Pattern` and `Regex` can complement one another by:

- Allowing the use of `Regex` literals within `Pattern` builders, alongside a rich library of off the shelf parsers. This will let folks choose succinct expressions when they want, but still nudge them towards more powerful and general constructs.
- Adding a refactor action to transform `Regex` literals into `Pattern` builders. This allows rapid prototyping using `Regex` literals with an easy off-ramp to something more maintainable and powerful.

### Collection Algorithms

We intended to extend and add generic [consumer and searcher][consumer-searcher] algorithms to the standard library for operating over collections using patterns or regexes.

Consider `contains`, which today can only check for the presence of a single `Element`:

```swift
let str = "Hello, World!"
str.contains("Hello") // error: cannot convert value of type 'String' to expected argument type 'String.Element' (aka 'Character')
```

As part of this effort, we'll be adding a variant of `contains` that invokes a "searcher" of the same element type:

```swift
// The below are all equivalent
str.contains("Hello") || str.contains("Goodbye")
str.contains(/Hello|Goodbye/)
str.contains {
  Alternation {
    "Hello"
    "Goodbye"
  }
}
```

The kinds of algorithms that can be added or enhanced by consumers and searchers include:
- `firstRange(of:)`, `lastRange(of:)`, `allRanges(of:)`, `contains(_:)`
- `split(separator:)`
- `trim(_:)`, `trimPrefix(_:)`, `trimSuffix(_:)`
- `replaceAll(_:with:)`, `removeAll(_:)`, `moveAll(_:to:)`
- `match(_:)`, `allMatches(_:)`

## Future Work

The Swift operator `~=` allows libraries to extend syntactic pattern matching by returning whether matching succeeded or not. An [enhancement to this][syntax] would allow libraries to produce a result as part of a _destructuring_ pattern match, allowing patterns and regexes to be used inside `case` syntax and directly bind their captures to variables.

```swift
func parseField(_ field: String) -> ParsedField {
  switch field {
  case let text <- /#\s?(.*)/:
    return .comment(text)
  case let (l, u) <- /([0-9A-F]+)(?:\.\.([0-9A-F]+))?/:
    return .scalars(Unicode.Scalar(hex: l) ... Unicode.Scalar(hex: u ?? l))
  case let prop <- GraphemeBreakProperty.init:
    return .property(prop)
  }
}
```

## The "Big Picture"

"String processing" as presented above is touching on something broader: processing content that might span from simple binary data (`UInt8`) to semantics-rich entities (`Character` or even generic over `Equatable`). Such content may be readily available for fully-synchronous processing, derived in contiguous chunks from an asynchronous source, or we may even be reacting live to some incoming stream of ephemeral content from a fully asynchronous source.

The "big picture" is a complex multi-dimensional (and non-orthogonal!) design space that we need some way to talk and reason about to make progress. Swift is source- and ABI-stable, meaning decisions we make now can positively or negatively impact the ability of Swift to meet future needs. Thinking ahead about different areas of this design space can help us avoid painting ourselves into a corner and can help guide us toward more general, broadly-useful approaches.

For musings on this topic, see [The Big Picture][big-picture].


[grapheme-breaking-pr]: https://github.com/apple/swift/pull/37864
[ucd-processing-script]: https://github.com/apple/swift/pull/37864/files#diff-d3587c4a489cae08c4d8a8fb38379a7b74198a07c9195d6d1f7c0c1cc639dd4e
[grapheme-break-table]: http://www.unicode.org/Public/13.0.0/ucd/auxiliary/GraphemeBreakProperty.txt
[regex-wikipedia]: https://en.wikipedia.org/wiki/Regular_expression
[big-picture]: BigPicture.md
[consumers]: https://github.com/apple/swift-evolution-staging/blob/976ea3a81813f06ec11f00550d4e83f340cf2f7e/Sources/CollectionConsumerSearcher/Eat.swift
[formal-language]: https://en.wikipedia.org/wiki/Formal_language
[consumer-searcher]: https://forums.swift.org/t/prototype-protocol-powered-generic-trimming-searching-splitting/29415
[regular-language]: https://en.wikipedia.org/wiki/Regular_language
[peg]: https://en.wikipedia.org/wiki/Parsing_expression_grammar
[regex-np]: https://perl.plover.com/NPC/NPC-3SAT.html
[syntax]: https://gist.github.com/milseman/bb39ef7f170641ae52c13600a512782f#pattern-matching-through-conformance-to-pattern
[format-style]: https://developers.apple.com/videos/play/wwdc2021/10109/
[ishan]: https://github.com/ishantheperson/swift/tree/ishan/regex
