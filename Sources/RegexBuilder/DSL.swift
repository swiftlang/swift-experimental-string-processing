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
  public init<Content: RegexComponent>(
    @RegexComponentBuilder _ content: () -> Content
  ) where Content.RegexOutput == Output {
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
  public init<Component: RegexComponent>(
    _ component: Component
  ) where Component.RegexOutput == Output {
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
/// for access in a regular expression match.
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

/// A reference to a captured portion of a regular expresion.
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
