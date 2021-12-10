/*

These functions are temporary AST construction helpers. As
the AST gets more and more source-location tracking, we'll
want easier migration paths for our parser tests (which
construct and compare location-less AST nodes) as well as the
result builder DSL (which has a different notion of location).

Without real namespaces and `using`, attempts at
pseudo-namespaces tie the use site to being nested inside a
type. So for now, these are global, but they will likely be
namespaced in the future if/when clients are weaned off the
AST.

*/

public let _fakeLoc = "".startIndex
public let _fakeRange = _fakeLoc ..< _fakeLoc
public func _fake<T: Hashable>(_ t: T) -> AST.Loc<T> {
  .init(t, _fakeRange)
}

public func alt(_ asts: [AST]) -> AST {
  .alternation(.init(asts, _fakeRange))
}
public func alt(_ asts: AST...) -> AST {
  alt(asts)
}

public func concat(_ asts: [AST]) -> AST {
  .concatenation(.init(asts, _fakeRange))
}
public func concat(_ asts: AST...) -> AST {
  concat(asts)
}

public func group(
  _ kind: AST.Group.Kind, _ child: AST
) -> AST {
  .group(.init(_fake(kind), child, _fakeRange))
}
public func capture(
  _ child: AST
) -> AST {
  group(.capture, child)
}
public func nonCapture(
  _ child: AST
) -> AST {
  group(.nonCapture, child)
}
public func namedCapture(
  _ name: String,
  _ child: AST
) -> AST {
  group(.namedCapture(_fake(name)), child)
}
public func nonCaptureReset(
  _ child: AST
) -> AST {
  group(.nonCaptureReset, child)
}
public func atomicNonCapturing(
  _ child: AST
) -> AST {
  group(.atomicNonCapturing, child)
}
public func lookahead(_ child: AST) -> AST {
  group(.lookahead, child)
}
public func lookbehind(_ child: AST) -> AST {
  group(.lookbehind, child)
}
public func negativeLookahead(_ child: AST) -> AST {
  group(.negativeLookahead, child)
}
public func negativeLookbehind(_ child: AST) -> AST {
  group(.negativeLookbehind, child)
}


public var any: AST { .atom(.any) }

public func quant(
  _ amount: AST.Quantification.Amount,
  _ kind: AST.Quantification.Kind = .greedy,
  _ child: AST
) -> AST {
  .quantification(.init(
    _fake(amount), _fake(kind), child, _fakeRange))
}
public func zeroOrMore(
  _ kind: AST.Quantification.Kind = .greedy,
  _ child: AST
) -> AST {
  quant(.zeroOrMore, kind, child)
}
public func zeroOrOne(
  _ kind: AST.Quantification.Kind = .greedy,
  _ child: AST
) -> AST {
  quant(.zeroOrOne, kind, child)
}
public func oneOrMore(
  _ kind: AST.Quantification.Kind = .greedy,
  _ child: AST
) -> AST {
  quant(.oneOrMore, kind, child)
}
public func exactly(
  _ kind: AST.Quantification.Kind = .greedy,
  _ i: Int,
  _ child: AST
) -> AST {
  quant(.exactly(_fake(i)), kind, child)
}
public func nOrMore(
  _ kind: AST.Quantification.Kind = .greedy,
  _ i: Int,
  _ child: AST
) -> AST {
  quant(.nOrMore(_fake(i)), kind, child)
}
public func upToN(
  _ kind: AST.Quantification.Kind = .greedy,
  _ i: Int,
  _ child: AST
) -> AST {
  quant(.upToN(_fake(i)), kind, child)
}
public func quantRange(
  _ kind: AST.Quantification.Kind = .greedy,
  _ r: ClosedRange<Int>,
  _ child: AST
) -> AST {
  let range = _fake(r.lowerBound) ... _fake(r.upperBound)
  return quant(.range(range), kind, child)
}

public func charClass(
  _ members: CustomCharacterClass.Member...,
  inverted: Bool = false
) -> AST {
  let cc = CustomCharacterClass(
    inverted ? .inverted : .normal, members, _fakeRange
  )
  return .customCharacterClass(cc)
}
public func charClass(
  _ members: CustomCharacterClass.Member...,
  inverted: Bool = false
) -> CustomCharacterClass.Member {
  let cc = CustomCharacterClass(
    inverted ? .inverted : .normal, members, _fakeRange
  )
  return .custom(cc)
}
public func posixSet(
  _ set: Unicode.POSIXCharacterSet, inverted: Bool = false
) -> Atom {
  .namedSet(.init(inverted: inverted, set: set))
}

public func quote(_ s: String) -> AST {
  .quote(.init(s, _fakeRange))
}

public func prop(
  _ kind: Atom.CharacterProperty.Kind, inverted: Bool = false
) -> Atom {
  return .property(.init(kind, isInverted: inverted))
}
