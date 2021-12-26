// TODO: Reevaluate whether to use pretty printer
// TODO: Round-tripping tests

extension AST {
  /// Render using Swift's preferred regex literal syntax
  public func renderAsCanonical() -> String {
    // TODO: Right now, just a simple recursive
    // function returning String, but it's likely we'll
    // want to manage some kind of state.
    var printer = PrettyPrinter()
    return printer.printAsCanonical(self)
    //    return printer.output
  }
}

extension PrettyPrinter {
  mutating func printAsCanonical(_ ast: AST) -> String {
    switch ast {
    case let .alternation(a):
      return a.children.map {
        printAsCanonical($0)
      }.joined(separator: "|")
    case let .concatenation(c):
      return c.children.map {
        printAsCanonical($0)
      }.joined()
    case let .group(g):
      let open = g.kind.value._canonicalBase
      let child = printAsCanonical(g.child)
      return "\(open)\(child))"

    case let .quantification(q):
      let child = printAsCanonical(q.child)
      let amt = q.amount.value._canonicalBase
      return "\(child)\(amt)\(q.kind.value.rawValue)"

    case let .quote(q):
      // TODO: Is this really what we want?
      return "\\Q\(q.literal)\\E"

    case let .trivia(t):
      return "/* TODO: trivia \(t) */"

    case let .atom(a):
      return a._canonicalBase

    case let .customCharacterClass(ccc):
      return printAsCanonical(ccc)

    case .empty:
      return ""

    case .groupTransform:
      return "/* TODO: get groupTransform out of AST */"
    }
  }

  func printAsCanonical(
    _ ccc: AST.CustomCharacterClass
  ) -> String {
    let start = ccc.start.value.rawValue
    // TODO: Do we need grouping or special escape rules?
    let middle = ccc.members.map {
      printAsCanonical($0)
    }.joined()
    return "\(start)\(middle)]"
  }

  func printAsCanonical(
    _ member: AST.CustomCharacterClass.Member
  ) -> String {
    // TODO: Do we need grouping or special escape rules?
    switch member {
    case .custom(let ccc):
      return printAsCanonical(ccc)
    case .range(let a, let b):
      let lhs = a._canonicalBase
      let rhs = b._canonicalBase
      return "\(lhs)-\(rhs)"
    case .atom(let a):
      return a._canonicalBase
    case .setOperation:
      return "/* TODO: set operation \(self) */"
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

    default:
      return "/* TODO: atom \(self) */"
    }
  }
}
