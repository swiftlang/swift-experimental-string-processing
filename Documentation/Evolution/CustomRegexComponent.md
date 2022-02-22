# Pattern matching algorithms and custom types 

// FIXME: To be combined with the pitch for pattern matching algorithms


## Use existing parsers with pattern matching algorithms

One advantage of having generic algorithm functions is that you can back them with any `RegexProtocol` types, including existing parsers of your own. 

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

if let dateMatch = header.firstMatch(of: regex)?.result.0 {
    let date = try? Date(dateMatch, strategy: .fixed(format: "\(day: .twoDigits) \(month: .abbreviated) \(year: .padded(4))", timeZone: .current, locale: .current))
}
```

This works, but wouldn't it be much more approachable if you can directly use the date parser within the match function?

```swift
let regex = Regex {
    capture { 
        .date(format: "\(day: .twoDigits) \(month: .abbreviated) \(year: .padded(4))") 
    }
}

if let match = header.firstMatch(of: regex) {
    let string = match.result.0 // "16 Feb 2022"
    let date = match.result.1 // 2022-02-16 00:00:00 +0000
}
```

You can do this because Foundation framework's `Date.ParseStrategy` conforms to `CustomRegexComponent`, defined as below. You can also conform your custom parser to `CustomRegexComponent`. Conformance is simple: implement the `match` function to return the upper bound of the matched substring, and the type represented by the matched range. It inherits from `RegexProtocol`, so you will be able to use it with all of the string algorithms that take a `RegexProtocol` type. 

```swift
public protocol CustomRegexComponent: RegexProtocol {
    /// Match the input string within the specified bounds, beginning at the given index, and return the end position (upper bound) of the match and the matched instance.
    /// - Parameters:
    ///   - input: The string in which the match is performed
    ///   - index: An index of `input` at which to begin matching. Usually it is `bounds.lowerBound` if the match is left-to-right, or `bounds.upperBound - 1` if it's right-to-left, but it could be anywhere, such as when there is an anchor
    ///   - bounds: The bounds in which to match is performed
    /// - Returns: The upper bound where the match terminates and a matched instance, or nil if there isn't a match
    func match(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) -> (upperBound: String.Index, match: Match)?
}
```


Foundation framework's `Date.ParseStrategy` conforms to `CustomRegexComponent` this way. It also adds a static function `date(format:timeZone:locale:)` as a static member of `RegexProtocol`, so you can refer to it as `.date(format:...)` in the `Regex` result builder. 

```swift
// Declared in Foundation.framework

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
        timeZone: TimeZone = .current, 
        locale: Locale? = .current,
    ) -> Self  
}
```

Here's another example of how you can use `FloatingPointFormatStyle<Double>.Currency` to parse a bank statement and record all the monetary values. Parsing a currency string such as `$3,020.85` with regex isn't trivial -- it can contain grouping separators, a decimal separator, and a currency symbol, all of which can be localized. Delegating parsing such strings to a dedicated currency parser alleviates the need to handle it yourself.

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

let amount = statement.matches(of: regex).map(\.result.1) // [4.99, 3020.85, 69.73, -38.25, -27.44, -52249.98]
```
