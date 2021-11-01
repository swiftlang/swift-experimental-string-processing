import Regex

// MARK: - Primitives

extension String: RegexProtocol {
  public typealias Capture = Empty

  public var regex: Regex<Capture> {
    .init(ast: .concatenation(map(AST.character)))
  }
}

extension Character: RegexProtocol {
  public typealias Capture = Empty

  public var regex: Regex<Capture> {
    .init(ast: .character(self))
  }
}

extension CharacterClass: RegexProtocol {
  public typealias Capture = Empty

  public var regex: Regex<Capture> {
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
  public typealias Capture = [Component.Capture]

  public let regex: Regex<Capture>

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
  public typealias Capture = [Component.Capture]

  public let regex: Regex<Capture>

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
  public typealias Capture = Component.Capture?

  public let regex: Regex<Capture>

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
  public typealias Capture = Component2.Capture

  public let regex: Regex<Capture>

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

public struct CapturingGroup<Capture>: RegexProtocol {
  public typealias Capture = Capture

  public let regex: Regex<Capture>

  init<Component: RegexProtocol>(
    _ component: Component
  ) {
    self.regex = .init(ast: .capturingGroup(component.regex.ast))
  }

  init<NewCapture, Component: RegexProtocol>(
    _ component: Component,
    transform: @escaping (Substring) -> NewCapture
  ) {
    self.regex = .init(ast: .capturingGroup(component.regex.ast, transform: CaptureTransform {
      transform($0) as Any
    }))
  }
}

extension RegexProtocol where Capture: EmptyProtocol {
  public func capture() -> CapturingGroup<Substring> {
    .init(self)
  }

  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<NewCapture> {
    .init(self, transform: transform)
  }
}

extension RegexProtocol {
  // Note: We use `@_disfavoredOverload` to prevent tuple captures from choosing this overload.
  @_disfavoredOverload
  public func capture() -> CapturingGroup<(Substring, Capture)> {
    .init(self)
  }

  // Note: We use `@_disfavoredOverload` to prevent tuple captures from choosing this overload.
  @_disfavoredOverload
  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, Capture)> {
    .init(self, transform: transform)
  }

  public func capture<C0, C1>() -> CapturingGroup<(Substring, C0, C1)> where Capture == (C0, C1) {
    .init(self)
  }

  public func capture<NewCapture, C0, C1>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, C0, C1)> where Capture == (C0, C1) {
    .init(self, transform: transform)
  }

  public func capture<C0, C1, C2>() -> CapturingGroup<(Substring, C0, C1, C2)>
  where Capture == (C0, C1, C2) {
    .init(self)
  }

  public func capture<NewCapture, C0, C1, C2>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(Substring, C0, C1, C2)> where Capture == (C0, C1, C2) {
    .init(self, transform: transform)
  }

  public func capture<C0, C1, C2, C3>() -> CapturingGroup<(Substring, C0, C1, C2, C3)>
  where Capture == (C0, C1, C2, C3) {
    .init(self)
  }

  public func capture<C0, C1, C2, C3, C4>() -> CapturingGroup<(Substring, C0, C1, C2, C3, C4)>
  where Capture == (C0, C1, C2, C3, C4) {
    .init(self)
  }

  public func capture<C0, C1, C2, C3, C4, C5>() -> CapturingGroup<(Substring, C0, C1, C2, C3, C4, C5)>
  where Capture == (C0, C1, C2, C3, C4, C5) {
    .init(self)
  }

  public func capture<C0, C1, C2, C3, C4, C5, C6>() -> CapturingGroup<(Substring, C0, C1, C2, C3, C4, C5, C6)>
  where Capture == (C0, C1, C2, C3, C4, C5, C6) {
    .init(self)
  }
}

/* Or using parameterized extensions and variadic generics.
extension<T...> RegexProtocol where Capture == (T...) {
  public func capture() -> CapturingGroup<(Substring, T...)> {
    .init(self)
  }

  public func capture<NewCapture>(
    _ transform: @escaping (Substring) -> NewCapture
  ) -> CapturingGroup<(NewCapture, T...)> {
    .init(self, transform: transform)
  }
}
*/
