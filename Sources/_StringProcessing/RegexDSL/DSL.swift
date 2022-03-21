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

import _MatchingEngine

// A convenience protocol for builtin regex components that are initialized with
// a `DSLTree` node.
internal protocol _BuiltinRegexComponent: RegexComponent {
  init(_ regex: Regex<Output>)
}

extension _BuiltinRegexComponent {
  init(node: DSLTree.Node) {
    self.init(Regex(node: node))
  }
}

// MARK: - Primitives

extension String: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    .init(node: .quotedLiteral(self))
  }
}

extension Substring: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    .init(node: .quotedLiteral(String(self)))
  }
}

extension Character: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    .init(node: .atom(.char(self)))
  }
}

extension UnicodeScalar: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    .init(node: .atom(.scalar(self)))
  }
}

extension CharacterClass: RegexComponent {
  public typealias Output = Substring

  public var regex: Regex<Output> {
    guard let ast = self.makeAST() else {
      fatalError("FIXME: extended AST?")
    }
    return Regex(ast: ast)
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

/// Specifies how much to attempt to match when using a quantifier.
public struct QuantificationBehavior {
  internal enum Kind {
    case eagerly
    case reluctantly
    case possessively
  }
  
  var kind: Kind
  
  internal var astKind: AST.Quantification.Kind {
    switch kind {
    case .eagerly: return .eager
    case .reluctantly: return .reluctant
    case .possessively: return .possessive
    }
  }
}

extension QuantificationBehavior {
  /// Match as much of the input string as possible, backtracking when
  /// necessary.
  public static var eagerly: QuantificationBehavior {
    .init(kind: .eagerly)
  }
  
  /// Match as little of the input string as possible, expanding the matched
  /// region as necessary to complete a match.
  public static var reluctantly: QuantificationBehavior {
    .init(kind: .reluctantly)
  }
  
  /// Match as much of the input string as possible, performing no backtracking.
  public static var possessively: QuantificationBehavior {
    .init(kind: .possessively)
  }
}

public struct OneOrMore<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

public struct ZeroOrMore<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

public struct Optionally<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

public struct Repeat<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers and operators are currently gyb'd. See
  // Variadics.swift.
}

postfix operator .?
postfix operator .*
postfix operator .+

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

@resultBuilder
public struct AlternationBuilder {
  @_disfavoredOverload
  public static func buildPartialBlock<R: RegexComponent>(
    first component: R
  ) -> ChoiceOf<R.Output> {
    .init(component.regex)
  }

  public static func buildExpression<R: RegexComponent>(_ regex: R) -> R {
    regex
  }

  public static func buildEither<R: RegexComponent>(first component: R) -> R {
    component
  }

  public static func buildEither<R: RegexComponent>(second component: R) -> R {
    component
  }
}

public struct ChoiceOf<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  public init(@AlternationBuilder _ builder: () -> Self) {
    self = builder()
  }
}

// MARK: - Capture

public struct Capture<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers are currently gyb'd. See Variadics.swift.
}

public struct TryCapture<Output>: _BuiltinRegexComponent {
  public var regex: Regex<Output>

  internal init(_ regex: Regex<Output>) {
    self.regex = regex
  }

  // Note: Public initializers are currently gyb'd. See Variadics.swift.
}

// MARK: - Backreference

struct ReferenceID: Hashable, Equatable {
  private static var counter: Int = 0
  var base: Int

  init() {
    base = Self.counter
    Self.counter += 1
  }
}

public struct Reference<Capture>: RegexComponent {
  let id = ReferenceID()
  
  public init(_ captureType: Capture.Type = Capture.self) {}

  public var regex: Regex<Capture> {
    .init(node: .atom(.symbolicReference(id)))
  }
}
