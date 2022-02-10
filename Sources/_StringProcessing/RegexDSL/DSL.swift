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

// Overloads for quantifying over a character class.
public func zeroOrOne(
  _ cc: CharacterClass,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring> {
  .init(node: .quantification(.zeroOrOne, behavior.astKind, cc.regex.root))
}

public func many(
  _ cc: CharacterClass,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring> {
  .init(node: .quantification(.zeroOrMore, behavior.astKind, cc.regex.root))
}

public func oneOrMore(
  _ cc: CharacterClass,
  _ behavior: QuantificationBehavior = .eagerly
) -> Regex<Substring> {
  .init(node: .quantification(.oneOrMore, behavior.astKind, cc.regex.root))
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

// MARK: - Assertions

public struct Assertion {
  internal enum Kind {
    case startOfSubject
    case endOfSubjectBeforeNewline
    case endOfSubject
    case firstMatchingPositionInSubject
    case textSegmentBoundary
    case startOfLine
    case endOfLine
    case wordBoundary
    case lookahead(Regex<Substring>)
  }
  
  var kind: Kind
  var isInverted: Bool = false
}

extension Assertion: RegexProtocol {
  var astAssertion: AST.Atom.AssertionKind? {
    if !isInverted {
      switch kind {
      case .startOfSubject: return .startOfSubject
      case .endOfSubjectBeforeNewline: return .endOfSubjectBeforeNewline
      case .endOfSubject: return .endOfSubject
      case .firstMatchingPositionInSubject: return .firstMatchingPositionInSubject
      case .textSegmentBoundary: return .textSegment
      case .startOfLine: return .startOfLine
      case .endOfLine: return .endOfLine
      case .wordBoundary: return .wordBoundary
      default: return nil
      }
    } else {
      switch kind {
      case .startOfSubject: fatalError("Not yet supported")
      case .endOfSubjectBeforeNewline: fatalError("Not yet supported")
      case .endOfSubject: fatalError("Not yet supported")
      case .firstMatchingPositionInSubject: fatalError("Not yet supported")
      case .textSegmentBoundary: return .notTextSegment
      case .startOfLine: fatalError("Not yet supported")
      case .endOfLine: fatalError("Not yet supported")
      case .wordBoundary: return .notWordBoundary
      default: return nil
      }
    }
  }
  
  public var regex: Regex<Substring> {
    if let assertionKind = astAssertion {
      return Regex(node: .atom(.assertion(assertionKind)))
    }
    
    switch (kind, isInverted) {
    case let (.lookahead(regex), false):
      return Regex(node: .group(.lookahead, regex.root))
    case let (.lookahead(regex), true):
      return Regex(node: .group(.negativeLookahead, regex.root))

    default:
      fatalError("Unsupported assertion")
    }
  }
}

extension Assertion {
  public static var startOfSubject: Assertion {
    Assertion(kind: .startOfSubject)
  }

  public static var endOfSubjectBeforeNewline: Assertion {
    Assertion(kind: .endOfSubjectBeforeNewline)
  }

  public static var endOfSubject: Assertion {
    Assertion(kind: .endOfSubject)
  }

  // TODO: Are we supporting this?
//  public static var resetStartOfMatch: Assertion {
//    Assertion(kind: resetStartOfMatch)
//  }

  public static var firstMatchingPositionInSubject: Assertion {
    Assertion(kind: .firstMatchingPositionInSubject)
  }

  public static var textSegmentBoundary: Assertion {
    Assertion(kind: .textSegmentBoundary)
  }
  
  public static var startOfLine: Assertion {
    Assertion(kind: .startOfLine)
  }

  public static var endOfLine: Assertion {
    Assertion(kind: .endOfLine)
  }

  public static var wordBoundary: Assertion {
    Assertion(kind: .wordBoundary)
  }
  
  public var inverted: Assertion {
    var result = self
    result.isInverted.toggle()
    return result
  }
}

extension Assertion {
  // TODO: Add overloads for other Match arities
  
  public static func lookahead<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> Assertion
    where R.Match == Substring
  {
    lookahead(content())
  }
  
  public static func lookahead<R: RegexProtocol>(_ component: R) -> Assertion
    where R.Match == Substring
  {
    Assertion(kind: .lookahead(component.regex))
  }
}
