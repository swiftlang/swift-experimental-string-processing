
# Regex Proposals

## Regex Type and Overview

- [Proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0350-regex-type-overview.md), [Thread](https://forums.swift.org/t/se-0350-regex-type-and-overview/56530)
- [Pitch thread](https://forums.swift.org/t/pitch-regex-type-and-overview/56029)

Presents basic Regex type and gives an overview of how everything fits into the overall story 


## Regex Builder DSL

- [Proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0351-regex-builder.md), [Thread](https://forums.swift.org/t/se-0351-regex-builder-dsl/56531)
- [Pitch thread](https://forums.swift.org/t/pitch-regex-builder-dsl/56007)

Covers the result builder approach and basic API.


## Run-time Regex Construction

- [Pitch](https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/RegexSyntaxRunTimeConstruction.md), [Thread](https://forums.swift.org/t/pitch-2-regex-syntax-and-run-time-construction/56624)
- (old) Pitch thread: [Regex Syntax](https://forums.swift.org/t/pitch-regex-syntax/55711)
    + Brief: Syntactic superset of PCRE2, Oniguruma, ICU, UTS\#18, etc.

Covers the "interior" syntax, extended syntaxes, run-time construction of a regex from a string, and details of `AnyRegexOutput`.

## Regex Literals

- [Draft](https://github.com/apple/swift-experimental-string-processing/pull/187), [Thread](https://forums.swift.org/t/pitch-2-regex-literals/56736)
- (Old) original pitch:
    + [Thread](https://forums.swift.org/t/pitch-regular-expression-literals/52820)
    + [Update](https://forums.swift.org/t/pitch-regular-expression-literals/52820/90)


## String processing algorithms

- [Pitch thread](https://forums.swift.org/t/pitch-regex-powered-string-processing-algorithms/55969)

Proposes a slew of Regex-powered algorithms.

Introduces `CustomMatchingRegexComponent`, which is a monadic-parser style interface for external parsers to be used as components of a regex.

## Unicode for String Processing

- [Draft](https://github.com/apple/swift-experimental-string-processing/blob/main/Documentation/Evolution/UnicodeForStringProcessing.md)
- (Old) [Character class definitions](https://forums.swift.org/t/pitch-character-classes-for-string-processing/52920)

Covers three topics:

- Proposes regex syntax and `RegexBuilder` API for options that affect matching behavior.
- Proposes regex syntax and `RegexBuilder` API for library-defined character classes, Unicode properties, and custom character classes.
- Defines how Unicode scalar-based classes are extended to grapheme clusters in the different semantic and other matching modes.


