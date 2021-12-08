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

public func alt(_ asts: [AST]) -> AST {
  .alternation(asts)
}
public func alt(_ asts: AST...) -> AST {
  alt(asts)
}

public func concat(_ asts: [AST]) -> AST {
  .concatenation(asts)
}
public func concat(_ asts: AST...) -> AST {
  concat(asts)
}

public func group(
  _ kind: Group.Kind, _ child: AST
) -> AST {
  .group(Group(kind, _fakeRange), child)
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
  group(.namedCapture(name), child)
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
  _ amount: Quantifier.Amount,
  _ kind: Quantifier.Kind = .greedy,
  _ child: AST
) -> AST {
  .quantification(Quantifier(amount, kind, _fakeRange), child)
}
public func zeroOrMore(
  _ kind: Quantifier.Kind = .greedy,
  _ child: AST
) -> AST {
  quant(.zeroOrMore, kind, child)
}
public func zeroOrOne(
  _ kind: Quantifier.Kind = .greedy,
  _ child: AST
) -> AST {
  quant(.zeroOrOne, kind, child)
}
public func oneOrMore(
  _ kind: Quantifier.Kind = .greedy,
  _ child: AST
) -> AST {
  quant(.oneOrMore, kind, child)
}
public func exactly(
  _ kind: Quantifier.Kind = .greedy,
  _ i: Int,
  child: AST
) -> AST {
  quant(.exactly(i), kind, child)
}
public func nOrMore(
  _ kind: Quantifier.Kind = .greedy,
  _ i: Int,
  child: AST
) -> AST {
  quant(.nOrMore(i), kind, child)
}
public func upToN(
  _ kind: Quantifier.Kind = .greedy,
  _ i: Int,
  child: AST
) -> AST {
  quant(.upToN(i), kind, child)
}
public func quantRange(
  _ kind: Quantifier.Kind = .greedy,
  _ r: ClosedRange<Int>,
  child: AST
) -> AST {
  quant(.range(r), kind, child)
}

public func charClass(
  _ members: CustomCharacterClass.Member...,
  inverted: Bool = false
) -> AST {
  let cc = CustomCharacterClass(
    inverted ? .inverted : .normal, members
  )
  return .customCharacterClass(cc)
}
public func charClass(
  _ members: CustomCharacterClass.Member...,
  inverted: Bool = false
) -> CustomCharacterClass.Member {
  let cc = CustomCharacterClass(
    inverted ? .inverted : .normal, members
  )
  return .custom(cc)
}
public func posixSet(
  _ set: Unicode.POSIXCharacterSet, inverted: Bool = false
) -> Atom {
  return .named(.init(inverted: inverted, set: set))
}
