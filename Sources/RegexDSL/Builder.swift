@resultBuilder
public enum RegexBuilder {
  public static func buildBlock<R0: RegexProtocol>(_ r0: R0) -> R0 {
    r0
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol>(_ r0: R0, _ r1: R1) -> Concatenate2<R0, R1> {
    .init(r0, r1)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2) -> Concatenate3<R0, R1, R2> {
    .init(r0, r1, r2)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3) -> Concatenate4<R0, R1, R2, R3> {
    .init(r0, r1, r2, r3)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4) -> Concatenate5<R0, R1, R2, R3, R4> {
    .init(r0, r1, r2, r3, r4)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5) -> Concatenate6<R0, R1, R2, R3, R4, R5> {
    .init(r0, r1, r2, r3, r4, r5)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6) -> Concatenate7<R0, R1, R2, R3, R4, R5, R6> {
    .init(r0, r1, r2, r3, r4, r5, r6)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol, R7: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7) -> Concatenate8<R0, R1, R2, R3, R4, R5, R6, R7> {
    .init(r0, r1, r2, r3, r4, r5, r6, r7)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol, R7: RegexProtocol, R8: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7, _ r8: R8) -> Concatenate9<R0, R1, R2, R3, R4, R5, R6, R7, R8> {
    .init(r0, r1, r2, r3, r4, r5, r6, r7, r8)
  }

  public static func buildBlock<R0: RegexProtocol, R1: RegexProtocol, R2: RegexProtocol, R3: RegexProtocol, R4: RegexProtocol, R5: RegexProtocol, R6: RegexProtocol, R7: RegexProtocol, R8: RegexProtocol, R9: RegexProtocol>(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7, _ r8: R8, _ r9: R9) -> Concatenate10<R0, R1, R2, R3, R4, R5, R6, R7, R8, R9> {
    .init(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9)
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
