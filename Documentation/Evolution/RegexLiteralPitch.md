# Regular Expression Literals

- Authors: Hamish Knight, Michael Ilseman

## Introduction

We propose to introduce a first-class regular expression literal into the language that can take advantage of library support to offer extensible, powerful, and familiar textual pattern matching.

This is a component of a larger string processing picture. We would like to start a focused discussion surrounding our approach to the literal itself, while acknowledging that evaluating the utility of the literal will ultimately depend on the whole picture (e.g. supporting API). To aid this focused discussion, details such as the representation of captures in the type system, semantic details, extensions to lexing/parsing, additional API, etc., are out of scope of this pitch and thread. Feel free to continue discussion of anything related in the [overview thread][overview].

## Motivation

Regular expressions are a ubiquitous, familiar, and concise syntax for matching and extracting text that satisfies a particular pattern. Their terse syntax makes them extremely useful for writing simple patterns as arguments to a function or cases of a `switch`. As such, we feel they can nicely complement the more versatile [`Pattern` result builder DSL][pattern-builder], which is well suited for more complex patterns.

Syntactically, a regex literal in Swift should:

- Support a syntax familiar to developers who have learned to use regular expressions in other tools and languages
- Allow reuse of many regular expressions not specifically designed for Swift (e.g. from Stack Overflow or popular programming books)
- Allow libraries to define custom types that can be constructed with regex literals, much like string literals
- Diagnose at compile time if a regex literal uses capabilities that aren't allowed by the type's regex dialect

Further motivation, examples, and discussion can be found in the [overview thread][overview].

## Proposed Solution

We propose the introduction of a regular expression literal that supports [the PCRE syntax][PCRE], in addition to new standard library protocols `ExpressibleByRegexLiteral` and `RegexLiteralProtocol` that allow for the customization of how the regex literal is interpreted (similar to [string interpolation][stringinterpolation]). The compiler will parse (potentially a superset of) PCRE syntax within a regex literal, and synthesize calls to corresponding builder methods. Types conforming to `ExpressibleByRegexLiteral` will be able to provide a builder type that opts into supporting various regex constructs through the use of normal function declarations and `@available`.

_Note: This pitch concerns language syntax and compiler changes alone, it isn't stating what features the stdlib should support in the initial version or in future versions._

## Detailed Design

A regular expression literal will be introduced using `/` delimiters, within which the compiler will parse (potentially a superset of) [PCRE regex syntax][PCRE]:

```swift
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = /([[:alpha:]]\w*) = ([0-9A-F]+)/
```

The above regex literal will be inferred to be the default regex literal type `Regex`. Errors in the regex will be diagnosed by the compiler.

_`Regex` here is a stand-in type, further details about the type such as if or how this will scale to strongly typed captures is still under investigation._

_How best to diagnose grapheme-semantic concerns is still under investigation and probably best discussed in their corresponding threads. For example, `Range<Character>` is not [countable][countable] and [ordering is not linguistically meaningful][ordering], so validating character class ranges may involve restricting to a semantically-meaningful range (e.g. ASCII). This is best discussed in the [character classes pitch thread][char-classes-pitch]._

The compiler will then transform the literal into a set of builder calls that may be customized by adopting the `ExpressibleByRegexLiteral` protocol. Below is a straw-person transformation of this example: 

```swift
// let regex = /([[:alpha:]]\w*) = ([0-9A-F]+)/
let regex = {
  var builder = T.RegexLiteral()

  // __A4 = /([[:alpha:]]\w*)/
  let __A1 = builder.buildCharacterClass_POSIX_alpha()
  let __A2 = builder.buildCharacterClass_w()
  let __A3 = builder.buildConcatenate(__A1, __A2)
  let __A4 = builder.buildCaptureGroup(__A3)

  // __B1 = / = /
  let __B1 = builder.buildLiteral(" = ")

  // __C3 = /([0-9A-F]+)/
  let __C1 = builder.buildCustomCharacterClass(["0"..."9", "A"..."F"])
  let __C2 = builder.buildOneOrMore(__C1)
  let __C3 = builder.buildCaptureGroup(__C2)

  let __D1 = builder.buildConcatenate(__A4, __B1, __C3)
  builder.finalize(__D1)
  return T(regexLiteral: builder)
}()
```

In this formulation, the compiler fully parses the regex literal, calling mutating methods on a builder which constructs an AST. Here, the compiler recognizes syntax such as ranges and classifies metacharacters (`buildCharacterClass_w()`). Alternate formulations could involve less reasoning (`buildMetacharacter_w`), or more (`builderCharacterClass_word`). We'd like community feedback on this approach.

Additionally, it may make sense for the stdlib to provide a `RegexLiteral` conformer that just constructs a string to pass off to a string-based library. Such a type might assume all features are supported unless communicated otherwise, and we'd like community feedback on mechanisms to communicate this (e.g. availability).

### The `ExpressibleByRegexLiteral` and `RegexLiteralProtocol` protocols

New `ExpressibleByRegexLiteral` and `RegexLiteralProtocol` protocols will be introduced to the standard library, and will serve a similar purpose to the existing literal protocols `ExpressibleByStringInterpolation` and `StringInterpolationProtocol`.

```swift
public protocol ExpressibleByRegexLiteral {
  associatedtype RegexLiteral : RegexLiteralProtocol = DefaultRegexLiteral
  init(regexLiteral: RegexLiteral)
}

public protocol RegexLiteralProtocol {
  init()

  // Informal builder requirements for building a regex literal
  // will be specified here.
}
```

Types conforming to `ExpressibleByRegexLiteral` will be able to provide a custom type that conforms to `RegexLiteralProtocol`, which will be used to build the resulting regex value. A default conforming type will be provided by the standard library (`DefaultRegexLiteral` here).

Libraries can extend regex handling logic for their domains. For example, a higher-level library could provide linguistically richer regular expressions by incorporating locale, collation, language dictionaries, and fuzzier matching. Similarly, libraries wrapping different regex engines (e.g. `NSRegularExpression`) can support custom regex literals.

### Opting into certain regex features

We intend for the compiler to completely parse [the PCRE syntax][PCRE]. However, types conforming to `RegexLiteralProtocol` might not be able to handle the full feature set. The compiler will look for corresponding function declarations inside `RegexLiteralProtocol` and will emit a compilation error if missing. Conforming types can use `@available` on these function declarations to communicate versioning and add more support in the future.

This approach of lookup combined with availability allows the stdlib to support more features over time.

### Impact of using `/` as the delimiter

The `/` character is already used in a couple of different places in the language, and users may have defined their own custom operators that use the character. In some places, there will be a parsing ambiguity with the use of `/` as a delimiter. In other places, there will be a minimal impact.

#### Cases with little or no impact

Single line comments use the syntax `//`, which would be the spelling for an empty regex literal. As such, it will not be possible to write an empty regex literal. However such a regex literal would have little utility.

Multi-line comments use the `/*` delimiter. As such, a regex literal starting with `*` wouldn't be parsed. This however isn't a major issue as an unqualified `*` is already invalid regex syntax. An escaped `/\*/` regex literal wouldn't be impacted.

While not conflicting with the syntax proposed in this pitch, it's also worth noting that the `//` comment syntax (in particular documentation comments that use `///`) would likely preclude the ability to use `///` as a delimiter if we ever wanted to support multi-line regex literals. It's possible though that future multi-line support could be provided through raw regex literals. Alternatively, it could be inferred from the regex options provided. For example, a regex that uses the multi-line option `/(?m)/` could be allowed to span multiple lines.

There will a conflict for infix operators containing `/` in cases where whitespace isn't used, for example:

```swift
x+/y/+z
```

Should the operators be parsed as `+/` and `/+` respectively, or should this be parsed as `x + /y/ + z`?

In this case, things can be readily disambiguated by the user inserting additional whitespace. We therefore can continue to parse `x+/y/+z` as a binary operator chain, and require additional whitespace to interpret `/y/` as a regex literal.

#### Cases that require language changes

There is a more significant conflict with prefix and postfix operators that use the `/` character, that would likely require the `/` regex delimiters to be introduced under a new language version mode, along with a deprecation of prefix and postfix `/` operators. Some prefix and postfix operators containing `/` may be disambiguated with parenthesis, but we may have to figure out a way to refer to the operator explicitly or deprecate prefix and postfix (but not infix) operators containing `/`.

<details><summary>Rationale</summary>
Code such as the following poses an issue:

```swift
let x = /0; let y = 1/
```

Should this be considered to be two `let` bindings, with each initialization expression using prefix and postfix `/` operators, or is it a single regex literal?

This also extends more generally to prefix and postfix operators containing the `/` character, e.g:

```swift
let x = </<0; let y = 1</<
```
Is this a regex literal `/<0; let y = 1</` with a prefix and postfix `<` operator applied, or two `let` bindings each using prefix and postfix `</<` operators?

There are no easy ways of resolving these ambiguities, therefore the above mentioned language changes would be required.
</details>

#### Cases that require more investigation

The existing division operator `/` raises some cases that currently parse as a sequence of binary operations, whereas the user might be expecting a regex literal.

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

There is currently no source compatibility impact as both cases will continue to parse as binary operations. The user may insert a `;` on the prior line to get the desired regex literal parsing. However this may not be sufficient, and we may need to change parsing rules (under a version check) to favor parsing regex literals in these cases. We'd like to discuss this further with the community.

It's worth noting that this is similar to an ambiguity that already exists today with trailing closures, for example:

```swift
SomeBuilder {
  SomeType()
  { print("hello") }
  AnotherType()
}
```

`{ print("hello") }` will be parsed as a trailing closure to `SomeType()` rather than as a separate element to the result builder.

It can also currently arise with leading dot syntax in a result builder, e.g:

```swift
SomeBuilder {
  SomeType()
  .member
}
```

`.member` will be parsed as a member access on `SomeType()` rather than as a separate element that may have its base type inferred by the parameter of a `buildExpression` method on the result builder. However it's likely the member access behavior is what the user is expecting in most cases, especially if chained with multiple member accesses.

These examples demonstrate that this ambiguity is a more general issue that, depending on feasibility, could potentially be addressed by a more general solution. We do however feel that the result builder case in particular is important for regex literals and, if not addressed in some way, may necessitate the choice of another delimiter.

## Future Directions

### Typed captures

Typed captures would statically represent how many captures and of what kind are present in a regex literals. They could produce a `Substring` for a regular capture, `Substring?` for a zero-or-one capture, and  `Array<Substring>` (or a lazy collection) for a zero(or one)-or-more capture. These are worth exploring, especially in the context of the [start of variadic generics][variadics] support, but we'd like to keep this pitch and discussion focused to the details presented.

### Other regex literals

Multi-line extensions to regex literals is considered future work. Generally, we'd like to encourage refactoring into `Pattern` when the regex gets to that degree of complexity.

User-specified [choice of quote delimiters][perlquotes] is considered future work. A related approach to this could be a "raw" regex literal analogous to [raw strings][rawstrings]. For example (total strawperson), an approach where `n` `#`s before the opening delimiter would requires `n` `#` at the end of the trailing delimiter as well as requiring `n-1` `#`s to access metacharacters.

```txt
// All of the below are trying to match a path like "/tmp/foo/bar/File.app/file.txt"

/\/tmp\/.*\/File\.app\/file\.txt/
#//tmp/.*/File\.app/file\.txt/#
##//tmp/#.#*/File.app/file.txt/##
```

"Swiftier" literals, such as with non-semantic whitespace (e.g. [Raku's][rakuregex]), is future work. We'd want to strongly consider using a different backing technology for Swifty matching literals, such as PEGs.

Fully-custom literal support, that is literals whose bodies are not parsed and there is no default type available, is orthogonal to this work. It would require support for compilation-time Swift libraries in addition to Swift APIs for the compiler and type system.


### Further extension to Swift language constructs

Other language constructs, such as raw-valued enums, might benefit from further regex enhancements.

```swift
enum CalculatorToken: Regex {
  case wholeNumber = /\d+/
  case identifier = /\w+/
  case symbol = /\p{Math}/
  ...
}
```

As mentioned in the overview, general purpose extensions to Swift (syntactic) pattern matching could benefit regex

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

### Regex interpolation

We could support the ability to perform interpolation in regex literals, similar to string literals. Types conforming to `RegexLiteralProtocol` could provide builder methods to interpolate other regex values, or even other strings. However this would likely not be able to use the same `\(...)` syntax as string literals, as `\(` is already valid regex syntax for a literal `(` character. As such, we would likely need a new syntax to express this. 


### Other semantic details

Further details about the semantics of regex literals, such as what definition we give to character classes, the initial supported feature set, and how to switch between grapheme-semantic and scalar-semantic usage, is still under investigation and outside the scope of this discussion.

## Alternatives considered

### Using a different delimiter to `/`

One of the main goals of this pitch is to introduce a familiar and ubiquitous syntax for regular expression literals, which has been the motivation behind choices such as parsing a superset of the PCRE regex syntax. Given the fact that `/` is an existing term of art for regular expressions, we feel it should be the preferred delimiter syntax. However, this is provided that it's not too late to make the language changes required, and that such changes are an acceptable cost for the syntax.

As explored above, the `/` delimiter has the potential to conflict with existing operators using that character, and may therefore necessitate:

- Deprecating prefix and postfix operators containing the `/` character
- Requiring a new language version mode to parse the literal with `/` delimiters
- Requiring users to add additional whitespace to disambiguate from infix operators containing `/`
- Changing of parsing rules around chained `/` over multiple lines

It may also require the escaping of the `/` character within the literal, unless a raw literal syntax is also available.

To help better evaluate the tradeoffs being made, we can take a look at some alternative delimiter suggestions that would not have the above impact.

#### Using a `#/` delimiter

We could use `#/.../#` delimiters, similar to the syntax for raw strings. This may subsume the need for raw regular expression literals, though like string literals we could additionally support an arbitrary number of balanced `#` characters in the delimiter.

This syntax would retain most of the familiarity of the `/` delimiter, only requiring surrounding `#`s. However it is somewhat heavier than `/regex/`, with the `#` characters standing out quite a bit.

#### Using `#regex(...)`

We could opt for for a more explicitly spelled out literal syntax such as `#regex(...)`. This is an even more heavyweight option, similar to `#selector(...)`. As such, it may be considered syntactically noisy as e.g a function argument `str.match(#regex([abc]+))` vs `str.match(/[abc]+/)`.

Such a syntax would require the containing regex to correctly balance capture group parentheses, otherwise the rest of the line might be incorrectly considered a regex. This could place additional cognitive burden on the user, and may lead to an awkward typing experience. For example, if the user is editing a previously written regex, the syntax highlighting for the rest of the line may change, and unhelpful spurious errors may be reported. With a different delimiter, the compiler would be able to detect and better diagnose unbalanced parentheses in the regex.

We could avoid the parenthesis balancing issue by requiring an additional internal delimiter such as `#regex(/.../)`, however that would lose the benefit of no longer requiring the escape of `/`, and adds additional syntax noise. It may also be unclear that `/` is part of the delimiter rather than part of the literal. Alternatively, we could replace the internal delimiter with another character such as ```#regex`...` ```, `#regex{...}`, or `#regex/.../`. However those would be inconsistent with the existing `#literal(...)` syntax and the first two would overload the existing meanings for the ``` `` ``` and `{}` delimiters.

It should also be noted that `#regex(...)` would introduce a syntactic inconsistency where the argument of a `#literal(...)` is no longer necessarily valid Swift syntax, despite being written in the form of an argument.

#### Using `#(...)`

We could reduce the visual weight of `#regex(...)` by only requiring `#(...)`. This would retain the same advantages e.g not requiring to escape `/`. However it would also still retain the same issues, such as still looking potentially visually noisy as an argument, and having suboptimal behavior for parenthesis balancing.

#### Using single quotes `'...'`

This would have similar advantages to the prior alternatives, while being much visually lighter. It would also allow for `'''` to be used as the delimiter for multi-line regex literals if decided to support them. However given how close it is to string literal syntax, it may not be entirely clear to users that `'...'` denotes a regular expression as opposed to some different form of string literal (e.g some form of character literal, or a string literal with different escaping rules).

We could help distinguish it from a string literal by requiring e.g `'/.../'`, though it may not be clear that the `/` characters are part of the delimiters rather than part of the literal.

#### Using modified string literal syntax

We could adopt the same syntax as a string literal, with a modifier such as `r"..."` used to denote a regex. This would be reasonably visually lightweight, and would have the advantage of the delimiter `r"""` being available for multi-line regex literals if we ever supported them.

Such a delimiter would be visually close to string literal syntax, though the prefix letter does help distinguish it.

### Reusing string literal syntax

Instead of supporting a first-class literal kind for regular expressions, we could instead allow users to write a regular expression in a string literal, and parse, diagnose, and generate the appropriate code when it's coerced to an `ExpressibleByRegexLiteral` conforming type.

```swift
let regex: Regex = "([[:alpha:]]\w*) = ([0-9A-F]+)"
```

However we decided against this because:

- We would not be able to easily apply custom syntax highlighting for the regex syntax
- It would require an `ExpressibleByRegexLiteral` contextual type to be treated as a regex, otherwise it would be defaulted to `String`, which may be undesired
- In an overloaded context it may be ambiguous whether a string literal is meant to be interpreted as a literal string or regex
- Regex escape sequences aren't currently compatible with string literal escape sequence rules, e.g `\w` is currently illegal in a string literal
- It wouldn't be compatible with other string literal features such as interpolations

### Using a custom regex syntax

Rather than using PCRE syntax, we could adopt a custom syntax to make the regular expression easier to read by e.g making the whitespace non-semantic, spelling out meta-characters such as `\w` more explicitly, etc. 

While the PCRE syntax definitely has its shortcomings, we feel that this is outweighed by the ubiquity and familiarity of the syntax for simple regular expressions. Introducing a custom syntax would help readability for more complex regular expressions, however in those cases we feel that users [would be better served by the `Pattern` result builder DSL][regex-to-pattern].


[PCRE]: http://pcre.org/current/doc/html/pcre2syntax.html
[overview]: https://forums.swift.org/t/declarative-string-processing-overview/52459
[variadics]: https://forums.swift.org/t/pitching-the-start-of-variadic-generics/51467
[stringinterpolation]: https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md
[countable]: https://en.wikipedia.org/wiki/Countable_set
[ordering]: https://forums.swift.org/t/min-function-doesnt-work-on-values-greater-than-9-999-any-idea-why/52004/16
[perlquotes]: https://perldoc.perl.org/perlop#Quote-and-Quote-like-Operators
[rawstrings]: https://github.com/apple/swift-evolution/blob/main/proposals/0200-raw-string-escaping.md
[rakuregex]: https://docs.raku.org/language/regexes
[regex-to-pattern]: https://forums.swift.org/t/declarative-string-processing-overview/52459#from-regex-to-pattern-8
[char-classes-pitch]: https://forums.swift.org/t/pitch-character-classes-for-string-processing/52920
[pattern-builder]: https://forums.swift.org/t/declarative-string-processing-overview/52459#pattern-builder-9
