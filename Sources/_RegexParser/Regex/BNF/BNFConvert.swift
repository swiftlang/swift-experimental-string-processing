//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// Create a unique non-terminal symbol
///
/// Namespace is used to disambiguate symbols if multiple regexes are combined into one grammar
struct SymbolGenerator {
  let namespace: String

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
    return NonTerminalSymbol(name: namespace + "_" + name + suffix)
  }
}

internal struct BNFConversionError: Error {
  let message: String
}

struct BNFConvert {
  var symbols: SymbolGenerator
  var productions = [NonTerminalSymbol: [Choice]]()
  var root: NonTerminalSymbol? = nil

  init(namespace: String) {
    self.symbols = .init(namespace: namespace)
  }
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

fileprivate func unsupported(_ s: String) -> BNFConversionError {
  .init(message: "Unsupported Regex feature for BNF conversion: \(s)")
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
        throw unsupported("Non-capture group reset")

      case .atomicNonCapturing:
        throw unsupported("Atomic non-capture groups")

      case .lookahead:
        throw unsupported("Lookahead")

      case .negativeLookahead:
        throw unsupported("Negative lookahead")

      case .nonAtomicLookahead:
        throw unsupported("Non-atomic lookahead")

      case .lookbehind:
        throw unsupported("Lookbehind")

      case .negativeLookbehind:
        throw unsupported("Negative lookbehind")

      case .nonAtomicLookbehind:
        throw unsupported("Non-atomic lookbehind")

      case .scriptRun:
        throw unsupported("Script run")

      case .atomicScriptRun:
        throw unsupported("Atomic script run")

      case .changeMatchingOptions(_):
        throw unsupported("Matching options")
      }

      /// (?(cond) true-branch | false-branch)
    case .conditional(_): throw unsupported("Conditionals")

    case .quantification(let q):
      let quantChild = createProduction("QUANT_CHILD", try convert(q.child))
      return try createQuantify(quantChild, q.kind.value, q.amount.value)

      /// \Q...\E
    case .quote(_): throw unsupported("Quotes")
      // FIXME: we probably can...

      /// Comments, non-semantic whitespace, etc
    case .trivia(_): throw unsupported("Comments and non-semantic whitespace")
      // FIXME: we probably can...

      /// Intepolation `<{...}>`, currently reserved for future use.
    case .interpolation(_): throw unsupported("Unsupported")

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

      case .dot:
        return [.builtin(.any)]

      case .escaped(let b):
        let builtin = try mapEscapedBuiltin(b)
        return [.builtin(builtin)]


        // FIXME: we probably can support the below
      case .scalar(_): throw unsupported("Scalar literals")

      case .scalarSequence(_): throw unsupported("Scalar sequence")

      case .keyboardControl(_): throw unsupported("Keyboard control")

      case .keyboardMeta(_): throw unsupported("Keyboard meta")

      case .keyboardMetaControl(_): throw unsupported("Keyboard meta control")

      case .property, .escaped, .caretAnchor, .dollarAnchor,
          .backreference, .subpattern, .namedCharacter, .callout,
          .backtrackingDirective, .changeMatchingOptions, .invalid:
        throw unsupported("")
      }

    case .customCharacterClass(let ccc):
      throw unsupported("Custom character classes")

    case .absentFunction(_): throw unsupported("Absent function")

    case .empty(_): throw unsupported("Empty")
    }
  }
}

extension BNFConvert {
  func mapEscapedBuiltin(_ b: AST.Atom.EscapedBuiltin) throws -> Builtin {
    switch b {

      // Scalar escapes
    case .alarm, .escape, .formfeed, .newline, .carriageReturn, .tab, .backspace:
      throw unsupported("Builtin scalar escapes") // FIXME: support

      // Built-in character classes
    case .whitespace: return .whitespace
    case .notWhitespace: return .notWhitespace
    case .decimalDigit: return .decimalDigit
    case .notDecimalDigit: return .notDecimalDigit
    case .wordCharacter: return .wordCharacter
    case .notWordCharacter: return .notWordCharacter

      // Other character classes
    case .horizontalWhitespace, .notHorizontalWhitespace, .notNewline, .newlineSequence, .verticalTab, .notVerticalTab:
      throw unsupported("Other whitespace character classes") // FIXME: support


      // Assertions
    case .wordBoundary, .notWordBoundary:
      throw unsupported("Word boundaries")

      // Anchors
    case .startOfSubject, .endOfSubjectBeforeNewline, .endOfSubject, .firstMatchingPositionInSubject:
      throw unsupported("Anchors")

      // Other
    case .singleDataUnit, .graphemeCluster, .resetStartOfMatch, .trueAnychar, .textSegment, .notTextSegment:
      throw unsupported("Other builtins")

    }
  }

  mutating func createQuantify(
    _ child: NonTerminalSymbol,
    _ kind: AST.Quantification.Kind,
    _ amount: AST.Quantification.Amount
  ) throws -> [Symbol] {
    switch kind {
    case .possessive: throw unsupported("Possessive quantification")
    case .reluctant: throw unsupported("Reluctant quantification")
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
      let name = symbols.genSym("QUANT_?")
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
      var res = try createQuantify(child, kind, .exactly(n))
      res.append(contentsOf: try createQuantify(child, kind, .zeroOrMore))

      return res

    case .upToN(let n):
      // QUANT ::= <empty> | QUANT_CHILD | ... | QUANT_CHILD^n
      let name = symbols.genSym("QUANT_UPTO_N")
      var choices = [ emptyChoice ]

      guard let n = n.value else {
        fatalError("Invalid AST")
      }

      for i in 1...n {
        choices.append(Choice(try createQuantify(
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

      var res = try createQuantify(child, kind, .exactly(.init(min, at: .fake)))
      let upto = try createQuantify(child, kind, .upToN(.init(max-min, at: .fake)))
      res.append(contentsOf: upto)
      
      return res
    }
  }
}

extension BNFConvert {
  /// Optimize the BNF
  mutating func optimize() {
    // Iterate until we reach a fixed point
    var changed = true
    while changed {
      changed = false

      //
      // Value propagation: propagate small single-choice single-symbol
      // productions
      //
      // A ::= B C D E
      // B ::= "b"
      // C ::= C2
      // C2 ::= "c"
      // D ::= "d" "d" "d"
      // E ::= "e" "e" "e" "e" ...
      //
      // -->
      //
      // A ::= "b" "c" "d" "d" "d" E
      // E ::= "e" "e" "e" "e" ...
      //

      // Build up a list of single-choice single-symbol productions
      // for upwards propagation
      let terminalSequenceThreshold = 3
      var singles = [NonTerminalSymbol: Symbol]()
      for (key, val) in productions {
        if val.count == 1 {
          let valChoice = val.first!
          if valChoice.sequence.count == 1 {
            let valSym = valChoice.sequence.first!
            if case .terminalSequence(let array) = valSym {
              if array.count > terminalSequenceThreshold {
                continue
              }
            }
            singles[key] = valSym
          }
        }
      }

      for (key, val) in productions {
        var valCopy = val
        var valCopyDidChange = false

        for choiceIdx in val.indices {

          let choice = val[choiceIdx]
          var choiceCopy = choice
          var choiceCopyDidChange = false

          for idx in choice.sequence.indices {
            if case .nonTerminal(let nt) = choice.sequence[idx] {
              if let sym = singles[nt] {
                choiceCopy.sequence[idx] = sym
                choiceCopyDidChange = true
              }
            }
          }

          if choiceCopyDidChange {
            valCopy[choiceIdx] = choiceCopy
            valCopyDidChange = true
          }
        }

        if valCopyDidChange {
          productions[key] = valCopy
          changed = true
        }
      }

      // Check ROOT, since it has no uses it couldn't upward propagate
      // a single non-terminal child
      guard let rootSymbol = root else {
        fatalError("Invariant violated: no root set")
      }
      guard let val = productions[rootSymbol] else {
        // TODO: or is this an empty grammar?
        // TODO: test empty regex
        fatalError("Invariant violated: root has no production")
      }

      // TODO: This isn't a win when RHS already has uses
      if val.count == 1 {
        let seq = val.first!.sequence
        if seq.count == 1 {
          if case .nonTerminal(let rhs) = seq.first! {
            productions[rootSymbol] = productions[rhs]
            changed = true
          }
        }
      }
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

