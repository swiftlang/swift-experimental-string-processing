//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@_implementationOnly import _RegexParser
@_spi(RegexBuilder) import _StringProcessing

@available(SwiftStdlib 5.7, *)
extension Regex {
  /// Creates a regular expression using a RegexBuilder closure.
  public init(
    @RegexComponentBuilder _ content: () -> some RegexComponent<Output>
  ) {
    self = content().regex
  }
}

// A convenience protocol for builtin regex components that are initialized with
// a `DSLTree` node.
@available(SwiftStdlib 5.7, *)
internal protocol _BuiltinRegexComponent: RegexComponent {
  init(_ regex: Regex<RegexOutput>)
}

// MARK: - Primitive regex components

@available(SwiftStdlib 5.7, *)
extension String: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> { .init(verbatim: self) }
}

@available(SwiftStdlib 5.7, *)
extension Substring: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> { String(self).regex }
}

@available(SwiftStdlib 5.7, *)
extension Character: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    _RegexFactory().char(self)
  }
}

@available(SwiftStdlib 5.7, *)
extension UnicodeScalar: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    _RegexFactory().scalar(self)
  }
}

// MARK: - Combinators

// MARK: Concatenation

// Note: Concatenation overloads are currently gyb'd.

// TODO: Variadic generics
// struct Concatenation<W0, C0..., R0: RegexComponent, W1, C1..., R1: RegexComponent>
// where R0.Match == (W0, C0...), R1.Match == (W1, C1...)
// {
//   typealias Match = (Substring, C0..., C1...)
//   let regex: Regex<Output>
//   init(_ first: R0, _ second: R1) {
//     regex = .init(concat(r0, r1))
//   }
// }

// MARK: Quantification

// Note: Quantifiers are currently gyb'd.

/// A regex component that matches exactly one occurrence of its underlying
/// component.
@available(SwiftStdlib 5.7, *)
public struct One<Output>: RegexComponent {
  public var regex: Regex<Output>

  /// Creates a regex component that matches the given component exactly once.
  public init(
    _ component: some RegexComponent<Output>
  ) {
    self.regex = component.regex
  }
}

/// A regex component that matches one or more occurrences of its underlying
/// component.
@available(SwiftStdlib 5.7, *)
public struct OneOrMore<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

/// A regex component that matches zero or more occurrences of its underlying
/// component.
@available(SwiftStdlib 5.7, *)
public struct ZeroOrMore<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

/// A regex component that matches zero or one occurrences of its underlying
/// component.
@available(SwiftStdlib 5.7, *)
public struct Optionally<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

/// A regex component that matches a selectable number of occurrences of its
/// underlying component.
@available(SwiftStdlib 5.7, *)
public struct Repeat<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

// MARK: Alternation

// TODO: Variadic generics
// @resultBuilder
// struct AlternationBuilder {
//   @_disfavoredOverload
//   func buildBlock<R: RegexComponent>(_ regex: R) -> R
//   func buildBlock<
//     R: RegexComponent, W0, C0...
//   >(
//     _ regex: R
//   ) -> R where R.Match == (W, C...)
// }

/// A custom parameter attribute that constructs regular expression alternations
/// from closures.
///
/// When you use a `ChoiceOf` initializer, the initializer's
/// closure parameter has an `AlternationBuilder` attribute, allowing you
/// to provide multiple regular expression statements as alternatives.
@available(SwiftStdlib 5.7, *)
@resultBuilder
public struct AlternationBuilder {
  @_disfavoredOverload
  public static func buildPartialBlock<R: RegexComponent>(
    first component: R
  ) -> ChoiceOf<R.RegexOutput> {
    .init(component.regex)
  }

  public static func buildExpression<R: RegexComponent>(_ regex: R) -> R {
    regex
  }
}

/// A regex component that chooses exactly one of its constituent regex
/// components when matching.
///
/// You can use `ChoiceOf` to provide a group of regex components, each of
/// which can be exclusively matched. In this example, `regex` successfully
/// matches either a `"CREDIT"` or `"DEBIT"` substring:
///
///     let regex = Regex {
///         ChoiceOf {
///             "CREDIT"
///             "DEBIT"
///         }
///     }
///     let match = try regex.prefixMatch(in: "DEBIT    04032020    Payroll $69.73")
///     print(match?.0 as Any)
///     // Prints "DEBIT"
@available(SwiftStdlib 5.7, *)
public struct ChoiceOf<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  /// Creates a regex component that chooses exactly one of the regex components
  /// provided by the builder closure.
  ///
  /// In this example, `regex` successfully matches either a `"CREDIT"` or
  /// `"DEBIT"` substring:
  ///
  ///     let regex = Regex {
  ///         ChoiceOf {
  ///             "CREDIT"
  ///             "DEBIT"
  ///         }
  ///     }
  ///     let match = try regex.prefixMatch(in: "DEBIT    04032020    Payroll $69.73")
  ///     print(match?.0 as Any)
  ///     // Prints "DEBIT"
  ///
  /// - Parameter builder: A builder closure that declares a list of regex
  ///   components, each of which can be exclusively matched.
  public init(@AlternationBuilder _ builder: () -> Self) {
    self = builder()
  }
}

// MARK: - Capture

/// A regex component that saves the matched substring, or a transformed result,
/// for access in a regex match.
///
/// Use a `Capture` component to capture one part of a regex to access
/// separately after matching. In the example below, `regex` matches a dollar
/// sign (`"$"`) followed by one or more digits, a period (`"."`), and then two
/// additional digits, as long as that pattern appears at the end of the line.
/// Because the `Capture` block wraps the digits and period, that part of the
/// match is captured separately.
///
///     let transactions = """
///         CREDIT     109912311421    Payroll   $69.73
///         CREDIT     105912031123    Travel   $121.54
///         DEBIT      107733291022    Refund    $8.42
///         """
///
///     let regex = Regex {
///         "$"
///         Capture {
///           OneOrMore(.digit)
///           "."
///           Repeat(.digit, count: 2)
///         }
///         Anchor.endOfLine
///     }
///
///     // The type of each match's output is `(Substring, Substring)`.
///     for match in transactions.matches(of: regex) {
///         print("Transaction amount: \(match.1)")
///     }
///     // Prints "Transaction amount: 69.73"
///     // Prints "Transaction amount: 121.54"
///     // Prints "Transaction amount: 8.42"
///
/// Each `Capture` block increases the number of components in the regex's
/// output type. In the example above, the capture type of each match is
/// `(Substring, Substring)`.
///
/// By providing a transform function to the `Capture` block, you can change the
/// type of the captured value from `Substring` to the result of the transform.
/// This example declares `doubleValueRegex`, which converts the captured amount
/// to a `Double`:
///
///     let doubleValueRegex = Regex {
///         "$"
///         Capture {
///             OneOrMore(.digit)
///             "."
///             Repeat(.digit, count: 2)
///         } transform: { Double($0)! }
///         Anchor.endOfLine
///     }
///
///     // The type of each match's output is `(Substring, Double)`.
///     for match in transactions.matches(of: doubleValueRegex) {
///         if match.1 >= 100.0 {
///             print("Large amount: \(match.1)")
///         }
///     }
///     // Prints "Large amount: 121.54"
///
/// Throwing an error from a `transform` closure aborts matching and propagates
/// the error out to the caller. If you instead want to use a failable
/// transformation, where a `nil` result participates in matching, use
/// ``TryCapture`` instead of `Capture`.
@available(SwiftStdlib 5.7, *)
public struct Capture<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers are currently gyb'd. See Variadics.swift.
}

/// A regex component that attempts to transform a matched substring, saving
/// the result if successful and backtracking if the transformation fails.
///
/// You use a `TryCapture` component to capture part of a match as a
/// transformed value, when a failure to transform should mean the regex
/// continues matching, backtracking from that point if necessary.
///
/// The code below demonstrates using `TryCapture` to include a test that the
/// `Double` value of a capture is over a limit. In the example, `regex`
/// matches a dollar sign (`"$"`) followed by one or more digits, a period
/// (`"."`), and then two additional digits, as long as that pattern appears at
/// the end of the line. The `TryCapture` block wraps the digits and period,
/// capturing that part of the match separately and passing it to its
/// `transform` closure. That closure converts the captured portion of the
/// match, converts it to a `Double`, and only returns a non-`nil` value if it
/// is over the transaction limit.
///
///     let transactions = """
///         CREDIT     109912311421    Payroll   $69.73
///         CREDIT     105912031123    Travel   $121.54
///         DEBIT      107733291022    Refund    $8.42
///         """
///     let transactionLimit = 100.0
///
///     let regex = Regex {
///         "$"
///         TryCapture {
///             OneOrMore(.digit)
///             "."
///             Repeat(.digit, count: 2)
///         } transform: { str -> Double? in
///             let value = Double(str)!
///             if value > transactionLimit {
///                 return value
///             }
///             return nil
///         }
///         Anchor.endOfLine
///     }
///
/// When the `TryCapture` block's `transform` closure processes the three
/// different amounts in the list of transactions, it only returns a non-`nil`
/// value for the $121.54 transaction. Even though the capture returns an
/// optional `Double` value, the captured value is non-optional.
///
///     // The type of each match's output is `(Substring, Double)`.
///     for match in transactions.matches(of: regex) {
///         print("Transaction amount: \(match.1)")
///     }
///     // Prints "Transaction amount: 121.54"
///
/// Throwing an error from a `transform` closure aborts matching and propagates
/// the error out to the caller. If you want to capture the `nil` results of a
/// failable transformation, instead of continuing a search, use ``Capture``
/// instead of `TryCapture`.
@available(SwiftStdlib 5.7, *)
public struct TryCapture<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers are currently gyb'd. See Variadics.swift.
}

// MARK: - Groups

/// A regex component that represents an atomic group.
///
/// An atomic group opens a local backtracking scope which, upon successful
/// exit, discards any remaining backtracking points from within the scope.
@available(SwiftStdlib 5.7, *)
public struct Local<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  @usableFromInline
  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }
}

// MARK: - Backreference

/// A reference to a captured portion of a regular expression.
///
/// You can use a `Reference` to access a regular expression, both during
/// the matching process and after a capture has been successful.
///
/// In this example, the `kind` reference captures either `"CREDIT"` or
/// `"DEBIT"` at the beginning of a line. Later in the regular expression, the
/// presence of `kind` matches the same substring that was captured previously
/// at the end of the line.
///
///     let kindRef = Reference(Substring.self)
///     let kindRegex = ChoiceOf {
///         "CREDIT"
///         "DEBIT"
///     }
///
///     let transactionRegex = Regex {
///         Anchor.startOfLine
///         Capture(kindRegex, as: kindRef)
///         OneOrMore(.anyNonNewline)
///         kindRef
///         Anchor.endOfLine
///     }
///
///     let validTransaction = "CREDIT     109912311421    Payroll   $69.73  CREDIT"
///     let invalidTransaction = "DEBIT     00522142123    Expense   $5.17  CREDIT"
///
///     print(validTransaction.contains(transactionRegex))
///     // Prints "true"
///     print(invalidTransaction.contains(transactionRegex))
///     // Prints "false"
///
/// Any reference that is used for matching must be captured elsewhere in the
/// `Regex` block. You can use a reference for matching before it is captured;
/// in that case, the reference will not match until it has previously been
/// captured.
///
/// To access the captured "transaction kind", you can use the `kind` reference
/// to subscript a `Regex.Match` instance:
///
///     if let match = validTransaction.firstMatch(of: transactionRegex) {
///         print(match[kindRef])
///     }
///     // Prints "CREDIT"
///
/// To use a `Reference` to capture a transformed value, include a `transform`
/// closure when capturing.
///
///     struct Transaction {
///         var id: UInt64
///     }
///     let transactionRef = Reference(Transaction.self)
///
///     let transactionIDRegex = Regex {
///         Capture(kindRegex, as: kindRef)
///         OneOrMore(.whitespace)
///         TryCapture(as: transactionRef) {
///             OneOrMore(.digit)
///         } transform: { str in
///             UInt64(str).map(Transaction.init(id:))
///         }
///         OneOrMore(.anyNonNewline)
///         kindRef
///         Anchor.endOfLine
///     }
///
///     if let match = validTransaction.firstMatch(of: transactionIDRegex) {
///         print(match[transactionRef])
///     }
///     // Prints "Transaction(id: 109912311421)"
@available(SwiftStdlib 5.7, *)
public struct Reference<Capture>: RegexComponent {
  let id = ReferenceID()

  /// Creates a reference with the specified capture type.
  public init(_ captureType: Capture.Type = Capture.self) {}

  @usableFromInline
  var _raw: Int {
    id._raw
  }
  
  public var regex: Regex<Capture> {
    _RegexFactory().symbolicReference(id)
  }
}

@available(SwiftStdlib 5.7, *)
extension Regex.Match {
  /// Accesses this match's capture by the given reference.
  public subscript<Capture>(_ reference: Reference<Capture>) -> Capture {
    self[reference.id]
  }
}

// RegexFactory's init is SPI, so we can't make an instance of one in AEIC, but
// if we hide it behind a resilience barrier we can call this function instead
// to get our instance of it.
@available(SwiftStdlib 5.7, *)
@usableFromInline
internal func makeFactory() -> _RegexFactory {
  _RegexFactory()
}

/// These are special `accumulate` methods that wrap one or both components in
/// a node that indicates that that their output types shouldn't be included in
/// the resulting strongly-typed output type. This is required from a
/// `buildPartialBlock` call where a component's output type is either ignored
/// or not included in the resulting type. For example:
///
///     static func buildPartialBlock<W0, W1, C1, R0: RegexComponent, R1: RegexComponent>(
///       accumulated: R0, next: R1
///     ) -> Regex<(Substring, C1)>  where R0.RegexOutput == W0, R1.RegexOutput == (W1, C1)
///
/// In this `buildPartialBlock` overload, `W0` isn't included in the
/// resulting output type, even though it can match any output type, including
/// a tuple. When `W0` matches a tuple type that doesn't match another overload
/// (because of arity or labels) we need this "ignoring" variant so that we
/// don't have a type mismatch when we ultimately cast the type-erased output
/// to the expected type.
@available(SwiftStdlib 5.7, *)
extension _RegexFactory {
  /// Concatenates the `left` and `right` component, wrapping `right` to
  /// indicate that its output type shouldn't be included in the resulting
  /// strongly-typed output type.
  @_alwaysEmitIntoClient
  internal func accumulate<Output>(
    _ left: some RegexComponent,
    ignoringOutputTypeOf right: some RegexComponent
  ) -> Regex<Output> {
    if #available(macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, *) {
      return accumulate(left, ignoreCapturesInTypedOutput(right))
    }
    return accumulate(left, right)
  }
  
  /// Concatenates the `left` and `right` component, wrapping `left` to
  /// indicate that its output type shouldn't be included in the resulting
  /// strongly-typed output type.
  @_alwaysEmitIntoClient
  internal func accumulate<Output>(
    ignoringOutputTypeOf left: some RegexComponent,
    _ right: some RegexComponent
  ) -> Regex<Output> {
    if #available(macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, *) {
      return accumulate(ignoreCapturesInTypedOutput(left), right)
    }
    return accumulate(left, right)
  }

  /// Concatenates the `left` and `right` component, wrapping both sides to
  /// indicate that their output types shouldn't be included in the resulting
  /// strongly-typed output type.
  @_alwaysEmitIntoClient
  internal func accumulate<Output>(
    ignoringOutputTypeOf left: some RegexComponent,
    andAlso right: some RegexComponent
  ) -> Regex<Output> {
    if #available(macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, *) {
      return accumulate(
        ignoreCapturesInTypedOutput(left), ignoreCapturesInTypedOutput(right))
    }
    return accumulate(left, right)
  }
}
