// BEGIN AUTO-GENERATED CONTENT


public struct Concatenate2_TT<T0: RegexProtocol, T1: RegexProtocol>: RegexProtocol {
  public typealias Capture = (T0.Capture, T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1>(
    _ x0: T0, _ x1: T1
  ) -> Concatenate2_TT<T0, T1> {
    Concatenate2_TT(x0, x1)
  }
}

public struct Concatenate2_TV<T0: RegexProtocol, T1: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1>(
    _ x0: T0, _ x1: T1
  ) -> Concatenate2_TV<T0, T1> {
    Concatenate2_TV(x0, x1)
  }
}

public struct Concatenate2_VT<T0: RegexProtocol, T1: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1>(
    _ x0: T0, _ x1: T1
  ) -> Concatenate2_VT<T0, T1> {
    Concatenate2_VT(x0, x1)
  }
}

public struct Concatenate2_VV<T0: RegexProtocol, T1: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol {
  public typealias Capture = Empty
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1>(
    _ x0: T0, _ x1: T1
  ) -> Concatenate2_VV<T0, T1> {
    Concatenate2_VV(x0, x1)
  }
}



public struct Concatenate3_TTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_TTT<T0, T1, T2> {
    Concatenate3_TTT(x0, x1, x2)
  }
}

public struct Concatenate3_TTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_TTV<T0, T1, T2> {
    Concatenate3_TTV(x0, x1, x2)
  }
}

public struct Concatenate3_TVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_TVT<T0, T1, T2> {
    Concatenate3_TVT(x0, x1, x2)
  }
}

public struct Concatenate3_TVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_TVV<T0, T1, T2> {
    Concatenate3_TVV(x0, x1, x2)
  }
}

public struct Concatenate3_VTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_VTT<T0, T1, T2> {
    Concatenate3_VTT(x0, x1, x2)
  }
}

public struct Concatenate3_VTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_VTV<T0, T1, T2> {
    Concatenate3_VTV(x0, x1, x2)
  }
}

public struct Concatenate3_VVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_VVT<T0, T1, T2> {
    Concatenate3_VVT(x0, x1, x2)
  }
}

public struct Concatenate3_VVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = Empty
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2>(
    _ x0: T0, _ x1: T1, _ x2: T2
  ) -> Concatenate3_VVV<T0, T1, T2> {
    Concatenate3_VVV(x0, x1, x2)
  }
}



public struct Concatenate4_TTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TTTT<T0, T1, T2, T3> {
    Concatenate4_TTTT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TTTV<T0, T1, T2, T3> {
    Concatenate4_TTTV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TTVT<T0, T1, T2, T3> {
    Concatenate4_TTVT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TTVV<T0, T1, T2, T3> {
    Concatenate4_TTVV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TVTT<T0, T1, T2, T3> {
    Concatenate4_TVTT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TVTV<T0, T1, T2, T3> {
    Concatenate4_TVTV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TVVT<T0, T1, T2, T3> {
    Concatenate4_TVVT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_TVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_TVVV<T0, T1, T2, T3> {
    Concatenate4_TVVV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VTTT<T0, T1, T2, T3> {
    Concatenate4_VTTT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VTTV<T0, T1, T2, T3> {
    Concatenate4_VTTV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VTVT<T0, T1, T2, T3> {
    Concatenate4_VTVT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VTVV<T0, T1, T2, T3> {
    Concatenate4_VTVV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VVTT<T0, T1, T2, T3> {
    Concatenate4_VVTT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VVTV<T0, T1, T2, T3> {
    Concatenate4_VVTV(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VVVT<T0, T1, T2, T3> {
    Concatenate4_VVVT(x0, x1, x2, x3)
  }
}

public struct Concatenate4_VVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = Empty
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3
  ) -> Concatenate4_VVVV<T0, T1, T2, T3> {
    Concatenate4_VVVV(x0, x1, x2, x3)
  }
}



public struct Concatenate5_TTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTTTT<T0, T1, T2, T3, T4> {
    Concatenate5_TTTTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTTTV<T0, T1, T2, T3, T4> {
    Concatenate5_TTTTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTTVT<T0, T1, T2, T3, T4> {
    Concatenate5_TTTVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTTVV<T0, T1, T2, T3, T4> {
    Concatenate5_TTTVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTVTT<T0, T1, T2, T3, T4> {
    Concatenate5_TTVTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTVTV<T0, T1, T2, T3, T4> {
    Concatenate5_TTVTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTVVT<T0, T1, T2, T3, T4> {
    Concatenate5_TTVVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TTVVV<T0, T1, T2, T3, T4> {
    Concatenate5_TTVVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVTTT<T0, T1, T2, T3, T4> {
    Concatenate5_TVTTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVTTV<T0, T1, T2, T3, T4> {
    Concatenate5_TVTTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVTVT<T0, T1, T2, T3, T4> {
    Concatenate5_TVTVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVTVV<T0, T1, T2, T3, T4> {
    Concatenate5_TVTVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVVTT<T0, T1, T2, T3, T4> {
    Concatenate5_TVVTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVVTV<T0, T1, T2, T3, T4> {
    Concatenate5_TVVTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVVVT<T0, T1, T2, T3, T4> {
    Concatenate5_TVVVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_TVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_TVVVV<T0, T1, T2, T3, T4> {
    Concatenate5_TVVVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTTTT<T0, T1, T2, T3, T4> {
    Concatenate5_VTTTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTTTV<T0, T1, T2, T3, T4> {
    Concatenate5_VTTTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTTVT<T0, T1, T2, T3, T4> {
    Concatenate5_VTTVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTTVV<T0, T1, T2, T3, T4> {
    Concatenate5_VTTVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTVTT<T0, T1, T2, T3, T4> {
    Concatenate5_VTVTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTVTV<T0, T1, T2, T3, T4> {
    Concatenate5_VTVTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTVVT<T0, T1, T2, T3, T4> {
    Concatenate5_VTVVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VTVVV<T0, T1, T2, T3, T4> {
    Concatenate5_VTVVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVTTT<T0, T1, T2, T3, T4> {
    Concatenate5_VVTTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVTTV<T0, T1, T2, T3, T4> {
    Concatenate5_VVTTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVTVT<T0, T1, T2, T3, T4> {
    Concatenate5_VVTVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVTVV<T0, T1, T2, T3, T4> {
    Concatenate5_VVTVV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVVTT<T0, T1, T2, T3, T4> {
    Concatenate5_VVVTT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVVTV<T0, T1, T2, T3, T4> {
    Concatenate5_VVVTV(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVVVT<T0, T1, T2, T3, T4> {
    Concatenate5_VVVVT(x0, x1, x2, x3, x4)
  }
}

public struct Concatenate5_VVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = Empty
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4
  ) -> Concatenate5_VVVVV<T0, T1, T2, T3, T4> {
    Concatenate5_VVVVV(x0, x1, x2, x3, x4)
  }
}



public struct Concatenate6_TTTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTTVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTTVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TTVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TTVVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TTVVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVTVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVTVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_TVVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_TVVVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_TVVVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTTVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTTVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VTVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VTVVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VTVVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVTVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVTVVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVTTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVTTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVTTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVTTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVTVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVTVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVTVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVTVV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVVTT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVVTT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVVTV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVVTV(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVVVT<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVVVT(x0, x1, x2, x3, x4, x5)
  }
}

public struct Concatenate6_VVVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = Empty
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5
  ) -> Concatenate6_VVVVVV<T0, T1, T2, T3, T4, T5> {
    Concatenate6_VVVVVV(x0, x1, x2, x3, x4, x5)
  }
}



public struct Concatenate7_TTTTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTTVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTTVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTTVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TTVVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol {
  public typealias Capture = (T5.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TTVVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TTVVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVTVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVTVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVTVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_TVVVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol {
  public typealias Capture = (T6.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_TVVVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_TVVVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTTVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTTVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTTVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VTVVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T5.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VTVVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VTVVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVTVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T4.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVTVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVTVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVTVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T3.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVTVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVTVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVTTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVTTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVTTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVTTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVTTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVTTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVTVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVTVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVTVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVTVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T2.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVTVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVTVV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVVTT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture, T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVVTT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVVTT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVVTV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T1.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVVTV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVVTV(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVVVT<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = (T0.Capture)
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVVVT<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVVVT(x0, x1, x2, x3, x4, x5, x6)
  }
}

public struct Concatenate7_VVVVVVV<T0: RegexProtocol, T1: RegexProtocol, T2: RegexProtocol, T3: RegexProtocol, T4: RegexProtocol, T5: RegexProtocol, T6: RegexProtocol>: RegexProtocol where T0.Capture: EmptyProtocol, T1.Capture: EmptyProtocol, T2.Capture: EmptyProtocol, T3.Capture: EmptyProtocol, T4.Capture: EmptyProtocol, T5.Capture: EmptyProtocol, T6.Capture: EmptyProtocol {
  public typealias Capture = Empty
  public let regex: Regex<Capture>
  init(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) {
    regex = .init(ast: .concatenation([x0.regex.ast, x1.regex.ast, x2.regex.ast, x3.regex.ast, x4.regex.ast, x5.regex.ast, x6.regex.ast]))
  }
}

extension RegexBuilder {
  public static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(
    _ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6
  ) -> Concatenate7_VVVVVVV<T0, T1, T2, T3, T4, T5, T6> {
    Concatenate7_VVVVVVV(x0, x1, x2, x3, x4, x5, x6)
  }
}



// END AUTO-GENERATED CONTENT