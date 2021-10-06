import Regex

// MARK: - Primitives

extension String: RegexProtocol {
  public typealias CaptureValue = ()

  public var regex: Regex<CaptureValue> {
    .init(ast: .concatenation(map(AST.character)))
  }
}

extension Character: RegexProtocol {
  public typealias CaptureValue = ()

  public var regex: Regex<CaptureValue> {
    .init(ast: .character(self))
  }
}

extension CharacterClass: RegexProtocol {
  public typealias CaptureValue = ()

  public var regex: Regex<CaptureValue> {
    .init(ast: .characterClass(self))
  }
}

// MARK: - Combinators

// MARK: Concatenation

public struct Concatenate2<R0: RegexProtocol, R1: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue)>

  public init(_ r0: R0, _ r1: R1) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast]))
  }
}

public struct Concatenate3<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast]))
  }
}

public struct Concatenate4<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast]))
  }
}

public struct Concatenate5<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue, R4.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast, r4.regex.ast]))
  }
}

public struct Concatenate6<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue, R4.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast, r4.regex.ast, r5.regex.ast]))
  }
}

public struct Concatenate7<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue, R4.CaptureValue, R5.CaptureValue, R6.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast, r4.regex.ast, r5.regex.ast, r6.regex.ast]))
  }
}

public struct Concatenate8<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol, R7: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue, R4.CaptureValue, R5.CaptureValue, R6.CaptureValue, R7.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast, r4.regex.ast, r5.regex.ast, r6.regex.ast, r7.regex.ast]))
  }
}

public struct Concatenate9<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol, R7: RegexProtocol, R8: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue, R4.CaptureValue, R5.CaptureValue, R6.CaptureValue, R7.CaptureValue, R8.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7, _ r8: R8) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast, r4.regex.ast, r5.regex.ast, r6.regex.ast, r7.regex.ast, r8.regex.ast]))
  }
}

public struct Concatenate10<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol, R7: RegexProtocol, R8: RegexProtocol, R9: RegexProtocol>: RegexProtocol {
  public let regex: Regex<(R0.CaptureValue, R1.CaptureValue, R2.CaptureValue, R3.CaptureValue, R4.CaptureValue, R5.CaptureValue, R6.CaptureValue, R7.CaptureValue, R8.CaptureValue, R9.CaptureValue)>

  public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7, _ r8: R8, _ r9: R9) {
    regex = .init(ast: .concatenation([r0.regex.ast, r1.regex.ast, r2.regex.ast, r3.regex.ast, r4.regex.ast, r5.regex.ast, r6.regex.ast, r7.regex.ast, r8.regex.ast, r9.regex.ast]))
  }
}

// TODO: We want variadic generics!
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

public struct Alternation<First: RegexProtocol, Second: RegexProtocol>: RegexProtocol {
  public enum CaptureValue {
    case first(First)
    case second(Second)
  }

  public let regex: Regex<CaptureValue>

  public init(_ first: First, _ second: Second) {
    regex = .init(ast: .alternation([first.regex.ast, second.regex.ast]))
  }

  public init(@RegexBuilder _ content: () -> Alternation<First, Second>) {
    self = content()
  }
}

public func | <First: RegexProtocol, Second: RegexProtocol>(
  lhs: First, rhs: Second
) -> Alternation<First, Second> {
  .init(lhs, rhs)
}

// MARK: - Capture

public struct CapturingGroup<Component: RegexProtocol>: RegexProtocol {
  public typealias CaptureValue = Component.CaptureValue

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
