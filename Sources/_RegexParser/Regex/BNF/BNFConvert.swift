//
//  BNFConvert.swift
//  swift-experimental-string-processing
//
//  Created by Michael Ilseman on 1/18/25.
//

/// Create a unique non-terminal symbol
///
/// NOTE: Currently, this is unique per input regex, but we should extend any
/// API or SPI to either be able to re-use a generator or pass in a unique seed
/// (such as a regex-counter).
struct SymbolGenerator {
  var prefix = ""

  var counters = [String: Int]()

  mutating func genSuffix(for s: String) -> String {
    guard let c = counters[s] else {
      counters[s] = 0
      return ""
    }
    defer { counters[s] = c + 1 }
    return "_\(c)"
  }

  mutating func genSym(_ name: String) -> NonTerminalSymbol {
    let suffix = genSuffix(for: name)
    return NonTerminalSymbol(name: prefix + name + suffix)
  }
}


struct BNFConvert {
  var symbols = SymbolGenerator()
  var productions = [NonTerminalSymbol: [Choice]]()
  var root: NonTerminalSymbol? = nil
}

extension BNFConvert {
  /// Create a new BNF rule for `sym` and add it to our productions.
  @discardableResult
  mutating func createProduction(
    _ sym: NonTerminalSymbol,
    _ choices: [Choice]
  ) -> NonTerminalSymbol {
    guard !productions.keys.contains(sym) else {
      fatalError("Internal invariant violated: non-unique symbols")
    }
    productions[sym] = choices
    return sym
  }

  /// Create a new symbol for `name` and BNF rule and add it to our productions.
  mutating func createProduction(
    _ name: String,
    _ choices: [Choice]
  ) -> NonTerminalSymbol {
    let sym = symbols.genSym(name)
    return createProduction(sym, choices)
  }
  mutating func createProduction(
    _ name: String,
    _ elements: [Symbol]
  ) -> NonTerminalSymbol {
    createProduction(name, [Choice(elements)])
  }
}

extension BNFConvert {
  /// Convert a Regex AST node to a concatnative component
  ///
  /// Alternations always produce a new rule, as do some quantifications
  mutating func convert(
    _ node: AST.Node
  ) throws -> [Symbol] {
    switch node {
      /// ... | ... | ...
    case .alternation(let a):
      let choices = try a.children.map {
        Choice(try convert($0))
      }
      let altSym = createProduction("ALT", choices)
      return [.nonTerminal(altSym)]

     /// ... ...
    case .concatenation(let c):
      return try c.children.flatMap { node in
        try convert(node)
      }

      /// (...)
    case .group(let g):
      // A group is where an alternation could be nested

      switch g.kind.value {
        // BNF has no captures, so these are just syntactic groups
      case .capture, .namedCapture(_), .balancedCapture(_), .nonCapture:
        return try convert(g.child)

      case .nonCaptureReset:
        fatalError()

      case .atomicNonCapturing:
        fatalError()

      case .lookahead:
        fatalError()
      case .negativeLookahead:
        fatalError()
      case .nonAtomicLookahead:
        fatalError()
      case .lookbehind:
        fatalError()
      case .negativeLookbehind:
        fatalError()
      case .nonAtomicLookbehind:
        fatalError()

      case .scriptRun:
        fatalError()
      case .atomicScriptRun:
        fatalError()

      case .changeMatchingOptions(_):
        fatalError()
      }

      /// (?(cond) true-branch | false-branch)
    case .conditional(_): fatalError()

    case .quantification(let q):
      let quantChild = createProduction("QUANT_CHILD", try convert(q.child))
      return createQuantify(quantChild, q.kind.value, q.amount.value)

      /// \Q...\E
    case .quote(_): fatalError()

      /// Comments, non-semantic whitespace, etc
    case .trivia(_): fatalError()

      /// Intepolation `<{...}>`, currently reserved for future use.
    case .interpolation(_): fatalError()

    case .atom(let atom):
      switch atom.kind {
      case .char(let c):

        let s: Symbol
        if c.unicodeScalars.count == 1 {
          s = .terminal(.character(c.unicodeScalars.first!))
        } else {
          s = .terminalSequence(c.unicodeScalars.map {
            .character($0)
          })
        }

        return [s]

      case .scalar(_): fatalError()
      case .scalarSequence(_): fatalError()
      case .keyboardControl(_): fatalError()
      case .keyboardMeta(_): fatalError()
      case .keyboardMetaControl(_): fatalError()

      case .property, .escaped, .dot, .caretAnchor, .dollarAnchor,
          .backreference, .subpattern, .namedCharacter, .callout,
          .backtrackingDirective, .changeMatchingOptions, .invalid:
        fatalError()
      }

    case .customCharacterClass(let ccc):
      if ccc.start.value == .inverted {
        fatalError("TODO: inverted character classes")
      }
      if ccc.members.count > 1 {
        fatalError("TODO: inverted character classes")
      }
      if ccc.members.isEmpty {
        fatalError("TODO")
      }

      fatalError()



    case .absentFunction(_): fatalError()

    case .empty(_): fatalError()
    }
  }
}

extension BNFConvert {

  mutating func createQuantify(
    _ child: NonTerminalSymbol,
    _ kind: AST.Quantification.Kind,
    _ amount: AST.Quantification.Amount
  ) -> [Symbol] {
    switch kind {
    case .possessive: fatalError("TODO: possessive quantification")
    case .reluctant:
      fatalError("NOTE: reluctanct is ignored")
    case .eager:
      break
    }

    // TODO: Not sure what the canonical empty choice is (i.e. ACCEPT).
    let emptyChoice = Choice(Symbol.terminalSequence([]))
    switch amount {
    case .zeroOrMore:
      // QUANT ::= QUANT_CHILD QUANT | <empty>
      let name = symbols.genSym("QUANT_*")
      let choices = [
        Choice(child, name),
        emptyChoice,
      ]
      createProduction(name, choices)
      return [.nonTerminal(name)]

    case .oneOrMore:
      // QUANT ::= QUANT_CHILD QUANT | QUANT_CHILD
      let name = symbols.genSym("QUANT_+")
      let choices = [
        Choice(child, name),
        Choice(child),
      ]
      createProduction(name, choices)
      return [.nonTerminal(name)]


    case .zeroOrOne:
      // QUANT ::= QUANT_CHILD | <empty>
      let name = symbols.genSym("QUANT_+")
      let choices = [
        Choice(child),
        emptyChoice
      ]
      createProduction(name, choices)
      return [.nonTerminal(name)]

    case .exactly(let n):
      // QUANT_CHILD^n
      guard let n = n.value else {
        fatalError("Invalid AST")
      }

      return Array<Symbol>(repeating: .nonTerminal(child), count: n)

    case .nOrMore(let n):
      // QUANT_CHILD^n QUANT_CHILD*
      var res = createQuantify(child, kind, .exactly(n))
      res.append(contentsOf: createQuantify(child, kind, .zeroOrMore))

      return res

    case .upToN(let n):
      // QUANT ::= <empty> | QUANT_CHILD | ... | QUANT_CHILD^n
      let name = symbols.genSym("QUANT_UPTO_N")
      var choices = [ emptyChoice ]

      guard let n = n.value else {
        fatalError("Invalid AST")
      }

      for i in 1...n {
        choices.append(Choice(createQuantify(
          child, kind, .exactly(.init(i, at: .fake)))))
      }
      // TODO: Do we want to emit differently for eager/reluctant?
      // TODO: Do we want to canonicalize if the BNF truly doesn't have
      // order?
      choices.reverse()

      createProduction(name, choices)
      return [.nonTerminal(name)]

    case .range(let min, let max):
      // QUANT ::= QUANT_CHILD^min QUANT_UPTO_(max-min)
      guard let min = min.value, let max = max.value else {
        fatalError("Invalid AST")
      }

      var res = createQuantify(child, kind, .exactly(.init(min, at: .fake)))
      let upto = createQuantify(child, kind, .upToN(.init(max-min, at: .fake)))
      res.append(contentsOf: upto)
      
      return res
    }
  }
}



extension BNFConvert {
  /// Apply `f` (accumulating results) to our rules in reverse-post-order.
  func reversePostOrder<T>(
    _ f: (NonTerminalSymbol, [Choice]) -> T
  ) -> [T] {
    guard let rootSymbol = root else {
      fatalError("No root symbol defined")
    }

    var visited: Set<NonTerminalSymbol> = []
    var result = [T]()
    func visit(
      _ sym: NonTerminalSymbol
    ) {
      if visited.contains(sym) { return }
      visited.insert(sym)

      guard let choices = productions[sym] else {
        fatalError("Internal invariant violated: undefined nonterminal")
      }

      for choice in choices {
        for symbol in choice.sequence.lazy.reversed() {
          if case .nonTerminal(let sym) = symbol {
            visit(sym)
          }
        }
      }

      result.append(f(sym, choices))
    }

    visit(rootSymbol)
    result.reverse()
    return result
  }

  func createBNF() -> BNF {
    guard let rootSymbol = root else {
      fatalError("No root symbol defined")
    }

    let rules = reversePostOrder { sym, choices in
      Rule(symbol: sym, expression: Expression(choices))
    }

    return BNF(
      root: rules.first!,
      rules: rules)
  }
}

//extension BNFConvert {
//
//  //  var productions = [NonTerminalSymbol: Rule]
//
//  // TODO: dictionary for the rules
//
//  mutating func processNode(
//    _ node: AST.Node
//  ) -> Rule {
//    return makeRule("ROOT", for: node).0
//  }
//
//  // NOTE: alternation produces expression, but it seems like everything
//  // else could produce a Choice or lower
//  mutating func mapNode(
//    _ node: AST.Node
//  ) -> Expression {
//    switch node {
//      /// ... | ... | ...
//    case .alternation(let a):
//      return Expression(convertAlternation(a))
//
//      /// ... ...
//    case .concatenation(let c):
//
//      let childrenChoices: [Symbol] = c.children.flatMap { node in
//        // TODO: look at just mapping to a choice
//        let expr = mapNode(node)
//        guard expr.choices.count == 1 else {
//          // TODO: Figure this out
//          fatalError("Concat's children had direct alternations")
//        }
//        return expr.choices.first!.sequence
//      }
//
//      return Expression(Choice(childrenChoices))
//
//      /// (...)
//    case .group(_): fatalError()
//
//      /// (?(cond) true-branch | false-branch)
//    case .conditional(_): fatalError()
//
//    case .quantification(let q):
//      // Make a rule for the child
//      let (_, childName) = addRule("QUANT_CHILD", for: q.child)
//
//      switch q.kind.value {
//      case .possessive: fatalError("TODO: possessive quantification")
//      case .reluctant:
//        fatalError("NOTE: reluctanct is ignored")
//      case .eager:
//        break
//      }
//
//      switch q.amount.value {
//      case .zeroOrMore:
//        // QUANT ::= <empty> | QUANT_CHILD QUANT
//
//        let name = symbols.genSym("QUANT_*")
//        let expr = Expression(
//          Choice(.terminalSequence([])),
//          Choice(childName, name))
//        rules.append(Rule(
//          symbol: name,
//          expression: expr))
//
//        return Expression(Choice(name))
//
//
//
//      case .oneOrMore:
//        // QUANT ::= QUANT_CHILD | QUANT_CHILD QUANT
//
//        let name = symbols.genSym("QUANT_*")
//        let expr = Expression(
//          Choice(childName),
//          Choice(childName, name))
//        rules.append(Rule(
//          symbol: name,
//          expression: expr))
//
//        return Expression(Choice(name))
//
//      case .zeroOrOne:
//        // QUANT ::= QUANT_CHILD | <empty>
//        fatalError()
//
//      case .exactly(let n):
//        // QUANT ::= QUANT_CHILD^n
//        fatalError()
//      case .nOrMore(let n):
//        fatalError()
//      case .upToN(let n):
//        fatalError()
//      case .range(let min, let max):
//        fatalError()
//      }
//
//      // let sym = .nonTerminal(name)
//
//
//
//
//      fatalError()
//
//      /// \Q...\E
//    case .quote(_): fatalError()
//
//      /// Comments, non-semantic whitespace, etc
//    case .trivia(_): fatalError()
//
//      /// Intepolation `<{...}>`, currently reserved for future use.
//    case .interpolation(_): fatalError()
//
//    case .atom(let atom):
//      switch atom.kind {
//      case .char(let c):
//
//        let s: Symbol
//        if c.unicodeScalars.count == 1 {
//          s = .terminal(.character(c.unicodeScalars.first!))
//        } else {
//          s = .terminalSequence(c.unicodeScalars.map {
//            .character($0)
//          })
//        }
//
//        return Expression(choices: [Choice(s)])
//
//      case .scalar(_): fatalError()
//      case .scalarSequence(_): fatalError()
//      case .keyboardControl(_): fatalError()
//      case .keyboardMeta(_): fatalError()
//      case .keyboardMetaControl(_): fatalError()
//
//      case .property, .escaped, .dot, .caretAnchor, .dollarAnchor,
//          .backreference, .subpattern, .namedCharacter, .callout,
//          .backtrackingDirective, .changeMatchingOptions, .invalid:
//        fatalError()
//      }
//
//    case .customCharacterClass(_): fatalError()
//
//    case .absentFunction(_): fatalError()
//
//    case .empty(_): fatalError()
//    }
//  }
//}
