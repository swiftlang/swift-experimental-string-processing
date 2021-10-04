# Regex Literals Musings

* Author: Michael Ilseman

## Introduction

As forums discussions bear fruit, I wanted to write down some of my emerging thoughts and musings on the topic of regex literals.

Main points:

- Go with a typical regex literal instead of something custom/nicer
    + Main reason for regex is familiarity and broad appeal
    + If we're building something custom, let's not do it on top of the shaky technical foundation that is regex
    + This _should not_ be done in a way that preclude us from other kinds of matching API or even literals
    + This _should_ be done in a way that motivates and develops the basis of future matching API or even literals
- Provide library-extensibility by parsing regex literals *fully* in the compiler, invoking function decls for each feature
    + Libraries (e.g. we) use availability on the ad-hoc function decls to statically communicate feature set
    + We provide a way to pretty-print them back out (e.g. enabling a PCRE2 wrapper library)
    + **TBD**: Tracking capabilities and API expressing capabilities
- **TBD**: choice of delimiter itself (`'` vs `/` vs `#/`, etc) and/or custom delimiters


## Normal Regex Literals

The main reason for regex literals is familiarity and broad appeal. We lose this when we do anything "weird".

Regular expressions serve as a poor basis for building something weird/custom on top of. Ambiguity / non-determinism is fine for their original intent of describing the set of strings belonging to a regular language, but that can really suck in practice. They occupy a weird complexity class, limiting their composability and applicability.

The challenge is to ship them in a way that helps establish the basis for more generalized pattern matching and parsing support. We don't want to preclude other approaches (or even literals) and we want to be building towards a common good with `Pattern`, etc.


## Library-extensible Regex Literals

### Example

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

This doesn't demonstrate typed captures, however...

Of course, we can also provide a built-in facility to pretty-print it back out, which would be useful for libraries wrapping string-based engines.

Note: Enumeration of character ranges only really works for single-scalar grapheme clusters and would be ordered based on scalar value. It would also probably only make sense for single-segment normalization-invariant scalars. It's also essentially meaningless unless someone is really doing data processing and wants the scalar value range behavior. Also, what to do about CR-LF?

### Supported features problem

There needs to be a way to surface the supported feature set:

1) This conformer doesn't support a particular feature that's used
2) This call site or usage doesn't support a particular feature that's used

This approach addresses concern #1. The compiler statically parses the regex, looking to invoke corresponding function declarations in some scope determined by the conforming type. If a declaration is not found, compiler issues an unsupported feature error. Libraries put availability on the declarations, which statically communicates their feature set and is the means for adding future functionality.

Concern #2 is... **TBD**. One example is if you're trying to run with grapheme cluster semantics, scalar properties aren't available (at least, beyond the subset that Swift can meaningfully prescribe grapheme cluster semantics for). APIs probably need some way to enforce this statically (and/or dynamically with traps).

### Why do this?

One argument is allowing libraries (e.g. something bundling PCRE, code that explicitly wants to call into NSRegularExpression or JSCore, etc.) to be able to use regex literals. This is compelling and completely in line with our library-extensibility story for `String`.

Personally, the argument I find the most compelling in the near term is that this pushes *us* into a clean and clear design. It can really highlight just-below-the-surface issues, and the "library" of ad-hoc function declarations serve as a compiler-checked specification of our feature set. The declarations can even serve as a place to hang documentation off of. Even if we start off with all this stuff being private, it's probably worth doing for ourselves.

The compiler has to do the parsing anyways. It's easier to just parse the whole thing up-front than continuously come back to add syntax for each new feature rolled out. This allows us to deliver a full PCRE-esque literal parser while rolling out features over time, achieving a separation of (design) concerns.


## Delimiters

- There might be problems with `/` specifically as the delimiter.
- It's less important to allow multi-line or whitespace-insensitive literal variants (refactor into `Pattern`).
    + It's probably also less important to allow for raw regex literals (requiring `#` to escape `\` or metacharacters)
- It would be nice to have custom balanced delimiters

Personally, I'm not too invested in the choice of delimiter, but I respect that people have strong opinions.


## Future Directions and Vague Concerns

### More general?

The basic syntax could be shared for PEG-like literals, though they have different semantics for quantification, so that trade-off would need to be considered.

The strictly lexical syntax could be used for shell-style globs or some such, but that's probably a bit nuts to try to support with the same literal type.

### Captures?

There can be a pretty significant difference between literals with captures and literals without. Captures are certainly not relevant for many APIs, and I don't think we want some global (or even task-local) context to query for capture information after an e.g. `split`. Then again, that could be neat if explicitly opted into...

### Fully-custom literals

It might be nice to have fully-custom literal syntax, understanding that we can say essentially nothing about them in general. One interface could be that both call and type context is passed to a compile-time library, which will parse and construct an instance of the requested type. This requires figuring out a significant portion of the library-driven compilation story, but any advance there is beneficial for this pattern matching effort. Beyond that, this seems mostly orthogonal to this effort.

### Vague concerns

I am a little concerned that typed captures will expose some latent issues or limitations in Swift's type system. I'm a little concerned that a particular approach or workaround might not generalize well to future matching capabilities.

I'm a little concerned that if we go with `/`, we'll end up parsing differently based on language mode or accumulating gross hacks.

I'm vaguely concerned that designing the literal feature set in isolation from the API they're intended for use with may be a source of blind spots. It could lead us to over-engineer or over-design unimportant parts that become clear in the context of the API its used with.

I'm very-vaguely concerned that a lack of first-class literal types might be a problem.
