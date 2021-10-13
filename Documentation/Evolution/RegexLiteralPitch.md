# Regular Expression Literals

- Authors: Hamish Knight, Michael Ilseman

## Introduction

We propose to introduce a first-class regular expression literal into the language that can take advantage of library support to offer extensible, powerful, and familiar textual pattern matching.

This is a component of a larger string processing picture. We would like to start a focused discussion surrounding our approach to the literal itself, while acknowledging that evaluating the utility of the literal will ultimately depend on the whole picture (e.g. supporting API). To aid this focused discussion, details such as the representation of captures in the type system, semantic details, extensions to lexing/parsing, additional API, etc., are out of scope of this pitch and thread. Feel free to continue discussion of anything related in the [overview thread][overview].

## Motivation

Regular expressions are a ubiquitous, familiar, and concise syntax for matching and extracting text that satisfies a particular pattern. Syntactically, a regex literal in Swift should:

- Be familiar and facilitate knowledge reuse
- Fit in with Swift's library extensibility story for literals

Further motivation, examples, and discussion can be found in the [overview thread][overview].

## Proposed Solution

We propose the introduction of a regular expression literal that supports [the PCRE syntax][PCRE], in addition to new standard library protocols `ExpressibleByRegexLiteral` and `RegexLiteralProtocol` that allow for the customization of how the regex literal is interpreted, similar to the existing `ExpressibleByStringInterpolation` protocol for string literals with interpolations. The compiler will parse the PCRE syntax within a regex literal, and synthesize calls to corresponding builder methods. Types conforming to `ExpressibleByRegexLiteral` will be able to provide a builder type that opts into supporting various regex constructs through the use of normal function declarations and `@available`.

It should be noted that this pitch concerns language syntax and compiler changes alone, it isn't stating what features the stdlib would/should support in the initial version or in the future.

## Detailed Design

A regular expression literal will be introduced using `/` delimiters, within which the compiler will parse [PCRE regex syntax][PCRE]:

```swift
let regex = /([0-9A-F]+)(?: = (\d+))?/
```

The above regex literal will be inferred to be the default regex literal type `Regex`, the details of which are out of scope for this pitch.

Errors in the regex will be diagnosed by the compiler, though details about these errors (e.g. character class range validation) is outside the scope of this pitch. The compiler will then transform the literal into a set of builder calls that may be customized by adopting the `ExpressibleByRegexLiteral` protocol.

As an example, the above regex may be transformed into:

```swift
// let regex = /([0-9A-F]+)(?: = (\d+))?/
let regex = {
  var builder = T.RegexLiteral()

  // __A3 == /([0-9A-F]+)/
  let __A1 = builder.customCharacterClass(["0"..."9", "A"..."F"])
  let __A2 = builder.oneOrMore(__A1)
  let __A3 = builder.captureGroup(__A2)

  // __B4 == / = (\d+)/
  let __B1 = builder.literal(" = ")
  let __B2 = builder.characterClassDigit()
  let __B3 = builder.oneOrMore(__B2)
  let __B3 = builder.captureGroup(__B3)
  let __B4 = builder.concatenate(__B1, __B3)

  // __C3 == /__A3(?:__B4)?/
  let __C1 = builder.group(__B4)
  let __C2 = builder.zeroOrOne(__C1)
  let __C3 = builder.concatenate(__A3, __C2)

  return T(regexLiteral: builder.finalize(__C3))
}()
```

### The `ExpressibleByRegexLiteral` and `RegexLiteralProtocol` protocols

New `ExpressibleByRegexLiteral` and `RegexLiteralProtocol` protocols will be introduced to the standard library, and will serve a similar purpose to the existing literal protocols `ExpressibleByStringInterpolation` and `StringInterpolationProtocol`.

```swift
public protocol ExpressibleByRegexLiteral {
  associatedtype RegexLiteral : RegexLiteralProtocol = Regex
  init(regexLiteral: RegexLiteral)
}

public protocol RegexLiteralProtocol {
  init()

  // Informal builder requirements for building a regex literal
  // will be specified here.
}
```

Types conforming to `ExpressibleByRegexLiteral` will be able to provide a custom type that conforms to `RegexLiteralProtocol`, which will be used to build the resulting regex value. A default conforming type will be provided by the standard library (`Regex` here), but further details of that type are out of scope for this pitch.

Libraries can extend regex handling logic for their domains. For example, a higher-level library could provide linguistically richer regular expressions by incorporate locale, collation, language dictionaries, and fuzzier matching. Similarly, a libraries wrapping different regex engines can support custom regex literals.

### Opting into certain regex features

We intend for the compiler to completely parse [the PCRE syntax][PCRE]. However, types conforming to `RegexLiteralProtocol` might not be able to handle the full feature set. The compiler looks for corresponding function declarations inside `RegexLiteralProtocol` and will emit a compilation error if missing. Conforming types can use `@availability` on these function declarations to communicate versioning and add more support in the future.

The feature set initially supported by the standard library is outside the scope of this pitch. But, the approach of lookup combined with availability allows us to extend support over time.

### Impact of using `/` as the delimiter

#### On comment syntax

Single line comments use the syntax `//`, which would conflict with the spelling for an empty regex literal. As such, an empty regex literal would be forbidden.

Multi-line comments use the `/*` delimiter. As such, a regex literal starting with `*` wouldn't be parsed. This however isn't a major issue as an unqualified `*` is already invalid regex syntax. An escaped `/\*/` regex literal wouldn't be impacted.

#### On custom prefix and postfix operators using the `/` character

Choosing `/` as the delimiter means there will be parsing ambiguity with any user-defined prefix and postfix operators containing the `/` character. For example, code such as the following poses an issue:

```swift
let x = /0; let y = 1/
```

Should this be considered to be two `let` bindings, with each initialization expression using prefix and postfix `/` operators, or is it a single regex literal?

This also extends to more generally to prefix and postfix operators containing the `/` character, e.g:

```swift
let x = </<0; let y = 1</<
```
Is this a regex literal `/<0; let y = 1</` with a prefix and postfix `<` operator applied, or two `let` bindings each using prefix and postfix `</<` operators?

There are no easy ways of resolving these ambiguities, therefore a regex literal parsed with `/` delimiters will likely need to be introduced under a new language version mode, along with a deprecation of prefix and postfix operators that use the `/` character. In the new language version mode, the above examples will be parsed as regex literals.

#### On custom infix operators using the `/` character

There is also a conflict for infix operators containing `/` in cases where whitespace isn't used, for example:

```swift
x+/y/+z
```

Should the operators be parsed as `+/` and `/+` respectively, or should this be parsed as `x + /y/ + z`?

In this case, things can be more readily disambiguated by the user inserting additional whitespace. We therefore could continue to parse `x+/y/+z` as a binary operator chain, and require additional whitespace to interpret `/y/` as a regex literal.

#### On the existing division operator `/`

The existing division operator `/` has less concerns than the above cases, however it raises some cases that currently parse as a sequence of binary operations, whereas the user might be expecting a regex literal.

For example:

```swift
extension Int {
  static func foo() -> Int { 0 }
}

let x = 0
/ 1 / .foo()
```

Today, this is parsed as a single binary operator chain `0 / 1 / .foo()`, with `.foo()` becoming an argument to the `/` operator. This is because while Swift does have some parser behavior that is affected by newlines, generally newlines are treated as whitespace, and expressions therefore may span multiple lines. However the user may well be expecting the second line to be parsed as a regex literal.

This is also potentially an issue for result builders, for example:

```swift
SomeBuilder {
  x
  / y /
  z
}
```

Today this is parsed as `SomeBuilder { x / y / z }`, however it's likely the user was expecting this to become a result builder with 3 elements, the second of which being a regex literal.

In both cases, there is currently no source compatibility impact as both cases will continue to parse as binary operations, and the user may insert a `;` on the prior line to get the desired regex literal parsing. However this may not be sufficient and it may be necessary to change parsing rules to favor parsing regex literals in these cases, which would have a source compatibility impact for any code with leading chained division operators over newlines. The question of how to best handle these cases is left open for community feedback.

It's worth noting that this is similar to an ambiguity that already exists today with trailing closures, for example:

```swift
SomeBuilder {
  SomeType()
  { print("hello") }
  AnotherType()
}
```

`{ print("hello") }` will be parsed as a trailing closure to `SomeType()` rather than as a separate element to the result builder.


## Future Directions

### Typed captures

Typed captures would statically represent how many captures and of what kind are present in a regex literals. They could produce a `Substring` for a regular capture, `Substring?` for a zero-or-one capture, and  `Array<Substring>` (or a lazy collection) for a zero(or one)-or-more capture. These are worth exploring, especially in the context of the [start of variadic generics][variadics] support, but are outside the scope of this pitch.

### Raw regex literals

Similar to raw string literals `#"I said "hello there""#`, we may allow additional `#` characters to be added to the regex literal delimiters to allow for easy escaping of the `/` character within the literal, e.g:

```swift
#/foo/bar/baz/#
```

This is outside of the scope of this pitch, but would make sense as an additive proposal to regex literals.

### Further extension to Swift language constructs (better name?)

TODO: I'm referring to things like a Regex-backed `enum` for declaring tokens.

TODO: Mention restructuring pattern-matching enhancements


### Semantic details

Further details about the semantics of regex literals, such as what definition we give to character classes, the initial supported feature set, and how to switch between grapheme-semantic and scalar-semantic usage, is still under investigation and outside the scope of this pitch.

## Alternatives considered

### Using a different delimiter to `/`

As explored above, using `/` as the delimiter has the potential to conflict with existing operators using that character, and may necessitate:

- Changing of parsing rules around chained `/` over multiple lines
- Deprecating prefix and postfix operators containing the `/` character
- Requiring additional whitespace to disambiguate from infix operators containing `/`
- Requiring a new language version mode to parse the literal with `/` delimiters

However one of the main goals of this pitch is to introduce a familiar syntax for regular expression literals, which has been the motivation behind choices such as using the PCRE regex syntax. Given the fact that `/` is an existing term of art for regular expressions, we feel that if the aforementioned parsing issues can be solved in a satisfactory manner, we should prefer it as the delimiter.

### Partially-custom delimiters

TODO

### Raku-style syntax

Instead of using PCRE regular expression syntax, we could instead support [a Raku-style syntax][raku]. However this wouldn't meet the desired goal of familiarity, and we feel that if we were to adopt a custom or different syntax, then we'd like to design something beyond regex. At that point, we'd be talking about something pretty different (and certainly not tied to strings, e.g. data processing literals), and this work does not preclude improvements there.

### Fully custom literals

It may be worth exploring the ability for users to define custom literals, where they have full generality and no default type. This would require fleshing out the library-driven compilation story (bootstrapping as well as compiler and type system API). However that it is mostly orthogonal to this effort.


[PCRE]: http://pcre.org/current/doc/html/pcre2syntax.html
[overview]: https://forums.swift.org/t/declarative-string-processing-overview/52459
[variadics]: https://forums.swift.org/t/pitching-the-start-of-variadic-generics/51467
[stringinterpolation]: https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md
[raku]: https://docs.raku.org/language/grammars
