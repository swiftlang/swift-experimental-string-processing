# Library-Extensible Regex Literals

* Author: Michael Ilseman

## Example

Total straw-person:

```
/([0-9A-F]+)(?:\.\.([0-9A-F]+))?/


var builder = T.createLiteralBuilder()

// __A3 == /([0-9A-F]+)/
let __A1 = builder.customCharacterClass(["0"..."9", "A"..."F"])
let __A2 = builder.oneOrMore(__A1)
let __A3 = builder.captureGroup(__A2)

// __B4 == /\.\.([0-9A-F]+)/
let __B1 = builder.literal("..")
let __B2 = builder.customCharacterClass(["0"..."9", "A"..."F"])
let __B3 = builder.oneOrMore(__B2)
let __B3 = builder.captureGroup(__B3)
let __B4 = builder.concatenate(__B1, __B3)

// __C3 == /__A3(?:__B4)?/
let __C1 = builder.group(__B4)
let __C2 = builder.zeroOrOne(__C1)
let __C3 = builder.concatenate(__A3, __C2)

return builder.finalize(__C3)
```

Since regex syntax is acyclic, we don't strictly need tokens for terms, but it keeps it cleaner in my mind. I didn't assign types to captures in this example...

Note: enumeration of character ranges only really works for single-scalar grapheme clusters and would be ordered based on scalar value. For scalars that have decompositions.... well... maybe this only makes sense for ASCII. Also, what to do about CR-LF?


## Supported features problem

There needs to be a way to surface the supported feature set:

1) This conformer doesn't support a particular feature that's used
2) This call site or usage doesn't support a particular feature that's used

### 1) Conformer feature set

Every single "feature" like a character class or some other meta-thingy, looks for a corresponding function definition on a conforming type. That is, we parse the regex, even providing intended semantics, while the conformer implements this. If the conformer doesn't provide a function definition, we generate a compilation error. Thus, conformers encode their feature set through ad-hoc function declarations, just like custom string interpolations.

Of course, we provide a built-in facility to pretty-print it back out, which would be useful for e.g. a PCRE-wrapping package.

### 2) Call site feature set

This is relevant to us. If you're trying to run with grapheme cluster semantics, scalar properties aren't available (at least, beyond the subset that Swift can meaningfully prescribe grapheme cluster semantics for).

The APIs (i.e. us for now) should enforce this, instead of the conformer. But doing so means we probably want to track or otherwise know the feature set of regexes or even patterns statically whenever possible. When we don't know statically, we might still want precondition checks. So we're likely to have both a compile-time and run-time encoding of the used feature set.

## Why do this?

One argument is allowing libraries (e.g. something bundling PCRE, code that explicitly wants to call into NSRegularExpression or JSCore, etc.) to be able to use regex literals. I find this compelling and completely in line with our library-extensibility story for `String`.

The argument I find the most compelling, personally, is that this pushes *us* into a clean and clear design. It can really highlight just-below-the-surface issues, and the "library" of ad-hoc function declarations serve as a compiler-checked specification of our feature set. It might be worth doing for ourselves, even if we make all the stuff private.

Taking this argument further, it could help us stage improvements more effectively since the compiler has to do the parsing work anyways. We might as well have it parse the full feature set we want one day as it's harder to come back and add syntax after the fact. This allows us to wholly define the literal syntax now, and still be able to roll out features over time, complete with compile-time checking.

The overloads would also be a pretty clean place to stick availability info.


### Captures?

There really is a pretty significant difference between literals with captures and literals without. Captures are certainly not relevant for many APIs, and I don't think we want some global (or even task-local) context to query for capture information after an e.g. `split`. Then again, that could be neat if explicitly opted into...

### Vague concerns

One of my (vague) concerns is that designing the literal feature set in isolation from the API they're intended for use with may be a source of blind spots. It could also lead us to over-engineer or over-design unimportant parts that become clear in the context of the API its used with.

Swift literals resolve to a library-provided type directly, that is there is no "StringLiteral" type. This is a problem for e.g. character literals as we can't host API directly on a literal (e.g. `'a'.ascii`). For regexes, we might want to provide a real type that is the AST of a parsed regex with functionality on it.

## Future Directions

### More general?

The basic syntax could be shared for PEG-like literals, though they have different semantics for quantification, so that trade-off would need to be considered.

The strictly lexical syntax could be used for shell-style globs or some such, but that's probably a bit nuts to try to support with the same literal type.

### Delimiters

- There might be problems with `/` specifically as the delimiter. That's TBD (CC Hamish).
- It's less important to allow multi-line or whitespace-insensitive literal variants (refactor into `Pattern`).
- It would be nice to have custom balanced delimiters

### Fully-custom delimiters

It might be nice to have fully-custom literal syntax, understanding that we can say essentially nothing about them in general. This seems mostly orthogonal to this effort.

