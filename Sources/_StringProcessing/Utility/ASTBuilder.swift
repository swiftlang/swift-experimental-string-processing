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

import _RegexParser

func alt(_ asts: [AST.Node]) -> AST.Node {
  return .alternation(
    .init(asts, pipes: Array(repeating: .fake, count: asts.count - 1))
  )
}
func alt(_ asts: AST.Node...) -> AST.Node {
  alt(asts)
}

func concat(_ asts: [AST.Node]) -> AST.Node {
  .concatenation(.init(asts, .fake))
}
func concat(_ asts: AST.Node...) -> AST.Node {
  concat(asts)
}

func empty() -> AST.Node {
  .empty(.init(.fake))
}

func ast(_ root: AST.Node, opts: [AST.GlobalMatchingOption.Kind]) -> AST {
  .init(root, globalOptions: .init(opts.map { .init($0, .fake) }))
}

func ast(_ root: AST.Node, opts: AST.GlobalMatchingOption.Kind...) -> AST {
  ast(root, opts: opts)
}

func group(
  _ kind: AST.Group.Kind, _ child: AST.Node
) -> AST.Node {
  .group(.init(.init(faking: kind), child, .fake))
}
func capture(
  _ child: AST.Node
) -> AST.Node {
  group(.capture, child)
}
func nonCapture(
  _ child: AST.Node
) -> AST.Node {
  group(.nonCapture, child)
}
func namedCapture(
  _ name: String,
  _ child: AST.Node
) -> AST.Node {
  group(.namedCapture(.init(faking: name)), child)
}
func balancedCapture(
  name: String?, priorName: String, _ child: AST.Node
) -> AST.Node {
  group(.balancedCapture(
    .init(name: name.map { .init(faking: $0) }, dash: .fake,
          priorName: .init(faking: priorName))
  ), child)
}
func nonCaptureReset(
  _ child: AST.Node
) -> AST.Node {
  group(.nonCaptureReset, child)
}
func atomicNonCapturing(
  _ child: AST.Node
) -> AST.Node {
  group(.atomicNonCapturing, child)
}
func lookahead(_ child: AST.Node) -> AST.Node {
  group(.lookahead, child)
}
func lookbehind(_ child: AST.Node) -> AST.Node {
  group(.lookbehind, child)
}
func negativeLookahead(_ child: AST.Node) -> AST.Node {
  group(.negativeLookahead, child)
}
func negativeLookbehind(_ child: AST.Node) -> AST.Node {
  group(.negativeLookbehind, child)
}
func nonAtomicLookahead(_ child: AST.Node) -> AST.Node {
  group(.nonAtomicLookahead, child)
}
func nonAtomicLookbehind(_ child: AST.Node) -> AST.Node {
  group(.nonAtomicLookbehind, child)
}
func scriptRun(_ child: AST.Node) -> AST.Node {
  group(.scriptRun, child)
}
func atomicScriptRun(_ child: AST.Node) -> AST.Node {
  group(.atomicScriptRun, child)
}
func changeMatchingOptions(
  _ seq: AST.MatchingOptionSequence, _ child: AST.Node
) -> AST.Node {
  group(.changeMatchingOptions(seq), child)
}
func changeMatchingOptions(
  _ seq: AST.MatchingOptionSequence
) -> AST.Node {
  atom(.changeMatchingOptions(seq))
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

func ref(_ i: Int, recursionLevel: Int? = nil) -> AST.Reference {
  .init(.absolute(i), recursionLevel: recursionLevel.map { .init(faking: $0) },
        innerLoc: .fake)
}
func ref(plus n: Int, recursionLevel: Int? = nil) -> AST.Reference {
  .init(.relative(n), recursionLevel: recursionLevel.map { .init(faking: $0) },
        innerLoc: .fake)
}
func ref(minus n: Int, recursionLevel: Int? = nil) -> AST.Reference {
  .init(.relative(-n), recursionLevel: recursionLevel.map { .init(faking: $0) },
        innerLoc: .fake)
}
func ref(_ s: String, recursionLevel: Int? = nil) -> AST.Reference {
  .init(.named(s), recursionLevel: recursionLevel.map { .init(faking: $0) },
        innerLoc: .fake)
}
func conditional(
  _ cond: AST.Conditional.Condition.Kind, trueBranch: AST.Node,
  falseBranch: AST.Node
) -> AST.Node {
  .conditional(.init(.init(cond, .fake), trueBranch: trueBranch, pipe: .fake,
                     falseBranch: falseBranch, .fake))
}
func pcreVersionCheck(
  _ kind: AST.Conditional.Condition.PCREVersionCheck.Kind,
  _ major: Int, _ minor: Int
) -> AST.Conditional.Condition.Kind {
  .pcreVersionCheck(.init(
    .init(faking: kind), .init(major: major, minor: minor, .fake)
  ))
}
func groupCondition(
  _ kind: AST.Group.Kind, _ child: AST.Node
) -> AST.Conditional.Condition.Kind {
  .group(.init(.init(faking: kind), child, .fake))
}

func pcreCallout(_ arg: AST.Atom.Callout.PCRE.Argument) -> AST.Node {
  atom(.callout(.pcre(.init(.init(faking: arg)))))
}

func absentRepeater(_ child: AST.Node) -> AST.Node {
  .absentFunction(.init(.repeater(child), start: .fake, location: .fake))
}
func absentExpression(_ absentee: AST.Node, _ child: AST.Node) -> AST.Node {
  .absentFunction(.init(
    .expression(absentee: absentee, pipe: .fake, expr: child),
    start: .fake, location: .fake
  ))
}
func absentStopper(_ absentee: AST.Node) -> AST.Node {
  .absentFunction(.init(.stopper(absentee), start: .fake, location: .fake))

}
func absentRangeClear() -> AST.Node {
  .absentFunction(.init(.clearer, start: .fake, location: .fake))
}

func onigurumaNamedCallout(
  _ name: String, tag: String? = nil, args: String...
) -> AST.Node {
  atom(.callout(.onigurumaNamed(.init(
    .init(faking: name),
    tag: tag.map { .init(.fake, .init(faking: $0), .fake) },
    args: args.isEmpty ? nil : .init(.fake, args.map { .init(faking: $0) }, .fake)
  ))))
}

func onigurumaCalloutOfContents(
  _ contents: String, tag: String? = nil,
  direction: AST.Atom.Callout.OnigurumaOfContents.Direction = .inProgress
) -> AST.Node {
  atom(.callout(.onigurumaOfContents(.init(
    .fake, .init(faking: contents), .fake,
    tag: tag.map { .init(.fake, .init(faking: $0), .fake) },
    direction: .init(faking: direction)
  ))))
}

func backtrackingDirective(
  _ kind: AST.Atom.BacktrackingDirective.Kind, name: String? = nil
) -> AST.Node {
  atom(.backtrackingDirective(
    .init(.init(faking: kind), name: name.map { .init(faking: $0) })
  ))
}

func quant(
  _ amount: AST.Quantification.Amount,
  _ kind: AST.Quantification.Kind = .eager,
  _ child: AST.Node
) -> AST.Node {
  .quantification(.init(
    .init(faking: amount), .init(faking: kind), child, .fake, trivia: []))
}
func zeroOrMore(
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  quant(.zeroOrMore, kind, child)
}
func zeroOrOne(
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  quant(.zeroOrOne, kind, child)
}
func oneOrMore(
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  quant(.oneOrMore, kind, child)
}
func exactly(
  _ i: Int,
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  quant(.exactly(.init(faking: i)), kind, child)
}
func nOrMore(
  _ i: Int,
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  quant(.nOrMore(.init(faking: i)), kind, child)
}
func upToN(
  _ i: Int,
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  quant(.upToN(.init(faking: i)), kind, child)
}
func quantRange(
  _ r: ClosedRange<Int>,
  _ kind: AST.Quantification.Kind = .eager,
  of child: AST.Node
) -> AST.Node {
  let lower = AST.Located(faking: r.lowerBound)
  let upper = AST.Located(faking: r.upperBound)
  return quant(.range(lower, upper), kind, child)
}

func charClass(
  _ members: AST.CustomCharacterClass.Member...,
  inverted: Bool = false
) -> AST.Node {
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

func quote(_ s: String) -> AST.Node {
  .quote(.init(s, .fake))
}
func quote_m(_ s: String) -> AST.CustomCharacterClass.Member {
  .quote(.init(s, .fake))
}

// MARK: - Atoms

func atom(_ k: AST.Atom.Kind) -> AST.Node {
  .atom(.init(k, .fake))
}

func escaped(
  _ e: AST.Atom.EscapedBuiltin
) -> AST.Node {
  atom(.escaped(e))
}
func scalar(_ s: Unicode.Scalar) -> AST.Node {
  atom(.scalar(s))
}
func scalar_m(_ s: Unicode.Scalar) -> AST.CustomCharacterClass.Member {
  atom_m(.scalar(s))
}

func backreference(_ r: AST.Reference.Kind, recursionLevel: Int? = nil) -> AST.Node {
  atom(.backreference(.init(
    r, recursionLevel: recursionLevel.map { .init(faking: $0) }, innerLoc: .fake
  )))
}
func subpattern(_ r: AST.Reference.Kind) -> AST.Node {
  atom(.subpattern(.init(r, innerLoc: .fake)))
}

func prop(
  _ kind: AST.Atom.CharacterProperty.Kind,
  inverted: Bool = false
) -> AST.Node {
  atom(.property(.init(kind, isInverted: inverted, isPOSIX: false)))
}
func posixProp(
  _ kind: AST.Atom.CharacterProperty.Kind, inverted: Bool = false
) -> AST.Node {
  atom(.property(.init(kind, isInverted: inverted, isPOSIX: true)))
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
