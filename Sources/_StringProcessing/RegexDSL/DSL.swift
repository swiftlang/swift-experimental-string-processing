import _MatchingEngine

// MARK: - Primitives

extension String: RegexProtocol {
  public typealias Capture = Empty

  public var regex: Regex<Capture> {
    let atoms = self.map { atom(.char($0)) }
    return .init(ast: concat(atoms))
  }
}

extension Character: RegexProtocol {
  public typealias Capture = Empty

  public var regex: Regex<Capture> {
    .init(ast: atom(.char(self)))
  }
}

extension CharacterClass: RegexProtocol {
  public typealias Capture = Empty

  public var regex: Regex<Capture> {
    guard let ast = self.makeAST() else {
      fatalError("FIXME: extended AST?")
    }
    return Regex(ast: ast)
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

/// A regular expression.
public struct OneOrMore<Component: RegexProtocol>: RegexProtocol {
  public typealias Capture = [Component.Capture]

  public let regex: Regex<Capture>

  public init(_ component: Component) {
    self.regex = .init(ast:
      oneOrMore(.greedy, component.regex.ast)
    )
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

postfix operator .+

public postfix func .+ <R: RegexProtocol>(lhs: R) -> OneOrMore<R> {
  .init(lhs)
}

public struct Repeat<Component: RegexProtocol>: RegexProtocol {
  public typealias Capture = [Component.Capture]

  public let regex: Regex<Capture>

  public init(_ component: Component) {
    self.regex = .init(ast:
      zeroOrMore(.greedy, component.regex.ast))
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

postfix operator .*

public postfix func .* <R: RegexProtocol>(lhs: R) -> Repeat<R> {
  .init(lhs)
}

public struct Optionally<Component: RegexProtocol>: RegexProtocol {
  public typealias Capture = Component.Capture?

  public let regex: Regex<Capture>

  public init(_ component: Component) {
    self.regex = .init(ast:
      zeroOrOne(.greedy, component.regex.ast))
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

postfix operator .?

public postfix func .? <R: RegexProtocol>(lhs: R) -> Optionally<R> {
  .init(lhs)
}

public struct Alternation<
  Component1: RegexProtocol,
  Component2: RegexProtocol
>: RegexProtocol {
  public typealias Capture = Component2.Capture

  public let regex: Regex<Capture>

  public init(_ first: Component1, _ second: Component2) {
    regex = .init(ast: alt(
      first.regex.ast, second.regex.ast
    ))
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

public struct CapturingGroup<Capture>: RegexProtocol {
  public typealias Capture = Capture

  public let regex: Regex<Capture>

  init<Component: RegexProtocol>(
    _ component: Component
  ) {
    self.regex = .init(ast:
      group(.capture, component.regex.ast)
    )
  }

  init<NewCapture, Component: RegexProtocol>(
    _ component: Component,
    transform: @escaping (Substring) -> NewCapture
  ) {
    self.regex = .init(ast:
      .groupTransform(
        .init(.init(faking: .capture), component.regex.ast, .fake),
        transform: CaptureTransform {
          transform($0) as Any
        }))
  }
}
