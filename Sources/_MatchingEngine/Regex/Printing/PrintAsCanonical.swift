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

// TODO: Round-tripping tests

extension AST {
  /// Render using Swift's preferred regex literal syntax
  public func renderAsCanonical(
    showDelimiters delimiters: Bool = false,
    terminateLine: Bool = false
  ) -> String {
    var printer = PrettyPrinter()
    printer.printAsCanonical(
       self,
       delimiters: delimiters,
       terminateLine: terminateLine)
    return printer.finish()
  }
}

extension PrettyPrinter {
  /// Will output `ast` in canonical form, taking care to
  /// also indent and terminate the line (updating internal state)
  mutating func printAsCanonical(
    _ ast: AST,
    delimiters: Bool = false,
    terminateLine terminate: Bool = true
  ) {
    indent()
    if delimiters { output("'/") }
    outputAsCanonical(ast)
    if delimiters { output("/'") }
    if terminate {
      terminateLine()
    }
  }

  /// Output the `ast` in canonical form, does not indent, terminate,
  /// or affect internal state
  mutating func outputAsCanonical(_ ast: AST) {
    switch ast {
    case let .alternation(a):
      for idx in a.children.indices {
        outputAsCanonical(a.children[idx])
        if a.children.index(after: idx) != a.children.endIndex {
          output("|")
        }
      }
    case let .concatenation(c):
      c.children.forEach { outputAsCanonical($0) }
    case let .group(g):
      output(g.kind.value._canonicalBase)
      outputAsCanonical(g.child)
      output(")")

    case let .quantification(q):
      outputAsCanonical(q.child)
      output(q.amount.value._canonicalBase)
      output(q.kind.value._canonicalBase)

    case let .quote(q):
      // TODO: Is this really what we want?
      output("\\Q\(q.literal)\\E")

    case let .trivia(t):
      // TODO: We might want to output comments...
      _ = t
      output("")

    case let .atom(a):
      output(a._canonicalBase)

    case let .customCharacterClass(ccc):
      outputAsCanonical(ccc)

    case .empty:
      output("")

    case .groupTransform:
      output("/* TODO: get groupTransform out of AST */")
    }
  }

  mutating func outputAsCanonical(
    _ ccc: AST.CustomCharacterClass
  ) {
    output(ccc.start.value._canonicalBase)
    ccc.members.forEach { outputAsCanonical($0) }
    output("]")
  }

  mutating func outputAsCanonical(
    _ member: AST.CustomCharacterClass.Member
  ) {
    // TODO: Do we need grouping or special escape rules?
    switch member {
    case .custom(let ccc):
      outputAsCanonical(ccc)
    case .range(let r):
      output(r.lhs._canonicalBase)
      output("-")
      output(r.rhs._canonicalBase)
    case .atom(let a):
      output(a._canonicalBase)
    case .setOperation:
      output("/* TODO: set operation \(self) */")
    }
  }
}

extension AST.Group.Kind {
  var _canonicalBase: String {
    switch self {
    case .capture:              return "("
    case .namedCapture(let n):  return "(?<\(n.value)>"
    case .nonCapture:           return "(?:"
    case .nonCaptureReset:      return "(?|"
    case .atomicNonCapturing:   return "(?>"
    case .lookahead:            return "(?="
    case .negativeLookahead:    return "(?!"
    case .nonAtomicLookahead:   return "(?*"
    case .lookbehind:           return "(?<="
    case .negativeLookbehind:   return "(?<!"
    case .nonAtomicLookbehind:  return "(?<*"
    case .scriptRun:            return "(*sr:"
    case .atomicScriptRun:      return "(*asr:"

    case .changeMatchingOptions:
      return "(/* TODO: matchign options in canonical form */"
    }
  }
}

extension AST.Quantification.Amount {
  var _canonicalBase: String {
    switch self {
    case .zeroOrMore:      return "*"
    case .oneOrMore:       return "+"
    case .zeroOrOne:       return "?"
    case let .exactly(n):  return "{\(n.value)}"
    case let .nOrMore(n):  return "{\(n.value),}"
    case let .upToN(n):    return "{,\(n.value)}"
    case let .range(lower, upper):
      return "{\(lower),\(upper)}"
    }
  }
}
extension AST.Quantification.Kind {
  var _canonicalBase: String { self.rawValue }
}

extension AST.Atom {
  var _canonicalBase: String {
    if let anchor = self.assertionKind {
      return anchor.rawValue
    }
    if let lit = self.literalStringValue {
      // FIXME: We may have to re-introduce escapes
      // For example, `\.` will come back as "." instead
      // For now, catch the most common offender
      if lit == "." { return "\\." }
      return lit
    }
    switch self.kind {
    case .escaped(let e):
      return "\\\(e.character)"
    case .backreference(let br):
       return br._canonicalBase

    default:
      return "/* TODO: atom \(self) */"
    }
  }
}

extension /*AST.Atom.*/Reference {
  var _canonicalBase: String {
    switch self {
    case .absolute(let i):
      // TODO: Honestly, I wouldn't mind saying that a clearer
      // syntax like `\g{n}`, though that's also problematic
      // because in Oniguruma every except `{` would mean
      // re-evaluate group
      return "\\\(i)"
    case .relative:
      return "/* TODO: relative reference \(self) */"
    case .named:
      return "/* TODO: named reference \(self) */"
    case .recurseWholePattern:
      return "/* TODO: recursive reference \(self) */"
    }
  }
}

extension AST.CustomCharacterClass.Start {
  var _canonicalBase: String { self.rawValue }
}
