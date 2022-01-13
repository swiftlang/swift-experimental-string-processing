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

private func concat(
  _ asts: RegexDSLAST...
) -> RegexDSLAST {
  .concatenation(asts)
}
private func atom(_ kind: AST.Atom.Kind) -> RegexDSLAST {
  .literal(atom(kind))
}

extension String: RegexProtocol {
  public typealias Capture = EmptyCapture
  public typealias Match = Substring

  public var regex: Regex<Match> {
    let atoms = self.map {
      RegexDSLAST.literal(atom(.char($0)))
    }
    return .init(ast: .concatenation(atoms))
  }
}

extension Character: RegexProtocol {
  public typealias Capture = EmptyCapture
  public typealias Match = Substring

  public var regex: Regex<Match> {
    .init(ast: atom(.char(self)))
  }
}

extension CharacterClass: RegexProtocol {
  public typealias Capture = EmptyCapture
  public typealias Match = Substring

  public var regex: Regex<Match> {
    // TODO: predicate-based version
    guard let ast = self.makeAST() else {
      fatalError("FIXME: extended AST?")
    }
    return Regex(literalAST: ast)
  }
}

// MARK: - Combinators

// TODO: We want variadic generics!
// Overloads are auto-generated in Concatenation.swift.
//
// public struct Concatenate<R...: RegexContent>: RegexContent {
//   public let regex: Regex<(R...).filter { $0 != Void.self }>
//
//   public init(_ components: R...) {
//     regex = .init(ast: .concatenation([#splat(components...)]))
//   }
// }

// MARK: Repetition

private func quant(
  _ amount: AST.Quantification.Amount,
  _ child: RegexDSLAST,
  _ kind: AST.Quantification.Kind = .eager
) -> RegexDSLAST {
  .quantification(amount, kind, child)
}

/// A regular expression.
public struct OneOrMore<Component: RegexProtocol>: RegexProtocol {
  public typealias Match = Tuple2<Substring, [Component.Match.Capture]>

  public let regex: Regex<Match>

  public init(_ component: Component) {
    self.regex = .init(
      ast: quant(.oneOrMore, component.regex.ast))
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

postfix operator .+

public postfix func .+ <R: RegexProtocol>(
  lhs: R
) -> OneOrMore<R> {
  .init(lhs)
}

public struct Repeat<
  Component: RegexProtocol
>: RegexProtocol {
  public typealias Match = Tuple2<Substring, [Component.Match.Capture]>

  public let regex: Regex<Match>

  public init(_ component: Component) {
    self.regex = .init(
      ast: quant(.zeroOrMore, component.regex.ast))
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

postfix operator .*

public postfix func .* <R: RegexProtocol>(
  lhs: R
) -> Repeat<R> {
  .init(lhs)
}

public struct Optionally<Component: RegexProtocol>: RegexProtocol {
  public typealias Match = Tuple2<Substring, Component.Match.Capture?>

  public let regex: Regex<Match>

  public init(_ component: Component) {
    self.regex = .init(ast:
      quant(.zeroOrOne, component.regex.ast))
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

postfix operator .?

public postfix func .? <R: RegexProtocol>(
  lhs: R
) -> Optionally<R> {
  .init(lhs)
}

// TODO: Support heterogeneous capture alternation.
public struct Alternation<
  Component1: RegexProtocol, Component2: RegexProtocol
>: RegexProtocol where Component1.Match.Capture == Component2.Match.Capture {
  public typealias Match = Tuple2<Substring, Component1.Match.Capture>

  public let regex: Regex<Match>

  public init(_ first: Component1, _ second: Component2) {
    regex = .init(
      ast: .alternation([first.regex.ast, second.regex.ast]))
  }

  public init(
    @RegexBuilder _ content: () -> Alternation<Component1, Component2>
  ) {
    self = content()
  }
}

public func | <Component1, Component2>(
  lhs: Component1, rhs: Component2
) -> Alternation<Component1, Component2> {
  .init(lhs, rhs)
}

// MARK: - Capture

public struct CapturingGroup<Match: MatchProtocol>: RegexProtocol {
  public let regex: Regex<Match>

  init<Component: RegexProtocol>(
    _ component: Component
  ) {
    self.regex = .init(
      ast: .group(.capture, component.regex.ast))
  }

  init<NewCapture, Component: RegexProtocol>(
    _ component: Component,
    transform: @escaping (Substring) -> NewCapture
  ) {

    fatalError("FIXME: Now's the time to move it off the AST")

//    self.regex = .init(ast:
//      .groupTransform(
//        .init(.init(faking: .capture), component.regex.ast, .fake),
//        transform: CaptureTransform {
//          transform($0) as Any
//        }))
  }
}
