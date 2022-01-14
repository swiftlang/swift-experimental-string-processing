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

// Overloads for quantifying over a character class.
public func zeroOrOne(_ cc: CharacterClass) -> _ZeroOrOne_0<CharacterClass> {
  .init(component: cc)
}

public func many(_ cc: CharacterClass) -> _ZeroOrMore_0<CharacterClass> {
  .init(component: cc)
}

public func oneOrMore(_ cc: CharacterClass) -> _OneOrMore_0<CharacterClass> {
  .init(component: cc)
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

public func oneOf<R: RegexProtocol>(
  @AlternationBuilder builder: () -> R
) -> R {
  builder()
}

// MARK: - Capture

public struct CapturingGroup<Match>: RegexProtocol {
  public let regex: Regex<Match>

  init<Component: RegexProtocol>(
    _ component: Component
  ) {
    self.regex = .init(node: .group(
      .capture, component.regex.root))
  }

  init<Component: RegexProtocol>(
    _ component: Component,
    transform: CaptureTransform
  ) {
    self.regex = .init(node: .groupTransform(
      .capture,
      component.regex.root,
      transform))
  }

  init<NewCapture, Component: RegexProtocol>(
    _ component: Component,
    transform: @escaping (Substring) -> NewCapture
  ) {
    self.init(
      component,
      transform: CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any
      })
  }

  init<NewCapture, Component: RegexProtocol>(
    _ component: Component,
    transform: @escaping (Substring) throws -> NewCapture
  ) {
    self.init(
      component,
      transform: CaptureTransform(resultType: NewCapture.self) {
        try transform($0) as Any
      })
  }

  init<NewCapture, Component: RegexProtocol>(
    _ component: Component,
    transform: @escaping (Substring) -> NewCapture?
  ) {
    self.init(
      component,
      transform: CaptureTransform(resultType: NewCapture.self) {
        transform($0) as Any?
      })
  }
}
