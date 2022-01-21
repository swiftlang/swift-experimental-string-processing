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

// TODO: Add an expansion level, both from top to bottom.
//       After `printAsCanonical` is fleshed out, these two
//       printers can call each other. This would enable
//       incremental conversion, such that leaves remain
//       as canonical regex literals.

extension AST {
  /// Render as a Pattern DSL
  public func renderAsPattern(
    maxTopDownLevels: Int? = nil,
    minBottomUpLevels: Int? = nil
  ) -> String {
    var printer = PrettyPrinter(
      maxTopDownLevels: maxTopDownLevels,
      minBottomUpLevels: minBottomUpLevels)
    printer.printAsPattern(self)
    return printer.finish()
  }
}

extension PrettyPrinter {
  /// If pattern printing should back off, prints the regex literal and returns true
  mutating func patternBackoff(_ ast: AST) -> Bool {
    if let max = maxTopDownLevels, depth >= max {
      return true
    }
    if let min = minBottomUpLevels, ast.height <= min {
      return true
    }
    return false
  }

  mutating func printAsPattern(_ ast: AST) {
    if patternBackoff(ast) {
      printAsCanonical(ast, delimiters: true)
      return
    }

    switch ast {
    case let .globalMatchingOptions(o):
      // TODO: Global options.
      printAsPattern(o.ast)

    case let .alternation(a):
      printBlock("Alternation") { printer in
        a.children.forEach { printer.printAsPattern($0) }
      }

    case let .concatenation(c):
      // Coalesce adjacent children who can produce a
      // string literal representation
      func coalesce(
        _ idx: inout Array<AST>.Index
      ) -> String? {
        let col = c.children
        var result = ""
        while idx < col.endIndex {
          let atom: AST.Atom? = col[idx].as()
          guard let str = atom?.literalStringValue else {
            break
          }
          result += str
          col.formIndex(after: &idx)
        }
        return result.isEmpty ? nil : result._quoted
      }

      // No need to nest single children concatenations
      if c.children.count == 1 {
        printAsPattern(c.children.first!)
        return
      }

      // Check for a single child post-coalescing
      var idx = c.children.startIndex
      if let s = coalesce(&idx), idx == c.children.endIndex {
        print(s)
        return
      }

      printBlock("Concatenation") { printer in
        var curIdx = c.children.startIndex
        while curIdx < c.children.endIndex {
          if let str = coalesce(&curIdx) {
            printer.print(str)
          } else {
            printer.printAsPattern(c.children[curIdx])
            c.children.formIndex(after: &curIdx)
          }
        }
      }

    case let .group(g):
      let kind = g.kind.value._patternBase
      printBlock("Group(\(kind))") { printer in
        printer.printAsPattern(g.child)
      }

    case let .conditional(c):
      print("/*TODO: conditional \(c)*/")

    case let .quantification(q):
      let amount = q.amount.value._patternBase
      let kind = q.kind.value._patternBase
      printBlock("\(amount)(\(kind))") { printer in
        printer.printAsPattern(q.child)
      }

    case let .quote(q):
      // FIXME: Count number of `#` in literal...
      print("#\"\(q.literal)\"#")

    case let .trivia(t):
      // TODO: We might want to output comments...
      _ = t
      return

    case let .atom(a):
      printAsPattern(a)

    case let .customCharacterClass(ccc):
      printAsPattern(ccc)

    case .empty: print("")
    case .groupTransform:
      print("// FIXME: get group transform out of here!")
    }
  }

  mutating func printAsPattern(_ a: AST.Atom) {
    if let s = a.literalStringValue {
      print(s._quoted)
    } else {
      print(a._patternBase)
    }
  }

  mutating func printAsPattern(_ ccc: AST.CustomCharacterClass) {
    let inv = ccc.isInverted ? "inverted: true" : ""
    printBlock("CharacterClass(\(inv))") { printer in
      ccc.members.forEach { printer.printAsPattern($0) }
    }
  }

  mutating func printAsPattern(_ member: AST.CustomCharacterClass.Member) {
    switch member {
    case .custom(let ccc):
      printAsPattern(ccc)
    case .range(let r):
      if let lhs = r.lhs.literalStringValue,
         let rhs = r.rhs.literalStringValue {
        indent()
        output(lhs._quoted)
        output("...")
        output(rhs._quoted)
        terminateLine()
      } else {
        print("// TODO: Range \(r.lhs) to \(r.rhs)")
      }
    case .atom(let a):
      if let s = a.literalStringValue {
        print(s._quoted)
      } else {
        print(a._patternBase)
      }
    case .quote(let q):
      print("// TODO: quote \(q.literal._quoted) in custom character classes (should we split it?)")
    case .setOperation:
      print("// TODO: Set operation: \(member)")
    }
  }
}

extension String {
  // TODO: Escaping?
  fileprivate var _quoted: String { "\"\(self)\"" }
}

extension AST.Atom.AssertionKind {
  var _patternBase: String {
    switch self {
    case .startOfSubject:    return "Anchor(.startOfSubject)"
    case .endOfSubject:      return "Anchor(.endOfSubject)"
    case .textSegment:       return "Anchor(.textSegment)"
    case .notTextSegment:    return "Anchor(.notTextSegment)"
    case .startOfLine:       return "Anchor(.startOfLine)"
    case .endOfLine:         return "Anchor(.endOfLine)"
    case .wordBoundary:      return "Anchor(.wordBoundary)"
    case .notWordBoundary:   return "Anchor(.notWordBoundary)"

    case .resetStartOfMatch:
      return "Anchor(.resetStartOfMatch)"
    case .endOfSubjectBeforeNewline:
      return "Anchor(.endOfSubjectBeforeNewline)"
    case .firstMatchingPositionInSubject:
      return "Anchor(.firstMatchingPositionInSubject)"
    }
  }
}

extension AST.Atom.CharacterProperty {
  var _patternBase: String {
    "Property(\(kind._patternBase)\(isInverted ? ", inverted: true" : ""))"
  }
}
extension AST.Atom.CharacterProperty.Kind {
  var _patternBase: String {
    "/* TODO: character properties */"
  }
}

extension AST.Atom {
  /// Base string to use when rendering as a component in a
  /// pattern. Note that when the atom is rendered individually,
  /// it still may need to be wrapped in quotes.
  ///
  /// TODO: We want to coalesce adjacent atoms, likely in
  /// caller, but we might want to be parameterized at that point.
  var _patternBase: String {
    if let anchor = self.assertionKind {
      return anchor._patternBase
    }

    switch kind {
    case let .char(c):
      return String(c)

    case let .scalar(s):
      let hex = String(s.value, radix: 16, uppercase: true)
      return "\\u{\(hex)}"

    case let .property(p):
      return p._patternBase

    case let .escaped(e):
      // TODO: API names instead of case names
      return ".\(e)"

    case .keyboardControl:
      return " /* TODO: keyboard control */"

    case .keyboardMeta:
      return " /* TODO: keyboard meta */"

    case .keyboardMetaControl:
      return " /* TODO: keyboard meta-control */"

    case .namedCharacter:
      return " /* TODO: named character */"

    case .any:
      return ".any"

    case .startOfLine, .endOfLine:
      fatalError("unreachable")

    case .backreference:
      return " /* TODO: back reference */"

    case .subpattern:
      return " /* TODO: subpattern */"

    case .callout:
      return " /* TODO: callout */"

    case .backtrackingDirective:
      return " /* TODO: backtracking directive */"
    }
  }
}

extension AST.Group.Kind {
  var _patternBase: String {
    switch self {
    case .capture:
      // TODO: We probably want this to be a prperty after group
      return ".capture"

    case .namedCapture(let n):
      return "name: \"\(n)\""

    case .balancedCapture:
      return "/* TODO: balanced captures */"

    case .nonCapture: return ""

    case .nonCaptureReset:
      return "/* TODO: non-capture reset */"

    case .atomicNonCapturing:
      return "/* TODO: atomicNonCapturing */"
    case .lookahead:
      return "/* TODO: lookahead */"
    case .negativeLookahead:
      return "/* TODO: negativeLookahead */"
    case .nonAtomicLookahead:
      return "/* TODO: nonAtomicLookahead */"
    case .lookbehind:
      return "/* TODO: lookbehind */"
    case .negativeLookbehind:
      return "/* TODO: negativeLookbehind */"
    case .nonAtomicLookbehind:
      return "/* TODO: nonAtomicLookbehind */"
    case .scriptRun:
      return "/* TODO: scriptRun */"
    case .atomicScriptRun:
      return "/* TODO: atomicScriptRun */"
    case .changeMatchingOptions:
      return "/* TODO: changeMatchingOptions */"
    }
  }
}

extension AST.Quantification.Amount {
  var _patternBase: String {
    switch self {
    case .zeroOrMore: return "ZeroOrMore"
    case .oneOrMore:  return "OneOrMore"
    case .zeroOrOne:  return "ZeroOrOne"
    case let .exactly(n):  return "Quantitified(exactly: \(n))"
    case let .nOrMore(n):  return "Quantified(\(n)...)"
    case let .upToN(n):    return "Quantified(...\(n))"
    case let .range(n, m): return "Quantified(\(n)...\(m))"
    }
  }
}

extension AST.Quantification.Kind {
  var _patternBase: String {
    switch self {
    case .eager: return ".eager"
    case .reluctant: return ".reluctant"
    case .possessive: return ".possessive"
    }
  }
}

extension AST {
  var height: Int {
    // FIXME: Is this right for custom char classes?
    // How do we count set operations?
    guard let children = self.children else {
      return 1
    }
    guard let max = children.lazy.map(\.height).max() else {
      return 1
    }
    return 1 + max
  }
}
