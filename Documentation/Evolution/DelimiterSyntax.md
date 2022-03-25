# Regex Literals

- Authors: Hamish Knight, Michael Ilseman, David Ewing

## Introduction

This proposal introduces regex literals to Swift source code. The proposed syntax mirrors literals in other programing languages such as Perl, JavaScript and Ruby. As in those languages, literals are delimited with the `/` character:

```swift
let re = /[0-9]+/
```

## Motivation

This proposal helps complete the story told in [Regex Type and Overview][regex-type] and [elsewhere][pitch-status]. Literals are compiled directly, allowing errors to be found at compile time, rather than at run time. Using a literal also allows editors to support features such as syntax coloring inside the literal, highlighting sub-structure of the regex, and conversion of the literal to an equivalent result builder DSL (see [Regex builder DSL][regex-dsl]). It would be difficult to support all of this if regexes could only be defined inside a string.


## Proposed solution

A regex literal will be introduced using `/.../` delimiters, within which the compiler will parse a regex (the details of which are outlined in [the Regex Syntax pitch][internal-syntax]):

```swift
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = /([[:alpha:]]\w*) = ([0-9A-F]+)/
```

The above regex literal will be inferred to be [the regex type][regex-type] `Regex<(Substring, Substring, Substring)>`, where the capture types have been automatically inferred. Errors in the regex will be diagnosed by the compiler.

Forward slashes are a regex term of art, and are used as the delimiters for regex literals in Perl, JavaScript and Ruby (though Perl and Ruby also provide alternatives). Their ubiquity and familiarity makes them a compelling choice for Swift.

Due to the existing use of `/` in comment syntax and operators, there are some syntactic ambiguities to consider. While there are quite a few cases to consider, we do not feel that the impact of any individual case is sufficient to disqualify the syntax. Some of these ambiguities require a couple of source breaking language changes, and as such the `/.../` syntax will require upgrading to a new language mode in order to use.

## Detailed design

Choosing `/` as the regex literal delimiter requires a number of ambiguities to be resolved. It also requires a couple of source breaking language changes to be introduced in a new language mode.

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

There would be a minor ambiguity with infix operators used with regex literals. When used without whitespace, e.g `x+/y/`, the expression will be treated as using an infix operator `+/`. Whitespace is therefore required `x + /y/` for regex literal interpretation.

### Regex syntax limitations

In order to help avoid further parsing ambiguities, a regex literal will not be parsed if it starts with a space, tab, or `)` character. Though the latter is already invalid regex syntax.

#### Rationale

This is due to 2 main ambiguities. The first of which arises when a `/.../` regex literal starts a new line. This is particularly problematic for result builders, where we expect it to be frequently used, for example:

```swift
Builder {
   1
   / 2 /
   3
}
```

This is parsed as a single operator chain, however it is likely the user is expecting a regex literal. To resolve this ambiguity, a regex literal may not start with a space or tab character. The above therefore remains an operator chain. This takes advantage of the fact that infix operators require consistent spacing on either side.

If a space or tab is needed as the first character, it must be escaped, e.g:

```swift
Builder {
   1
   /\ 2 /
   3
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

In addition to ambiguities listed above, there are also some parsing ambiguities that would require the following language changes in Swift 6 mode:

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

### Raw literals

The obvious choice here would follow string literals and use `#/.../#`.

**TODO: What backslash rules do we want?**

### Multi-line literals

The obvious choice for a multi-line regex literal would be to use `///` delimiters, in accordance with the precedent set by multi-line string literals `"""`. But this signifies a (documentation) comment, so a different multi-line delimiter would be needed, with no obvious choice. However, it's not clear that we need multi-line regex literals. The existing literals can be used inside a regex builder DSL. 

### Regex extended syntax

Allowing non-semantic whitespace and other features of the extended syntax would be highly desired, with no obvious choice for a literal. Perhaps the need is also lessened by the ability to use regex literals inside the regex builder DSL.

## Alternatives Considered

Given the fact that `/` is an existing term of art for regular expressions, we feel it should be the preferred delimiter syntax. While it has some syntactic ambiguities, we do not feel that they are sufficient to disqualify the syntax. To evaluate this trade-off, below is a list of alternative delimiters that would not have the same ambiguities.

### Pound slash `#/.../#`

This is a less syntactically ambiguous version of `/.../` that retains some of the term-of-art familiarity. It could potentially provide a natural path through which to introduce `/.../` in a new language mode, as users could drop the `#` characters once they upgrade.

However, introducing this as non-raw regex literal syntax would introduce an inconsistency with raw string literal syntax, as `#/.../#` on its own would not treat backslashes as literal, unlike `#"..."#`. If raw regex syntax was added, it would likely start at `##/.../##`. With raw strings, escape sequences must use the same number of `#`s as the delimiter, e.g `#"\#n"#` for a newline. However for raw regex literals it would be one fewer `#` than the delimiter e.g `##/\#n/##`.

**TODO: What backslash rules do we want?**

It should also be noted that this option has the same block comment issue as `/.../` where e.g `#/[0-9]*/#` nested inside a block comment would prematurely end. Similarly, it's not clear how a multi-line version of the literal would be spelled.

### Prefixed quote `re'...'`

We could choose to use `re'...'` delimiters, for example:

```swift
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = re'([[:alpha:]]\w*) = ([0-9A-F]+)'
```

The use of two letter prefix could potentially be used as a namespace for future literal types. It would also have obvious extensions to raw and multi-line literals using `re#'...'#` and `re'''...'''` respectively. However, it is unusual for a Swift literal to be prefixed in this way. We also feel that its similarity to a string literal might have users confuse it with a raw string literal. 

Also, there are a few items of regex grammar that use the single quote character as a metacharacter. These include named group definitions and references such as `(?'name')`, `(?('name'))`, `\g'name'`, `\k'name'`, as well as callout syntax `(?C'arg')`. The use of a single quote conflicts with the `re'...'` delimiter as it will be considered the end of the literal. However, alternative syntax exists for all of these constructs, e.g `(?<name>)`, `\k<name>`, and `(?C"arg")`. Those could be required instead. A raw regex literal syntax e.g `re#'...'#` would also avoid this issue.

### Prefixed double quote `re"...."`

This would be a double quoted version of `re'...'`, more similar to string literal syntax. This has the advantage that single quote regex syntax e.g `(?'name')` would continue to work without requiring the use of the alternative syntax or raw literal syntax. However it could be argued that regex literals are distinct from string literals in that they introduce their own specific language to parse. As such, regex literals are more like "program literals" than "data literals", and the use of single quote instead of double quote may be useful in expressing this difference.

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
