@resultBuilder
public enum RegexBuilder {
  public static func buildBlock<R0: RegexProtocol>(_ r0: R0) -> R0 {
    r0
  }
  
  public static func buildEither<R: RegexProtocol>(first component: R) -> R {
    component
  }

  public static func buildEither<R: RegexProtocol>(second component: R) -> R {
    component
  }

  public static func buildLimitedAvailability<R: RegexProtocol>(_ component: R) -> Optionally<R> {
    .init(component)
  }
}
