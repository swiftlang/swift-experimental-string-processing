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

protocol BNFNode: CustomStringConvertible {
  func render() -> String
}
extension BNFNode {
  var description: String { render() }
}

struct BNF: BNFNode {
  var root: Rule
  var rules: [Rule]

  func render() -> String {
    var str = ""// root.render() + "\n"
    if rules.isEmpty {
      return str
    }
    return str
      + rules.lazy.map {
        $0.render()
      }.joined(separator: "\n")
      + "\n"
  }
}

struct Rule: BNFNode {
  // The left-hand side
  var symbol: NonTerminalSymbol

  var expression: Expression

  var predicates: [CharacterPredicate] = []

  func render() -> String {
    "\(symbol.render()) ::= \(expression.render())"
  }
}

struct CharacterPredicate {
  // TODO: convention c or trivial?
  let impl: (Unicode.Scalar) -> Bool
}

struct NonTerminalSymbol: Hashable, BNFNode {
  var name: String

  func render() -> String {
    "<\(name)>"
  }
}

struct Expression: BNFNode {
  var choices: [Choice]

  func render() -> String {
    "\(choices.map({ $0.render() }).joined(separator: " | "))"
  }
}

struct Choice: BNFNode {
  var sequence: [Symbol]

  init(_ symbols: Array<Symbol>) {
    self.sequence = symbols
  }
  init(_ symbols: Symbol...) {
    self.init(symbols)
  }

  func render() -> String {
    "\(sequence.map({ $0.render() }).joined(separator: " "))"
  }
}

enum Symbol: BNFNode {
  case terminal(TerminalSymbol)
  case terminalSequence([TerminalSymbol])
  case nonTerminal(NonTerminalSymbol)
  case builtin(Builtin)

  func render() -> String {
    switch self {
    case .terminal(let t):
      return t.render()

    case .terminalSequence(let s):
      guard !s.isEmpty else {
        return "\"\""
      }
      return "\(s.map({ $0.render() }).joined(separator: " "))"

    case .nonTerminal(let n):
      return n.render()

    case .builtin(let b):
      return b.render()
    }
  }
}

enum Builtin: BNFNode {
  case any   // NOTE: we map dot to this, not sure if we want non-newline dots
  case whitespace
  case notWhitespace
  case decimalDigit
  case notDecimalDigit
  case wordCharacter
  case notWordCharacter

  func render() -> String {
    switch self {
    case .any:
      return "<ALL_CHARACTERS_EXCEPT_QUOTE_AND_BACKSLASH>"
    case .whitespace:
      return "<WHITESPACES_AND_NEWLINES>"
    case .notWhitespace:
      fatalError()
    case .decimalDigit:
      return "<DECIMAL_DIGITS>"
    case .notDecimalDigit:
      fatalError()
    case .wordCharacter:
      return "<ALPHANUMERICS>"
    case .notWordCharacter:
      fatalError()
    }
  }
}

enum CharacterSet {}

enum TerminalSymbol: BNFNode {
  case character(Unicode.Scalar)
  case characterSet(CharacterSet)
  case utf8CodeUnit(UInt8)

  case characterPredicate(CharacterPredicate)

  func render() -> String {
    switch self {
    case .character(let c):
      return "\"\(c)\""
    case .characterSet(let _):
      fatalError()
    case .utf8CodeUnit(let u):
      return "\"\(u)\""
    case .characterPredicate(_):
      fatalError()
    }
  }
}

extension Expression {
  init(_ choices: [Choice]) {
    self.init(choices: choices)
  }
  init(_ choices: Choice...) {
    self.init(choices)
  }
}

extension Choice {
  init(_ elements: [NonTerminalSymbol]) {
    self.init(elements.map { .nonTerminal($0) })
  }
  init(_ elements: NonTerminalSymbol...) {
    self.init(elements)
  }
}

/*


node -> choice

 */
