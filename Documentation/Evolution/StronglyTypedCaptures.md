# Strongly Typed Regex Captures

Authors: [Richard Wei](https://github.com/rxwei), [Kyle Macomber](https://github.com/kylemacomber)

## Revision history

- **v1**
    - Initial pitch.
- **v2**
    - `Regex<Captures>` includes entire match as first generic parameter.

## Introduction

Capturing groups are a commonly used component of regular expressions as they
allow the programmer to extract information from matched input. A capturing
group collects multiple characters together as a single unit that can be
[backreferenced](https://www.regular-expressions.info/backref.html) within the
regular expression and accessed in the result of a successful match. For
example, the following regular expression contains the capturing groups `(cd*)`
and `(ef)`.

```swift
// Regex literal syntax:
let regex = /ab(cd*)(ef)gh/
// => `Regex<(Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let regex = Pattern {
//         "ab"
//         Group {
//             "c"
//             Repeat("d")
//         }.capture()
//         "ef".capture()
//         "gh"
//     }

if let match = "abcddddefgh".firstMatch(of: regex) {
    print(match) // => ("abcddddefgh", "cdddd", "ef")
}
```

>***Note:** The `Regex` type includes, and `firstMatch(of:)` returns, the entire
match as the "0th capture".*

We introduce a generic type `Regex<Captures>`, which treats the type of captures
as part of a regular expression's type information for clarity, type safety, and
convenience. As we explore a fundamental design aspect of the regular expression
feature, this pitch discusses the following topics:

- A type definition of the generic type `Regex<Captures>` and `firstMatch(of:)`
  method.
- Capture type inference and composition in regular expression literals and the
  forthcoming result builder syntax.
- New language features which this design may require.

The focus of this pitch is the structural properties of capture types and how
regular expression patterns compose to form new capture types. The semantics of
string matching, its effect on the capture types (i.e.
`UnicodeScalarView.SubSequence` or `Substring`), the result builder syntax, or
the literal syntax will be discussed in future pitches.

For background on Declarative String Processing, see related topics:
- [Declarative String Processing Overview](https://forums.swift.org/t/declarative-string-processing-overview/52459)
- [Regular Expression Literals](https://forums.swift.org/t/pitch-regular-expression-literals/52820)
- [Character Classes for String Processing](https://forums.swift.org/t/pitch-character-classes-for-string-processing/52920)

## Motivation

Across a variety of programming languages, many established regular expression
libraries present captures as a collection of captured content to the caller
upon a successful match
[[1](https://developer.apple.com/documentation/foundation/nsregularexpression)][[2](https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.capture)].
However, to know the structure of captured contents, programmers often need to
carefully read the regular expression or run the regular expression on some
input to find out. Because regular expressions are oftentimes statically
available in the source code, there is a missed opportunity to use generics to
present captures as part of type information to the programmer, and to leverage
the compiler to infer the type of captures based on a regular expression
literal. As we propose to introduce declarative string processing capabilities
to the language and the Standard Library, we would like to explore a type-safe
approach to regular expression captures.

## Proposed solution

We introduce a generic structure `Regex<Captures>` whose generic parameter
`Captures` denotes the type of the captured content of such a regular
expression. With a single generic parameter `Captures`, we make use of tuples to
represent multiple and nested captures.

```swift
let regex = /ab(cd*)(ef)gh/
// => Regex<(Substring, Substring, Substring)>
if let match = "abcddddefgh".firstMatch(of: regex) {
  print(match) // => ("abcddddefgh", "cdddd", "ef")
}
```

During type inference for regular expression literals, the compiler infers the
capture type based on the regular expression's content.  Same for the result
builder syntax, except that the type inference rules are expressed as method
declarations in the result builder type.

Because much of the motivation behind providing regex literals in Swift is their
familiarity, a top priority of this design is for the result of
`firstMatch(of:)` to align with the traditional numbering of backreferences to
capture groups, which start at `\1`.

```swift
let regex = /ab(cd*)(ef)gh/
if let match = "abcddddefgh".firstMatch(of: regex) {
  print((match.1, match.2)) // => ("cdddd", "ef")
}
```

## Detailed design

### `Regex` type

`Regex` is a structure that represents a regular expression. `Regex` is generic
over an unconstrained generic parameter `Captures`. Upon a regex match, the
captured values are available as part of the result.

```swift
public struct Regex<Captures>: RegexProtocol, ExpressibleByRegexLiteral {
    ...
}
```

> ***Note**: Semantic-level switching (i.e. matching grapheme clusters with
canonical equivalence vs Unicode scalar values) is out-of-scope for this pitch,
but handling that will likely introduce constraints on `Captures`. We use an
unconstrained generic parameter in this pitch for brevity and simplicity. The
`Substring`s we use for illustration throughout this pitch are created
on-the-fly; the actual memory representation uses `Range<String.Index>`. In this
sense, the `Captures` generic type is just an encoding of the arity and kind of captured content.*

### `firstMatch(of:)` method

The `firstMatch(of:)` method returns a `Substring` of the first match of the
provided regex in the string, or `nil` if there are no matches. If the provided
regex contains captures, the result is a tuple of the matching string and any
captures (described more below).

```swift
extension String {
    public func firstMatch<R: RegexProtocol>(of regex: R) -> R.Captures?
}
```

This signature is consistent with the traditional numbering of backreferences to
capture groups starting at `\1`. Many regex libraries make the entire match
available as the "0th capture". We propose to do the same in order to align the
tuple index numbering with the regex backreference numbering:

```swift
let scalarRangePattern = /([0-9a-fA-F]+)(?:\.\.([0-9a-fA-F]+))?/
// Positions in result: 0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                      1 ^~~~~~~~~~~     2 ^~~~~~~~~~~
if let match = line.firstMatch(of: scalarRangePattern) {
    print((match.0, match.1, match.2)) // => ("007F..009F", "007F", "009F")
}
```

> ***Note**: Additional features like efficient access to the matched ranges are
out-of-scope for this pitch, but will likely mean returning a nominal type from
`firstMatch(of:)`. In this pitch, the result type of `firstMatch(of:)` is a
tuple of `Substring`s for simplicity and brevity. Either way, the developer
experience is meant to be light-weight and tuple-y. Any nominal type would
likely come with dynamic member lookup for accessing captures by index (i.e.
`.0`, `.1`, etc.) and name.*

### Capture type

In this section, we dive into capture types for regular expression patterns and
how they compose.

By default, a regular expression literal has type `Regex`. Its generic argument
`Captures` is its capture type.

#### Basics

Regular expressions without any capturing groups have type `Regex<Substring>`,
for example:

```swift
let identifier = /[_a-zA-Z]+[_a-zA-Z0-9]*/  // => `Regex<Substring>`

// Equivalent result builder syntax:
//     let identifier = Pattern {
//         OneOrMore(/[_a-zA-Z]/)
//         Repeat(/[_a-zA-Z0-9]/)
//     }
```

#### Capturing group: `(...)`

A `Regex`'s `Captures` type can be viewed as a tuple of the entire matched
substring and any captures.

```txt
(EntireMatch, Captures...)
              ^~~~~~~~~~~
              Capture types
```

When there are no captures, it's the entire matched substring
itself.

A capturing group saves the portion of the input matched by its contained
pattern. Its capture type is `Substring`.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)/
// => `Regex<(Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakLowerBound = OneOrMore(.hexDigit).capture()
```

#### Concatenation: `abc`

A concatenation's `Captures` is a tuple of `Substring` followed by every
pattern's capture type. When there are no capturing groups, the `Captures` is
just `Substring`.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)\.\.[0-9a-fA-F]+/
// => `Regex<(Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakLowerBound = Pattern {
//         OneOrMore(.hexDigit).capture()
//         ".."
//         OneOrMore(.hexDigit)
//     }

let graphemeBreakRange = /([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)/
// => `Regex<(Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakRange = Pattern {
//         OneOrMore(.hexDigit).capture()
//         ".."
//         OneOrMore(.hexDigit).capture()
//     }
```

#### Named capturing group: `(?<name>...)`

A named capturing group's capture type is `Substring`. In its `Captures` type,
the capture type has a tuple element label specified by the capture name.

```swift
let graphemeBreakLowerBound = /(?<lower>[0-9a-fA-F]+)\.\.[0-9a-fA-F]+/
// => `Regex<(Substring, lower: Substring)>`

let graphemeBreakRange = /(?<lower>[0-9a-fA-F]+)\.\.(?<upper>[0-9a-fA-F]+)/
// => `Regex<(Substring, lower: Substring, upper: Substring)>`
```

#### Non-capturing group: `(?:...)`

A non-capturing group's capture type is the same as its underlying pattern's.
That is, it does not capture anything by itself, but transparently propagates
its underlying pattern's captures.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)(?:\.\.([0-9a-fA-F]+))?/
// => `Regex<(Substring, Substring, Substring?)>`

// Equivalent result builder syntax:
//     let graphemeBreakLowerBound = Pattern {
//         OneOrMore(.hexDigit).capture()
//         Optionally {
//             ".."
//             OneOrMore(.hexDigit).capture()
//         }
//     }
```

#### Nested capturing group: `(...(...))`

When capturing group is nested within another capturing group, they count as two
distinct captures in the order their left parenthesis first appears in the
regular expression literal. This is consistent with traditional regex
backreference numbering.

```swift
let graphemeBreakPropertyData = /(([0-9a-fA-F]+)(\.\.([0-9a-fA-F]+)))\s*;\s(\w+).*/
// Positions in result:        1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    5 ^~~~~
//                                            3 ^~~~~~~~~~~~~~~~~~~~
//                              2 ^~~~~~~~~~~~~~   4 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring, Substring, Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakPropertyData = Pattern {
//         Group {
//             OneOrMore(.hexDigit).capture() // (2)
//             Group {
//                 ".."
//                 OneOrMore(.hexDigit).capture() // (4)
//             }.capture() // (3)
//         }.capture() // (1)
//         Repeat(.whitespace)
//         ";"
//         CharacterClass.whitespace
//         OneOrMore(.word).capture() // (5)
//         Repeat(.any)
//     }

let input = "007F..009F   ; Control"
// Match result for `input`:
// ("007F..009F   ; Control", "007F..009F", "007F", "..009F", "009F", "Control")
```


#### Quantification: `*`, `+`, `?`, `{n}`, `{n,}`, `{n,m}`

A quantifier wraps its underlying pattern's capture type in either an `Optional`
or `Array`. Zero-or-one quantification (`?`) produces an `Optional` and all
others produce an `Array`. The kind of quantification, i.e. greedy vs reluctant
vs possessive, is irrelevant to determining the capture type.

| Syntax               | Description           | Capture type                                                  |
| -------------------- | --------------------- | ------------------------------------------------------------- |
| `*`                  | 0 or more             | `Array` of the sub-pattern capture type                       |
| `+`                  | 1 or more             | `Array` of the sub-pattern capture type                       |
| `?`                  | 0 or 1                | `Optional` of the sub-pattern capture type                    |
| `{n}`                | Exactly _n_           | `Array` of the sub-pattern capture type                       |
| `{n,m}`              | Between _n_ and _m_   | `Array` of the sub-pattern capture type                       |
| `{n,}`               | _n_ or more           | `Array` of the sub-pattern capture type                       |

```swift
/([0-9a-fA-F]+)+/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     OneOrMore {
//         OneOrMore(.hexDigit).capture()
//     }

/([0-9a-fA-F]+)*/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat {
//         OneOrMore(.hexDigit).capture()
//     }

/([0-9a-fA-F]+)?/
// => `Regex<(Substring, Substring?)>`

// Equivalent result builder syntax:
//     Optionally {
//         OneOrMore(.hexDigit).capture()
//     }

/([0-9a-fA-F]+){3}/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat(3) {
//         OneOrMore(.hexDigit).capture()
//     )

/([0-9a-fA-F]+){3,5}/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat(3...5) {
//         OneOrMore(.hexDigit).capture()
//     )

/([0-9a-fA-F]+){3,}/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat(3...) {
//         OneOrMore(.hexDigit).capture()
//     )

let multipleAndNestedOptional = /(([0-9a-fA-F]+)\.\.([0-9a-fA-F]+))?/
// Positions in result:        1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                              2 ^~~~~~~~~~~~~~  3 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?, Substring?)>`

// Equivalent result builder syntax:
//     let multipleAndNestedOptional = Pattern {
//         Optionally {
//             OneOrMore(.hexDigit).capture()
//             ".."
//             OneOrMore(.hexDigit).capture()
//         }
//         .capture()
//     }

let multipleAndNestedQuantifier = /(([0-9a-fA-F]+)\.\.([0-9a-fA-F]+))+/
// Positions in result:          1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                                2 ^~~~~~~~~~~~~~  3 ^~~~~~~~~~~~~~
// => `Regex<(Substring, [Substring], [Substring], [Substring])>`

// Equivalent result builder syntax:
//     let multipleAndNestedQuantifier = Pattern {
//         OneOrMore {
//             OneOrMore(.hexDigit).capture()
//             ".."
//             OneOrMore(.hexDigit).capture()
//         }
//         .capture()
//         .unzipped()
//     }
```

Note that capturing collections of repeated captures like this is a departure
from most regular expression implementations, which only provide access to the
_last_ match of a repeated capture group. For example, Python only captures the
last group in this dash-separated string:

```python
rep = re.compile('(?:([0-9a-fA-F]+)-?)+')
match = rep.match("1234-5678-9abc-def0")
print(match.group(1))
# Prints "def0"
```

By contrast, the proposed Swift version captures all four sub-matches:

```swift
let pattern = /(?:([0-9a-fA-F]+)-?)+/
if let match = "1234-5678-9abc-def0".firstMatch(of: pattern) {
    print(match.1)
}
// Prints ["1234", "5678", "9abc", "def0"]
```

We believe that the proposed capture behavior leads to better consistency with
the meaning of these quantifiers. However, the alternative behavior does have
the advantage of a smaller memory footprint because the matching algorithm would
not need to allocate storage for capturing anything but the last match. As a
future direction, we could introduce a variant of quantifiers for this behavior
that the programmer would opt in for memory-critical use cases.

#### Alternation: `a|b`

A quantifier wraps its underlying pattern's capture type in either an `Optional`
or `Array`.

Alternations are used to match one of multiple patterns. An alternation wraps
its underlying pattern's capture type in an `Optional`.

```swift
let numberAlternationRegex = /([01]+)|[0-9]+|([0-9a-fA-F]+)/
// Positions in result:     1 ^~~~~~~      2 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?)>`

// Equivalent result builder syntax:
//     let numberAlternationRegex = Pattern {
//         OneOf {
//             OneOrMore(.binaryDigit).capture()
//             OneOrMore(.decimalDigit)
//             OneOrMore(.hexDigit).capture()
//         }
//         .flattened()
//     }

let scalarRangeAlternation = /([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)|([0-9a-fA-F]+)/
// Positions in result:     1 ^~~~~~~~~~~~~~  2 ^~~~~~~~~~~~~~
//                                                           3 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?, Substring?)>

// Equivalent result builder syntax:
//     let scalarRangeAlternation = Pattern {
//         OneOf {
//             Group {
//                 OneOrMore(.hexDigit).capture()
//                 ".."
//                 OneOrMore(.hexDigit).capture()
//             }
//             OneOrMore(.hexDigit).capture()
//         }
//         .flattened()
//     }

let nestedScalarRangeAlternation = /(([0-9a-fA-F]+)\.\.([0-9a-fA-F]+))|([0-9a-fA-F]+)/
// Positions in result:           1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
//                                 2 ^~~~~~~~~~~~~~  3 ^~~~~~~~~~~~~~
//                                                                   4 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?, Substring?, Substring?)>

// Equivalent result builder syntax:
//     let scalarRangeAlternation = Pattern {
//         OneOf {
//             Group {
//                 OneOrMore(.hexDigit).capture()
//                 ".."
//                 OneOrMore(.hexDigit).capture()
//             }
//             .capture()
//
//             OneOrMore(.hexDigit).capture()
//         }
//         .flattened()
//     }
```

## Effect on ABI stability

None.  This is a purely additive change to the Standard Library.

## Effect on API resilience

None.  This is a purely additive change to the Standard Library.

## Alternatives considered

### Lazy collections instead of arrays of substrings

For quantifiers that produce an array, it is arguable that a lazy collection
based on matched ranges could minimize reference counting operations on
`Substring` and reduce allocations.

```swift
let regex = /([a-z])+/
// => `Regex<Substring, CaptureCollection<Substring>>`

// `CaptureCollection` implemented as... 
public struct CaptureCollection<Captures>: BidirectionalCollection {
    private var ranges: [ClosedRange<String.Index>]
    ...
}
```

However, we believe the use of arrays in capture types would make a much cleaner
type signature.
  
### Homogeneous tuples for exact-count quantification

For exact-count quantifications, e.g. `[a-z]{5}`, it would slightly improve
type safety to make its capture type be a homogeneous tuple instead of an array,
e.g. `(5 x Substring)` as pitched in [Improved Compiler Support for Large Homogenous Tuples](https://forums.swift.org/t/pitch-improved-compiler-support-for-large-homogenous-tuples/49023).

```swift
/[a-z]{5}/     // => Regex<(Substring, (5 x Substring))> (exact count)
/[a-z]{5, 8}/  // => Regex<(Substring, [Substring])>     (bounded count)
/[a-z]{5,}/    // => Regex<(Substring, [Substring])>     (lower-bounded count)
```

However, this would cause an inconsistency between exact-count quantification
and bounded quantification.  We believe that the proposed design will result in
fewer surprises as we associate the `{...}` quantifier syntax with `Array`.

### `Regex<Captures>` instead of `Regex<Match>`

TODO: The previous version of this pitch...

Old definition of Regex and `firstMatch` go here.

### Nested rather than flattened captures

TODO: Including a more ergonomic Alternation. Maybe the default for `Pattern`?

## Future directions

### Dynamic captures

So far, we have explored offering static capture types for using a regular
expression that is available in source code. Meanwhile, we would like to apply
Swift's string processing capabilities to fully dynamic use cases, such as
matching a string using a regular expression obtained at runtime.

To support dynamism, we could introduce a new type, `DynamicCaptures` that
represents a tree of captures, and add a `Regex` initializer that accepts a
string and produces `Regex<Substring, DynamicCaptures>`.
  
```swift
public struct DynamicCaptures: Equatable, RandomAccessCollection {
  var range: Range<String.Index> { get }
  var substring: Substring? { get }
  subscript(name: String) -> DynamicCaptures { get }
  subscript(position: Int) -> DynamicCaptures { get }
}

extension Regex where Captures == DynamicCaptures {
  public init(_ string: String) throws
}
```

Example usage:

```swift
let regex = readLine()! // (\w*)(\d)+z(\w*)?
let input = readLine()! // abcd1234xyz
print(input.firstMatch(of: regex)?.1)
// [
//     "abcd",
//     [
//         "1",
//         "2",
//         "3",
//         "4",
//     ],
//     .some("xyz")
// ]
```
