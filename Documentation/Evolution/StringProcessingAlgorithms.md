# String processing algorithms

## Introduction

The standard library is currently missing a large number of `String` algorithms that do exist in Foundation. We introduce a more coherent set of `Collection` algorithms with a focus on string processing, including support for regular expressions.

## Motivation

TODO

## Proposed solution

We introduce internal infrastructure that allows groups of `Collection` algorithms that perform the same operations on different types to share their implementation, leading to a more coherent set of public APIs. This allows us to more easily provide algorithms that work with `RegexProtocol` values, such as

```swift
extension BidirectionalCollection where SubSequence == Substring {
    public func ranges<R: RegexProtocol>(of regex: R) -> some Collection<Range<Index>>
}
```

We also introduce the `CustomRegexComponent` protocol that conveniently lets types from outside the standard library participate in regex builders and `RegexProtocol` algorithms:

```swift
public protocol CustomRegexComponent: RegexProtocol {
    /// Match the input string within the specified bounds, beginning at the given index, and return
    /// the end position (upper bound) of the match and the matched instance.
    /// - Parameters:
    ///   - input: The string in which the match is performed.
    ///   - index: An index of `input` at which to begin matching.
    ///   - bounds: The bounds in `input` in which the match is performed.
    /// - Returns: The upper bound where the match terminates and a matched instance, or nil if
    ///   there isn't a match.
    func match(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) -> (upperBound: String.Index, match: Match)?
}
```

Consider parsing an HTTP header to capture the date field as a `Date` type:

```
HTTP/1.1 301 Redirect
Date: Wed, 16 Feb 2022 23:53:19 GMT
Connection: close
Location: https://www.apple.com/
Content-Type: text/html
Content-Language: en
```

You are likely going to match a substring that look like a date string (`16 Feb 2022`), and parse the substring as a `Date` with one of Foundation's date parsers:

```swift
let regex = Regex {
    capture {
        oneOrMore(.digit)
        " "
        oneOrMore(.word)
        " "
        oneOrMore(.digit)
    }
}

if let dateMatch = header.firstMatch(of: regex)?.0 {
    let date = try? Date(dateMatch, strategy: .fixed(format: "\(day: .twoDigits) \(month: .abbreviated) \(year: .padded(4))", timeZone: TimeZone(identifier: "GMT")!, locale: Locale(identifier: "en_US")))
}
```

This works, but wouldn't it be much more approachable if you can directly use the date parser within the string match function?

```swift
let regex = Regex {
    capture { 
        .date(format: "\(day: .twoDigits) \(month: .abbreviated) \(year: .padded(4))", timeZone: TimeZone(identifier: "GMT")!, locale: Locale(identifier: "en_US")) 
    }
}

if let match = header.firstMatch(of: regex) {
    let string = match.0 // "16 Feb 2022"
    let date = match.1 // 2022-02-16 00:00:00 +0000
}
```

You can do this because Foundation framework's `Date.ParseStrategy` conforms to `CustomRegexComponent`, defined above. You can also conform your custom parser to `CustomRegexComponent`. Conformance is simple: implement the `match` function to return the upper bound of the matched substring, and the type represented by the matched range. It inherits from `RegexProtocol`, so you will be able to use it with all of the string algorithms that take a `RegexProtocol` type.

Foundation framework's `Date.ParseStrategy` conforms to `CustomRegexComponent` this way. It also adds a static function `date(format:timeZone:locale)` as a static member of `RegexProtocol`, so you can refer to it as `.date(format:...)` in the `Regex` result builder. 

```swift
extension Date.ParseStrategy : CustomRegexComponent { 
    func match(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) -> (upperBound: String.Index, match: Date)?
}

extension RegexProtocol where Self == Date.ParseStrategy {
    public static func date(
        format: Date.FormatString, 
        timeZone: TimeZone, 
        locale: Locale? = nil
    ) -> Self  
}
```

Here's another example of how you can use `FloatingPointFormatStyle<Double>.Currency` to parse a bank statement and record all the monetary values:

```swift

let statement = """
CREDIT    04/06/2020    Paypal transfer        $4.99
DSLIP    04/06/2020    REMOTE ONLINE DEPOSIT  $3,020.85
CREDIT    04/03/2020    PAYROLL                $69.73
DEBIT    04/02/2020    ACH TRNSFR             ($38.25)
DEBIT    03/31/2020    Payment to BoA card    ($27.44)
DEBIT    03/24/2020    IRX tax payment        ($52,249.98)
"""

let regex = Regex {
    capture {
        .currency(code: "USD").sign(strategy: .accounting)
    }
}

let amount = statement.matches(of: regex).map(\.1)
// [4.99, 3020.85, 69.73, -38.25, -27.44, -52249.98]
```

## Detailed design

### `CustomRegexComponent` protocol

The `CustomRegexComponent` protocol inherits from `RegexProtocol` and satisfies its sole requirement. This enables the usage of types that conform to `CustomRegexComponent` in regex builders and `RegexProtocol` algorithms.

```swift
public protocol CustomRegexComponent: RegexProtocol {
    /// Match the input string within the specified bounds, beginning at the given index, and return
    /// the end position (upper bound) of the match and the matched instance.
    /// - Parameters:
    ///   - input: The string in which the match is performed.
    ///   - index: An index of `input` at which to begin matching.
    ///   - bounds: The bounds in `input` in which the match is performed.
    /// - Returns: The upper bound where the match terminates and a matched instance, or nil if
    ///   there isn't a match.
    func match(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) -> (upperBound: String.Index, match: Match)?
}
```

### Algorithms

The following algorithms are included in this pitch:

#### Contains

```swift
extension Collection where Element: Equatable {
    public func contains<S: Sequence>(_ other: S) -> Bool
        where S.Element == Element
}

extension BidirectionalCollection where SubSequence == Substring {
    public func contains<R: RegexProtocol>(_ regex: R) -> Bool
}
```

#### Starts with

```swift
extension BidirectionalCollection where SubSequence == Substring {
    public func starts<R: RegexProtocol>(with regex: R) -> Bool
}
```

#### Trim prefix

```swift
extension Collection {
    public func trimmingPrefix(while predicate: (Element) -> Bool) -> SubSequence
}

extension Collection where SubSequence == Self {
    public mutating func trimPrefix(while predicate: (Element) -> Bool)
}

extension RangeReplaceableCollection {
    public mutating func trimPrefix(while predicate: (Element) -> Bool)
}

extension Collection where Element: Equatable {
    public func trimmingPrefix<Prefix: Collection>(_ prefix: Prefix) -> SubSequence
        where Prefix.Element == Element
}

extension Collection where SubSequence == Self, Element: Equatable {
    public mutating func trimPrefix<Prefix: Collection>(_ prefix: Prefix)
        where Prefix.Element == Element
}

extension RangeReplaceableCollection where Element: Equatable {
    public mutating func trimPrefix<Prefix: Collection>(_ prefix: Prefix)
        where Prefix.Element == Element
}

extension BidirectionalCollection where SubSequence == Substring {
    public func trimmingPrefix<R: RegexProtocol>(_ regex: R) -> SubSequence
}

extension RangeReplaceableCollection
  where Self: BidirectionalCollection, SubSequence == Substring
{
    public mutating func trimPrefix<R: RegexProtocol>(_ regex: R)
}
```

#### First range

```swift
extension Collection where Element: Equatable {
    public func firstRange<S: Sequence>(of sequence: S) -> Range<Index>? 
        where S.Element == Element
}

extension BidirectionalCollection where Element: Comparable {
    public func firstRange<S: Sequence>(of other: S) -> Range<Index>?
        where S.Element == Element
}

extension BidirectionalCollection where SubSequence == Substring {
    public func firstRange<R: RegexProtocol>(of regex: R) -> Range<Index>?
}
```

#### Ranges

```swift
extension Collection where Element: Equatable {
    public func ranges<S: Sequence>(of other: S) -> some Collection<Range<Index>>
        where S.Element == Element
}

extension BidirectionalCollection where SubSequence == Substring {
    public func ranges<R: RegexProtocol>(of regex: R) -> some Collection<Range<Index>>
}
```

#### First match

```swift
extension BidirectionalCollection where SubSequence == Substring {
    public func firstMatch<R: RegexProtocol>(of regex: R) -> RegexMatch<R.Match>?
}
```

#### Matches

```swift
extension BidirectionalCollection where SubSequence == Substring {
    public func matches<R: RegexProtocol>(of regex: R) -> some Collection<RegexMatch<R.Match>>
}
```

#### Replace

```swift
extension RangeReplaceableCollection where Element: Equatable {
    public func replacing<S: Sequence, Replacement: Collection>(
        _ other: S,
        with replacement: Replacement,
        subrange: Range<Index>,
        maxReplacements: Int = .max
    ) -> Self where S.Element == Element, Replacement.Element == Element
  
    public func replacing<S: Sequence, Replacement: Collection>(
        _ other: S,
        with replacement: Replacement,
        maxReplacements: Int = .max
    ) -> Self where S.Element == Element, Replacement.Element == Element
  
    public mutating func replace<S: Sequence, Replacement: Collection>(
        _ other: S,
        with replacement: Replacement,
        maxReplacements: Int = .max
    ) where S.Element == Element, Replacement.Element == Element
}

extension RangeReplaceableCollection where SubSequence == Substring {
    public func replacing<R: RegexProtocol, Replacement: Collection>(
        _ regex: R,
        with replacement: Replacement,
        subrange: Range<Index>,
        maxReplacements: Int = .max
    ) -> Self where Replacement.Element == Element
  
    public func replacing<R: RegexProtocol, Replacement: Collection>(
        _ regex: R,
        with replacement: Replacement,
        maxReplacements: Int = .max
    ) -> Self where Replacement.Element == Element
  
    public mutating func replace<R: RegexProtocol, Replacement: Collection>(
        _ regex: R,
        with replacement: Replacement,
        maxReplacements: Int = .max
    ) where Replacement.Element == Element
  
    public func replacing<R: RegexProtocol, Replacement: Collection>(
        _ regex: R,
        with replacement: (RegexMatch<R.Match>) throws -> Replacement,
        subrange: Range<Index>,
        maxReplacements: Int = .max
    ) rethrows -> Self where Replacement.Element == Element
  
    public func replacing<R: RegexProtocol, Replacement: Collection>(
        _ regex: R,
        with replacement: (RegexMatch<R.Match>) throws -> Replacement,
        maxReplacements: Int = .max
    ) rethrows -> Self where Replacement.Element == Element
  
    public mutating func replace<R: RegexProtocol, Replacement: Collection>(
        _ regex: R,
        with replacement: (RegexMatch<R.Match>) throws -> Replacement,
        maxReplacements: Int = .max
    ) rethrows where Replacement.Element == Element
}
```

#### Split

```swift
extension Collection where Element: Equatable {
    public func split<S: Sequence>(by separator: S) -> some Collection<SubSequence>
        where S.Element == Element
}

extension BidirectionalCollection where SubSequence == Substring {
    public func split<R: RegexProtocol>(by separator: R) -> some Collection<Substring>
}
```

## Alternatives considered

### Extend `Sequence` instead of `Collection`

All of the proposed algorithms are specific to the `Collection` protocol, without support for plain `Sequence`s. Types conforming to the `Sequence` protocol are not required to support multi-pass iteration, which makes a `Sequence` conformance insufficient for most of these algorithms. In light of this, the decision was made to have the underlying shared algorithm implementations work exclusively with `Collection`s.

## Future directions

### Backward algorithms

There are some unanswered questions about algorithms that operate from the back of a collection.

There is a subtle difference between finding the last non-overlapping range of a pattern in a string, and finding the first range of this pattern when searching from the back. `"aaaaa".ranges(of: "aa")` produces two non-overlapping ranges, splitting the string in the chunks `aa|aa|a`. It would not be completely unreasonable to expect `"aaaaa".lastRange(of: "aa")` to be shorthand for `"aaaaa".ranges(of: "aa").last`, i.e. to return the range that contains the third and fourth characters of the string. Yet, the first range of `"aa"` when searching from the back of the string yields the range that contains the fourth and fifth characters.

It is not obvious whether both of these notions of what it means for a range to be the "last" range should be supported, or what names should be used in order to disambiguate them. It is also worth noting that some kinds of patterns do behave nicely and always produce the same results when searching forwards or backwards, e.g. `myInts.lastIndex(where: { $0 > 10 })` is unambiguous. These kinds of patterns might warrant special treatment when designing algorithms that process the collection in reverse.

Similar questions arise when trimming a string from both sides: `"ababa".trimming("aba")` can return either `"ba"` or `"ab"`, depending on whether the prefix or the suffix was trimmed first.

### Throwing closures

The closure parameters of `trimPrefix(while:)` and `replace(_:with:)` aren't marked `throws` and the methods themselves aren't marked `rethrows`, because the shared implementations of these groups of related algorithms do not yet support error handling.

### Open up the shared algorithm implementations for user-defined types

At this point we have not settled on a final design for the protocol hierarchy that the shared algorithm implementations rely on, so we are not ready to expose this infrastructure and stabilize the entire ABI. We aim to eventually open up the ability for users to pass their own types to these `Collection` algorithms without having to go through the `RegexProtocol` overload which creates an intermediate `Regex` instance.
