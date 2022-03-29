# Regex Literals

- Authors: Hamish Knight, Michael Ilseman, David Ewing

## Introduction

This proposal helps complete the story told in [Regex Type and Overview][regex-type] and [elsewhere][pitch-status]. We propose the introduction of regex literals to Swift source code. The proposed syntax mirrors literals in other programing languages such as Perl, JavaScript and Ruby. As in those languages, literals are delimited with the `/` character:

```swift
let re = /[0-9]+/
```

## Motivation

In [Regex Type and Overview][regex-type] we introduced the `Regex` type, which is able to dynamically compile a regex pattern:

```swift
let pattern = #"(\w+)\s\s+(\S+)\s\s+((?:(?!\s\s).)*)\s\s+(.*)"#
let regex = try! Regex(compiling: pattern)
// regex: Regex<AnyRegexOutput>
```

The ability to compile regex patterns at runtime is useful for cases where it is e.g provided as user input, however it is suboptimal when the pattern is statically known for a number of reasons:

- Regex syntax errors aren't detected until runtime, and explicit error handling (e.g `try!`) is required to deal with these errors.
- No special source tooling support, such as syntactic highlighting, code completion, and refactoring support, is available.
- Capture types aren't known until runtime, and as such a dynamic `AnyRegexOutput` capture type must be used.
- The syntax is overly verbose, especially for e.g an argument to a matching function.

## Proposed solution

We propose introducing a new kind of literal for a regex. In Swift 5.7 mode, a regex literal may be written using `/.../` delimiters:

```swift
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = /(?<identifier>[[:alpha:]]\w*) = (?<hex>[0-9A-F]+)/
// regex: Regex<(Substring, identifier: Substring, hex: Substring)>
```

Forward slashes are a regex term of art, and are used as the delimiters for regex literals in Perl, JavaScript and Ruby (though Perl and Ruby also provide alternatives). Their ubiquity and familiarity makes them a compelling choice for Swift.

A regex literal may also be spelled using an extended syntax `#/.../#`, which allows the placement of an arbitrary number of balanced `#` characters around a regex literal. This syntax allows regex literals to contain unescaped forward slashes, and may be used without needing to upgrade to Swift 5.7 mode.

Within a regex literal, the compiler will parse the regex syntax outlined in in [the Regex Syntax pitch][internal-syntax], and diagnose any errors at compile time. The capture types and labels are automatically inferred based on the capture groups present in the regex. Using a literal allows editors to support features such as syntax coloring inside the literal, highlighting sub-structure of the regex, and conversion of the literal to an equivalent result builder DSL (see [Regex builder DSL][regex-dsl]).

A regex literal also allows for seamless composition with the Regex DSL, enabling lightweight intermixing of a regex syntax with other elements of the builder:

```swift
// A regex literal for parsing an amount of currency in dollars or pounds.
let regex = Regex {
  /([$£])/
  TryCapture {
    OneOrMore(.digit)
    "."
    Repeat(.digit, count: 2)
  } transform: { Amount(twoDecimalPlaces: $0) }
}
```

This flexibility allows for terse matching syntax to be used when it's suitable, and more explicit syntax where clarity and strong types are required.

Due to the existing use of `/` in comment syntax and operators, there are some syntactic ambiguities to consider. While there are quite a few cases to consider, we do not feel that the impact of any individual case is sufficient to disqualify the syntax. Some of these ambiguities require a couple of source breaking language changes, and as such the `/.../` syntax requires upgrading to a new language mode in order to use.

## Detailed design

### Typed captures

Regex literals have their capture types statically determined by the capture groups present. A initial `Substring` is always present for the entire match, and each capture group adds an additional capture to the match tuple, with named capture groups receiving a corresponding tuple label. Once matched, such captures may later be referenced:

```swift
func matchHexAssignment(_ input: String) -> (String, Int)? {
  let regex = /(?<identifier>[[:alpha:]]\w*) = (?<hex>[0-9A-F]+)/
  // regex: Regex<(Substring, identifier: Substring, hex: Substring)>
  
  guard let match = regex.matchWhole(input), 
        let hex = Int(match.hex, radix: 16) 
  else { return nil }
  
  return (match.identifier, hex)
}
```

Unnamed capture groups produce unlabeled tuple elements and must be referenced by their position, e.g `match.1`, `match.2`.

**TODO: Should we cover more general typed capture behavior from [StronglyTypedCaptures.md](https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/StronglyTypedCaptures.md) here? There is some overlap with the typed capture behavior of the DSL tho, labels are the main thing that are literal specific**

### Extended delimiters `#/.../#`, `##/.../##`

A regex literal may be surrounded by an arbitrary number of balanced pound characters. This is a similar to raw string literal syntax introduced by [SE-0200], and allows a regex literal to use forward slashes without the need to escape them, e.g:

```swift
let regex = #/usr/lib/modules/([^/]+)/vmlinuz/#
// regex: Regex<(Substring, Substring)>
```

Additionally, this syntax provides a way to write a regex literal without needing to upgrade to Swift 5.7 mode.

#### Escaping of backslashes

This syntax differs from raw string literals `#"..."#` in that it does not treat backslashes as literal within the regex. A string literal `#"\n"#` represents the literal characters `\n`. However a regex literal `#/\n/#` remains a newline escape sequence.

One of the primary motivations behind this escaping behavior in raw string literals is that it allows the contents to be easily transportable to/from e.g external files where escaping is unnecessary. For string literals, this suggests that backslashes be treated as literal by default. For regex literals, it instead suggests that backslashes should retain their semantic meaning, as it enables interoperability with regexes taken from outside your code without having to adjust escape sequences to match the delimiters used.

With string literals, escaping can be tricky without the use of raw syntax, as backslashes may have semantic meaning to the consumer, rather than the compiler. For example:

```swift
// Matches '\' <word char> <whitespace>* '=' <whitespace>* <digit>+
let regex = try NSRegularExpression(pattern: "\\\\w\\s*=\\s*\\d+", options: [])
```

In this case, the intent is not for the compiler to recognize any of these sequences as string literal escapes, it is instead for `NSRegularExpression` to interpret them as regex escape sequences. However this is not an issue for regex literals, as the regex parser is the only possible consumer of such escape sequences. Such a regex would instead be spelled as:

```swift
let regex = /\\\w\s*=\s*\d+/
// regex: Regex<Substring>
```

Backslashes still require escaping to be treated as literal, however we don't expect this to be as common of an occurrence as needing to write a regex escape sequence such as `\s`, `\w`, or `\p{...}`, within a regex literal with extended delimiters `#/.../#`.

### Ambiguities with comment syntax

Perhaps the most obvious parsing ambiguity with `/.../` delimiters is with comment syntax.

- An empty regex literal would conflict with line comment syntax `//`. But an empty regex isn't a particularly useful thing to express, and can be disallowed without significant impact.

- There is a conflict with block comment syntax, when surrounding a regex literal ending with `*`, for example:

  ```swift
  /*
  let regex = /[0-9]*/
  */
  ```

   In this case, the block comment would prematurely end on the second line, rather than extending all the way to the third line as the user would expect. This is already an issue today with `*/` in a string literal, though it is more likely to occur in a regex given the prevalence of the `*` quantifier. This issue can be avoided in many cases by using line comment syntax `//` instead, which it should be noted is the syntax that Xcode uses when commenting out multiple lines.

- Block comment syntax also means that a regex literal would not be able to start with the `*` character, however this is less of a concern as it would not be valid regex syntax.


### Ambiguity with infix operators

There would be a minor ambiguity with infix operators used with regex literals. When used without whitespace, e.g `x+/y/`, the expression will be treated as using an infix operator `+/`. Whitespace is therefore required `x + /y/` for regex literal interpretation. Alternatively, extended syntax may be used, e.g `x+#/y/#`.

### Regex syntax limitations

In order to help avoid further parsing ambiguities, a `/.../` regex literal will not be parsed if it starts with a space, tab, or `)` character. Though the latter is already invalid regex syntax. This restriction may be avoided by using extended `#/.../#` syntax.

#### Rationale

This is due to 2 main parsing ambiguities. The first of which arises when a `/.../` regex literal starts a new line. This is particularly problematic for result builders, where we expect it to be frequently used, in particular within a `Regex` builder:

```swift
let digit = Regex {
  TryCapture(OneOrMore(.digit)) { Int($0) }
}
// Matches against <digit>+ (' + ' | ' - ') <digit>+
let regex = Regex {
   digit
   / [+-] /
   digit
}
```

Instead of being parsed as 3 result builder elements, the second of which being a regex literal, this is instead parsed as a single operator chain with the operands `digit`, `[+-]`, and `digit`. This will therefore be diagnosed as semantically invalid.

To avoid this issue, a regex literal may not start with a space or tab character. This takes advantage of the fact that infix operators require consistent spacing on either side.

If a space or tab is needed as the first character, it must be either escaped, e.g:

```swift
let regex = Regex {
   digit
   /\ [+-] /
   digit
}
```

or extended syntax must be used, e.g:

```swift
let regex = Regex {
   digit
   #/ [+-] /#
   digit
}
```

The second ambiguity arises with Swift's ability to pass an unapplied operator reference as an argument to a function or subscript, for example:

```swift
let arr: [Double] = [2, 3, 4]
let x = arr.reduce(1, /) / 5
```

The `/` in the call to `reduce` is in a valid expression context, and as such could be parsed as a regex literal. This is also applicable to operators in tuples and parentheses. To help mitigate this ambiguity, a regex literal will not be parsed if the first character is `)`. This should have minimal impact, as this would not be valid regex syntax anyway.

It should be noted that this only mitigates the issue, as it does not handle the case where the next character is a comma or right square bracket. These cases are explored further in the following section.

### Language changes required

In addition to ambiguities listed above, there are also some parsing ambiguities that would require the following language changes in Swift 5.7 mode:

- Deprecation of prefix operators containing the `/` character.
- Parsing `/,` and `/]` as the start of a regex literal if a closing `/` is found, rather than an unapplied operator in an argument list. For example, `fn(/, /)` becomes a regex literal rather than 2 unapplied operator arguments.
  
#### Prefix operators containing `/`

We need to ban prefix operators starting with `/`, to avoid ambiguity with cases such as:

```swift
let x = /0; let y = 1/
let z = /^x^/
```

Prefix operators containing `/` more generally also need banning, in order to allow prefix operators to be used with regex literals in an unambiguous way, e.g:
    
```swift
let x = !/y / .foo()
```

Today, this is interpreted as the prefix operator `!/` on `y`. With the banning of prefix operators containing `/`, it becomes prefix `!` on a regex literal, with a member access `.foo`. 

Postfix `/` operators do not require banning, as they'd only be treated as regex literal delimiters if we are already trying to lex as a regex literal.
    
#### `/,` and `/]` as regex literal openings

**TODO: Do we still want to break source here given we're also proposing `#/.../#`?**

As stated previously, there is a parsing ambiguity with unapplied operators in argument lists, tuples, and parentheses. Some of these cases can be mitigated by not parsing a regex literal if the starting character is `)`. However it does not solve the issue when the next character is `,` or `]`. Both of these are valid regex starting characters, and comma in particular may be a fairly common case for a regex.

For example:

```swift
// Ambiguity with comma:
func foo(_ x: (Int, Int) -> Int, _ y: (Int, Int) -> Int) {}
foo(/, /)

// Also affects cases where the closing '/' is outside the argument list.
func bar(_ fn: (Int, Int) -> Int, _ x: Int) -> Int { 0 }
bar(/, 2) + bar(/, 3)

// Ambiguity with right square bracket:
struct S {
  subscript(_ fn: (Int, Int) -> Int) -> Int { 0 }
}
func baz(_ x: S) -> Int {
  x[/] + x[/]
}
```

`foo(/, /)` is currently parsed as 2 unapplied operator arguments. `bar(/, 2) + bar(/, 3)` is currently parsed as two independent calls that each take an unapplied `/` operator reference. Both of these would become regex literals arguments, `/, /` and `/, 2) + bar(/` respectively (though the latter would produce a regex error).

To disambiguate these cases, users will need to surround at least the opening `/` with parentheses, e.g:

```swift
foo((/), /)
bar((/), 2) + bar(/, 3)

func baz(_ x: S) -> Int {
  x[(/)] + x[/]
}
```

This takes advantage of the fact that a regex literal will not be parsed if the first character is `)`.

</details>

## Future Directions

### Multi-line literals

The obvious choice for a multi-line regex literal would be to use `///` delimiters, in accordance with the precedent set by multi-line string literals `"""`. But this signifies a (documentation) comment, so a different multi-line delimiter would be needed, with no obvious choice. However, it's not clear that we need multi-line regex literals. The existing literals can be used inside a regex builder DSL. 

### Regex extended syntax

Allowing non-semantic whitespace and other features of the extended syntax would be highly desired, with no obvious choice for a literal. Perhaps the need is also lessened by the ability to use regex literals inside the regex builder DSL.

## Alternatives Considered

Given the fact that `/` is an existing term of art for regular expressions, we feel it should be the preferred delimiter syntax. While it has some syntactic ambiguities, we do not feel that they are sufficient to disqualify the syntax. To evaluate this trade-off, below is a list of alternative delimiters that would not have the same ambiguities.

### Prefixed quote `re'...'`

We could choose to use `re'...'` delimiters, for example:

```swift
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = re'([[:alpha:]]\w*) = ([0-9A-F]+)'
```

The use of two letter prefix could potentially be used as a namespace for future literal types. It would also have obvious extensions to extended and multi-line literals using `re#'...'#` and `re'''...'''` respectively. However, it is unusual for a Swift literal to be prefixed in this way. We also feel that its similarity to a string literal might have users confuse it with a raw string literal. 

Also, there are a few items of regex grammar that use the single quote character as a metacharacter. These include named group definitions and references such as `(?'name')`, `(?('name'))`, `\g'name'`, `\k'name'`, as well as callout syntax `(?C'arg')`. The use of a single quote conflicts with the `re'...'` delimiter as it will be considered the end of the literal. However, alternative syntax exists for all of these constructs, e.g `(?<name>)`, `\k<name>`, and `(?C"arg")`. Those could be required instead. An extended regex literal syntax e.g `re#'...'#` would also avoid this issue.

### Prefixed double quote `re"...."`

This would be a double quoted version of `re'...'`, more similar to string literal syntax. This has the advantage that single quote regex syntax e.g `(?'name')` would continue to work without requiring the use of the alternative syntax or extended literal syntax. However it could be argued that regex literals are distinct from string literals in that they introduce their own specific language to parse. As such, regex literals are more like "program literals" than "data literals", and the use of single quote instead of double quote may be useful in expressing this difference.

### Single letter prefixed quote `r'...'`

This would be a slightly shorter version of `re'...'`. While it's more concise, it could potentially be confused to mean "raw", especially as Python uses this syntax for raw strings.

### Single quotes `'...'`

This would be an even more concise version of `re'...'` that drops the prefix entirely. However, given how close it is to string literal syntax, it may not be entirely clear to users that `'...'` denotes a regex as opposed to some different form of string literal (e.g some form of character literal, or a string literal with different escaping rules).

We could help distinguish it from a string literal by requiring e.g `'/.../'`, though it may not be clear that the `/` characters are part of the delimiters rather than part of the literal. Additionally, this would potentially rule out the use of `'...'` as a future literal kind. 

### Magic literal `#regex(...)`

We could opt for for a more explicitly spelled out literal syntax such as `#regex(...)`. This is a more heavyweight option, similar to `#selector(...)`. As such, it may be considered syntactically noisy as e.g a function argument `str.match(#regex([abc]+))` vs `str.match(/[abc]+/)`.

Such a syntax would require the containing regex to correctly balance parentheses for groups, otherwise the rest of the line might be incorrectly considered a regex. This could place additional cognitive burden on the user, and may lead to an awkward typing experience. For example, if the user is editing a previously written regex, the syntax highlighting for the rest of the line may change, and unhelpful spurious errors may be reported. With a different delimiter, the compiler would be able to detect and better diagnose unbalanced parentheses in the regex.

We could avoid the parenthesis balancing issue by requiring an additional internal delimiter such as `#regex(/.../)`. However this is even more heavyweight, and it may be unclear that `/` is part of the delimiter rather than part of an argument. Alternatively, we could replace the internal delimiter with another character such as ```#regex`...` ```, `#regex{...}`, or `#regex/.../`. However those would be inconsistent with the existing `#literal(...)` syntax and the first two would overload the existing meanings for the ``` `` ``` and `{}` delimiters.

It should also be noted that `#regex(...)` would introduce a syntactic inconsistency where the argument of a `#literal(...)` is no longer necessarily valid Swift syntax, despite being written in the form of an argument.

### Shortened magic literal `#(...)`

We could reduce the visual weight of `#regex(...)` by only requiring `#(...)`. However it would still retain the same issues, such as still looking potentially visually noisy as an argument, and having suboptimal behavior for parenthesis balancing. It is also not clear why regex literals would deserve such privileged syntax.

### Reusing string literal syntax

Instead of supporting a first-class literal kind for regex, we could instead allow users to write a regex in a string literal, and parse, diagnose, and generate the appropriate code when it's coerced to the `Regex` type.

```swift
let regex: Regex = #"([[:alpha:]]\w*) = ([0-9A-F]+)"#
```

However we decided against this because:

- We would not be able to easily apply custom syntax highlighting and other editor features for the regex syntax.
- It would require a `Regex` contextual type to be treated as a regex, otherwise it would be defaulted to `String`, which may be undesired.
- In an overloaded context it may be ambiguous or unclear whether a string literal is meant to be interpreted as a literal string or regex.
- Regex-specific escape sequences such as `\w` would likely require the use of raw string syntax `#"..."#`, as they are otherwise invalid in a string literal.
- It wouldn't be compatible with other string literal features such as interpolations.

### No custom literal

Instead of adding a custom regex literal, we could require users to explicitly write `try! Regex(compiling: "[abc]+")`. This would be similar to `NSRegularExpression`, and loses all the benefits of parsing the literal at compile time. This would mean:

- No source tooling support (e.g syntax highlighting, refactoring actions) would be available.
- Parse errors would be diagnosed at run time rather than at compile time.
- We would lose the type safety of typed captures.
- More verbose syntax is required.

We therefore feel this would be a much less compelling feature without first class literal support.

[SE-0168]: https://github.com/apple/swift-evolution/blob/main/proposals/0168-multi-line-string-literals.md
[SE-0200]: https://github.com/apple/swift-evolution/blob/main/proposals/0200-raw-string-escaping.md
[internal-syntax]: https://forums.swift.org/t/pitch-regex-syntax/55711
[regex-type]: https://forums.swift.org/t/pitch-regex-type-and-overview/56029
[pitch-status]: https://github.com/apple/swift-experimental-string-processing/issues/107
[regex-dsl]: https://forums.swift.org/t/pitch-regex-builder-dsl/56007
