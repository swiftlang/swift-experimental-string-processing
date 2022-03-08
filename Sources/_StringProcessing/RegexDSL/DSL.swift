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

// MARK: - Primitives

extension String: RegexComponent {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    .init(node: .quotedLiteral(self))
  }
}

extension Substring: RegexComponent {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    .init(node: .quotedLiteral(String(self)))
  }
}

extension Character: RegexComponent {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    .init(node: .atom(.char(self)))
  }
}

extension UnicodeScalar: RegexComponent {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    .init(node: .atom(.scalar(self)))
  }
}

extension CharacterClass: RegexComponent {
  public typealias Match = Substring

  public var regex: Regex<Match> {
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
//   let regex: Regex<Match>
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

// TODO: Variadic generics
// struct _OneOrMore<W, C..., Component: RegexComponent>
// where R.Match == (W, C...)
// {
//   typealias Match = (Substring, [(C...)])
//   let regex: Regex<Match>
//   init(_ component: Component) {
//     regex = .init(oneOrMore(r0))
//   }
// }
//
// struct _OneOrMoreNonCapturing<Component: RegexComponent> {
//   typealias Match = Substring
//   let regex: Regex<Match>
//   init(_ component: Component) {
//     regex = .init(oneOrMore(r0))
//   }
// }
//
// func oneOrMore<W, C..., Component: RegexComponent>(
//   _ component: Component
// ) -> <R: RegexComponent where R.Match == (Substring, [(C...)])> R {
//   _OneOrMore(component)
// }
//
// @_disfavoredOverload
// func oneOrMore<Component: RegexComponent>(
//   _ component: Component
// ) -> <R: RegexComponent where R.Match == Substring> R {
//   _OneOrMoreNonCapturing(component)
// }

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
  public static func buildBlock<R: RegexComponent>(_ regex: R) -> R {
    regex
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

public func choiceOf<R: RegexComponent>(
  @AlternationBuilder builder: () -> R
) -> R {
  builder()
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
