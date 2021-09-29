public enum PEG<Element: Comparable & Hashable> {}

extension PEG {
  enum Pattern {
    /// Match any element
    case any

    /// Match succeeds
    case success

    /// Match fails
    case failure

    /// Match a specific element
    case element(Element)

    /// Match one of many potential elements
    case charactetSet((Element) -> Bool)

    /// A literal sequence of elements
    case literal(Array<Element>)

    /// Try `p1` first, and only if it doesn't work, backtrack and try `p2`
    indirect case orderedChoice(Pattern, Pattern)

    /// Try each pattern in succession
    indirect case concat([Pattern])

    /// `p1 - p2` == `!p2 p1`, i.e. match `p1` so long as `p2` is not true
    indirect case difference(Pattern, Pattern)

    /// Repeat a pattern at least `n` times
    indirect case `repeat`(Pattern, atLeast: Int)
    indirect case repeatRange(Pattern, atLeast: Int, atMost: Int)

    /// Match if `p1` matches, but does not consume input
    indirect case and(Pattern)

    /// Match if `p1` does not match. Does not consume input
    indirect case not(Pattern)

    /// Capture `p1`
    indirect case capture(Pattern)

    /// Reference a declared variable (e.g. for recursive patterns)
    case variable(String)


    // Some conveniences

    /// The end of input
    ///
    /// .end == .not(.any) == assertion { $1 == $0.endIndex }
    case end

    static func many(_ p: Pattern) -> Pattern {
      .repeat(p, atLeast: 0)
    }
    static func oneOrMore(_ p: Pattern) -> Pattern {
      .repeat(p, atLeast: 1)
    }
    static func range<RE: RangeExpression>(
      _ re: RE
    ) -> Pattern where RE.Bound == Element {
      .charactetSet({ re.contains($0) })
    }
  }

  struct Production {
    let name: String
    let pattern: Pattern

    var destructure: (name: String, pattern: Pattern) {
      (name, pattern)
    }
  }

  // Environment is, effectively, a list of productions
  typealias Environment = Dictionary<String, Pattern>

  struct Program {
    let start: String
    let environment: Environment

    func checkInvariants() {
      assert(environment[start] != nil)
    }

    var entry: Production {
      Production(name: start, pattern: environment[start]!)
    }

    var destructure: (start: String, environment: Environment) {
      (start, environment)
    }
  }
}

extension PEG.Pattern: CustomStringConvertible {
  var description: String {
    switch self {
    case .any: return "<any>"
    case .success: return "<success>"
    case .failure: return "<failure>"
    case .element(let e): return "'\(e)'"

    case .charactetSet(let s):
      return "\(String(describing: s))"

    case .literal(let l):
      return "'\(l.map { "\($0)" }.joined())'"

    case .orderedChoice(let lhs, let rhs):
      return "(\(lhs) | \(rhs))"

    case .concat(let s):
      return s.map { "\($0)" }.joined(separator: " ")

    case .difference(let lhs, let rhs): return "(\(lhs) - \(rhs))"

    case .repeat(let p, let atLeast):
      return "<repeat \(p) atLeast: \(atLeast)>"

    case .repeatRange(let p, let atLeast, let atMost):
      return "<repeat \(p) atLeast: \(atLeast) atMost: \(atMost)>"

    case .and(let p): return "&(\(p))"
    case .not(let p): return "!(\(p))"
    case .capture(let p): return "<capture \(p)>"
    case .variable(let v): return "\(v)"
    case .end: return "<end>"
    }
  }
}
