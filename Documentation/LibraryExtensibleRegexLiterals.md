# Regex Literals Musings

* Author: Michael Ilseman

## Introduction

As forums discussions bear fruit, I wanted to write down some of my emerging thoughts and musings on the topic of regex literals.

Main points:

- Go with [PCRE syntax](http://pcre.org/current/doc/html/pcre2syntax.html) instead of something custom, **or** skip regex literals
- Provide library-extensibility by parsing regex literals *fully* in the compiler, invoking function decls for each feature
- Try really hard to make `/` work as the delimiter

_**Note**: This doesn't discuss typed captures nor prescribes specific semantics, just covers a basic literal._


## Normal Regex Literals

The main reason for regex literals is familiarity and broad appeal. We lose this when we do anything "weird".

Regular expressions serve as a poor basis for building something custom on top of. They are ambiguous / non-deterministic, which was fine for their original academic purpose of describing the set of strings belonging to a regular language, but gets in the way of understanding how code executes (contrast with [PEGs](https://en.wikipedia.org/wiki/Parsing_expression_grammar#Semantics)). They occupy an awkward complexity class, too powerful to compose and not powerful enough for parsing. If we're doing something custom, let's build on a better technical foundation than regex.

The challenge is to ship them in a way that helps establish the basis for more generalized pattern matching and parsing support. We don't want to preclude other approaches (or even literals) and we want to be building towards a common good with `Pattern`, etc. 

My recommended alternative to PCRE syntax regex literals is not an alternate syntax, but to not do them at all. If we are doing them, here is my recommendation of how we go about doing so:

## Library-extensible Regex Literals

Add a `ExpressibleByRegexLiteral` protocol and check a provided namespace (ala custom string interpolations) for calls to a builder.

### Example

Total straw-person:

```
/([0-9A-F]+)(?:\.\.([0-9A-F]+))?/

{
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
}()
```

Of course, we can also provide a built-in facility to pretty-print it back out, which would be useful for libraries wrapping string-based engines.

Note: Grapheme clusters are not enumerable (i.e. they're more akin to the real numbers than the natural numbers). Enumeration of character ranges only really works for single-scalar grapheme clusters and would be ordered based on scalar value. It would be advisable to only do them for normalization-invariant scalars. We could/should strongly consider rejecting ranges that are problematic, perhaps even restricting range-based character sets to ASCII.


### Supported features problem

There needs to be a way to surface the supported feature set:

1) This conformer doesn't support a particular feature that's used
2) This call site or usage doesn't support a particular feature that's used

This approach addresses concern #1. The compiler statically parses the regex, looking to invoke corresponding function declarations in some scope determined by the conforming type. If a declaration is not found, compiler issues an unsupported feature error. Libraries put availability on the declarations, which statically communicates their feature set and is the means for adding future functionality.

Concern #2 is... **TBD**. One example is if you're trying to run with grapheme cluster semantics, scalar properties aren't available (at least, beyond the subset that Swift can meaningfully prescribe grapheme cluster semantics for). APIs probably need some way to enforce this statically (and/or dynamically with traps).

### Why do this?

One argument is allowing libraries (e.g. something bundling PCRE, code that explicitly wants to call into NSRegularExpression or JSCore, etc.) to be able to use regex literals. This is compelling and completely in line with our library-extensibility story for `String`. Similarly, libraries could provide more linguistic level processing (e.g. using Unicode word-break iterators, collation and/or locale support, fuzzier matching, etc).

Personally, the argument I find the most compelling in the near term is that this pushes *us* into a clean and clear design. It can really highlight just-below-the-surface issues, and the "library" of ad-hoc function declarations serve as a compiler-checked specification of our feature set. The declarations can even serve as a place to hang documentation off of. Even if we start off with all this stuff being private, it's probably worth doing for ourselves.

The compiler has to do the parsing anyways. It's easier to just parse the whole thing up-front than continuously come back to add syntax for each new feature rolled out. This allows us to deliver a full PCRE-esque literal parser while rolling out features over time, achieving a separation of (design) concerns.


## Delimiters

There are some problems with `/` as the delimiter. Libraries can declare pre- or post-fix `/` operator, which this could clash with. (Independently, let's see about making enum key-paths happen so one of the more high-profile uses of this can go away). Shadowing alone is probably not sufficient. Thus, `/` may be gated on a Swift 6 mode check.

It's less important to allow multi-line or whitespace-insensitive literal variants (just refactor into `Pattern`). It's probably also less important to allow for raw regex literals (requiring `#` to escape `\` or metacharacters) and that can into us doing something custom quickly. All that being said, custom balanced delimiters ala Perl could be nice.

Personally, I'm not too invested in the choice of delimiter, but I respect that people have strong opinions.


## Future Directions and Vague Concerns

### More general?

The basic syntax could be shared for PEG-like literals, though they have different semantics for quantification, so that trade-off would need to be considered. I think it's likely that a nicer, custom matching literal would be more useful here. Swift values clarity and doesn't try to pack entire programs into a single line, so a custom matching literal is likely to look pretty different than regex.


### Captures?

There can be a pretty significant difference between literals with captures and literals without. Captures are certainly not relevant for many APIs, and I don't think we want some global (or even task-local) context to query for capture information after an e.g. `split`. Then again, that could be neat if explicitly opted into...

Either way, outside the scope of this document.

### Fully-custom literals

It might be nice to have fully-custom literal syntax, understanding that we can say essentially nothing about them in general and there is no default type. This requires fleshing out the library-driven compilation story (bootstrapping as well as compiler and type system API). While I'm a big fan of fleshing that out, fully-custom no-default-type literals are mostly orthogonal to this effort.

### Vague concerns

I am a little concerned that typed captures will expose some latent issues or limitations in Swift's type system. I'm a little concerned that a particular approach or workaround might not generalize well to future matching capabilities.

I'm a little concerned that it might be too late to retroactively use `/`, but it's worth an effort.

I'm vaguely concerned that designing the literal feature set in isolation from the API they're intended for use with may be a source of blind spots. It could lead us to over-engineer or over-design unimportant parts that become clear in the context of the API its used with. This is more so a concern when we talk about character sets, adverbs, etc.

I'm very-vaguely concerned that a lack of first-class literal types might be a problem. I don't know if the type that's produced is `Regex` or if it's just `Pattern` directly. Perhaps it's an AST and it gets desugared/compiled.
