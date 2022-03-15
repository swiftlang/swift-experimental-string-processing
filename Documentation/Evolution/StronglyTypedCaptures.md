# Strongly Typed Regex Captures

Authors: [Richard Wei](https://github.com/rxwei), [Kyle Macomber](https://github.com/kylemacomber)

## Revision history

- **v1**
    - [Initial pitch](https://forums.swift.org/t/pitch-strongly-typed-regex-captures/53391).
- **v2**
    - Includes entire match in `Regex`'s generic parameter.
    - Fixes Quantification and Alternation capture types to be consistent with traditional back reference numbering.
- **v3**
    - Updates quantifiers to not save the history.
    - Updates `capture` method to type `Capture`.
    - Adds `Regex<Output>.Match` indirection.

## Introduction

Capturing groups are a commonly used component of regular expressions as they allow the programmer to extract information from matched input. A capturing group collects multiple characters together as a single unit that can be [backreferenced](https://www.regular-expressions.info/backref.html) within the regular expression and accessed in the result of a successful match. For example, the following regular expression contains the capturing groups `(cd*)` and `(ef)`.

```swift
// Regex literal syntax:
let regex = /ab(cd*)(ef)gh/
// => `Regex<(Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let regex = Regex {
//         "ab"
//         Capture {
//             "c"
//             ZeroOrMore("d")
//         }
//         Capture("ef")
//         "gh"
//     }

if let result = "abcddddefgh".firstMatch(of: regex) {
    print(result.match) // => ("abcddddefgh", "cdddd", "ef")
}
```

>_**Note:** The `Regex` type includes, and `firstMatch(of:)` returns, the entire match as the "0th element"._

We introduce a generic type `Regex<Match>`, which treats the capture types as part of a regular expression's type information for clarity, type safety, and convenience. As we explore a fundamental design aspect of the regular expression feature, this pitch discusses the following topics:

- A type definition of the generic type `Regex<Match>` and `firstMatch(of:)` method.
- Inference and composition of capture types in regular expression literals and the forthcoming result builder syntax.
- New language features which this design may require.

The focus of this pitch is the structural properties of capture types and how regular expression patterns compose to form new capture types. The semantics of string matching, its effect on the capture types (i.e. `UnicodeScalarView.SubSequence` or `Substring`), and the result builder syntax will be discussed in future pitches.

For background on Declarative String Processing, see related topics:
- [Declarative String Processing Overview](https://forums.swift.org/t/declarative-string-processing-overview/52459)
- [Regular Expression Literals](https://forums.swift.org/t/pitch-regular-expression-literals/52820)
- [Character Classes for String Processing](https://forums.swift.org/t/pitch-character-classes-for-string-processing/52920)

## Motivation

Across a variety of programming languages, many established regular expression libraries present a collection of captured content to the caller upon a successful match [[1](https://developer.apple.com/documentation/foundation/nsregularexpression)][[2](https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.capture)]. However, to know the structure of captured contents, programmers often need to carefully read the regular expression or run the regular expression on some input to find out. Because regular expressions are oftentimes statically available in the source code, there is a missed opportunity to use generics to present captures as part of type information to the programmer, and to leverage the compiler to infer the type of captures based on a regular expression literal. As we propose to introduce declarative string processing capabilities to the language and the Standard Library, we would like to explore a type-safe approach to regular expression captures.

## Proposed solution

We introduce a generic structure `Regex<Match>` whose generic parameter `Output` includes the match and any captures, using tuples to represent multiple and nested captures.

```swift
let regex = /ab(cd*)(ef)gh/
// => Regex<(Substring, Substring, Substring)>
if let result = "abcddddefgh".firstMatch(of: regex) {
  print(result.match) // => ("abcddddefgh", "cdddd", "ef")
}
```

During type inference for regular expression literals, the compiler infers the type of `Output` from the content of the regular expression. The same will be true for the result builder syntax, except that the type inference rules are expressed as method declarations in the result builder type.

Because much of the motivation behind providing regex literals in Swift is their familiarity, a top priority of this design is for the result of calling `firstMatch(of:)` with a regex to align with the traditional numbering of backreferences to capture groups, which start at `\1`.

```swift
let regex = /ab(cd*)(ef)gh/
if let result = "abcddddefgh".firstMatch(of: regex) {
  print((result.1, result.2)) // => ("cdddd", "ef")
}
```

Quantifiers (`*`, `+`, and `?`) and alternations (`|`) wrap each capture inside them in `Array` or `Optional`. These structures can be nested, so a capture which is inside multiple levels of quantifiers or alternations will end up with a type like `[Substring?]?`. To ensure that backreference numbering and tuple element numbering match, each capture is separately wrapped in the structure implied by the quantifiers and alternations around it, rather than wrapping tuples of adjacent captures in the structure.

```swift
let regex = /ab(?:c(d)*(ef))?gh/
if let result = "abcddddefgh".firstMatch(of: regex) {
  print((result.1, result.2)) // => (Optional(["d","d","d","d"]), Optional("ef"))
}
```

## Detailed design

### `Regex` type

`Regex` is a structure that represents a regular expression. `Regex` is generic over an unconstrained generic parameter `Output`. Upon a regex match, the entire match and any captured values are available as part of the result.

```swift
public struct Regex<Match>: RegexProtocol, ExpressibleByRegexLiteral {
    ...
}
```

> ***Note**: Semantic-level switching (i.e. matching grapheme clusters with canonical equivalence vs Unicode scalar values) is out-of-scope for this pitch, but handling that will likely introduce constraints on `Output`. We use an unconstrained generic parameter in this pitch for brevity and simplicity. The `Substring`s we use for illustration throughout this pitch are created on-the-fly; the actual memory representation uses `Range<String.Index>`. In this sense, the `Output` generic type is just an encoding of the arity and kind of captured content.*

### `firstMatch(of:)` method

The `firstMatch(of:)` method returns a `Substring` of the first match of the provided regex in the string, or `nil` if there are no matches. If the provided regex contains captures, the result is a tuple of the matching string and any captures (described more below).

```swift
extension String {
    public func firstMatch<R: RegexProtocol>(of regex: R) -> Regex<R.Output>.Match?
}
```

This signature is consistent with the traditional numbering of backreferences to capture groups starting at `\1`. Many regex libraries make the entire match available at position `0`. We propose to do the same in order to align the tuple index numbering with the regex backreference numbering:

```swift
let scalarRangePattern = /([0-9a-fA-F]+)(?:\.\.([0-9a-fA-F]+))?/
// Positions in result: 0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                      1 ^~~~~~~~~~~~~~     2 ^~~~~~~~~~~~~~
if let match = line.firstMatch(of: scalarRangePattern) {
    print((match.0, match.1, match.2)) // => ("007F..009F", "007F", "009F")
}
```

> ***Note**: Additional features like efficient access to the matched ranges are out-of-scope for this pitch, but will likely mean returning a nominal type from `firstMatch(of:)`. In this pitch, the result type of `firstMatch(of:)` is a tuple of `Substring`s for simplicity and brevity. Either way, the developer experience is meant to be light-weight and tuple-y. Any nominal type would likely come with dynamic member lookup for accessing captures by index (i.e. `.0`, `.1`, etc.) and name.*

### Capture types

In this section, we describe the inferred capture types for regular expression patterns and how they compose.

By default, a regular expression literal has type `Regex`. Its generic argument `Output` can be viewed as a tuple of the entire matched substring and any captures.

```txt
(WholeMatch, Captures...)
             ^~~~~~~~~~~
             Capture types
```

When there are no captures, `Output` is just the entire matched substring, for example:

```swift
let identifier = /[_a-zA-Z]+[_a-zA-Z0-9]*/  // => `Regex<Substring>`

// Equivalent result builder syntax:
//     let identifier = Regex {
//         OneOrMore(/[_a-zA-Z]/)
//         ZeroOrMore(/[_a-zA-Z0-9]/)
//     }
```

This falls out of Swift's normal type system rules, which treat a 1-tuple as synonymous with the element itself.

#### Capturing group: `(...)`

A capturing group saves the portion of the input matched by its contained pattern. The capture type of a leaf capturing group is `Substring`.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)/
// => `Regex<(Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakLowerBound = Capture(OneOrMore(.hexDigit))
```

#### Concatenation: `abc`

A concatenation's capture types are a concatenation of the capture types of its underlying patterns, ignoring any underlying patterns with no captures.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)\.\.[0-9a-fA-F]+/
// => `Regex<(Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakLowerBound = Regex {
//         Capture(OneOrMore(.hexDigit))
//         ".."
//         OneOrMore(.hexDigit)
//     }

let graphemeBreakRange = /([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)/
// => `Regex<(Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakRange = Regex {
//         Capture(OneOrMore(.hexDigit))
//         ".."
//         Capture(OneOrMore(.hexDigit))
//     }
```

#### Named capturing group: `(?<name>...)`

A named capturing group includes the capture's name as the label of the tuple element.

```swift
let graphemeBreakLowerBound = /(?<lower>[0-9a-fA-F]+)\.\.[0-9a-fA-F]+/
// => `Regex<(Substring, lower: Substring)>`

let graphemeBreakRange = /(?<lower>[0-9a-fA-F]+)\.\.(?<upper>[0-9a-fA-F]+)/
// => `Regex<(Substring, lower: Substring, upper: Substring)>`
```

#### Non-capturing group: `(?:...)`

A non-capturing group's capture types are the same as its underlying pattern's. That is, it does not capture anything by itself, but transparently propagates its underlying pattern's captures.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)(?:\.\.([0-9a-fA-F]+))?/
// => `Regex<(Substring, Substring, Substring?)>`

// Equivalent result builder syntax:
//     let graphemeBreakLowerBound = Regex {
//         Capture(OneOrMore(.hexDigit))
//         Optionally {
//             ".."
//             Capture(OneOrMore(.hexDigit))
//         }
//     }
```

#### Nested capturing group: `(...(...))`

When a capturing group is nested within another capturing group, they count as two distinct captures in the order their left parenthesis first appears in the regular expression literal. This is consistent with traditional regex backreference numbering.

```swift
let graphemeBreakPropertyData = /(([0-9a-fA-F]+)(\.\.([0-9a-fA-F]+)))\s*;\s(\w+).*/
// Positions in result:        0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                             1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    5 ^~~~~
//                                            3 ^~~~~~~~~~~~~~~~~~~~
//                              2 ^~~~~~~~~~~~~~   4 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring, Substring, Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let graphemeBreakPropertyData = Regex {
//         Capture {
//             Capture(OneOrMore(.hexDigit)) // (2)
//             Capture {
//                 ".."
//                 Capture(OneOrMore(.hexDigit)) // (4)
//             } // (3)
//         } // (1)
//         Repeat(.whitespace)
//         ";"
//         CharacterClass.whitespace
//         Capture(OneOrMore(.word)) // (5)
//         Repeat(.any)
//     }

let input = "007F..009F   ; Control"
// Match result for `input`:
// ("007F..009F   ; Control", "007F..009F", "007F", "..009F", "009F", "Control")
```

#### Quantification: `*`, `+`, `?`, `{n}`, `{n,}`, `{n,m}`

A quantifier may wrap its underlying pattern's capture types in `Optional`s. Quantifiers whose lower bound is zero produces an `Optional`. The kind of quantification, i.e. greedy vs reluctant vs possessive, is irrelevant to determining the capture type.

| Syntax  | Description         | Capture type                             |
|---------|---------------------|------------------------------------------|
| `*`     | 0 or more           | `Optional`s of sub-pattern capture types |
| `+`     | 1 or more           | Sub-pattern capture types                |
| `?`     | 0 or 1              | `Optional`s of sub-pattern capture types |
| `{n}`   | Exactly _n_         | Sub-pattern capture types                |
| `{n,m}` | Between _n_ and _m_ | `Optional`s of sub-pattern capture types |
| `{n,}`  | _n_ or more         | `Optional`s of Sub-pattern capture types |

```swift
/([0-9a-fA-F]+)+/
// => `Regex<(Substring, Substring)>`

// Equivalent result builder syntax:
//     OneOrMore {
//         Capture(OneOrMore(.hexDigit))
//     }

/([0-9a-fA-F]+)*/
// => `Regex<(Substring, Substring?)>`

// Equivalent result builder syntax:
//     ZeroOrMore {
//         Capture(OneOrMore(.hexDigit))
//     }

/([0-9a-fA-F]+)?/
// => `Regex<(Substring, Substring?)>`

// Equivalent result builder syntax:
//     Optionally {
//         Capture(OneOrMore(.hexDigit))
//     }

/([0-9a-fA-F]+){3}/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat(count: 3) {
//         Capture(OneOrMore(.hexDigit))
//     )

/([0-9a-fA-F]+){3,5}/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat(3...5) {
//         Capture(OneOrMore(.hexDigit))
//     )

/([0-9a-fA-F]+){3,}/
// => `Regex<(Substring, [Substring])>`

// Equivalent result builder syntax:
//     Repeat(3...) {
//         Capture(OneOrMore(.hexDigit))
//     )

let multipleAndNestedOptional = /(([0-9a-fA-F]+)\.\.([0-9a-fA-F]+))?/
// Positions in result:        0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                             1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                              2 ^~~~~~~~~~~~~~  3 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?, Substring?)>`

// Equivalent result builder syntax:
//     let multipleAndNestedOptional = Regex {
//         Capture {
//             Optionally {
//                 Capture(OneOrMore(.hexDigit))
//                 ".."
//                 Capture(OneOrMore(.hexDigit))
//             }
//         }
//     }

let multipleAndNestedQuantifier = /(([0-9a-fA-F]+)\.\.([0-9a-fA-F]+))+/
// Positions in result:          0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                               1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                                2 ^~~~~~~~~~~~~~  3 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring, Substring, Substring)>`

// Equivalent result builder syntax:
//     let multipleAndNestedQuantifier = Regex {
//         OneOrMore {
//             Capture(OneOrMore(.hexDigit))
//             ".."
//             Capture(OneOrMore(.hexDigit))
//         }
//     }
```

Capturing collections of repeated captures like this is consistent with most regular expression implementations, which only provide access to the _last_ match of a repeated capture group. For example, Python only captures the last group in this dash-separated string:

```python
rep = re.compile('(?:([0-9a-fA-F]+)-?)+')
match = rep.match("1234-5678-9abc-def0")
print(match.group(1))
# Prints "def0"
```

Capturing only the last occurrences is the most memory-efficient behavior. For consistency and efficiency, we chose this behavior and its corresponding type.

```swift
let pattern = /(?:([0-9a-fA-F]+)-?)+/
if let result = "1234-5678-9abc-def0".firstMatch(of: pattern) {
    print(result.1)
}
// Prints "def0"
```

As a future direction, a way to save the capture history could be useful. We could introduce some way of opting into this behavior.

#### Alternation: `a|b`

Alternations are used to match one of multiple patterns. An alternation wraps its underlying patterns' capture types in an `Optional`s and concatenates them together, first to last.

```swift
let numberAlternationRegex = /([01]+)|[0-9]+|([0-9a-fA-F]+)/
// Positions in result:     0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                          1 ^~~~~~~      2 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?)>`

// Equivalent result builder syntax:
//     let numberAlternationRegex = Regex {
//         ChoiceOf {
//             Capture(OneOrMore(.binaryDigit))
//             OneOrMore(.decimalDigit)
//             Capture(OneOrMore(.hexDigit))
//         }
//     }

let scalarRangeAlternation = /([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)|([0-9a-fA-F]+)/
// Positions in result:     0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                          1 ^~~~~~~~~~~~~~  2 ^~~~~~~~~~~~~~
//                                                           3 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?, Substring?)>

// Equivalent result builder syntax:
//     let scalarRangeAlternation = Regex {
//         ChoiceOf {
//             Group {
//                 Capture(OneOrMore(.hexDigit))
//                 ".."
//                 Capture(OneOrMore(.hexDigit))
//             }
//             Capture(OneOrMore(.hexDigit))
//         }
//     }

let nestedScalarRangeAlternation = /(([0-9a-fA-F]+)\.\.([0-9a-fA-F]+))|([0-9a-fA-F]+)/
// Positions in result:           0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                                1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
//                                 2 ^~~~~~~~~~~~~~  3 ^~~~~~~~~~~~~~
//                                                                   4 ^~~~~~~~~~~~~~
// => `Regex<(Substring, Substring?, Substring?, Substring?, Substring?)>

// Equivalent result builder syntax:
//     let scalarRangeAlternation = Regex {
//         ChoiceOf {
//             Capture {
//                 ChoiceOf(OneOrMore(.hexDigit))
//                 ".."
//                 ChoiceOf(OneOrMore(.hexDigit))
//             }
//             Capture(OneOrMore(.hexDigit))
//         }
//     }
```

### Dynamic captures

So far, we have explored offering static capture types for using a regular expression that is available in source code. Meanwhile, we would like to apply Swift's string processing capabilities to fully dynamic use cases, such as matching a string using a regular expression obtained at runtime.

To support dynamism, we introduce a new type, `AnyRegexOutput` that represents a tree of captures, and add a `Regex` initializer that accepts a string and produces `Regex<AnyRegexOutput>`. `AnyRegexOutput` can also be used to retrofit regexes with strongly typed captures to preexisting use sites of `Regex<AnyRegexOutput>`.
  
```swift
public struct AnyRegexOutput: Equatable, RandomAccessCollection {
  public var match: Substring? { get }
  public var range: Range<String.Index> { get }
  public var count: Int { get }
  public subscript(name: String) -> Substring { get }
  public subscript(position: Int) -> Substring { get }
  ...
}

extension Regex.Match where Output == AnyRegexOutput {
  /// Creates a regex dynamically from text.
  public init(_ text: String) throws where Output == AnyRegexOutput

  /// Creates a type-erased match from an existing one.
  public init<OtherOutput>(_ other: Regex<OtherOutput>.Match)
}
```

Example usage:

```swift
let regex = readLine()! // (\w*)(\d)+z(\w*)?
let input = readLine()! // abcd1234xyz
print(input.firstMatch(of: regex)?.1)
// [
//     "abcd",
//     "4",
//     .some("xyz")
// ]
```

## Effect on ABI stability

None.  This is a purely additive change to the Standard Library.

## Effect on API resilience

None.  This is a purely additive change to the Standard Library.

## Alternatives considered

### Lazy collections instead of arrays of substrings

For quantifiers that produce an array, it is arguable that a lazy collection based on matched ranges could minimize reference counting operations on `Substring` and reduce allocations.

```swift
let regex = /([a-z])+/
// => `Regex<(Substring, CaptureCollection<Substring>)>`

// `CaptureCollection` implemented as... 
public struct CaptureCollection<Captures>: BidirectionalCollection {
    private var ranges: [ClosedRange<String.Index>]
    ...
}
```

However, we believe the use of arrays in capture types would make a much cleaner type signature.
  
### Homogeneous tuples for exact-count quantification

For exact-count quantifications, e.g. `[a-z]{5}`, it would slightly improve type safety to make its capture type be a homogeneous tuple instead of an array, e.g. `(5 x Substring)` as pitched in [Improved Compiler Support for Large Homogenous Tuples](https://forums.swift.org/t/pitch-improved-compiler-support-for-large-homogenous-tuples/49023).

```swift
/[a-z]{5}/     // => Regex<(Substring, (5 x Substring))> (exact count)
/[a-z]{5, 8}/  // => Regex<(Substring, [Substring])>     (bounded count)
/[a-z]{5,}/    // => Regex<(Substring, [Substring])>     (lower-bounded count)
```

However, this would cause an inconsistency between exact-count quantification and bounded quantification. We believe that the proposed design will result in fewer surprises as we associate the `{...}` quantifier syntax with `Array`.

### `Regex<Captures>` instead of `Regex<Output>`

In the initial version of this pitch, `Regex` was _only_ generic over its captures and `firstMatch(of:)` was responsible for flattening together the match and captures into a tuple.

```swift
extension String {
    public func firstMatch<R: RegexProtocol, C...>(of regex: R)
        -> (Substring, C...)? where R.Captures == (C...)
}

// Expands to:
//     extension String {
//         func firstMatch<R: RegexProtocol>(of regex: R)
//             -> Substring? where R.Captures == ()
//         func firstMatch<R: RegexProtocol, C1>(of regex: R)
//             -> (Substring, C1)? where R.Captures == (C1)
//         func firstMatch<R: RegexProtocol, C1, C2>(of regex: R)
//             -> (Substring, C1, C2)? where R.Captures == (C1, C2)
//         ...
//     }
```

For simple regular expressions this had the benefit of aligning the generic signature more obviously with the captures in the regex.

```swift
let regex = /ab(cd*)(ef)gh/
// => `Regex<(Substring, Substring)>`
```

However, it came with a number of (not necessarily insurmountable) open questions:

- Will variadic generic tuple splatting preserve element labels?
- Will variadic generic tuple splatting eliminate `Void`s? _(We don't want `firstMatch(of:)` to return `(Substring, Void)` for a regex with no captures)._
- Will we be able to add [single-element labeled tuples](https://forums.swift.org/t/single-element-labeled-tuples/9797)? _(This would be needed to preserve the name of a capture in a regex with a single named capturing group.)_
- What should be the type of `Captures` for a regex with no captures (e.g. `Void` or `Never` or something else)?

Given all of this, it seems simpler and more pragmatic to make `Regex` generic over both the match and the captures.

### Structured rather than flat captures

This pitch proposes inferring capture types in such a way as to align with the traditional numbering of backreferences. This is because much of the motivation behind providing regex literals in Swift is their familiarity.

If we decided to deprioritize this motivation, there are opportunities to infer safer, more ergonomic, and arguably more intuitive types for captures.

For example, to be consistent with traditional regex backreferences quantifications of multiple or nested captures had to produce parallel arrays rather than an array of tuples.

```swift
/(?:(?<lower>[0-9a-fA-F]+)\.\.(?<upper>[0-9a-fA-F]+))+/
// Flat capture types:
// => `Regex<(Substring, lower: [Substring], upper: [Substring])>`

// Structured capture types:
// => `Regex<(Substring, [(lower: Substring, upper: Substring)])>`
```

The structured capture types are safer because the type system encodes that there are an equal number of `lower` and `upper` hex numbers. It's also more convenient because you're likely to be processing `lower` and `upper` in parallel (e.g. to create ranges).

Similarly, alternations of multiple or nested captures produces flat optionals rather than a structured alternation type.

```swift
/([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)|([0-9a-fA-F]+)/
// Flat capture types:
// => `Regex<(Substring, Substring?, Substring?, Substring?)>`

// Structured capture types:
// => `Regex<(Substring, Alternation<((Substring, Substring), Substring)>)>`
```

The structured capture types are safer because the type system encodes which options in the alternation of mutually exclusive. It'd also be much more convenient if, in the future, `Alternation` could behave like an enum, allowing exhaustive switching over all the options.

It's possible to derive the flat type from the structured type (but not vice versa), so `Regex` could be generic over the structured type and `firstMatch(of:)` could return a result type that vends both.

```swift
extension String {
    struct MatchResult<R: RegexProtocol> {
        var flat: R.Output.Flat { get }
        var structured: R.Output { get }
    }
    func firstMatch<R>(of regex: R) -> MatchResult<R>?
}
```

This is cool, but it adds extra complexity to `Regex` and it isn't as clear because the generic type no longer aligns with the traditional regex backreference numbering. Because the primary motivation for providing regex literals in Swift is their familiarity, we think the consistency of the flat capture types trumps the added safety and ergonomics of the structured capture types.

We think the calculus probably flips in favor of a structured capture types for the result builder syntax, for which familiarity is not as high a priority.
