
# Implementation Musings

* Author: [Michael Ilseman][milseman]

## General-purpose matching engine

Academically, these seemingly different domains are unified by mapping to [automata](https://en.wikipedia.org/wiki/Automata_theory). For us, we unify using a general-purpose matching engine. The matching engine is fully deterministic, so compilation of non-deterministic or ambiguous languages (such as regular expressions) involves picking an execution strategy or strategies.

### Static compilation

The most likely implementation strategy would be to statically compile (or partially compile) matching programs into a low-level bytecode. At run time, the bytecode is loaded, linked together (Swift supports separate compilation), and interpreted by a general-purpose matching engine. We'd likely want compile-time analysis and optimization as well as some limited form of run-time analysis and optimization for matching programs.

A bytecode geared towards pattern matching can be significantly more compact than the corresponding executable machine code, especially when many applications on a system can share the same interpreter code. For some matching programs, especially the simpler or more performance-critical ones, statically compiling all the way to machine code is worthwhile.

### Instruction Set

ISA design can range from a small number of primitive operations which complex operations decompose to (RISC), to having complex operations encoded in a single instructions (CISC). We will likely want... a bit of both.

Primitive operations are more general, in that novel operations can be added by decomposing to the primitive operations. These give us a better avenue for supporting unanticipated needs, such as by libraries or new features we add and would like to backport.

Complex instructions aid efficiency, as we need to do fewer fetch-decode-execute iterations, and can avoid needing to store or refer to intermediary results.

For example, `a*` can be represented many ways:

```
# e0 contains element "a"

# Match "a" as many times as we can before falling through

    repeat e0

# Do the same with control flow and save points. `saveAddress` will resume execution
# from the given label upon match fail without touching the current position

    saveAddress(DONE)
START:
    consume e0
    goto START
DONE:
    ...

# Do the same with just control flow, but doubly-inspecting the input (once for peek and once for advance)

START:
    peek b0, e0
    cond-branch !b0, DONE
    advance
    goto START
DONE:    
    ...

```

We also will want the ability to call custom hooks, e.g. for composing with library calls. So, a matching program may include e.g. a list of elements to compare against and a list of closures to invoke. We'll want to version the bytecode and we can backport new operations via decomposition to primitives (also a good way to test and benchmark new operations).

### Generalizing operations

A generalization of a character class is `(Element) -> Bool` (throwing might be useful to signal a matching abort in contrast to a failure).

A generalization of a match/consume operation is `(Input, Position) -> Position?`, for which assertions can be viewed as a special case. This requires having a notion of position and having bound a type for the input (e.g. some instance of `Collection`). For collections, this is basically the interface of `CollectionConsumer`, so it is also a means of composition, separate compilation, and a vector for backporting.

A different generalization of match/consume is `(inout MatchingEngine) -> Bool`, where the engine has API for consuming, advancing, querying information about how it got there, and even interacting with save points used for backtracking. This works well as a generalization for monitors, which have no notion of position and which may want to query matching state. This has the downside of stabilizing an API for the engine.

Of course, whenever possible we'd prefer to compile or link in bytecode for such things, but calling out to arbitrary Swift code is behavior we want to allow.

## Frontends

For string processing, this repo contains an example regex parser, compiler, and a few execution strategies. The regex parser itself serves as an example of writing parsers in Swift for simple languages. It hasn't (yet) been ported to run on the MatchingEngine, and doing so requires picking an execution strategy or strategies. It's AST can serve as the start of a simple result-builder API (tbd).

For generic parsing, this repo contains an implementation of generic PEGs ("parsing expression grammars"). It is **not** a goal to ship PEGs specifically in Swift, but it **is** a goal to empower libraries providing parser formalisms such as PEGs. In the meantime, PEGs serve as a drop-in API for specifying parsers and can help stress the performance of generic code paths.

We haven't added a representative example yet of low-level binary deserialization-like operations. We also haven't added a representative example of "bottoms-up" processing (e.g. with a cost function to select the best candidate).

For event processing, this repo contains a formulation (but not yet implementation) of PTCaRet ("past time linear temporal logic with call and return"). It's a formal logic variant that's a little better suited for software systems than some others as it's oriented around making statements about *how* the program got to its current state. "Call" and "return" are not (necessarily, but could be!) Swift function call and returns, so much as a way of abstracting parts of a program trace similar to procedural abstraction in code. It is **not** a goal to ship this particular logic in Swift, but it **is** a goal to empower libraries to provide this kind of capability. In the meantime, it stresses our async story, ability to scale to virtually infinite histories, and how to enable custom code to react to and participate in pattern matching.

We haven't added any particular parser combinator library or approach yet.


### Enhanced syntactic pattern matching over sets and collections

Functional programming languages often support simple structural pattern matching against the head/tail of a list under a `cons`-like operation.

One interesting bit of obscure functionality is so-called "ACI" matching (associativity, commutativity, and identity). For example, imagine matching against an Array using its associative `+` operator with identity `[]`:

```swift
// Strawperson syntax
switch myArray {
case (let prefix) + [3, 4] + (let suffix):
```

which would successfully match the array `[1, 2, 3, 4, 5, 6]` and assign the `ArraySlice` `[1, 2]` to `prefix` and `[5, 6]` to `suffix`. Prefix and suffix can be empty, hence "identity" matching.

Similarly, `OptionSet`'s `|` operator is associative and commutative with identity `[]`:

```swift
// Strawperson syntax
switch myOptionSet {
case .specificValue | (let theRest):
```

which would match any set with `.specificValue` in it, binding everything else in the set to `theRest` (which again can be empty).

When there are multiple terms to match, some of which might just be variables and thus not available statically, this kind of matching is [surprisingly complex][aci], though often fast in common cases. Compiling to the MatchingEngine could be an interesting future direction for the language.

[milseman]: https://github.com/milseman
[aci]: https://www.sciencedirect.com/science/article/pii/S0747717187800275
