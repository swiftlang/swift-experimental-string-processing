
/// Mock-up of the Swift lexer, so we can model our interfaces
struct SwiftLexer {
  enum Tok {
    case opaque(AST)

    var ast: AST {
      switch self {
      case .opaque(let ast): return ast
      }
    }
  }

  static func lex(_ src: String) -> Tok {
    // Assume there's just a single literal here, no escaping
    if let start = src.firstIndex(of: "'") {
      return lexSingleQuotedLiteral(
        src[src.index(after: start)..<src.lastIndex(of: "'")!])
    }
    fatalError()
  }

  static func lexSingleQuotedLiteral(_ sub: Substring) -> Tok {
    let ast: AST
    if sub.first == "/" && sub.last == "/" {
      ast = try! parse(
        sub.dropFirst().dropLast(), .traditional)
    } else {
      ast = try! parse(sub, .modern)
    }

    // TODO: ... call regex parser
    return .opaque(ast)
  }

}

// TODO: mock up multi-line soon
