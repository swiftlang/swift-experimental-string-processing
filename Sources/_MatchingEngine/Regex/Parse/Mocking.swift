
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


enum LexError: Error {
  case endOfString
  case invalidUTF8 // TODO: better range reporting
  case notRegexLiteralStart
}

public func _lexRegex(
  _ start: UnsafeRawPointer
) throws -> (String, SyntaxOptions)? {
  var current = start

  func ascii(_ s: Unicode.Scalar) -> UInt8 {
    assert(s.value <= 0x7F)
    return UInt8(truncatingIfNeeded: s.value)
  }
  func load(offset: Int) -> UInt8 {
    current.load(fromByteOffset: offset, as: UInt8.self)
  }
  func load() -> UInt8 { load(offset: 0) }
  func advance() { current = current.successor() }
  func eat() -> UInt8 {
    defer { advance() }
    return load()
  }

  guard eat() == ascii("'") else {
    throw LexError.notRegexLiteralStart
  }

  let syntax: SyntaxOptions
  let delimiter = eat()
  switch delimiter {
  case ascii("|"): syntax = .modern
  case ascii("/"): syntax = .traditional
  default: return nil
  }

  let contentsStart = current
  let count: Int = try {
    while true {
      switch load() {
      case 0: throw LexError.endOfString
      case ascii("\\"):
        // Skip next byte
        advance()
        advance()
      case delimiter:
        if load(offset: 1) == ascii("'") {
          return current - contentsStart
        }
        advance()

      default: advance()
      }
    }
  }()

  let contents = UnsafeRawBufferPointer(
    start: contentsStart, count: count)
  let s = String(decoding: contents, as: UTF8.self)

  guard s.utf8.elementsEqual(contents) else {
    throw LexError.invalidUTF8
  }

  return (s, syntax)
}
