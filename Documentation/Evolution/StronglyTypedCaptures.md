# Strongly Typed Regex Captures

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Strongly typed regex captures](#strongly-typed-regex-captures)
    - [Introduction](#introduction)
    - [Motivation](#motivation)
    - [Proposed solution](#proposed-solution)
    - [Detailed design](#detailed-design)
        - [`Regex` type](#regex-type)
        - [Capture type](#capture-type)
            - [Basics](#basics)
            - [Capturing group](#capturing-group)
            - [Concatenation](#concatenation)
            - [Named capturing group](#named-capturing-group)
            - [Non-capturing group](#non-capturing-group)
            - [Nested capturing group](#nested-capturing-group)
            - [Quantification](#quantification)
            - [Alternation](#alternation)
    - [Effect on ABI stability](#effect-on-abi-stability)
    - [Effect on API resilience](#effect-on-api-resilience)
    - [Alternatives considered](#alternatives-considered)
        - [Lazy collections instead of arrays of substrings](#lazy-collections-instead-of-arrays-of-substrings)
        - [Homogeneous tuples for exact-count quantification](#homogeneous-tuples-for-exact-count-quantification)
        - [`Never` as empty capture instead of `Void`](#never-as-empty-capture-instead-of-void)
    - [Future directions](#future-directions)
        - [Dynamic captures](#dynamic-captures)
        - [Single-element labeled tuples](#single-element-labeled-tuples)

<!-- markdown-toc end -->

## Introduction

Capturing groups are a commonly used component of regular expressions as they
allow the programmer to extract information from matched input. A capturing
group collects multiple characters together as a single unit that can be
[backreferenced](https://www.regular-expressions.info/backref.html) within the
regular expression and accessed in the result of a successful match. For
example, the following regular expression contains the capturing groups `(cd*)`
and `(ef)`.

```swift
// Literal version.
let regex = /ab(cd*)(ef)gh/
// => `Regex<(Substring, Substring)>`

// Result builder DSL equivalent:
//     let regex = Regex {
//         "ab"
//         Regex {
//             "c"
//             Repeat("d")
//         }.capture()
//         "ef".capture()
//         "gh"
//     }

if let match = "abcddddefgh".firstMatch(of: regex) {
    print(match.captures) // => ("cdddd", "ef")
}
```

We introduce a generic type `Regex<Captures>`, which treats the type of captures
as part of a regular expression's type information for type safety and ease of
use. As we explore a fundamental design aspect of the regular expression
feature, this pitch discusses the following topics.

- A type definition of generic type `Regex<Captures>`.
- Capture type inference and composition in regular expression literals and the
  forthcoming result builder DSL.
- New language features which this design may require.

This focus of this pitch is the structural properties of capture types and how
regular expression patterns compose to form new capture types. The semantics of
string matching, its effect on the capture types (i.e. `UnicodeScalarView` or
`Substring`), the result builder DSL, or the literal syntax will be discussed in
future pitches.

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
represent multiple and nested captures, and are looking to be one of the first
adopters of variadic generics.

```swift
let regex = /ab(cd*)(ef)gh/
// => Regex<(Substring, Substring)>
if let match = "abcddddefgh".firstMatch(of: regex) {
  print(match) // => (match: "abcddddefgh", "cdddd", "ef")
}
```

During type inference for regular expression literals, the compiler infers the
capture type based on the regular expression's content.  Same for the result
builder syntax, except that the type inference rules are expressed as method
declarations in the result builder type.

## Detailed design

### `Regex` type

`Regex` is a structure that represents a regular expression. `Regex` is generic
over an unconstrained generic parameter `Captures`. Upon a regex match, the
captured value is available in type `Captures` in the match result.

```swift
public struct Regex<Captures>: RegexProtocol, ExpressibleByRegexLiteral {
    ...
}
```

### `firstMatch` method

The `firstMatch` method returns a `Substring` of the first match of the provided regex in the string, or `nil` if there are no matches. If the provided regex contains captures, the result is a tuple of the match and the flattened capture type (described more below).

```swift
extension String {
    public func firstMatch<R: RegexProtocol, C...>(of regex: R)
        -> (match: Substring, C...)? where R.Captures == (C...)
}

// Expands to:
//     extension String {
//         func firstMatch<R: RegexProtocol>(of regex: R)
//             -> Substring? where R.Captures == ()
//         func firstMatch<R: RegexProtocol, C1>(of regex: R)
//             -> (match: Substring, C1)? where R.Captures == (C1)
//         func firstMatch<R: RegexProtocol, C1, C2>(of regex: R)
//             -> (match: Substring, C1, C2)? where R.Captures == (C1, C2)
//         ...
//     }
```

This signature is approachable and ergonomic:

- When there are no captures, it degenerates to returning an optional substring that represents the match.

    ```swift
    let line = "007F..009F    ; Control # Cc  [33] <control-007F>..<control-009F>"
    line.firstMatch(/[0-9A-F]+/) // => "007F"
    ```

- It supports convienent tuple destructuring.

    ```swift
    line
        .firstMatch(/([0-9A-F]+)(?:\.\.([0-9A-F]+))?/)
        .flatMap { (_, l, u)
            guard 
                let lower = Int(l, radix: 16),
                let upper = Int(u ?? l, radix: 16),
            else { return nil }
            return lower...upper
        }
    // => 127...159
    ```

This signature is also consistent with traditional regex backreference numbering. The numbering of backreferences to captures starts at `\1` because `\0` refers to the entire match. Flattening the match and captures into the same tuple, aligns the tuple index numbering of the result with the regex backreference numbering:

```swift
let scalarRangePattern = /([0-9A-F]+)(?:\.\.([0-9A-F]+))?/
// Result tuple index:  1 ^~~~~~~~~~~     2 ^~~~~~~~~~~
if let match = line.firstMatch(scalarRangePattern) {
    print(match.0, match.1, match.2) // => 007F..009F, 007F, 009F
}
```

### Capture type

In this section, we dive into capture types for regular expression patterns and
how they compose.

By default, a regular expression literal has type `Regex`. Its generic argument
`Capture` is its capture type.

#### Basics

Regular expressions without any capturing groups have type `Regex<Void>`, for example:

```swift
let identifier = /[_a-zA-Z]+[_a-zA-Z0-9]*/  // => `Regex<Void>`

// Result builder DSL equivalent:
//     let identifier = Regex {
//         OneOrMore(/[_a-zA-Z]/)
//         Repeat(/[_a-zA-Z0-9]/)
//     } // => `Regex<Void>`
```

#### Capturing group: `(...)`

In regular expression literals, a capturing group is a pattern wrapped by a pair
of parentheses. A capturing group's capture type is reflected in the result
type's `Capture` generic argument. A capturing group's corresponding capture type
is `Substring`.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)/ // => `Regex<Substring>`

// Result builder DSL equivalent
//     let graphemeBreakLowerBound = OneOrMore(CharacterClass.hexDigit).capture()
//     // `.Captures == Substring`
```

#### Concatenation: `abc`

Concatenating a sequence of patterns, _r0_, _r1_, _r2_, ..., will cause the
resulting capture type to reflect the _concatenated capture type_, represented
as a tuple of capture types or a single capture type depending on the overall
quantity of captures in _r0_, _r1_, _r2_, ... If the overall capture quantity is
`1`, the resulting capture type is the capture type of the single pattern that
has a capture; otherwise, the resulting capture type is a tuple of capture types
of all patterns that have a capture.

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)\.\.[0-9a-fA-F]+/
// => `Regex<Substring>`

// Result builder DSL equivalent:
//     let graphemeBreakLowerBound = Regex {
//         OneOrMore(CharacterClass.hexDigit).capture()
//         ".."
//         OneOrMore(CharacterClass.hexDigit)
//     }
//     // `.Captures == Substring`

let graphemeBreakRange = /([0-9a-fA-F]+)\.\.([0-9a-fA-F]+)/
// => `Regex<(Substring, Substring)>`

// Result builder DSL equivalent:
//     let graphemeBreakRange = Regex {
//         OneOrMore(CharacterClass.hexDigit).capture()
//         ".."
//         OneOrMore(CharacterClass.hexDigit).capture()
//     }
//     // `.Captures == (Substring, Substring)`
```

#### Named capturing group: `(?<name>...)`

A named capturing group in a pattern with multiple captures causes the resulting
tuple to have a tuple element label at the corresponding capture type position.
When the pattern has only one capture, there will be no tuple element label
because there are no 1-element tuples.

```swift
let graphemeBreakLowerBound = /(?<lower>[0-9A-F]+)\.\.[0-9A-F]+/
// => `Regex<Substring>`

let graphemeBreakRange = /(?<lower>[0-9A-F]+)\.\.(?<upper>[0-9A-F]+)/
// => `Regex<(lower: Substring, upper: Substring)>`
```

#### Non-capturing group: `(?:...)`

A non-capturing group's capture type is the capture type of its underlying
pattern. That is, it does not capture anything by itself, but transparently
propagates its underlying pattern's captures.

```swift
let graphemeBreakLowerBound = /([0-9A-F]+)(?:\.\.([0-9A-F]+))?/
// => `Regex<(Substring, Substring?)>`

// Result builder DSL equivalent:
//     let graphemeBreakLowerBound = Regex {
//         OneOrMore(CharacterClass.hexDigit).capture()
//         Optionally {
//             ".."
//             OneOrMore(CharacterClass.hexDigit).capture()
//         }
//     }
//     // `.Captures == (Substring, Substring?)`
```

#### Nested capturing group: `(abc(def))`

When capturing group is nested within another capturing group, they count as two
distinct captures in the order their left parenthesis first appears in the
regular expression literal. This is consistent with PCRE and allows us to use
backreferences (e.g. `\2`) with linear indices.

```swift
let graphemeBreakPropertyData = /(([0-9A-F]+)(\.\.([0-9A-F]+)))\s*;\s(\w+).*/
// Positions in result tuple:  1 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    5 ^~~~~
//                                         3 ^~~~~~~~~~~~~~~~~
//                              2 ^~~~~~~~~~~   4 ^~~~~~~~~~~
// => `Regex<(Substring, Substring, Substring, Substring, Substring)>`

// Result builder DSL equivalent:
//     let graphemeBreakPropertyData = Regex {
//         Regex {
//             OneOrMore(CharacterClass.hexDigit).capture() // (2)
//             Regex {
//                 ".."
//                 OneOrMore(CharacterClass.hexDigit).capture() // (4)
//             }.capture() // (3)
//         }.capture() // (1)
//         Repeat(CharacterClass.whitespace)
//         ";"
//         CharacterClass.whitespace
//         OneOrMore(CharacterClass.word).capture() // (5)
//         Repeat(CharacterClass.any)
//     }
//     // `.Captures == Regex(Substring, Substring, Substring, Substring, Substring)`

let input = "007F..009F    ; Control # Cc  [33] <control-007F>..<control-009F>"
// Match result for `input`:
// ("007F..009F", "007F", "..009F", "009F", "Control")
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
// => `Regex<[Substring]>`

// Result builder DSL equivalent:
//     OneOrMore {
//         OneOrMore(CharacterClass.hexDigit).capture()
//     }
//     // `.Captures == [Substring]`

/([0-9a-fA-F]+)*/
// => `Regex<[Substring]>`

// Result builder DSL equivalent:
//     Repeat {
//         OneOrMore(CharacterClass.hexDigit).capture()
//     }
//     // `.Captures == [Substring]`

/([0-9a-fA-F]+)?/
// => `Regex<Substring?>`

// Result builder DSL equivalent:
//     Optionally {
//         OneOrMore(CharacterClass.hexDigit).capture()
//     }
//     // `.Captures == Substring?`

/([0-9a-fA-F]+){3}/
// => `Regex<[Substring]>

// Result builder DSL equivalent:
//     Repeat(3) {
//         OneOrMore(CharacterClass.hexDigit).capture()
//     )
//     // `.Captures == [Substring]`

/([0-9a-fA-F]+){3,5}/
// => `Regex<[Substring]>`

// Result builder DSL equivalent:
//     Repeat(3...5) {
//         OneOrMore(CharacterClass.hexDigit).capture()
//     )
//     // `.Captures == [Substring]`

/([0-9a-fA-F]+){3,}/
// => `Regex<[Substring]>`

// Result builder DSL equivalent:
//     Repeat(3...) {
//         OneOrMore(CharacterClass.hexDigit).capture()
//     )
//     // `.Captures == [Substring]`
```

Note that capturing collections of repeated captures like this is a departure
from most regular expression implementations, which only provide access to the
_last_ match of a repeated capture group. For example, Python only captures the
last group in this dash-separated string:

```python
rep = re.compile('(?:([0-9a-f]+)-?)+')
match = rep.match("1234-5678-9abc-def0")
print(match.group(1))
# Prints "def0"
```

By contrast, the proposed Swift version captures all four sub-matches:

```swift
let pattern = /(?:([0-9a-f]+)-?)+/
if let match = "1234-5678-9abc-def0".firstMatch(of: pattern) {
    print(match.captures)
}
// Prints ["1234", "5678", "9abc", "def0"]
```

Despite the deviation from prior art, we believe that the proposed capture
behavior leads to better consistency with the meaning of these quantifiers.

#### Alternation: `a|b`

Alternations are used to match one of multiple patterns. If there are one or
more capturing groups within an alternation, the resulting capture type is an
`Alternation` that's generic over each option's underlying pattern.

```swift
/([01]+)|[0-9]+|([0-9A-F]+)/
// => `Regex<Alternation<(Substring, Void, Substring)>>`
```

If there are no capturing groups within an alternation the resulting capture
type is `Void`.

```swift
/[01]+|[0-9]+|[0-9A-F]+/
// => `Regex<Void>`
```

Nested captures follow the algebra previously described.

```swift
/([01]+|[0-9]+|[0-9A-F]+)/
// => `Regex<Substring>`
/(([01]+)|([0-9]+)|([0-9A-F]+))/
// => `Regex<(Substring, Alternation<(Substring, Substring, Substring))>>`
/(?<overall>(?<binary>[01]+)|(?<decimal>[0-9]+)|(?<hex>[0-9A-F]+))/
// => `Regex<(overall: Substring, Alternation<(binary: Substring, decimal: Substring, hex: Substring))>>`
```

At the use site, `Alternation` behaves like an `enum`. Ideally you should be
able to exhaustively switch over all the captures.

```swift
let number = line
    .firstMatch(of: /([01]+)|([0-9]+)|([0-9A-F]+)/)
    .flatMap {
        switch $0.1 {
        case let .0(binary):
            return Int(binary, radix: 2)
        case let .1(decimal):
            return Int(decimal, radix: 10)
        case let .2(hex):
            return Int(hex, radix: 16)
        }
    }

// Or with named captures:
let number = line
    .firstMatch(of: /(?<binary>[01]+)|(?<decimal>[0-9]+)|(?<hex>[0-9A-F]+)/)
    .flatMap {
        switch $0.1 {
        case let .binary(str):
            return Int(str, radix: 2)
        case let .decimal(str):
            return Int(str, radix: 10)
        case let .hex(str):
            return Int(str, radix: 16)
        }
    }
```

In the fullness of time, we'd like to design a language feature to support this.
In the meantime, we would like to do the best we can and leave the door open for
a source-compatible migration.

With variadic generics we think we can define the following `Alternation` type.

```swift
@dynamicMemberLookup
public struct Alternation<Captures> { ... }

extension<Option...> Alternation where Captures == (Option...) {
    public var options: (Option?...) { get }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<(Option?...), T>) -> T {
      options[keyPath: keyPath]
    }
}
```

An optional projection property, `options`, presents all options as a tuple of
optionals. The Standard Library will provide the runtime guarantee that only one
element of the `options` tuple will be non-nil. The programmer can use a
`switch` statement to pattern-match the tuple and handle each case, or directly
access the tuple's properties via key path dynamic member lookup.

```swift
let number = line
    .firstMatch(of: /([01]+)|([0-9]+)|([0-9A-F]+)/)
    .flatMap {
        switch $0.1.options {
        case let (binary?, nil, nil):
            return Int(binary, radix: 2)
        case let (nil, decimal?, nil):
            return Int(decimal, radix: 10)
        case let (nil, nil, hex?):
            return Int(hex, radix: 16)
        default:
            fatalError("unreachable")
        }
    }

// Or with named captures:
let number = line
    .firstMatch(of: /(?<binary>[01]+)|(?<decimal>[0-9]+)|(?<hex>[0-9A-F]+)/)
    .flatMap {
        if let binary = $0.1.binary {
            return Int(binary, radix: 2)
        } else if let decimal = $0.1.decimal {
            return Int(decimal, radix: 10)
        } else if let hex = $0.1.hex {
            return Int(hex, radix: 16)
        } else {
            fatalError("unreachable")
        }
    }
```

We acknowledge that it is unforunate that the programmer has to write an
unreachable `fatalError(...)` even when all possible cases are handled.  We
believe that, in the fullness of time, this will motivate the design of a
language-level solution to variadic enumerations.

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
// => `Regex<CaptureCollection<Substring>>`

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
/[a-z]{5}/     // => Regex<(5 x Substring)> (exact count)
/[a-z]{5, 8}/  // => Regex<[Substring]>     (bounded count) 
/[a-z]{5,}/    // => Regex<[Substring]>     (lower-bounded count)
```

However, this would cause an inconsistency between exact-count quantification
and bounded quantification.  We believe that the proposed design will result in
fewer surprises as we associate the `{...}` quantifier syntax with `Array`.

### `Never` as empty capture instead of `Void`

Past swift evolution proposals
([SE-0215](https://github.com/apple/swift-evolution/blob/main/proposals/0215-conform-never-to-hashable-and-equatable.md),
[SE-0319](https://github.com/apple/swift-evolution/blob/main/proposals/0319-never-identifiable.md))
have added conformances for `Never` in order to support its use a bottom type.
`Never` may seem like a natural fit for the empty capture type instead of
`Void`, such that a regex of type `Regex<Never>` means it never captures.

However, a `Never` value never exists. Functions with return type `Never` will
never return. As a result, a trivial use of regex like the following could cause
the program to abort or hang.

```swift
let identifier = /[_a-zA-Z]+[_a-zA-Z0-9]*/  // => `Regex<Never>`
print(str.firstMatch(of: identifier)?.captures)
// ❗️ Program aborts or hangs.
```

In contrast, using `Void` as the empty capture type allows captures to be
accessed safely at anytime. When a regex has no captures, the match result's
capture is simply `()`.

```swift
let identifier = /[_a-zA-Z]+[_a-zA-Z0-9]*/  // => `Regex<Void>`
print(str.firstMatch(of: identifier)?.captures)
// Prints `()`.
```

## Future directions

### Dynamic captures

So far, we have explored offering static capture types for using a regular
expression that is available in source code. Meanwhile, we would like to apply
Swift's string processing capabilities to fully dynamic use cases, such as
matching a string using a regular expression obtained at runtime.

To support dynamism, we could introduce a new type, `DynamicCaptures` that
represents a tree of captures, and add a `Regex` initializer that accepts a
string and produces `Regex<DynamicCaptures>`.
  
```swift
public struct DynamicCaptures: Equatable, RandomAccessCollection {
  var range: Range<String.Index> { get }
  var substring: Substring? { get }
  subscript(name: String) -> DynamicCaptures { get }
  subscript(position: Int) -> DynamicCaptures { get }
}

extension Regex where Capture == DynamicCaptures {
  public init(_ string: String) throws
}
```

Example usage:

```swift
let regex = readLine()! // (\w*)(\d)+z(\w*)?
let input = readLine()! // abcd1234xyz
print(input.firstMatch(of: regex)?.captures)
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

### Single-element labeled tuples

Swift doesn't currently support [single-element labeled tuples](https://forums.swift.org/t/single-element-labeled-tuples/9797), which leads to a discontinuity at arity 1:

```swift
let noCaptures = /[0-9A-F]+\.\.[0-9A-F]+/
// => `Regex<()>`

let oneCapture = /(?<lower>[0-9A-F]+)\.\.[0-9A-F]+/
// => `Regex<Substring>`

let twoCaptures = /(?<lower>[0-9A-F]+)\.\.(?<upper>[0-9A-F]+)/
// => `Regex<(lower: Substring, upper: Substring)>`
```

Dropping the argument label is particularly undesirable because `firstMatch` concatenates the match and the captures, make the argument label more significant:

```swift
let str = "007F..009F    ; Control # Cc  [33] <control-007F>..<control-009F>"

if let m = str.firstMatch(of: /(?<lower>[0-9A-F]+)\.\.(?<upper>[0-9A-F]+)/) {
    print(type(of: m)) // Prints (match: Substring, lower: Substring, upper: Substring)
    print(m.match) // Prints "007F..009F"
    print(m.lower) // Prints "007F"
    print(m.upper) // Prints "009F"
}

if let m = str.firstMatch(of: /(?<lower>[0-9A-F]+)\.\.[0-9A-F]+/) {
    print(type(of: m)) // Prints (match: Substring, Substring)
    print(m.match) // Prints "007F..009F"
    print(m.lower) // error
}
```

[Forum discussion](https://forums.swift.org/t/single-element-labeled-tuples/9797/21) suggests there isn't a  technical reason why support for single-element labeled tuples can't be added in the future. In particular, the examples here would be source compatible if as [suggested](https://forums.swift.org/t/single-element-labeled-tuples/9797/23) `(T)`, which is equivalent to `T`, is made a supertype of `(label: T)`.
