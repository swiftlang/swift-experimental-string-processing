struct BNF {
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

struct Rule {
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

struct NonTerminalSymbol: Hashable {
  var name: String

  func render() -> String {
    name
  }
}

struct Expression {
  var choices: [Choice]

  func render() -> String {
    "\(choices.map({ $0.render() }).joined(separator: " | "))"
  }
}

// Was Choice
struct Choice {
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

enum Symbol {
  case terminal(TerminalSymbol)
  case terminalSequence([TerminalSymbol])
  case nonTerminal(NonTerminalSymbol)

  func render() -> String {
    switch self {
    case .terminal(let t):
      return t.render()
    case .terminalSequence(let s):
      return "\(s.map({ $0.render() }).joined(separator: " "))"
    case .nonTerminal(let n):
      return n.render()
    }
  }
}

enum CharacterSet {}

enum TerminalSymbol {
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
