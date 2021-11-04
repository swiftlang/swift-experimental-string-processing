# Strongly typed regex captures

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
            - [Capturing Group](#capturing-group)
            - [Concatenation](#concatenation)
            - [Named Capturing Group](#named-capturing-group)
            - [Non-capturing Group](#non-capturing-group)
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

if let match = "abcddddefgh".firstMatch(regex) {
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
`Substring`), or the matching API will be discussed in a separate pitch.

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
if let match = "abcddddefgh".firstMatch(regex) {
  print(match.captures) // => ("cdddd", "ef")
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

#### Capturing Group

In regular expression literals, a capturing group is a pattern wrapped by a pair
of parentheses. A capturing group's capture type is reflected in the result
type's `Capture` generic argument. A capturing group's corresponding capture type
is `Substring`.

```
pattern ::= '(' pattern ')'
```

```swift
let graphemeBreakLowerBound = /([0-9a-fA-F]+)/ // => `Regex<Substring>`

// Result builder DSL equivalent
//     let graphemeBreakLowerBound = OneOrMore(CharacterClass.hexDigit).capture()
//     // `.Captures == Substring`
```

#### Concatenation

Concatenating a sequence of patterns, _r0_, _r1_, _r2_, ..., will cause the
resulting capture type to reflect the _concatenated capture type_, represented
as a tuple of capture types or a single capture type depending on the overall
quantity of captures in _r0_, _r1_, _r2_, ... If the overall capture quantity is
`1`, the resulting capture type is the capture type of the single pattern that
has a capture; otherwise, the resulting capture type is a tuple of capture types
of all patterns that have a capture.

```
pattern ::= pattern pattern
```

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

#### Named Capturing Group

A named capturing group in a pattern with multiple captures causes the resulting
tuple to have a tuple element label at the corresponding capture type position.
When the pattern has only one capture, there will be no tuple element label
because there are no 1-element tuples.

```
pattern ::= '(' '?' '<' name '>' pattern ')'
```

```swift
let graphemeBreakLowerBound = /(?<lower>[0-9A-F]+)\.\.[0-9A-F]+/
// => `Regex<Substring>`

let graphemeBreakRange = /(?<lower>[0-9A-F]+)\.\.(?<upper>[0-9A-F]+)/
// => `Regex<(lower: Substring, upper: Substring)>`
```

#### Non-capturing Group

A non-capturing group's capture type is the capture type of its underlying pattern.

```
pattern ::= '(' '?' ':' pattern ')'
```

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

#### Nested capturing group

When capturing group is nested within another capturing group, they count as two
distinct captures in the order their left parenthesis first appears in the
regular expression literal. This is consistent with PCRE and allows us to use
backreferences (e.g. `\2`) with linear indices.

```swift
let graphemeBreakPropertyData = /(([0-9A-F]+)(\.\.([0-9A-F]+)))\s*;\s(\w+).*/
// Positions in capture tuple: 0 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    4 ^~~~~
//                                         2 ^~~~~~~~~~~~~~~~~
//                              1 ^~~~~~~~~~~   3 ^~~~~~~~~~~
// => `Regex<(Substring, Substring, Substring, Substring, Substring)>`

// Result builder DSL equivalent:
//     let graphemeBreakPropertyData = Regex {
//         Regex {
//             OneOrMore(CharacterClass.hexDigit).capture() // (1)
//             Regex {
//                 ".."
//                 OneOrMore(CharacterClass.hexDigit).capture() // (3)
//             }.capture() // (2)
//         }.capture() // (0)
//         Repeat(CharacterClass.whitespace)
//         ";"
//         CharacterClass.whitespace
//         OneOrMore(CharacterClass.word).capture() // (4)
//         Repeat(CharacterClass.any)
//     }
//     // `.Captures == Regex(Substring, Substring, Substring, Substring, Substring)`

let input = "007F..009F    ; Control # Cc  [33] <control-007F>..<control-009F>"
// Match result for `input`:
// ("007F..009F", "007F", "..009F", "009F", "Control")
```


#### Quantification

A quantifier's capture type depends on its underlying pattern. The laziness of
a quantifier, as denoted by a `?` suffix, does not affect the capture type. 

```
pattern ::= pattern '*' '?'?
pattern ::= pattern '+' '?'?
pattern ::= pattern '?' '?'?
pattern ::= pattern '{' number (',' spaces? number?)? '}' '?'?
```

| Syntax               | Description           | Capture type                                                  |
| -------------------- | --------------------- | ------------------------------------------------------------- |
| `*` / `*?`           | 0 or more             | `Array` of the sub-pattern capture type                       |
| `+` / `+?`           | 1 or more             | `Array` of the sub-pattern capture type                       |
| `?` / `??`           | 0 or 1                | `Optional` of the sub-pattern capture type                    |
| `{n}` / `{n}?`       | Exactly _n_           | `Array` of the sub-pattern capture type                       |
| `{n, m}` / `{n, m}?` | Between _n_ and _m_   | `Array` of the sub-pattern capture type                       |
| `{n,}` / `{n,}?`     | _n_ or more           | `Array` of the sub-pattern capture type                       |

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
if let match = “1234-5678-9abc-def0".firstMatch(of: pattern) {
    print(match.captures)
}
// Prints [“1234”, “5678", “9abc”, “def0"]
```

Despite the deviation from prior art, we believe that the proposed capture
behavior leads to better consistency with the meaning of these quantifiers.

#### Alternation

Alternations are used to match one of multiple possible patterns.

```txt
pattern ::= pattern '|' pattern
```

If there are one or more capturing groups within an alternation, the resulting
capture type is an `Alternation` that's generic over each option's underlying
pattern.

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
    .firstMatch(/([01]+)|([0-9]+)|([0-9A-F]+)/)?
    .captures
    .flatMap {
        switch $0 {
        case let .0(binary):
            return Int(binary, radix: 2)
        case let .1(decimal):
            return Int(decimal, radix: 10)
        case let .2(hex):
            return Int(decimal, radix: 16)
        }
    }

// Or with named captures:
let number = line
    .firstMatch(/(?<binary>[01]+)|(?<decimal>[0-9]+)|(?<hex>[0-9A-F]+)/)?
    .captures
    .flatMap {
        switch $0 {
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
    .firstMatch(/([01]+)|([0-9]+)|([0-9A-F]+)/)?
    .captures
    .flatMap {
        switch $0.options {
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
    .firstMatch(/(?<binary>[01]+)|(?<decimal>[0-9]+)|(?<hex>[0-9A-F]+)/)?
    .captures
    .flatMap {
        if let binary = $0.binary {
            return Int(binary, radix: 2)
        } else if let decimal = $0.decimal {
            return Int(decimal, radix: 10)
        } else if let hex = $0.hex {
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

TODO 

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
public enum DynamicCaptures: Equatable {
  case substring(Substring)
  indirect case tuple([DynamicCaptures])
  indirect case optional(DynamicCaptures?)
  indirect case array([DynamicCaptures])
}

extension Regex where Capture == DynamicCaptures {
  public init(_ string: String) throws
}
```

Example usage:

```swift
let regex = readLine()! // (\w*)(\d)+z(\w*)?
let input = readLine()! // abcd1234xyz
print(input.firstMatch(regex)?.captures)
// .tuple(
//     .substring("abcd"),
//     .array([
//         .substring("1"),
//         .substring("2"),
//         .substring("3"),
//         .substring("4"),
//     ]),
//     .optional(
//         .substring("xyz")
//     )
// )
```
