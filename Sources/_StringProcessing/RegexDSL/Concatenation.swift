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

// BEGIN AUTO-GENERATED CONTENT

import _MatchingEngine

@frozen @dynamicMemberLookup
public struct Tuple2<_0, _1> {
  public typealias Tuple = (_0, _1)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple2: EmptyCaptureProtocol where _1: EmptyCaptureProtocol {}
extension Tuple2: MatchProtocol {
  public typealias Capture = _1
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1) {
    self.init((_0, _1))
  }
}
extension Tuple2: Equatable where _0: Equatable, _1: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1
  }
}
@frozen @dynamicMemberLookup
public struct Tuple3<_0, _1, _2> {
  public typealias Tuple = (_0, _1, _2)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple3: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol {}
extension Tuple3: MatchProtocol {
  public typealias Capture = Tuple2<_1, _2>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2) {
    self.init((_0, _1, _2))
  }
}
extension Tuple3: Equatable where _0: Equatable, _1: Equatable, _2: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2
  }
}
@frozen @dynamicMemberLookup
public struct Tuple4<_0, _1, _2, _3> {
  public typealias Tuple = (_0, _1, _2, _3)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple4: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol {}
extension Tuple4: MatchProtocol {
  public typealias Capture = Tuple3<_1, _2, _3>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3) {
    self.init((_0, _1, _2, _3))
  }
}
extension Tuple4: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3
  }
}
@frozen @dynamicMemberLookup
public struct Tuple5<_0, _1, _2, _3, _4> {
  public typealias Tuple = (_0, _1, _2, _3, _4)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple5: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol {}
extension Tuple5: MatchProtocol {
  public typealias Capture = Tuple4<_1, _2, _3, _4>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4) {
    self.init((_0, _1, _2, _3, _4))
  }
}
extension Tuple5: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4
  }
}
@frozen @dynamicMemberLookup
public struct Tuple6<_0, _1, _2, _3, _4, _5> {
  public typealias Tuple = (_0, _1, _2, _3, _4, _5)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple6: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol, _5: EmptyCaptureProtocol {}
extension Tuple6: MatchProtocol {
  public typealias Capture = Tuple5<_1, _2, _3, _4, _5>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4, _ _5: _5) {
    self.init((_0, _1, _2, _3, _4, _5))
  }
}
extension Tuple6: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable, _5: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4 && lhs.tuple.5 == rhs.tuple.5
  }
}
@frozen @dynamicMemberLookup
public struct Tuple7<_0, _1, _2, _3, _4, _5, _6> {
  public typealias Tuple = (_0, _1, _2, _3, _4, _5, _6)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple7: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol, _5: EmptyCaptureProtocol, _6: EmptyCaptureProtocol {}
extension Tuple7: MatchProtocol {
  public typealias Capture = Tuple6<_1, _2, _3, _4, _5, _6>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4, _ _5: _5, _ _6: _6) {
    self.init((_0, _1, _2, _3, _4, _5, _6))
  }
}
extension Tuple7: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable, _5: Equatable, _6: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4 && lhs.tuple.5 == rhs.tuple.5 && lhs.tuple.6 == rhs.tuple.6
  }
}
@frozen @dynamicMemberLookup
public struct Tuple8<_0, _1, _2, _3, _4, _5, _6, _7> {
  public typealias Tuple = (_0, _1, _2, _3, _4, _5, _6, _7)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple8: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol, _5: EmptyCaptureProtocol, _6: EmptyCaptureProtocol, _7: EmptyCaptureProtocol {}
extension Tuple8: MatchProtocol {
  public typealias Capture = Tuple7<_1, _2, _3, _4, _5, _6, _7>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4, _ _5: _5, _ _6: _6, _ _7: _7) {
    self.init((_0, _1, _2, _3, _4, _5, _6, _7))
  }
}
extension Tuple8: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable, _5: Equatable, _6: Equatable, _7: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4 && lhs.tuple.5 == rhs.tuple.5 && lhs.tuple.6 == rhs.tuple.6 && lhs.tuple.7 == rhs.tuple.7
  }
}
@frozen @dynamicMemberLookup
public struct Tuple9<_0, _1, _2, _3, _4, _5, _6, _7, _8> {
  public typealias Tuple = (_0, _1, _2, _3, _4, _5, _6, _7, _8)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple9: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol, _5: EmptyCaptureProtocol, _6: EmptyCaptureProtocol, _7: EmptyCaptureProtocol, _8: EmptyCaptureProtocol {}
extension Tuple9: MatchProtocol {
  public typealias Capture = Tuple8<_1, _2, _3, _4, _5, _6, _7, _8>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4, _ _5: _5, _ _6: _6, _ _7: _7, _ _8: _8) {
    self.init((_0, _1, _2, _3, _4, _5, _6, _7, _8))
  }
}
extension Tuple9: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable, _5: Equatable, _6: Equatable, _7: Equatable, _8: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4 && lhs.tuple.5 == rhs.tuple.5 && lhs.tuple.6 == rhs.tuple.6 && lhs.tuple.7 == rhs.tuple.7 && lhs.tuple.8 == rhs.tuple.8
  }
}
@frozen @dynamicMemberLookup
public struct Tuple10<_0, _1, _2, _3, _4, _5, _6, _7, _8, _9> {
  public typealias Tuple = (_0, _1, _2, _3, _4, _5, _6, _7, _8, _9)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple10: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol, _5: EmptyCaptureProtocol, _6: EmptyCaptureProtocol, _7: EmptyCaptureProtocol, _8: EmptyCaptureProtocol, _9: EmptyCaptureProtocol {}
extension Tuple10: MatchProtocol {
  public typealias Capture = Tuple9<_1, _2, _3, _4, _5, _6, _7, _8, _9>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4, _ _5: _5, _ _6: _6, _ _7: _7, _ _8: _8, _ _9: _9) {
    self.init((_0, _1, _2, _3, _4, _5, _6, _7, _8, _9))
  }
}
extension Tuple10: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable, _5: Equatable, _6: Equatable, _7: Equatable, _8: Equatable, _9: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4 && lhs.tuple.5 == rhs.tuple.5 && lhs.tuple.6 == rhs.tuple.6 && lhs.tuple.7 == rhs.tuple.7 && lhs.tuple.8 == rhs.tuple.8 && lhs.tuple.9 == rhs.tuple.9
  }
}
@frozen @dynamicMemberLookup
public struct Tuple11<_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10> {
  public typealias Tuple = (_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)
  public var tuple: Tuple
  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Tuple, T>) -> T {
    get { tuple[keyPath: keyPath] }
    _modify { yield &tuple[keyPath: keyPath] }
  }
}
extension Tuple11: EmptyCaptureProtocol where _1: EmptyCaptureProtocol, _2: EmptyCaptureProtocol, _3: EmptyCaptureProtocol, _4: EmptyCaptureProtocol, _5: EmptyCaptureProtocol, _6: EmptyCaptureProtocol, _7: EmptyCaptureProtocol, _8: EmptyCaptureProtocol, _9: EmptyCaptureProtocol, _10: EmptyCaptureProtocol {}
extension Tuple11: MatchProtocol {
  public typealias Capture = Tuple10<_1, _2, _3, _4, _5, _6, _7, _8, _9, _10>
  public init(_ tuple: Tuple) { self.tuple = tuple }
  public init(_ _0: _0, _ _1: _1, _ _2: _2, _ _3: _3, _ _4: _4, _ _5: _5, _ _6: _6, _ _7: _7, _ _8: _8, _ _9: _9, _ _10: _10) {
    self.init((_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10))
  }
}
extension Tuple11: Equatable where _0: Equatable, _1: Equatable, _2: Equatable, _3: Equatable, _4: Equatable, _5: Equatable, _6: Equatable, _7: Equatable, _8: Equatable, _9: Equatable, _10: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple.0 == rhs.tuple.0 && lhs.tuple.1 == rhs.tuple.1 && lhs.tuple.2 == rhs.tuple.2 && lhs.tuple.3 == rhs.tuple.3 && lhs.tuple.4 == rhs.tuple.4 && lhs.tuple.5 == rhs.tuple.5 && lhs.tuple.6 == rhs.tuple.6 && lhs.tuple.7 == rhs.tuple.7 && lhs.tuple.8 == rhs.tuple.8 && lhs.tuple.9 == rhs.tuple.9 && lhs.tuple.10 == rhs.tuple.10
  }
}
public struct Concatenate_0_0<
  W0, W1, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == W1 {
  public typealias Match = Substring
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_0<W0, W1, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_1<
  W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple2<W1, C0> {
  public typealias Match = Tuple2<Substring, C0>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_1<W0, W1, C0, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_2<
  W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple3<W1, C0, C1> {
  public typealias Match = Tuple3<Substring, C0, C1>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_2<W0, W1, C0, C1, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_3<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple4<W1, C0, C1, C2> {
  public typealias Match = Tuple4<Substring, C0, C1, C2>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_3<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_4<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple5<W1, C0, C1, C2, C3> {
  public typealias Match = Tuple5<Substring, C0, C1, C2, C3>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_4<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_5<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple6<W1, C0, C1, C2, C3, C4> {
  public typealias Match = Tuple6<Substring, C0, C1, C2, C3, C4>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_5<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_6<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple7<W1, C0, C1, C2, C3, C4, C5> {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_6<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple8<W1, C0, C1, C2, C3, C4, C5, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_8<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple9<W1, C0, C1, C2, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_8<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_9<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple10<W1, C0, C1, C2, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_9<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_0_10<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == W0, R1.Match == Tuple11<W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_0_10<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_0<
  W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == W1 {
  public typealias Match = Tuple2<Substring, C0>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_0<W0, W1, C0, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_1<
  W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple2<W1, C1> {
  public typealias Match = Tuple3<Substring, C0, C1>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_1<W0, W1, C0, C1, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_2<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple3<W1, C1, C2> {
  public typealias Match = Tuple4<Substring, C0, C1, C2>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_2<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_3<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple4<W1, C1, C2, C3> {
  public typealias Match = Tuple5<Substring, C0, C1, C2, C3>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_3<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_4<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple5<W1, C1, C2, C3, C4> {
  public typealias Match = Tuple6<Substring, C0, C1, C2, C3, C4>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_4<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_5<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple6<W1, C1, C2, C3, C4, C5> {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_5<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple7<W1, C1, C2, C3, C4, C5, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple8<W1, C1, C2, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_8<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple9<W1, C1, C2, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_8<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_1_9<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple2<W0, C0>, R1.Match == Tuple10<W1, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_1_9<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_0<
  W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == W1 {
  public typealias Match = Tuple3<Substring, C0, C1>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_0<W0, W1, C0, C1, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_1<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple2<W1, C2> {
  public typealias Match = Tuple4<Substring, C0, C1, C2>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_1<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_2<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple3<W1, C2, C3> {
  public typealias Match = Tuple5<Substring, C0, C1, C2, C3>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_2<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_3<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple4<W1, C2, C3, C4> {
  public typealias Match = Tuple6<Substring, C0, C1, C2, C3, C4>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_3<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_4<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple5<W1, C2, C3, C4, C5> {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_4<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple6<W1, C2, C3, C4, C5, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple7<W1, C2, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple8<W1, C2, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_2_8<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple3<W0, C0, C1>, R1.Match == Tuple9<W1, C2, C3, C4, C5, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_2_8<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_0<
  W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == W1 {
  public typealias Match = Tuple4<Substring, C0, C1, C2>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_0<W0, W1, C0, C1, C2, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_1<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple2<W1, C3> {
  public typealias Match = Tuple5<Substring, C0, C1, C2, C3>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_1<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_2<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple3<W1, C3, C4> {
  public typealias Match = Tuple6<Substring, C0, C1, C2, C3, C4>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_2<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_3<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple4<W1, C3, C4, C5> {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_3<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple5<W1, C3, C4, C5, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple6<W1, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple7<W1, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_3_7<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match == Tuple8<W1, C3, C4, C5, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_3_7<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_0<
  W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == W1 {
  public typealias Match = Tuple5<Substring, C0, C1, C2, C3>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_0<W0, W1, C0, C1, C2, C3, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_1<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == Tuple2<W1, C4> {
  public typealias Match = Tuple6<Substring, C0, C1, C2, C3, C4>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_1<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_2<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == Tuple3<W1, C4, C5> {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_2<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == Tuple4<W1, C4, C5, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == Tuple5<W1, C4, C5, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == Tuple6<W1, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_4_6<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match == Tuple7<W1, C4, C5, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_4_6<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_0<
  W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match == W1 {
  public typealias Match = Tuple6<Substring, C0, C1, C2, C3, C4>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_0<W0, W1, C0, C1, C2, C3, C4, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_1<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match == Tuple2<W1, C5> {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_1<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match == Tuple3<W1, C5, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match == Tuple4<W1, C5, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match == Tuple5<W1, C5, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_5_5<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match == Tuple6<W1, C5, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_5_5<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_0<
  W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple7<W0, C0, C1, C2, C3, C4, C5>, R1.Match == W1 {
  public typealias Match = Tuple7<Substring, C0, C1, C2, C3, C4, C5>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_0<W0, W1, C0, C1, C2, C3, C4, C5, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple7<W0, C0, C1, C2, C3, C4, C5>, R1.Match == Tuple2<W1, C6> {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple7<W0, C0, C1, C2, C3, C4, C5>, R1.Match == Tuple3<W1, C6, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple7<W0, C0, C1, C2, C3, C4, C5>, R1.Match == Tuple4<W1, C6, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_6_4<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple7<W0, C0, C1, C2, C3, C4, C5>, R1.Match == Tuple5<W1, C6, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_6_4<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_0<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple8<W0, C0, C1, C2, C3, C4, C5, C6>, R1.Match == W1 {
  public typealias Match = Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_0<W0, W1, C0, C1, C2, C3, C4, C5, C6, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple8<W0, C0, C1, C2, C3, C4, C5, C6>, R1.Match == Tuple2<W1, C7> {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple8<W0, C0, C1, C2, C3, C4, C5, C6>, R1.Match == Tuple3<W1, C7, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_7_3<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple8<W0, C0, C1, C2, C3, C4, C5, C6>, R1.Match == Tuple4<W1, C7, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_7_3<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_8_0<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple9<W0, C0, C1, C2, C3, C4, C5, C6, C7>, R1.Match == W1 {
  public typealias Match = Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_8_0<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_8_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple9<W0, C0, C1, C2, C3, C4, C5, C6, C7>, R1.Match == Tuple2<W1, C8> {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_8_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_8_2<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple9<W0, C0, C1, C2, C3, C4, C5, C6, C7>, R1.Match == Tuple3<W1, C8, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_8_2<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_9_0<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple10<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8>, R1.Match == W1 {
  public typealias Match = Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_9_0<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0, R1> {
    .init(combined, next)
  }
}
public struct Concatenate_9_1<
  W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol
>: RegexProtocol where R0.Match == Tuple10<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8>, R1.Match == Tuple2<W1, C9> {
  public typealias Match = Tuple11<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>
  public let regex: Regex<Match>
  init(_ r0: R0, _ r1: R1) {
    self.regex = .init(node: r0.regex.root.appending(r1.regex.root))
  }
}
extension RegexBuilder {
  @_disfavoredOverload
  public static func buildBlock<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Concatenate_9_1<W0, W1, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, R0, R1> {
    .init(combined, next)
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Substring> where R0.Match == W0, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple2<Substring, C0>> where R0.Match == Tuple2<W0, C0>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple3<Substring, C0, C1>> where R0.Match == Tuple3<W0, C0, C1>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple4<Substring, C0, C1, C2>> where R0.Match == Tuple4<W0, C0, C1, C2>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple5<Substring, C0, C1, C2, C3>> where R0.Match == Tuple5<W0, C0, C1, C2, C3>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple6<Substring, C0, C1, C2, C3, C4>> where R0.Match == Tuple6<W0, C0, C1, C2, C3, C4>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple7<Substring, C0, C1, C2, C3, C4, C5>> where R0.Match == Tuple7<W0, C0, C1, C2, C3, C4, C5>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple8<Substring, C0, C1, C2, C3, C4, C5, C6>> where R0.Match == Tuple8<W0, C0, C1, C2, C3, C4, C5, C6>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple9<Substring, C0, C1, C2, C3, C4, C5, C6, C7>> where R0.Match == Tuple9<W0, C0, C1, C2, C3, C4, C5, C6, C7>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}
extension RegexBuilder {
  public static func buildBlock<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8, R0: RegexProtocol, R1: RegexProtocol>(
    combining next: R1, into combined: R0
  ) -> Regex<Tuple10<Substring, C0, C1, C2, C3, C4, C5, C6, C7, C8>> where R0.Match == Tuple10<W0, C0, C1, C2, C3, C4, C5, C6, C7, C8>, R1.Match: EmptyCaptureProtocol {
    .init(node: combined.regex.root.appending(next.regex.root))
  }
}


public struct _ZeroOrOne_0<Component: RegexProtocol>: RegexProtocol  {
  public typealias Match = Substring
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}

@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_0<Component> {
  .init(component: component)
}

@_disfavoredOverload
public func optionally<Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_0<Component> {
  optionally(component())
}

@_disfavoredOverload
public postfix func .?<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_0<Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_0<Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_0<Component: RegexProtocol>: RegexProtocol  {
  public typealias Match = Substring
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}

@_disfavoredOverload
public func many<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_0<Component> {
  .init(component: component)
}

@_disfavoredOverload
public func many<Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_0<Component> {
  many(component())
}

@_disfavoredOverload
public postfix func .+<Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_0<Component> {
  many(component)
}


public struct _OneOrMore_0<Component: RegexProtocol>: RegexProtocol  {
  public typealias Match = Substring
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}

@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_0<Component> {
  .init(component: component)
}

@_disfavoredOverload
public func oneOrMore<Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_0<Component> {
  oneOrMore(component())
}

@_disfavoredOverload
public postfix func .*<Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_0<Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_1<W, C0, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple2<W, C0> {
  public typealias Match = Tuple2<Substring, C0?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_1<W, C0, Component> {
  .init(component: component)
}


public func optionally<W, C0, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_1<W, C0, Component> {
  optionally(component())
}


public postfix func .?<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_1<W, C0, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_1<W, C0, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_1<W, C0, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple2<W, C0> {
  public typealias Match = Tuple2<Substring, [C0]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_1<W, C0, Component> {
  .init(component: component)
}


public func many<W, C0, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_1<W, C0, Component> {
  many(component())
}


public postfix func .+<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_1<W, C0, Component> {
  many(component)
}


public struct _OneOrMore_1<W, C0, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple2<W, C0> {
  public typealias Match = Tuple2<Substring, [C0]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_1<W, C0, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_1<W, C0, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_1<W, C0, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_2<W, C0, C1, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple3<W, C0, C1> {
  public typealias Match = Tuple2<Substring, Tuple2<C0, C1>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_2<W, C0, C1, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_2<W, C0, C1, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_2<W, C0, C1, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_2<W, C0, C1, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_2<W, C0, C1, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple3<W, C0, C1> {
  public typealias Match = Tuple2<Substring, [Tuple2<C0, C1>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_2<W, C0, C1, Component> {
  .init(component: component)
}


public func many<W, C0, C1, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_2<W, C0, C1, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_2<W, C0, C1, Component> {
  many(component)
}


public struct _OneOrMore_2<W, C0, C1, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple3<W, C0, C1> {
  public typealias Match = Tuple2<Substring, [Tuple2<C0, C1>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_2<W, C0, C1, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_2<W, C0, C1, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_2<W, C0, C1, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_3<W, C0, C1, C2, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple4<W, C0, C1, C2> {
  public typealias Match = Tuple2<Substring, Tuple3<C0, C1, C2>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_3<W, C0, C1, C2, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_3<W, C0, C1, C2, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple4<W, C0, C1, C2> {
  public typealias Match = Tuple2<Substring, [Tuple3<C0, C1, C2>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_3<W, C0, C1, C2, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_3<W, C0, C1, C2, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_3<W, C0, C1, C2, Component> {
  many(component)
}


public struct _OneOrMore_3<W, C0, C1, C2, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple4<W, C0, C1, C2> {
  public typealias Match = Tuple2<Substring, [Tuple3<C0, C1, C2>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_3<W, C0, C1, C2, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_3<W, C0, C1, C2, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_3<W, C0, C1, C2, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_4<W, C0, C1, C2, C3, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple5<W, C0, C1, C2, C3> {
  public typealias Match = Tuple2<Substring, Tuple4<C0, C1, C2, C3>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_4<W, C0, C1, C2, C3, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_4<W, C0, C1, C2, C3, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple5<W, C0, C1, C2, C3> {
  public typealias Match = Tuple2<Substring, [Tuple4<C0, C1, C2, C3>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_4<W, C0, C1, C2, C3, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_4<W, C0, C1, C2, C3, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_4<W, C0, C1, C2, C3, Component> {
  many(component)
}


public struct _OneOrMore_4<W, C0, C1, C2, C3, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple5<W, C0, C1, C2, C3> {
  public typealias Match = Tuple2<Substring, [Tuple4<C0, C1, C2, C3>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_4<W, C0, C1, C2, C3, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_4<W, C0, C1, C2, C3, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_4<W, C0, C1, C2, C3, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple6<W, C0, C1, C2, C3, C4> {
  public typealias Match = Tuple2<Substring, Tuple5<C0, C1, C2, C3, C4>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_5<W, C0, C1, C2, C3, C4, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple6<W, C0, C1, C2, C3, C4> {
  public typealias Match = Tuple2<Substring, [Tuple5<C0, C1, C2, C3, C4>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  many(component)
}


public struct _OneOrMore_5<W, C0, C1, C2, C3, C4, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple6<W, C0, C1, C2, C3, C4> {
  public typealias Match = Tuple2<Substring, [Tuple5<C0, C1, C2, C3, C4>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_5<W, C0, C1, C2, C3, C4, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple7<W, C0, C1, C2, C3, C4, C5> {
  public typealias Match = Tuple2<Substring, Tuple6<C0, C1, C2, C3, C4, C5>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_6<W, C0, C1, C2, C3, C4, C5, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple7<W, C0, C1, C2, C3, C4, C5> {
  public typealias Match = Tuple2<Substring, [Tuple6<C0, C1, C2, C3, C4, C5>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  many(component)
}


public struct _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple7<W, C0, C1, C2, C3, C4, C5> {
  public typealias Match = Tuple2<Substring, [Tuple6<C0, C1, C2, C3, C4, C5>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_6<W, C0, C1, C2, C3, C4, C5, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple8<W, C0, C1, C2, C3, C4, C5, C6> {
  public typealias Match = Tuple2<Substring, Tuple7<C0, C1, C2, C3, C4, C5, C6>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple8<W, C0, C1, C2, C3, C4, C5, C6> {
  public typealias Match = Tuple2<Substring, [Tuple7<C0, C1, C2, C3, C4, C5, C6>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  many(component)
}


public struct _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple8<W, C0, C1, C2, C3, C4, C5, C6> {
  public typealias Match = Tuple2<Substring, [Tuple7<C0, C1, C2, C3, C4, C5, C6>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_7<W, C0, C1, C2, C3, C4, C5, C6, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple9<W, C0, C1, C2, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple2<Substring, Tuple8<C0, C1, C2, C3, C4, C5, C6, C7>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple9<W, C0, C1, C2, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple2<Substring, [Tuple8<C0, C1, C2, C3, C4, C5, C6, C7>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  many(component)
}


public struct _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple9<W, C0, C1, C2, C3, C4, C5, C6, C7> {
  public typealias Match = Tuple2<Substring, [Tuple8<C0, C1, C2, C3, C4, C5, C6, C7>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_8<W, C0, C1, C2, C3, C4, C5, C6, C7, Component> {
  oneOrMore(component)
}


public struct _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple10<W, C0, C1, C2, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple2<Substring, Tuple9<C0, C1, C2, C3, C4, C5, C6, C7, C8>?>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrOne, .eager, component.regex.root))
  }
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  .init(component: component)
}


public func optionally<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  optionally(component())
}


public postfix func .?<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  optionally(component)
}

extension RegexBuilder {
  public static func buildLimitedAvailability<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
    _ component: Component
  ) -> _ZeroOrOne_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
    optionally(component)
  }
}
public struct _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple10<W, C0, C1, C2, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple2<Substring, [Tuple9<C0, C1, C2, C3, C4, C5, C6, C7, C8>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.zeroOrMore, .eager, component.regex.root))
  }
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  .init(component: component)
}


public func many<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  many(component())
}


public postfix func .+<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _ZeroOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  many(component)
}


public struct _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>: RegexProtocol where Component.Match == Tuple10<W, C0, C1, C2, C3, C4, C5, C6, C7, C8> {
  public typealias Match = Tuple2<Substring, [Tuple9<C0, C1, C2, C3, C4, C5, C6, C7, C8>]>
  public let regex: Regex<Match>
  public init(component: Component) {
    self.regex = .init(node: .quantification(.oneOrMore, .eager, component.regex.root))
  }
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  .init(component: component)
}


public func oneOrMore<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  @RegexBuilder _ component: () -> Component
) -> _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  oneOrMore(component())
}


public postfix func .*<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component: RegexProtocol>(
  _ component: Component
) -> _OneOrMore_9<W, C0, C1, C2, C3, C4, C5, C6, C7, C8, Component> {
  oneOrMore(component)
}




// END AUTO-GENERATED CONTENT
