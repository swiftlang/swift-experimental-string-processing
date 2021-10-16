import Regex

// MARK: - Primitives

extension String: RegexProtocol {
  public typealias MatchValue = Substring
  public typealias CaptureValue = Empty

  public var regex: Regex<CaptureValue> {
    .init(ast: .concatenation(map(AST.character)))
  }
}

extension Character: RegexProtocol {
  public typealias MatchValue = Character
  public typealias CaptureValue = Empty

  public var regex: Regex<CaptureValue> {
    .init(ast: .character(self))
  }
}

extension CharacterClass: RegexProtocol {
  public typealias MatchValue = Character
  public typealias CaptureValue = Empty

  public var regex: Regex<CaptureValue> {
    .init(ast: .characterClass(self))
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
  public typealias MatchValue = [Component.MatchValue]
  public typealias CaptureValue = [Component.CaptureValue]

  public let regex: Regex<CaptureValue>

  public init(_ component: Component) {
    self.regex = .init(ast: .oneOrMore(component.regex.ast))
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
  public typealias MatchValue = [Component.MatchValue]
  public typealias CaptureValue = [Component.CaptureValue]

  public let regex: Regex<CaptureValue>

  public init(_ component: Component) {
    self.regex = .init(ast: .many(component.regex.ast))
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
  public typealias MatchValue = Component.MatchValue?
  public typealias CaptureValue = Component.CaptureValue?

  public let regex: Regex<CaptureValue>

  public init(_ component: Component) {
    self.regex = .init(ast: .zeroOrOne(component.regex.ast))
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
  public typealias MatchValue = Component1.MatchValue
  public typealias CaptureValue = Component2.CaptureValue

  public let regex: Regex<CaptureValue>

  public init(_ first: Component1, _ second: Component2) {
    regex = .init(ast: .alternation([first.regex.ast, second.regex.ast]))
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

public struct CapturingGroup<Component: RegexProtocol>: RegexProtocol {
  public typealias MatchValue = Component.MatchValue
  public typealias CaptureValue = Component.MatchValue

  public let regex: Regex<CaptureValue>

  public init(_ component: Component) {
    self.regex = .init(ast: .capturingGroup(component.regex.ast))
  }

  public init(@RegexBuilder _ content: () -> Component) {
    self.init(content())
  }
}

extension RegexProtocol {
  public func capture() -> CapturingGroup<Self> {
    .init(self)
  }
}
