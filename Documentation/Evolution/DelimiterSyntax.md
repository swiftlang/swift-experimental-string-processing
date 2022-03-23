# Regular Expression Literal Delimiters

- Authors: Hamish Knight, Michael Ilseman, David Ewing

## Introduction

**TODO**

**TODO: Motivation for regex literals in the first place? Or is that a given?**

**TODO: Overview of regex literals in other languages?**

## Detailed Design

**TODO: Say that this is Swift 6 syntax only, `#/.../#` would be 5.7 syntax**

A regular expression literal will be introduced using `/.../` delimiters, within which the compiler will parse a regular expression (the details of which are outlined in [the Regex Syntax pitch][internal-syntax]):

```
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = /([[:alpha:]]\w*) = ([0-9A-F]+)/
```

Forward slashes are a regex term of art, and are used as the delimiters for regex literals in Perl, JavaScript and Ruby (though Perl and Ruby also provide alternative choices). Due to its existing use in comment syntax and operators, there are some syntactic ambiguities to consider. While there are quite a few cases to consider, we do not feel that the impact of any individual case is particularly high.

**TODO: Do we want to present a stronger argument for `/.../`?**

**TODO: Anything else we want to say here before segueing into the massive list?**

### Parsing ambiguities

The obvious parsing ambiguity with `/.../` delimiters is with comment syntaxes.

- An empty regex literal would conflict with line comment syntax `//`. But this isn't a particularly useful thing to express, and can therefore be disallowed without significant impact.

- The obvious choice for a multi-line regular expression literal would be to use `///` delimiters, in accordance with the precedent set by multi-line string literals `"""`. A different multi-line delimiter would be needed, with no obvious choice.

- There is a conflict with block comment syntax, when surrounding a regex literal ending with `*`, for example:

  ```swift
  /*
  let regex = /x*/
  */
  ```

   In this case, the block comment would prematurely end on the second line, rather than extending all the way to the third line as the user would expect. This is already an issue today with `*/` in a string literal, however it is much more likely to occur in a regular expression given the prevalence of the `*` quantifier.

- Block comment syntax also means that a regex literal would not be able to start with the `*` character, however this is less of a concern as it would not be valid regex syntax.

- Finally, there would be a minor ambiguity with infix operators used with regex literals. When used without whitespace, e.g `x+/y/`, the expression will be treated as using an infix operator `+/`. Whitespace is therefore required `x + /y/` for regex literal interpretation.

### Regex syntax limitations

In order to help avoid further parsing ambiguities, a regex literal will not be parsed if it starts with a space, tab, or `)` character. Though the latter is already invalid regex syntax.

<details><summary>Rationale</summary>

This is due to 2 main ambiguities. The first of which arises when a `/.../` regex literal starts a new line. This is particularly problematic for result builders, where we expect it to be frequently used, for example:

```swift
Builder {
   1
   / 2 /
   3
}
```

This is parsed as a single operator chain, however it is likely the user is expecting a regex literal. To resolve this ambiguity, a regex literal may not start with a space or tab character. This takes advantage of the fact that infix operators require consistent spacing on either side.

If a space or tab is needed as the first character, it must be escaped, e.g:

```swift
Builder {
   1
   /\ 2 /
   3
}
```

The second ambiguity arises with Swift's ability to pass an unapplied operator reference as an argument to a function, for example:

```swift
let arr: [Double] = [2, 3, 4]
let x = arr.reduce(1, /) / 5
```

The `/` in the call to `reduce` is in a valid expression context, and as such could be parsed as a regex literal. This is also applicable to operators in tuples and parentheses. To help mitigate this ambiguity, a regex literal will not be parsed if the first character is `)`. This should have minimal impact, as this would not be valid regex syntax anyway.

It should be noted that this only mitigates the issue, as it does not handle the case where the next character is a comma or right square bracket. These cases are explored further in the following section.

</details>

### Language changes required

In addition to ambiguities listed above, there are also some parsing ambiguities that would require the following language changes in Swift 6 mode:

- Deprecation of prefix operators containing the `/` character.
- Parsing `/,` and `/]` as the start of a regex literal if a closing `/` is found, rather than an unapplied operator in an argument list. For example, `fn(/, /)` becomes a regex literal rather than 2 unapplied operator arguments.

<details><summary>Rationale</summary>
  
#### Prefix operators starting with `/`

We'd need to ban prefix operators starting with `/`, to avoid ambiguity with cases such as:

```swift
let x = /0; let y = 1/
let z = /^x^/
```
  
Postfix `/` operators would be okay, as they'd only be treated as regex literal delimiters if we were already trying to lex as a regex literal.

#### Prefix operators containing `/`
    
Prefix operators *containing* `/` (not just at the start) would likely need banning too, in order to allow prefix operators to be used with regex literals in an unambiguous way, e.g:
    
```swift
let x = !/y / .foo()
```
    
Otherwise it would be interpreted as the prefix operator `!/` by default, and require parens `!(/y /)` for regex parsing.
    
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

**TODO: Do we want to talk about a heuristic that looks for unbalanced parens? I'm kind of hesitant to implement that, as it would have edge cases and might screw with regex errors that should be diagnosed as invalid regex, rather than some cryptic Swift syntactic error. Which would also make it harder to explain to users.**

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

### Editor Considerations

**TODO: Rewrite now that `/.../` is the syntax being pitched?**

As described above, there would be a lot involved in handling the parsing ambiguities with `/.../` delimiters. It's one thing to do this in the compiler. But the language also has to be understood by a plethora of source code editors. Those editors either need encode all those ambiguities, or they need to provide a "best effort" at handling the most common cases. It's all too common for editors to take the "best effort" route. There's a long history of complaints with editors that don't completely support a language's features. And indeed, there's plenty of history of editors that don't correctly support regular expression literals in other languages. By choosing a literal that is easily parsed, we should avoid seeing those complaints regarding Swift.


### Pound slash `#/.../#`

**TODO: This needs to be rewritten to say that it's a transition syntax**

This would be less syntactically ambiguous than `/.../`, while retaining some of the term-of-art familiarity. It would also provide a natural path through which to introduce `/.../` in a new language mode, as users could drop the `#` characters once they upgrade.

However this option would also have the same block comment issue as `/.../` where e.g `#/x*/#` nested inside a block comment would prematurely end. Similarly, it's not clear how a multi-line version of the literal would be spelled.

Additionally, introducing this syntax would introduce an inconsistency with raw string literal syntax, as `#/.../#` on its own would not treat backslashes as literal, unlike `#"..."#`. If raw regex syntax were implemented, it would start at `##/.../##`. With raw strings, escape sequences must use the same number of `#`s as the delimiter, e.g `#"\#n"#` for a newline. However for raw regex literals it would be one fewer `#` than the delimiter e.g `##/\#n/##`.

## Future Directions

**TODO: What do we want to say here?**

## Alternatives Considered

### Prefixed quote `re'...'`

We could choose to use `re'...'` delimiters, for example:

```
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = re'([[:alpha:]]\w*) = ([0-9A-F]+)'
```

The use of two letter prefix could potentially be used as a namespace for future literal types. However, it is unusual for a Swift literal to be prefixed in this way.

**TODO: Fill in reasons why not to pick this**

**TODO: Mention that it nicely extends to raw and multiline?**

#### Regex syntax limitations

There are a few items of regex grammar that use the single quote character as a metacharacter. These include named group definitions and references such as `(?'name')`, `(?('name'))`, `\g'name'`, `\k'name'`, as well as callout syntax `(?C'arg')`. The use of a single quote conflicts with the `re'...'` delimiter as it will be considered the end of the literal. Fortunately, alternative syntax exists for all of these constructs, e.g `(?<name>)`, `\k<name>`, and `(?C"arg")`.

As such, the single quote variants of the syntax would be considered invalid in a `re'...'` literal, and users must use the alternative syntax instead. If a raw variant of the syntax `re#'...'#` of the syntax is later added, that may also be used. In order to improve diagnostic behavior, the compiler would attempt to scan ahead when encountering the ending sequences `(?`, `(?(`, `\g`, `\k` and `(?C`. This would enable a more accurate error to be emitted that suggests the alternative syntax.

### Prefixed double quote `re"...."`

This would be a double quoted version of `re'...'`, more similar to string literal syntax. This has the advantage that single quote regex syntax e.g `(?'name')` would continue to work without requiring the use of the alternative syntax or "raw syntax" delimiters. However it could be argued that regex literals are distinct from string literals in that they introduce their own specific language to parse. As such, regex literals are more like "program literals" than "data literals", and the use of single quote instead of double quote may be useful in expressing this difference.

### Single letter prefixed quote `r'...'`

This would be a slightly shorter version of `re'...'`. While it's more concise, it could potentially be confused to mean "raw", especially as Python uses this syntax for raw strings.

### Single quotes `'...'`

This would be an even more concise version of `re'...'` that drops the prefix entirely. However, given how close it is to string literal syntax, it may not be entirely clear to users that `'...'` denotes a regular expression as opposed to some different form of string literal (e.g some form of character literal, or a string literal with different escaping rules).

We could help distinguish it from a string literal by requiring e.g `'/.../'`, though it may not be clear that the `/` characters are part of the delimiters rather than part of the literal. Additionally, this would potentially rule out the use of `'...'` as a future literal kind. 

### Magic literal `#regex(...)`

We could opt for for a more explicitly spelled out literal syntax such as `#regex(...)`. This is a more heavyweight option, similar to `#selector(...)`. As such, it may be considered syntactically noisy as e.g a function argument `str.match(#regex([abc]+))` vs `str.match(/[abc]+/)`.

Such a syntax would require the containing regex to correctly balance capture group parentheses, otherwise the rest of the line might be incorrectly considered a regex. This could place additional cognitive burden on the user, and may lead to an awkward typing experience. For example, if the user is editing a previously written regex, the syntax highlighting for the rest of the line may change, and unhelpful spurious errors may be reported. With a different delimiter, the compiler would be able to detect and better diagnose unbalanced parentheses in the regex.

We could avoid the parenthesis balancing issue by requiring an additional internal delimiter such as `#regex(/.../)`. However it is even more heavyweight, and it may be unclear that `/` is part of the delimiter rather than part of the literal. Alternatively, we could replace the internal delimiter with another character such as ```#regex`...` ```, `#regex{...}`, or `#regex/.../`. However those would be inconsistent with the existing `#literal(...)` syntax and the first two would overload the existing meanings for the ``` `` ``` and `{}` delimiters.

It should also be noted that `#regex(...)` would introduce a syntactic inconsistency where the argument of a `#literal(...)` is no longer necessarily valid Swift syntax, despite being written in the form of an argument.

### Shortened magic literal `#(...)`

We could reduce the visual weight of `#regex(...)` by only requiring `#(...)`. However it would still retain the same issues, such as still looking potentially visually noisy as an argument, and having suboptimal behavior for parenthesis balancing. It is also not clear why regex literals would deserve such privileged syntax.

### Reusing string literal syntax

Instead of supporting a first-class literal kind for regular expressions, we could instead allow users to write a regular expression in a string literal, and parse, diagnose, and generate the appropriate code when it's coerced to an `ExpressibleByRegexLiteral` conforming type.

```swift
let regex: Regex = #"([[:alpha:]]\w*) = ([0-9A-F]+)"#
```

However we decided against this because:

- We would not be able to easily apply custom syntax highlighting for the regex syntax.
- It would require an `ExpressibleByRegexLiteral` contextual type to be treated as a regex, otherwise it would be defaulted to `String`, which may be undesired.
- In an overloaded context it may be ambiguous or unclear whether a string literal is meant to be interpreted as a literal string or regex.
- Regex-specific escape sequences such as `\w` would likely require the use of raw string syntax `#"..."#`, as they are otherwise invalid in a string literal.
- It wouldn't be compatible with other string literal features such as interpolations.

### No custom literal

Instead of adding a custom regex literal, we could require users to explicitly write `Regex(compiling: "[abc]+")`. This would however lose all the benefits of parsing the literal at compile time, meaning that parse errors will instead be diagnosed at runtime, and no source tooling support (e.g syntax highlighting, refactoring actions) would be available. 

[SE-0168]: https://github.com/apple/swift-evolution/blob/main/proposals/0168-multi-line-string-literals.md
[SE-0200]: https://github.com/apple/swift-evolution/blob/main/proposals/0200-raw-string-escaping.md
[internal-syntax]: https://forums.swift.org/t/pitch-regex-syntax/55711
