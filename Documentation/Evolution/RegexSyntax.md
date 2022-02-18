<!--
Hello, we want to issue an update to [Regular Expression Literals](https://forums.swift.org/t/pitch-regular-expression-literals/52820) and prepare for a formal proposal. The great delimiter delibration continues to unfold, so in the meantime, we have a significant amount of surface area to present for review/feedback: the syntax _inside_ a regex literal.
-->

# Regex Literal Interior Syntax

- Authors: Hamish Knight, Michael Ilseman

## Introduction

Regex literals declare a string processing algorithm using syntax familiar across a variety of languages and tools throughout programming history. Formalizing regex literals in Swift requires choosing a delimiter strategy (e.g. `#/.../#` or `re'...'`), detailing the syntax accepted in between the delimiters ("interior syntax"), and specifying actual types and any relevant protocols for the literal itself.

This proposal-component focuses on the interior syntax, which is large enough for its own targeted discussion ahead of the full proposal. Regex literal interior syntax will be part of Swift's source-compatibility story (and to some extent binary compatibility), so we present a detailed and comprehensive design.

## Motivation

Swift aims to be a pragmatic programming language, balancing (TODO: prose). Rather than pursue a novel interior syntax, (TODO: prose).

Regex interior syntax is part of a larger [proposal](https://forums.swift.org/t/pitch-regular-expression-literals/52820), which in turn is part of a larger [string processing effort](https://forums.swift.org/t/declarative-string-processing-overview/52459).

## Proposed Solution

We propose accepting a syntactic "superset" of the following existing regular expression engines:

- [PCRE 2][pcre2-syntax], an "industry standard" and a rough superset of Perl, Python, etc.
- [Oniguruma][oniguruma-syntax], a modern engine with additional features.
- [ICU][icu-syntax], used by NSRegularExpression, a Unicode-focused engine.
- [.NET][.net-syntax], which adds delimiter-balancing and some interesting minor details around conditional patterns.

To our knowledge, all other popular regex engines support a subset of the above syntaxes.

We also support [UTS#18][uts18]'s full set of character class operators (to our knowledge no other engine does). Beyond that, UTS#18 deals with semantics rather than syntax, and what syntax it uses is covered by the above list. We also parse `\p{javaLowerCase}`, meaning we support a superset of Java 8 as well.

Note that there are minor syntactic incompatibilities and ambiguities involved in this approach. Each is addressed in the relevant sections below


## Detailed Design

We're proposing the following regular expression syntactic superset for Swift.

### Top-level regular expression

```
Regex     -> GlobalMatchingOptionSequence? RegexNode
RegexNode -> '' | Alternation
```

A top-level regular expression may consist of a sequence of global matching options followed by a `RegexNode`, which is the recursive part of the grammar that may be nested within e.g a group. A regex node may be empty, which is the null pattern that always matches, but does not advance the input.

### Alternation

```
Alternation -> Concatenation ('|' Concatenation)*
```

The `|` operator denotes what is formally called an alternation, or a choice between alternatives. Any number of alternatives may appear, including empty alternatives. This operator has the lowest precedence of all operators in a regex literal.

### Concatenation

```
Concatenation   -> (!'|' !')' ConcatComponent)*
ConcatComponent -> Trivia | Quote | Quantification
```

Implicitly denoted by adjacent expressions, a concatenation matches against a sequence of regular expression patterns. This has a higher precedence than an alternation, so e.g `abc|def` matches against `abc` or `def`. The `ConcatComponent` token varies across engine, but at least matches some form of trivia, e.g comments, quoted sequences e.g `\Q...\E`, and a potentially quantified expression.

### Quantification

```
Quantification -> QuantOperand Quantifier?
Quantifier     -> QuantAmount QuantKind?
QuantAmount    -> '?' | '*' | '+' | '{' Range '}'
QuantKind      -> '?' | '+'
Range          -> ',' <Int> | <Int> ',' <Int>? | <Int>

QuantOperand -> AbsentFunction | Atom | Conditional | CustomCharClass | Group
```

A quantification consists of an operand optionally followed by a quantifier that specifier how many times it may be matched. An operand without a quantifier is matched once.

The quantifiers supported are:

- `?`: 0 or 1 matches
- `*`: 0 or more matches
- `+`: 1 or more matches
- `{n,m}`: Between `n` and `m` (inclusive) matches
- `{n,}`: `n` or more matches
- `{,m}`: Up to `m` matches
- `{n}`: Exactly `n` matches

A quantifier may optionally be followed by `?` or `+`, which adjust its semantics. If neither are specified, by default the quantification happens *eagerly*, meaning that it will try to maximize the number of matches made. However, if `?` is specified, quantification happens *reluctantly*, meaning that the number of matches will instead be minimized. If `+` is specified, *possessive* matching occurs, which is eager matching with the additional semantic that it may not be backtracked into to try a different number of matches.

### Atom

```
Atom -> Anchor
      | Backreference
      | BacktrackingDirective
      | BuiltinCharClass
      | Callout
      | CharacterProperty
      | EscapeSequence
      | NamedCharacter
      | Subpattern
      | UniScalar
      | '\'? <Character>
```

Atoms are the smallest units of regular expression syntax. They include escape sequences e.g `\b`, `\d`, as well as meta-characters such as `.` and `$`. They also include some larger syntactic constructs such as backreferences and callouts. The most basic form of atom is a literal character. A meta-character may be treated as literal by preceding it with a backslash. Other characters may also be preceded with a backslash, but it has no effect, e.g `\I` is literal `I`.

### Groups

```
Group      -> GroupStart RegexNode ')'
GroupStart -> '(' GroupKind | '('
GroupKind  -> '' | '?' BasicGroupKind | '*' PCRE2GroupKind ':'

BasicGroupKind -> ':' | '|' | '>' | '=' | '!' | '*' | '<=' | '<!' | '<*'
                | NamedGroup 
                | MatchingOptionSeq (':' | ')')
                
PCRE2GroupKind -> 'atomic' 
                | 'pla' | 'positive_lookahead'
                | 'nla' | 'negative_lookahead'
                | 'plb' | 'positive_lookbehind'
                | 'nlb' | 'negative_lookbehind'
                | 'napla' | 'non_atomic_positive_lookahead'
                | 'naplb' | 'non_atomic_positive_lookbehind'
                | 'sr' | 'script_run'
                | 'asr' | 'atomic_script_run'

NamedGroup -> 'P<' GroupNameBody '>'
            | '<' GroupNameBody '>'
            | "'" GroupNameBody "'"

GroupNameBody -> Identifier | BalancingGroupBody

Identifier -> [\w--\d] \w*
```

Groups define a new scope within which a recursive regular expression pattern may occur. Groups have different semantics depending on how they are introduced, some may capture the nested match, some may match against the input without advancing, some may change the matching options set in the new scope, etc.

Groups may be named, the characters of which may be any letter or number characters (or `_`). However the name must not start with a number. This restriction follows the behavior of other regex engines and avoids ambiguities when it comes to named and numeric group references.

Groups may be used to change the matching options present within their scope, see the *Matching options* section.

Note there are additional constructs that may syntactically appear similar to groups, but are distinct. See the *group-like atoms* section.


#### Lookahead and lookbehind

- `(?=` specifies a lookahead that attempts to match against the group body, but does not advance.
- `(?!` specifies a negative lookahead that ensures the group body does not match, and does not advance.
- `(?<=` specifies a lookbehind that attempts to match the group body against the input before the current position. Does not advance the input.
- `(?!<` specifies a negative lookbehind that ensures the group body does not match the input before the current position. Does not advance the input.

PCRE2 defines explicitly spelled out versions of the syntax, e.g `(*negative_lookbehind:)`.

#### Atomic groups

An atomic group e.g `(?>...)` specifies that its contents should not be re-evaluated for backtracking. This the same semantics as a possessive quantifier, but applies more generally to any regex pattern.

#### Script runs

A script run e.g `(*script_run:...)` specifies that the contents must match against a sequence of characters from the same Unicode script, e.g Latin or Greek.

#### Balancing groups

```
BalancingGroupBody -> Identifier? '-' Identifier
```

Introduced by .NET, balancing groups extend the `GroupNameBody` syntax to support the ability to refer to a prior group. Upon matching, the prior group is deleted, and any intermediate matched input becomes the capture of the current group.

### Matching options

```
MatchingOptionSeq -> '^' MatchingOption* 
                   | MatchingOption+ 
                   | MatchingOption* '-' MatchingOption*

MatchingOption -> 'i' | 'J' | 'm' | 'n' | 's' | 'U' | 'x' | 'xx' | 'w' | 'D' | 'P' | 'S' | 'W' | 'y{' ('g' | 'w') '}'
```

A matching option sequence may be used as a group specifier, and denotes a change in matching options for the scope of that group. For example `(?x:a b c)` enables extended syntax for `a b c`. A matching option sequence may be part of an "isolated group" which has an implicit scope that wraps the remaining elements of the current group. For example, `(?x)a b c` also enables extended syntax for `a b c`.

We support all the matching options accepted by PCRE, ICU, and Oniguruma. In addition, we accept some matching options unique to our matching engine.

#### PCRE options

- `i`: Case insensitive matching
- `J`: Allows multiple groups to share the same name, which is otherwise forbidden
- `m`: Enables `^` and `$` to match against the start and end of a line rather than only the start and end of the entire string
- `n`: Disables capturing of `(...)` groups. Named capture groups must be used instead. 
- `s`: Changes `.` to match any character, including newlines.
- `U`: Changes quantifiers to be reluctant by default, with the `?` specifier changing to mean greedy.
- `x`, `xx`: Enables extended syntax mode, which allows non-semantic whitespace and end-of-line comments. See the *trivia* section for more info.

#### ICU options

- `w`: Enables the Unicode interpretation of word boundaries `\b`.

#### Oniguruma options
      
- `D`: Enables ASCII-only digit matching for `\d`, `\p{Digit}`, `[:digit:]`
- `S`: Enables ASCII-only space matching for `\s`, `\p{Space}`, `[:space:]`
- `W`: Enables ASCII-only word matching for `\w`, `\p{Word}`, `[:word:]`, and `\b`
- `P`: Enables ASCII-only for all POSIX properties (including `digit`, `space`, and `word`)
- `y{g}`, `y{w}`: Changes the meaning of `\X`, `\y`, `\Y`. These are mutually exclusive options, with `y{g}` specifying extended grapheme cluster mode, and `y{w}` specifying word mode.

#### Swift options

These options are specific to the Swift regex matching engine and control the semantic level at which matching takes place.

- `X`: Grapheme cluster matching
- `u`: Unicode scalar matching
- `b`: Byte matching


### Anchors

```
Anchor -> '^' | '$' | '\A' | '\b' | '\B' | '\G' | '\y' | '\Y' | '\z' | '\Z'
```

Anchors match against a certain position in the input rather than on a particular character of the input.

- `^`: Matches at the start of a line.
- `$`: Matches at the end of a line.
- `\A`: Matches at the very start of the input string.
- `\Z`: Matches at the very end of the input string, in addition to before a newline at the very end of the input string.
- `\z`: Like `\Z`, but only matches at the very end of the input string.
- `\G`: Like `\A`, but also matches against the start position of where matching resumes in global matching mode (e.g `\Gab` matches twice in `abab`, `\Aab` would only match once).
- `\b` matches a boundary between a word character and a non-word character. The definitions of which vary depending on matching engine.
- `\B` matches a non-word-boundary. 
- `\y` matches a text segment boundary, the definition of which varies based on the `y{w}` and `y{g}` matching option.
- `\Y` matches a non-text-segment-boundary.

### Unicode scalars

```
UniScalar -> '\u{' HexDigit{1...} '}'
           | '\u'  HexDigit{4}
           | '\x{' HexDigit{1...} '}'
           | '\x'  HexDigit{0...2}
           | '\U'  HexDigit{8}
           | '\o{' OctalDigit{1...} '}'
           | '\0' OctalDigit{0...3}

HexDigit   -> [0-9a-zA-Z]
OctalDigit -> [0-7]
```

These sequences define a unicode scalar value to be matched against. There is both syntax for specifying the scalar value in hex notation, as well as octal notation.

### Escape sequences

```
EscapeSequence -> '\a' | '\b' | '\c' <Char> | '\e' | '\f' | '\n' | '\r' | '\t'
```

These escape sequences denote a specific character.

- `\a`: The alert (bell) character `U+7`.
- `\b`: The backspace character `U+8`. Note this may only be used in a custom character class, otherwise it represents a word boundary.
- `\c <Char>`: A control character sequence (`U+00` - `U+7F`).
- `\e`: The escape character `U+1B`.
- `\f`: The form-feed character `U+C`.
- `\n`: The newline character `U+A`.
- `\r`: The carriage return character `U+D`.
- `\t`: The tab character `U+9`

### Builtin character classes

```
BuiltinCharClass -> '.' | '\d' | '\D' | '\h' | '\H' | '\N' | '\O' | '\R' | '\s' | '\S' | '\v' | '\V' | '\w' | '\W' | '\X'
```

- `.`: Any character excluding newlines
- `\d`: Digit character
- `\D`: Non-digit character
- `\h`: Horizontal space character
- `\H`: Non-horizontal-space character
- `\N`: Non-newline character
- `\O`: Any character (including newlines). This is syntax from Oniguruma.
- `\R`: Newline sequence
- `\s`: Whitespace character
- `\S`: Non-whitespace character
- `\v`: Vertical space character
- `\V`: Non-vertical-space character
- `\w`: Word character
- `\W`: Non-word character
- `\X`: Any extended grapheme cluster

### Custom character classes

```
CustomCharClass -> Start Set (SetOp Set)* ']'
Start           -> '[' '^'?
Set             -> Member+
Member          -> CustomCharClass | Quote | Range | Atom
Range           -> RangeElt `-` RangeElt
RangeElt        -> <Char> | UniScalar | EscapeSequence
SetOp           -> '&&' | '--' | '~~' | '-'
```

Custom characters classes introduce their own language, in which most regular expression metacharacters become literal. The basic element in a custom character class is an `Atom`, though only a few atoms are considered valid:

- Builtin character classes, except `.`, `\O`, `\X`, and `\N`.
- Escape sequences, including `\b` which becomes the backspace character (rather than a word boundary)
- Unicode scalars
- Named characters
- Character properties
- Plain literal characters

Atoms may be used to compose other character class members, including ranges, quoted sequences, and even nested custom character classes `[[ab]c\d]`. Adjacent members form an implicit union of character classes, e.g `[[ab]c\d]` is the union of the characters `a`, `b`, `c`, and digit characters.

Quoted sequences may be used to escape the contained characters, e.g `[\Q]\E]` is the character class of the literal character `[`.

Ranges of characters may be specified with `-`, e.g `[a-z]` matches against the letters from `a` to `z`. Only unicode scalars and literal characters are valid range operands. If `-` appears at the start or end of a custom character class, it is interpreted as literal, e.g `[-a-]` is the character class of `-` and `a`.

Operators may be used to apply set operations to character class members. The operators supported are:

- `&&`: Intersection of the LHS and RHS
- `--`: Subtraction of the RHS from the LHS
- `~~`: Symmetric difference of the RHS and LHS
- `-`: .NET's spelling of subtracting the RHS from the LHS.

These operators have a lower precedence than the implicit union of members, e.g `[ac-d&&a[d]]` is an intersection of the character classes `[ac-d]` and `[ad]`.

To avoid ambiguity between .NET's subtraction syntax and range syntax, .NET specifies that a subtraction will only be parsed if the right-hand-side is a nested custom character class. We intend to follow this behavior.

### Character properties

```
CharacterProperty      -> '\' ('p' | 'P') '{' PropertyContents '}'
POSIXCharacterProperty -> '[:' PropertyContents ':]'

PropertyContents -> PropertyName ('=' PropertyName)?
PropertyName     -> [\s\w-]+
```

A character property specifies a particular Unicode or POSIX property to match against. Fuzzy matching is used when parsing the property name, and is done according to rules set out by [UAX44-LM3]. This means that the following property names are considered equivalent:

- `whitespace`
- `isWhitespace`
- `is-White_Space`
- `iSwHiTeSpaCe`
- `i s w h i t e s p a c e`

Unicode properties consist of both a key and a value, e.g `General_Category=Whitespace`. However there are some properties where the key or value may be inferred. These include:

- General category properties e.g `\p{Whitespace}` is inferred as `\p{General_Category=Whitespace}`.
- Script properties e.g `\p{Greek}` is inferred as `\p{Script=Greek}`.
- Boolean properties that are inferred to have a `True` value, e.g `\p{Lowercase}` is inferred as `\p{Lowercase=True}`.

Other Unicode properties however must specify both a key and value.

For non-Unicode properties, only a value is required. These include:

- The special properties `any`, `assigned`, `ascii`.
- The POSIX compatibility properties `alnum`, `blank`, `graph`, `print`, `word`, `xdigit`. The remaining POSIX properties are already covered by boolean Unicode property spellings. 

**TODO: Spell out the properties we recognize while parsing vs. those we just parse as String?**

Note that the internal `PropertyContents` syntax is shared by both the `\p{...}` and POSIX-style `[:...:]` syntax, allowing e.g `[:script=Latin:]` as well as `\p{alnum}`.

### Named characters

```
NamedCharacter -> '\N{' CharName '}'
CharName -> 'U+' HexDigit{1...8} | [\s\w-]+
```

Allows a specific Unicode scalar to be specified by name or code point.

**TODO: Should this be called "named scalar" or similar?**

### Trivia

```
Trivia  -> Comment | Whitespace
Comment -> InlineComment | EndOfLineComment

InlineComment    -> '(?#' (!')')* ')'
EndOfLineComment -> '#' .*$

Whitespace -> \s+
```

Trivia is consumed by the regular expression parser, but has no semantic meaning. This includes inline PCRE-style comments e.g `(?#comment)`. It also includes non-semantic whitespace and end-of-line comments which may only occur when either of the extended syntax matching options `(?x)`, `(?xx)` are enabled.

### Quotes

```
Quote -> '\Q' (!'\E' .)* '\E'
```

A quoted sequence is delimited by `\Q...\E`, and allows the escaping of metacharacters such that they are interpreted literally. For example, `\Q^[xy]+$\E`, is treated as the literal characters `^[xy]+$` rather than an anchored quantified character class.

The backslash character is also treated as literal within a quoted sequence, and may not be used to escape the closing delimiter, e.g `\Q\\E` is a literal `\`.

`\E` may appear without a preceding `\Q`, in which case it is a literal `E`.

### References

```
NamedRef       -> Identifier
NumberRef      -> ('+' | '-')? <Decimal Number> RecursionLevel?
RecursionLevel -> '+' <Int> | '-' <Int>
```

A reference is an abstract identifier for a particular capturing group in a regular expression. It can either be named or numbered, and in the latter case may be specified relative to the current group. For example `-2` refers to the capture group `N - 2` where `N` is the number of the next capture group. References may refer to groups ahead of the current position e.g `+3`, or the name of a future group. These may be useful in recursive cases where the group being referenced has been matched in a prior iteration.

**TODO: Describe how capture groups are numbered? Including nesting & resets?**

#### Backreferences

```
Backreference -> '\g{' NameOrNumberRef '}'
               | '\g' NumberRef
               | '\k<' Identifier '>'
               | "\k'" Identifier "'"
               | '\k{' Identifier '}'
               | '\' [1-9] [0-9]+
               | '(?P=' Identifier ')'
```

A backreference evaluates to the value last captured by the referenced capturing group.

#### Subpatterns

```
Subpattern -> '\g<' NameOrNumberRef '>' 
            | "\g'" NameOrNumberRef "'"
            | '(?' GroupLikeSubpatternBody ')'
            
GroupLikeSubpatternBody -> 'P>' <String>
                         | '&' <String>
                         | 'R'
                         | NumberRef
```

A subpattern causes the referenced group to be re-evaluated at the current position. The syntax `(?R)` is equivalent to `(?0)`, and causes the entire pattern to be recursed.

### Conditionals

```
Conditional      -> ConditionalStart Concatenation ('|' Concatenation)? ')'
ConditionalStart -> KnownConditionalStart | GroupConditionalStart

KnownConditionalStart -> '(?(' KnownCondition ')'
GroupConditionalStart -> '(?' GroupStart

KnownCondition -> 'R'
                | 'R' NumberRef
                | 'R&' <String> !')'
                | '<' NameRef '>'
                | "'" NameRef "'"
                | 'DEFINE'
                | 'VERSION' VersionCheck
                | NumberRef
                | NameRef
                
PCREVersionCheck  -> '>'? '=' PCREVersionNumber
PCREVersionNumber -> <Int> '.' <Int>
```

A conditional evaluates a particular condition, and chooses a branch to match against accordingly. 1 or 2 branches may be specified. If 1 branch is specified e.g `(?(...)x)`, it is treated as the true branch. Note this includes an empty true branch, e.g `(?(...))` which is the null pattern as described in *top-level regular expression*. If 2 branches are specified, e.g `(?(...)x|y)`, the first is treated as the true branch, the second being the false branch.

A condition may be:

- A reference to a capture group, which checks whether the group matched successfully.
- A recursion check on either a particular group or the entire regex. In the former case, this checks to see if the last recursive call is through that group. In the latter case, it checks if the match is currently taking place in any kind of recursive call.
- An arbitrary recursive regular expression, which is matched against, and evaluates to true if the match is successful. (**TODO: Clarify whether it introduces captures**)
- A PCRE version check.

The `DEFINE` keyword is not used as a condition, but rather a way in which to define a group which is not evaluated, but may be referenced by a subpattern.

### PCRE backtracking directives

```
BacktrackingDirective     -> '(*' BacktrackingDirectiveKind (':' <String>)? ')'
BacktrackingDirectiveKind -> 'ACCEPT' | 'FAIL' | 'F' | 'MARK' | '' | 'COMMIT' | 'PRUNE' | 'SKIP' | 'THEN'
```

This is syntax specific to PCRE, and is used to control backtracking behavior. Any of the directives may include an optional tag, however `MARK` must have a tag. The empty directive is treated as `MARK`. Only the `ACCEPT` directive may be quantified, as it can use the backtracking behavior of the engine to be evaluated only if needed by a reluctant quantification.

- `ACCEPT`: Causes matching to terminate immediately as a successful match. If used within a subpattern, only that level of recursion is terminated.
- `FAIL`, `F`: Causes matching to fail, forcing backtracking to occur if possible.
- `MARK`: Assigns a label to the current matching path, which is passed back to the caller on success. Subsequent `MARK` directives overwrite the label assigned, so only the last is passed back.
- `COMMIT`: Prevents backtracking from reaching any point prior to this directive, causing the match to fail. This does not allow advancing the input to try a different starting match position.
- `PRUNE`: Similar to `COMMIT`, but allows advancing the input to try and find a different starting match position.
- `SKIP`: Similar to `PRUNE`, but skips ahead to the position of `SKIP` to try again as the starting position.
- `THEN`: Similar to `PRUNE`, but when used inside an alternation will try to match in the subsequent branch before attempting to advance the input to find a different starting position.

### PCRE global matching options

```
GlobalMatchingOptionSequence -> GlobalMatchingOption+
GlobalMatchingOption -> '(*' GlobalMatchingOptionKind ')'

GlobalMatchingOptionKind -> LimitOptionKind '=' <Int>
                          | NewlineKind | NewlineSequenceKind
                          | 'NOTEMPTY_ATSTART' | 'NOTEMPTY'
                          | 'NO_AUTO_POSSESS' | 'NO_DOTSTAR_ANCHOR'
                          | 'NO_JIT' | 'NO_START_OPT' | 'UTF' | 'UCP'
  
LimitOptionKind     -> 'LIMIT_DEPTH' | 'LIMIT_HEAP' | 'LIMIT_MATCH'
NewlineKind         -> 'CRLF' | 'CR' | 'ANYCRLF' | 'ANY' | 'LF' | 'NUL'
NewlineSequenceKind -> 'BSR_ANYCRLF' | 'BSR_UNICODE'
```

This is syntax specific to PCRE, and allows a set of global options to appear at the start of a regular expression. They may not appear at any other position.

- `LIMIT_DEPTH`, `LIMIT_HEAP`, `LIMIT_MATCH`: These place certain limits on the resources the matching engine may consume, and matches it may make.
- `CRLF`, `CR`, `ANYCRLF`, `ANY`, `LF`, `NUL`: These control the definition of a newline character, which is used when matching e.g the `.` character class, and evaluating where a line ends in multi-line mode.
- `BSR_ANYCRLF`, `BSR_UNICODE`: These change the definition of `\R`.
- `NOTEMPTY`: Does not consider the empty string to be a valid match.
- `NOTEMPTY_ATSTART`: Like `NOT_EMPTY`, but only applies to the first matching position in the input.
- `NO_AUTO_POSSESS`: Disables an optimization that treats a quantifier as possessive if the following construct clearly cannot be part of the match. In other words, disables the short-circuiting of backtracks in cases where the engine knows it will not produce a match. This is useful for debugging, or for ensuring a callout gets invoked.
- `NO_DOTSTAR_ANCHOR`: Disables an optimization that tries to automatically anchor `.*` at the start of a regex. Like `NO_AUTO_POSSESS`, this is mainly used for debugging or ensuring a callout gets invoked.
- `NO_JIT`: Disables JIT compilation
- `NO_START_OPT`: Disables various optimizations performed at the start of matching. Like `NO_DOTSTAR_ANCHOR`, is mainly used for debugging or ensuring a callout gets invoked.
- `UTF`: Enables UTF pattern support.
- `UCP`: Enables Unicode property support.

### Callouts

```
Callout -> PCRECallout | OnigurumaCallout

PCRECallout -> '(?C' CalloutBody ')'
PCRECalloutBody -> '' | <Number>
                 | '`' <String> '`'
                 | "'" <String> "'"
                 | '"' <String> '"'
                 | '^' <String> '^'
                 | '%' <String> '%'
                 | '#' <String> '#'
                 | '$' <String> '$'
                 | '{' <String> '}'
                 
OnigurumaCallout -> OnigurumaNamedCallout | OnigurumaCalloutOfContents

OnigurumaNamedCallout   -> '(*' Identifier OnigurumaTag? OnigurumaCalloutArgs? ')'
OnigurumaCalloutArgs    -> '{' OnigurumaCalloutArgList '}'
OnigurumaCalloutArgList -> OnigurumaCalloutArg (',' OnigurumaCalloutArgList)*
OnigurumaCalloutArg     -> [^,}]+
OnigurumaTag            -> '[' Identifier ']'

OnigurumaCalloutOfContents -> '(?' '{'+ Contents '}'+ OnigurumaTag? Direction? ')'
OnigurumaCalloutContents   -> <String>
OnigurumaCalloutDirection  -> 'X' | '<' | '>'
```

A callout is a feature that allows a user-supplied function to be called when matching reaches that point in the pattern. We supported parsing both the PCRE and Oniguruma callout syntax. The PCRE syntax accepts a string or numeric argument that is passed to the function. The Oniguruma syntax is more involved, and may accept a tag, argument list, or even an arbitrary program in the 'callout of contents' syntax.

### Absent functions

```
AbsentFunction -> '(?~' RegexNode ')'
                | '(?~|' Concatenation '|' Concatenation ')'
                | '(?~|' Concatenation ')'
                | '(?~|)'
```

An absent function is an Oniguruma feature that allows for the easy inversion of a given pattern. There are 4 variants of the syntax:

- `(?~|absent|expr)`: Absent expression, which attempts to match against `expr`, but is limited by the range that is not matched by `absent`.
- `(?~absent)`: Absent repeater, which matches against any input not matched by `absent`. Equivalent to `(?~|absent|\O*)`.
- `(?~|absent)`: Absent stopper, which limits any subsequent matching to not include `absent`.
- `(?~|)`: Absent clearer, which undoes the effects of the absent stopper.

## Syntactic differences between engines

**TODO: Intro**

**TODO: Talk about compatibility modes for different engines being a possible future direction?**

### Character class set operations

In a custom character class, some engines allow for binary set operations that take two character class inputs, and produce a new character class output. However which set operations are supported and the spellings used differ by engine.

| PCRE | ICU | UTS#18 | Oniguruma | .NET | Java |
|------|-----|--------|-----------|------|------|
| ❌ | Intersection `&&`, Subtraction `--` | Intersection, Subtraction | Intersection `&&` | Subtraction via `-` | Intersection  `&&` |

[UTS#18][uts18] requires intersection and subtraction, and uses the operation spellings `&&` and `--` in its examples, though it doesn't mandate a particular spelling. In particular, conforming implementations could spell the subtraction `[[x]--[y]]` as `[[x]&&[^y]]`. UTS#18 also suggests a symmetric difference operator `~~`, and uses an explicit `||` operator in examples, though doesn't require either.

The differing support between engines is conflicting, as engines that don't support a particular operator treat them as literal, e.g `[x&&y]` in PCRE is the character class of `["x", "&", "y"]` rather than an intersection.

Another conflict arises with .NET's support of using the `-` character in a custom character class to denote both a range as well as a set subtraction. .NET disambiguates this by only permitting its use as a subtraction if the right hand operand is a nested custom character class, otherwise it is a range. This conflicts with e.g ICU where `[x-[y]]`, in which the `-` is treated as literal.

We intend to support the operators `&&`, `--`, and `~~`. This means that any regex literal containing these sequences in a custom character class while being written for an engine not supporting that operation will have a different semantic meaning in our engine. However this ought not to be a common occurrence, as specifying a character multiple times in a custom character class is redundant.

In the interests of compatibility, we also intend on supporting the `-` operator, though we likely want to emit a warning and encourage users to switch to `--`.

### Nested custom character classes

This allows e.g `[[a]b[c]]`, which is interpreted the same as `[abc]`. It also allows for more complex set operations with custom character classes as the operands.

| PCRE | ICU | UTS#18 | Oniguruma | .NET | Java |
|------|-----|--------|-----------|------|------|
| ❌ | ✅ | 💡 | ✅ | ❌ | ✅ |

UTS#18 doesn't require this, though it does suggest it as a way to clarify precedence for chains of character class set operations e.g `[\w--\d&&\s]`, which the user could write as `[[\w--\d]&&\s]`.

PCRE does not support this feature, and as such treats `]` as the closing character of the custom character class. Therefore `[[a]b[c]]` is interpreted as the character class `["[", "a"]`, followed by literal `b`, and then the character class `["c"]`, followed by literal `]`.

.NET does not support nested character classes in general, although allows them as the right-hand side of a subtraction operation.

### `\U`

In PCRE, if `PCRE2_ALT_BSUX` or `PCRE2_EXTRA_ALT_BSUX` are specified, `\U` matches literal `U`. However in ICU, `\Uhhhhhhhh` matches a hex sequence. We intend on following the ICU behavior.

### `{,n}`

This quantifier is supported by Oniguruma, but in PCRE it matches the literal chars. We intend on supporting it as a quantifier.

### `\DDD`

This syntax is implemented in a variety of different ways depending on the engine. In ICU and Java, it is always a backreference unless prefixed with `0`, in which case it is an octal sequence.

In PCRE, Oniguruma, and .NET, it is also always an octal sequence if prefixed with `0`, however there are also other conditions where it may be treated as octal. These conditions vary slightly been the engines. In PCRE, it will be treated as backreference if any of the following hold:

- Its `0 < n < 10`.
- Its first digit is `8` or `9`.
- Its value corresponds to a valid *prior* group number.

Otherwise it is treated as an octal sequence.

Oniguruma follows all of these except the second. If the first digit is `8` or `9`, it is instead treated as the literal number, e.g `\81` is `81`. .NET also follows this behavior, but additionally has the last condition consider *all* groups, not just prior ones (as backreferences can refer to future groups in recursive cases).

We intend to implement a simpler behavior more inline with ICU and Java. A `\DDD` sequence that does not start with a `0` will be treated as a backreference, otherwise it will be treated as an octal sequence. If an invalid backreference is formed with this syntax, we will suggest prefixing with a `0` if an octal sequence is desired.

One further difference between engines exists with this syntax in the octal sequence case. In ICU, up to 3 additional digits are read after the `0`. In PCRE, only 2 additional digits may be interpreted as octal, the last is literal. We intend to follow the ICU behavior, as it is necessary when requiring a `0` prefix.

### `\x`

In PCRE, a bare `\x` denotes the NUL character (`U+00`). In Oniguruma, it denotes literal `x`. We intend on following the PCRE behavior.

### Whitespace in ranges

In PCRE, `x{2,4}` is a range quantifier meaning that `x` can be matched from 2 to 4 times. However if any whitespace is introduced within the braces, it becomes an invalid range and is then treated as the literal characters instead. We find this behavior to be unintuitive, and therefore intend to parse any intermixed whitespace in the range, but will emit a warning telling users that we're doing so (**TODO: how would they silence? move to modern syntax?**).

### Implicitly-scoped matching option scopes

PCRE and Oniguruma both support changing the active matching options through an isolated group e.g `(?i)`. However, they have differing semantics when it comes to their scoping. In Oniguruma, it is treated as an implicit new scope that wraps everything until the end of the current group. In PCRE, it is treated as changing the matching option for all the following expressions until the end of the group.

These sound similar, but have different semantics around alternations, e.g for `a(?i)b|c|d`, in Oniguruma this becomes `a(?i:b|c|d)`, where `a` is no longer part of the alternation. However in PCRE it becomes `a(?i:b)|(?i:c)|(?i:d)`, where `a` remains a child of the alternation.

We aim to support the PCRE behavior.

### Backreference condition kinds

PCRE and .NET allow for conditional patterns to reference a group by its name, e.g:

```
(?<group1>x)?(?(group1)y)
```

where `y` will only be matched if `(?<group1>x)` was matched. PCRE will always treat such syntax as a backreference condition, however .NET will only treat it as such if a group with that name exists somewhere in the regex (including after the conditional). Otherwise, .NET interprets `group1` as an arbitrary regular expression condition to try match against. 

We intend to always parse such conditions as an arbitrary regular expression condition, and will emit a warning asking users to explicitly use the syntax `(?('group1')y)` if they want a backreference condition. This more explicit syntax is supported by PCRE.

### `\N`

PCRE supports `\N` meaning "not a newline", however there are engines that treat it as a literal `N`. We intend on supporting the PCRE behavior.

### Extended character property syntax

ICU unifies the character property syntax `\p{...}` with the syntax for POSIX character classes `[:...:]`, such that they follow the same internal grammar, which allows referencing any Unicode character property in addition to the POSIX properties. We intend to support this, though it is a purely additive feature, and therefore should not conflict with regex engines that implement a more limited POSIX syntax.

### Extended syntax modes

Various regex engines offer an "extended syntax" where whitespace is treated as non-semantic (e.g `a b c` is equivalent to `abc`), in addition to allowing end-of-line comments `# comment`. In PCRE, this enabled through the `(?x)` and `(?xx)` matching options, where the former allows non-semantic whitespace outside of character classes, and the latter also allows non-semantic whitespace in custom character classes.

Oniguruma, Java, and ICU however enable the more broad behavior under `(?x)`. We therefore intend to follow this behavior, with `(?x)` and `(?xx)` being treated the same.

Different regex engines also have different rules around what characters are considered non-semantic whitespace. When compiled with Unicode support, PCRE considers the following whitespace:

- The space character `U+20`
- Whitespace characters `U+9...U+D`
- Next line `U+85`
- Left-to-right mark `U+200E`
- Right-to-left mark `U+200F`
- Line separator `U+2028`
- Paragraph separator `U+2029`

This is a subset of the scalars matched by `UnicodeScalar.isWhitespace`. Additionally, in a custom character class, PCRE only considers the space and tab characters as whitespace. Other engines do not differentiate between whitespace characters inside and outside custom character classes, and appear to follow a subset of this list. Therefore we intend to support exactly the characters in this list for the purposes of non-semantic whitespace.

## Canonical representations

Many engines have different spellings for the same regex features, and as such we need to decide on a preferred canonical syntax.

### Backreferences

There are a variety of backreference spellings accepted by different engines

```
Backreference -> '\g{' NameOrNumberRef '}'
               | '\g' NumberRef
               | '\k<' Identifier '>'
               | "\k'" Identifier "'"
               | '\k{' Identifier '}'
               | '\' [1-9] [0-9]+
               | '(?P=' Identifier ')'
```

We plan on choosing the canonical spelling **TODO: decide**.


[pcre2-syntax]: https://www.pcre.org/current/doc/html/pcre2syntax.html
[oniguruma-syntax]: https://github.com/kkos/oniguruma/blob/master/doc/RE
[icu-syntax]: https://unicode-org.github.io/icu/userguide/strings/regexp.html
[uts18]: https://www.unicode.org/reports/tr18/
[.net-syntax]: https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expressions
[UAX44-LM3]: https://www.unicode.org/reports/tr44/#UAX44-LM3
