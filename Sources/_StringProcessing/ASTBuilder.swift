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

import _MatchingEngine

func alt(_ asts: [AST]) -> AST {
  return .alternation(
    .init(asts, pipes: Array(repeating: .fake, count: asts.count - 1))
  )
}
func alt(_ asts: AST...) -> AST {
  alt(asts)
}

func concat(_ asts: [AST]) -> AST {
  .concatenation(.init(asts, .fake))
}
func concat(_ asts: AST...) -> AST {
  concat(asts)
}

func empty() -> AST {
  .empty(.init(.fake))
}

func group(
  _ kind: AST.Group.Kind, _ child: AST
) -> AST {
  .group(.init(.init(faking: kind), child, .fake))
}
func capture(
  _ child: AST
) -> AST {
  group(.capture, child)
}
func nonCapture(
  _ child: AST
) -> AST {
  group(.nonCapture, child)
}
func namedCapture(
  _ name: String,
  _ child: AST
) -> AST {
  group(.namedCapture(.init(faking: name)), child)
}
func nonCaptureReset(
  _ child: AST
) -> AST {
  group(.nonCaptureReset, child)
}
func atomicNonCapturing(
  _ child: AST
) -> AST {
  group(.atomicNonCapturing, child)
}
func lookahead(_ child: AST) -> AST {
  group(.lookahead, child)
}
func lookbehind(_ child: AST) -> AST {
  group(.lookbehind, child)
}
func negativeLookahead(_ child: AST) -> AST {
  group(.negativeLookahead, child)
}
func negativeLookbehind(_ child: AST) -> AST {
  group(.negativeLookbehind, child)
}
public func nonAtomicLookahead(_ child: AST) -> AST {
  group(.nonAtomicLookahead, child)
}
public func nonAtomicLookbehind(_ child: AST) -> AST {
  group(.nonAtomicLookbehind, child)
}
public func scriptRun(_ child: AST) -> AST {
  group(.scriptRun, child)
}
public func atomicScriptRun(_ child: AST) -> AST {
  group(.atomicScriptRun, child)
}
func changeMatchingOptions(
  _ seq: AST.MatchingOptionSequence, isIsolated: Bool, _ child: AST
) -> AST {
  group(.changeMatchingOptions(seq, isIsolated: isIsolated), child)
}

func matchingOptions(
  adding: [AST.MatchingOption.Kind] = [],
  removing: [AST.MatchingOption.Kind] = []
) -> AST.MatchingOptionSequence {
  .init(caretLoc: nil, adding: adding.map { .init($0, location: .fake) },
        minusLoc: nil, removing: removing.map { .init($0, location: .fake)})
}
func matchingOptions(
  adding: AST.MatchingOption.Kind...,
  removing: AST.MatchingOption.Kind...
) -> AST.MatchingOptionSequence {
  matchingOptions(adding: adding, removing: removing)
}
func unsetMatchingOptions(
  adding: [AST.MatchingOption.Kind]
) -> AST.MatchingOptionSequence {
  .init(caretLoc: .fake, adding: adding.map { .init($0, location: .fake) },
        minusLoc: nil, removing: [])
}
func unsetMatchingOptions(
  adding: AST.MatchingOption.Kind...
) -> AST.MatchingOptionSequence {
  unsetMatchingOptions(adding: adding)
}

func quant(
  _ amount: AST.Quantification.Amount,
  _ kind: AST.Quantification.Kind = .eager,
  _ child: AST
) -> AST {
  .quantification(.init(
    .init(faking: amount), .init(faking: kind), child, .fake))
}
func zeroOrMore(
  _ kind: AST.Quantification.Kind = .eager,
  _ child: AST
) -> AST {
  quant(.zeroOrMore, kind, child)
}
func zeroOrOne(
  _ kind: AST.Quantification.Kind = .eager,
  _ child: AST
) -> AST {
  quant(.zeroOrOne, kind, child)
}
func oneOrMore(
  _ kind: AST.Quantification.Kind = .eager,
  _ child: AST
) -> AST {
  quant(.oneOrMore, kind, child)
}
func exactly(
  _ kind: AST.Quantification.Kind = .eager,
  _ i: Int,
  _ child: AST
) -> AST {
  quant(.exactly(.init(faking: i)), kind, child)
}
func nOrMore(
  _ kind: AST.Quantification.Kind = .eager,
  _ i: Int,
  _ child: AST
) -> AST {
  quant(.nOrMore(.init(faking: i)), kind, child)
}
func upToN(
  _ kind: AST.Quantification.Kind = .eager,
  _ i: Int,
  _ child: AST
) -> AST {
  quant(.upToN(.init(faking: i)), kind, child)
}
func quantRange(
  _ kind: AST.Quantification.Kind = .eager,
  _ r: ClosedRange<Int>,
  _ child: AST
) -> AST {
  let lower = AST.Located(faking: r.lowerBound)
  let upper = AST.Located(faking: r.upperBound)
  return quant(.range(lower, upper), kind, child)
}

func charClass(
  _ members: AST.CustomCharacterClass.Member...,
  inverted: Bool = false
) -> AST {
  let cc = AST.CustomCharacterClass(
    .init(faking: inverted ? .inverted : .normal),
    members,
    .fake)
  return .customCharacterClass(cc)
}
func charClass(
  _ members: AST.CustomCharacterClass.Member...,
  inverted: Bool = false
) -> AST.CustomCharacterClass.Member {
  let cc = AST.CustomCharacterClass(
    .init(faking: inverted ? .inverted : .normal),
    members,
    .fake)
  return .custom(cc)
}

func quote(_ s: String) -> AST {
  .quote(.init(s, .fake))
}

// MARK: - Atoms

func atom(_ k: AST.Atom.Kind) -> AST {
  .atom(.init(k, .fake))
}

func escaped(
  _ e: AST.Atom.EscapedBuiltin
) -> AST {
  atom(.escaped(e))
}
func scalar(_ s: Unicode.Scalar) -> AST {
  atom(.scalar(s))
}
func scalar_m(_ s: Unicode.Scalar) -> AST.CustomCharacterClass.Member {
  atom_m(.scalar(s))
}

func backreference(_ r: Reference) -> AST {
  atom(.backreference(r))
}
func subpattern(_ r: Reference) -> AST {
  atom(.subpattern(r))
}
func condition(_ r: Reference) -> AST {
  atom(.condition(r))
}

func prop(
  _ kind: AST.Atom.CharacterProperty.Kind,
  inverted: Bool = false
) -> AST {
  atom(.property(.init(kind, isInverted: inverted, isPOSIX: false)))
}

// Raw atom constructing variant
func atom_a(
  _ k: AST.Atom.Kind
) -> AST.Atom {
  AST.Atom(k, .fake)
}

// CustomCC member variant
func atom_m(
  _ k: AST.Atom.Kind
) -> AST.CustomCharacterClass.Member {
  .atom(atom_a(k))
}
func posixProp_m(
  _ kind: AST.Atom.CharacterProperty.Kind, inverted: Bool = false
) -> AST.CustomCharacterClass.Member {
  atom_m(.property(.init(kind, isInverted: inverted, isPOSIX: true)))
}
func prop_m(
  _ kind: AST.Atom.CharacterProperty.Kind,
  inverted: Bool = false
) -> AST.CustomCharacterClass.Member {
  atom_m(.property(.init(kind, isInverted: inverted, isPOSIX: false)))
}
func range_m(
  _ lower: AST.Atom, _ upper: AST.Atom
) -> AST.CustomCharacterClass.Member {
  .range(.init(lower, .fake, upper))
}
func range_m(
  _ lower: AST.Atom.Kind, _ upper: AST.Atom.Kind
) -> AST.CustomCharacterClass.Member {
  range_m(atom_a(lower), atom_a(upper))
}
