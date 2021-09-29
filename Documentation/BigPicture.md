
# The Big Picture

* Author: [Michael Ilseman][milseman]

## Introduction

I've been finding it helpful to think of our long-term goal as making Swift awesome at string processing, data processing, and "event processing" (working title, suggestions welcome). These are not rigid or clear-cut distinct domains (they actually blend together in extremity) so much as they are 3 interesting "regions" in this design space. Thinking about these regions helps clarify what tasks we're enabling and helps push us towards more general solutions.

Each of these regions share technical fundamentals, but present novel performance and API design challenges. I hope that keeping the big picture in mind will help guide the design process towards pragmatic trade-offs and robust solutions.

By "string processing" (at least in the context of this document), I mean processing with the Unicode-rich semantics of Swift's `String` and `Character` types. By "data processing", I mean efficient processing done at a binary semantics level, even if such data happens to be viewable as text. By "event processing" (working title, suggestions welcome), I mean being able to detect and respond to patterns over ephemeral "events" issued from an asynchronous source.

We want to be able to compose, layer, and even interweave different kinds of processing together. And, we want these areas to be library-extensible, so that libraries can provide custom behavior through custom protocol conformances. For example, [custom String interpolation](https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md) is extended by libraries for [logging](https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code),  [sanitizing](https://nshipster.com/expressiblebystringinterpolation/#implementing-a-custom-string-interpolation-type), [templating](https://github.com/ilyapuchka/Interplate), and many other applications. Similarly, there are myriad formulations of pattern matching and we want to enable libraries to provide powerful new abstractions.

## String processing

Swift's `String` is presented as a collection of `Character`s, or [extended grapheme clusters][grapheme-cluster]. Thus, a wildcard match such as a `.` in a regular expression should match a `Character`, `Unicode.Scalar`, or `UInt8` when applied to `String`, `String.UnicodeScalarView`, or `String.UTF8View` respectively:

| Matching "🧟‍♀️" using `.` wildcard    | Matched | Remaining content          |
|-------------------------------------|---------|----------------------------|
| String                              | 🧟‍♀️      | ""                         |
| String.UnicodeScalarView            | U+1F9DF | U+200D U+2640              |
| String.UTF8View                     | F0      | 9F A7 9F E2 80 8D E2 99 80 |


`String` and `Character` comparison honors [Unicode Canonical Equivalence][canonical-equivalence]: `"é"` (U+00E8 Latin Small Letter E with Grave) compares equally to `"e\u{0300}"` (U+0065 Latin Small Letter E, U+0300 Combining Grave Accent). The standard library aims to provide this level of Unicode support while paying the minimal performance cost possible by only performing the more complex analysis when needed.

We aim for string processing to be library-extensible, meaning high level frameworks and platforms can provide linguistically-rich interfaces through protocol conformances. String processors should be composable, so that one can e.g. seamlessly call into Foundation's `FormatStyle`s to do rich, localized or standards-conforming parsing as part of a larger string processing operation.

We also aim to generalize to `Collection` processing. A simple example of this is applying the wildcard `.` to each of String's views above, in effect executing a simple generic pattern over different collections. This ties in naturally with [Collection consumers and searchers](https://forums.swift.org/t/prototype-protocol-powered-generic-trimming-searching-splitting/29415), as collection processors can conform to `CollectionConsumer` enabling them to be used with generic API. This conformance is also a means of composition, as combinators can combine consumers together.

In extremity, when `Element` is trivial ("plain ol' data"), contiguously stored in memory (or at least presented as contiguous chunks in memory), and processing can be done within a moving window over the input, then we are approaching the realm of data processing.


## Data processing

Data processing can span from low-level efficient binary deserializers to industrial strength parsers. Many examples that appear to be string processing are fundamentally data processing with a layer of string processing on top. Formats such as JSON, CSV, plists, and even source code are data formats that have a textual presentation when rendered by an editor or terminal. Their stored content may be Unicode-rich, but the format itself should be processed as data.

For example, imagine processing a CSV document of all defined Unicode scalars. Inside such a document would appear the CSV field-separator `,` followed by `U+0301` (Combining Acute Accent). If we were doing string processing, this would appear to us as a single ([degenerate][degenerates]) grapheme cluster `,́`, that is the comma combined with the following accent into a single grapheme cluster that does not compare equal to either piece. Instead, we want to process CSV at the binary-semantics level where we match field separators literally and everything in-between is opaque content which we present for interpretation by a higher-level layer.

We want to support composition of data processing with string processing. An example of multi-tiered string-over-data processing is parsing JSON into strongly typed data structures such as `Dictionary`s with `String` keys. Parsing JSON is done at the binary-semantics level, but interpreting the *content* of a JSON field uses `String`'s semantics such that dictionary keys are uniqued under Unicode canonical equivalence. We want to allow tiered string processing to drive the behavior of the data processing layer, such that Unicode-rich analysis of a token can affect parsing (e.g. is this a Unicode-rich identifier or Unicode-rich operator).

Backtracking during data processing is usually limited or constrained, and processing often happens over a contiguous moving window, making it amenable to processing contiguous chunks derived from an asynchronous source. There may or may not be a notion of position in the input data (e.g. `seek`-able files vs device files).

API design challenges include squaring the circle of `Sequence` and `AsyncSequence`, how we express such window sizes (e.g. look-ahead) and/or backtracking constraints, designing the core low-level "peek" and "consume" pattern, clarifying buffer ownership and management, and allowing parsers to self-direct their behavior (e.g. error handling and early pruning).

Performance challenges include avoiding fully-generic evaluation, managing buffers and avoiding intermediary ones, generating compact code comparable in performance to hand-written parsers, and using window size to limit memory usage.

In extremity, when the chunk size is 1, the `Element` type is ephemeral or otherwise unpersistable, there is no concept of position, and we need to process virtually infinite input within a small time/memory budget, we are approaching the realm of event processing.

## Event processing

Event processing is the fuzziest area of this design space (at least for me), as there's not a ton of direct precedent in common Swift code. And yet, much application logic can be thought of as state machines responding live to user input, and critical safety invariants can be thought of as simple logics evaluated over abstract program traces.

For example, a server process might wish to enforce the invariant that an approval of a user `u` to access some resource requires that `u` first be authenticated. An engine can allocate a bit per user in a bitvector and actively monitor an event stream, setting the corresponding bit upon authentication. If an approve happens without the authentication bit being set, the engine invokes custom handling code, which could do anything from logging that tidbit to tearing down the server process and drafting a security advisory. This is scalable and efficient: it scales to virtually-infinite trace histories because it only cares about a single bit-per-user of history: whether `u` was authenticated.

Implementation techniques involve heavy use of bitvectors and, if events can map to the natural numbers, highly-specialized data structures such as [SparseSets][sparse-set].

API design challenges include expressing this mapping to the natural numbers when possible and providing a matching engine API for custom hooks to use (e.g. to retrieve more information about *how* the program got to its current state). Performance challenges include taking advantage of this mapping and compiling rich logics to efficient code. Implementation challenges include sharing the technical infrastructure for generic events without an `Index` type or other notion of position. Event processing shares the same technical fundamentals as string and data processing, but stresses asynchronous API design and directly interacting with the matching engine.

## Developer experience

We want to provide a developer experience more akin to parser-combinators: i.e. you're just writing code and calling or composing functions normally. If you need to do something custom, you can just write custom code. We want to provide a build-system experience similar to normal code: there's no extra steps or external tools to invoke. We want to provide a compilation model more akin to parser-generator tools: we provide a large number of constructs (alternation, repetition, etc.) whose semantics are statically-known with little bits of custom user code scattered about. When that custom code is available in the current compilation context, we can even perform (and evolve over time) cross-cutting analysis and optimizations.

We want powerful functionality presented as normal Swift code, not forced into a particular formalism. In academia, the computational complexity class of a formalism is often the most salient point. That's a *really nice* thing to have and know, but it's usually not even in the top-5 concerns. For example, imagine adding a typo-correction feature to an existing parser for a programming language: surfacing in-scope corrections would be context-sensitive, and furthermore, candidates would be weighted by things such as edit distance or even lexical distance.


## Where to go from here

Most early discussion will be happening in the context of string processing or generic collection processing (with some data parsing thrown in). Since implementation details can quickly become binary compatibility requirements, we'll want to be running ahead to make sure data and event processing works or can be made to work in the future with the API and ABI we ship. We'll want to support asynchronous sources of content so as not to overly fixate on `Collection`, and most notably, `Index` as a representation of position.

For more musings on implementation strategies, see [Implementation Musings][impl-musings]

[milseman]: https://github.com/milseman
[sparse-set]: https://github.com/apple/swift-collections/pull/80
[impl-musings]: ImplementationMusings.md
[grapheme-cluster]: https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries
[canonical-equivalence]: https://www.unicode.org/reports/tr15/#Canon_Compat_Equivalence
[degenerates]: https://www.unicode.org/reports/tr29/#Rule_Constraints
