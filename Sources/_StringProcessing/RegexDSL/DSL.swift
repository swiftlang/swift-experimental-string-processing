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

extension String: RegexProtocol {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    let atoms = self.map { atom(.char($0)) }
    return .init(ast: concat(atoms))
  }
}

extension Substring: RegexProtocol {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    let atoms = self.map { atom(.char($0)) }
    return .init(ast: concat(atoms))
  }
}

extension Character: RegexProtocol {
  public typealias Match = Substring

  public var regex: Regex<Match> {
    .init(ast: atom(.char(self)))
  }
}

extension CharacterClass: RegexProtocol {
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
// struct Concatenation<W0, C0..., R0: RegexProtocol, W1, C1..., R1: RegexProtocol>
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
// struct _OneOrMore<W, C..., Component: RegexProtocol>
// where R.Match == (W, C...)
// {
//   typealias Match = (Substring, [(C...)])
//   let regex: Regex<Match>
//   init(_ component: Component) {
//     regex = .init(oneOrMore(r0))
//   }
// }
//
// struct _OneOrMoreNonCapturing<Component: RegexProtocol> {
//   typealias Match = Substring
//   let regex: Regex<Match>
//   init(_ component: Component) {
//     regex = .init(oneOrMore(r0))
//   }
// }
//
// func oneOrMore<W, C..., Component: RegexProtocol>(
//   _ component: Component
// ) -> <R: RegexProtocol where R.Match == (Substring, [(C...)])> R {
//   _OneOrMore(component)
// }
//
// @_disfavoredOverload
// func oneOrMore<Component: RegexProtocol>(
//   _ component: Component
// ) -> <R: RegexProtocol where R.Match == Substring> R {
//   _OneOrMoreNonCapturing(component)
// }

postfix operator .?
postfix operator .*
postfix operator .+

/// Generates a DSLTree node for a repeated range of the given DSLTree node.
/// Individual public API functions are in the generated Variadics.swift file.
internal func _repeatingNode(
  _ range: Range<Int>,
  _ behavior: QuantificationBehavior,
  _ node: DSLTree.Node
) -> DSLTree.Node {
  // TODO: Throw these as errors
  assert(range.lowerBound >= 0, "Cannot specify a negative lower bound")
  assert(!range.isEmpty, "Cannot specify an empty range")
  
  switch (range.lowerBound, range.upperBound) {
  case (0, Int.max): // 0...
    return .quantification(.zeroOrMore, behavior.astKind, node)
  case (1, Int.max): // 1...
    return .quantification(.oneOrMore, behavior.astKind, node)
  case _ where range.count == 1: // ..<1 or ...0 or any range with count == 1
    // Note: `behavior` is ignored in this case
    return .quantification(.exactly(.init(faking: range.lowerBound)), .eager, node)
  case (0, _): // 0..<n or 0...n or ..<n or ...n
    return .quantification(.upToN(.init(faking: range.upperBound)), behavior.astKind, node)
  case (_, Int.max): // n...
    return .quantification(.nOrMore(.init(faking: range.lowerBound)), behavior.astKind, node)
  default: // any other range
    return .quantification(.range(.init(faking: range.lowerBound), .init(faking: range.upperBound)), behavior.astKind, node)
  }
}

// MARK: Alternation

// TODO: Variadic generics
// @resultBuilder
// struct AlternationBuilder {
//   @_disfavoredOverload
//   func buildBlock<R: RegexProtocol>(_ regex: R) -> R
//   func buildBlock<
//     R: RegexProtocol, W0, C0...
//   >(
//     _ regex: R
//   ) -> R where R.Match == (W, C...)
// }

@resultBuilder
public struct AlternationBuilder {
  @_disfavoredOverload
  public static func buildBlock<R: RegexProtocol>(_ regex: R) -> R {
    regex
  }

  public static func buildExpression<R: RegexProtocol>(_ regex: R) -> R {
    regex
  }

  public static func buildEither<R: RegexProtocol>(first component: R) -> R {
    component
  }

  public static func buildEither<R: RegexProtocol>(second component: R) -> R {
    component
  }
}

public func choiceOf<R: RegexProtocol>(
  @AlternationBuilder builder: () -> R
) -> R {
  builder()
}
