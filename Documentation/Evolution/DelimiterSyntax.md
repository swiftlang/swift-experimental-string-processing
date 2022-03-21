# Regular Expression Literal Delimiters

- Authors: Hamish Knight, Michael Ilseman, David Ewing

## Introduction

**TODO**

**TODO: Motivation for regex literals in the first place? Or is that a given?**

**TODO: Overview of regex literals in other languages?**

## Detailed Design

A regular expression literal will be introduced using `re'...'` delimiters, within which the compiler will parse a regular expression (the details of which are outlined in [the Regex Syntax pitch][internal-syntax]):

```
// Matches "<identifier> = <hexadecimal value>", extracting the identifier and hex number
let regex = re'([[:alpha:]]\w*) = ([0-9A-F]+)'
```

The use of a two letter prefix allows for easy future extensibility of such literals, by allowing different prefixes to indicate different types of literal. **TODO: examples**

### Regex limitations

There are a few items of regex grammar that use the single quote character as a metacharacter. These include named group definitions and references such as `(?'name')`, `(?('name'))`, `\g'name'`, `\k'name'`, as well as callout syntax `(?C'arg')`. The use of a single quote conflicts with the `re'...'` delimiter as it will be considered the end of the literal. Fortunately, alternative syntax exists for all of these constructs, e.g `(?<name>)`, `\k<name>`, and `(?C"arg")`.

As such, the single quote variants of the syntax will be considered invalid in a `re'...'` literal, and users must use the alternative syntax. If a raw variant of the syntax `re#'...'#` of the syntax is later added, that may also be used. In order to improve diagnostic behavior, the compiler will attempt to scan ahead when encountering the ending sequences `(?`, `(?(`, `\g`, `\k` and `(?C`. This will enable a more accurate error to be emitted that suggests the alternative syntax.

## Future Directions

### Raw literals

The `re'...'` syntax could be naturally extended to supporting "raw text" through allowing additional `#` characters to surround the quote characters e.g `re#'...'#`. Such literals would follow the same rules as the string literals introduced in [SE-0200].

In particular:

- `\` and `'` characters would become literal, e.g `re#''\n''#` expresses a regular expression pattern that literally matches against the characters `'\n'` (including the quotes).
- Any number of `#` characters may surround the literal.
- Escape sequences would require the same number of `#` characters as in the delimiter to be treated specially. For example, `re##'\##n'##` would be required for a newline character sequence.

### Multi-line literals

A natural extension to the `re'...'` syntax to support multi-line regex literals would be to allow triple quote syntax:

```
re'''
  abc
  def
  '''
```

This would follow the precedent set by [SE-0168] for multi-line string literals, and obey the same rules, in particular with the stripping of any leading whitespace prior to the position of the closing delimiter.

## Alternatives Considered

### Double quoted `re"...."`

We could choose to use double quotes instead of single quotes. This would be similar in appearance to string literals, however it could be argued that regex literals are distinct from string literals in that they introduce their own specific language to parse. As such, regex literals are more like "program literals" than "data literals", and the use of single quote instead of double quote could express this difference.

### Single letter `r'...'`

We could choose to shorten the literal prefix to just `r`. However this could potentially be confused to mean "raw", especially as Python uses this syntax for raw strings. The syntax `re'...'` could also set the precedent for a 2 letter namespace for future literals.

### Forward slashes `/.../`

Forward slashes are a regex term of art, and are used as the delimiters for regex literals in Perl, JavaScript and Ruby (though Perl and Ruby also provide alternative choices). However, they would be an awkward fit in Swift's language grammar, and would not provide a path for extensibility. Here we give an extensive list of drawbacks to the choice. While no individual issue is terribly bad and each could be overcome, the list of issues is quite long. 

#### Parsing ambiguities

The obvious parsing ambiguity with `/.../` delimiters is with comment syntaxes.

- An empty regex literal would conflict with line comment syntax `//`. But this isn't a particularly useful thing to express, and could be disallowed.

- The obvious choice for a multi-line regular expression literal would be to use `///` delimiters, in accordance with the precedent set by multi-line string literals `"""`. A different multi-line delimiter would be needed, with no obvious choice.

- There is also a conflict with block comment syntax, when surrounding a regex literal ending with `*`, for example:

```swift
/*
let regex = /x*/
*/
```

   In this case, the block comment would prematurely end on the second line, rather than extending all the way to the third line as the user would expect. This is already an issue today with `*/` in a string literal, however it is much more likely to occur in a regular expression given the prevalence of the `*` quantifier.

- Block comment syntax also means that a regex literal would not be able to start with the `*` character, however this is less of a concern as it would not be valid regex syntax.

- Finally, there would be a minor ambiguity with infix operators used with regex literals. When used without whitespace, e.g `x+/y/`, the expression will be treated as using an infix operator `+/`. Whitespace is therefore required `x + /y/` for regex literal interpretation.

#### Regex limitations

Another ambiguity with `/.../` arises when it is used to start a new line. This is particularly problematic for result builders, where we expect it to be frequently used, for example:

```swift
Builder {
   1
   / 2 /
   3
}
```

This is parsed as a single operator chain, however it is likely the user is expecting a regex literal. To resolve this ambiguity, a regex literal may not start with a space or tab character. This takes advantage of the fact that infix operators require consistent spacing.

If a space or tab is needed as the first character, it must be escaped, e.g:

```swift
Builder {
   1
   /\ 2 /
   3
}
```

**TODO: Regex starting with `)`**

#### Language changes required

In addition to ambiguities listed above, there are also some parsing ambiguities that would require the following language changes:

- Deprecation of prefix operators containing the `/` character.
- Potentially parsing `/,` as the start of a regex literal rather than an unapplied operator in an argument list e.g `fn(/, 5) + fn(/, 3)`.

<details><summary>Rationale</summary>
  
##### Prefix operators starting with `/`

We'd need to ban prefix operators starting with `/`, to avoid ambiguity with cases such as:

```swift
let x = /0; let y = 1/
let z = /^x^/
```
  
Postfix `/` operators would be okay, as they'd only be treated as regex literal delimiters if we were already trying to lex as a regex literal.

##### Prefix operators containing `/`
    
Prefix operators *containing* `/` (not just at the start) would likely need banning too, in order to allow prefix operators to be used with regex literals in an unambiguous way, e.g:
    
```swift
let x = !/y / .foo()
```
    
Otherwise it would be interpreted as the prefix operator `!/` by default, and require parens `!(/y /)` for regex parsing.



**TODO: More cases from slack discussion **

```swift
func foo(_ x: (Int, Int) -> Int, _ y: (Int, Int) -> Int) {}
foo(/, /)
```

`foo(/, "(") / 2` !!!


    
##### Comma as the starting character of a regex literal

**TODO: Or do we want to ban it as the starting character?**

#### Editor Considerations

As described above, there would be a lot involved in handling the parsing ambiguities with `/.../` delimiters. It's one thing to do this in the compiler. But the language also has to be understood by a plethora of source code editors. Those editors either need encode all those ambiguities, or they need to provide a "best effort" at handling the most common cases. It's all too common for editors to take the "best effort" route. There's a long history of complaints with editors that don't completely support a language's features. And indeed, there's plenty of history of editors that don't correctly support regular expression literals in other languages. By choosing a literal that is easily parsed, we should avoid seeing those complaints regarding Swift.

### Pound slash `#/.../#`

This would be less syntactically ambiguous than `/.../`, while retaining some of the term-of-art familiarity. It would also provide a natural path through which to introduce `/.../` in a new language mode, as users could drop the `#` characters once they upgrade.

However this option would also have the same block comment issue as `/.../` where e.g `#/x*/#` nested inside a block comment would prematurely end. Similarly, it's not clear how a multi-line version of the literal would be spelled.

Additionally, introducing this syntax would introduce an inconsistency with raw string literal syntax, as `#/.../#` on its own would not treat backslashes as literal, unlike `#"..."#`. If raw regex syntax were implemented, it would start at `##/.../##`. With raw strings, escape sequences must use the same number of `#`s as the delimiter, e.g `#"\#n"#` for a newline. However for raw regex literals it would be one fewer `#` than the delimiter e.g `##/\#n/##`.


[SE-0168]: https://github.com/apple/swift-evolution/blob/main/proposals/0168-multi-line-string-literals.md
[SE-0200]: https://github.com/apple/swift-evolution/blob/main/proposals/0200-raw-string-escaping.md
[internal-syntax]: https://forums.swift.org/t/pitch-regex-syntax/55711
