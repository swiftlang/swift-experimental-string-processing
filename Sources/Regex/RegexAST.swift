/// A regex abstract syntax tree
public enum AST: Hashable {
  indirect case alternation([AST]) // alternation(AST, AST?)
  indirect case concatenation([AST])
  indirect case group(AST)
  indirect case capturingGroup(AST, transform: CaptureTransform? = nil)

  // Post-fix modifiers
  indirect case many(AST)
  indirect case zeroOrOne(AST)
  indirect case oneOrMore(AST)

  // Lazy versions of quantifiers
  indirect case lazyMany(AST)
  indirect case lazyZeroOrOne(AST)
  indirect case lazyOneOrMore(AST)

  case character(Character)
  case unicodeScalar(UnicodeScalar)
  case characterClass(CharacterClass)
  case any
  case empty
}

extension AST: CustomStringConvertible {
  public var description: String {
    switch self {
    case .alternation(let rest): return ".alt(\(rest))"
    case .concatenation(let rest): return ".concat(\(rest))"
    case .group(let rest): return ".group(\(rest))"
    case .capturingGroup(let rest, let transform):
      return """
          .capturingGroup(\(rest), transform: \(transform.map(String.init(describing:)) ?? "nil")
          """
    case .many(let rest): return ".many(\(rest))"
    case .zeroOrOne(let rest): return ".zeroOrOne(\(rest))"
    case .oneOrMore(let rest): return ".oneOrMore(\(rest))"
    case .lazyMany(let rest): return ".lazyMany(\(rest))"
    case .lazyZeroOrOne(let rest): return ".lazyZeroOrOne(\(rest))"
    case .lazyOneOrMore(let rest): return ".lazyOneOrMore(\(rest))"
    case .character(let c): return c.halfWidthCornerQuoted
    case .unicodeScalar(let u): return u.halfWidthCornerQuoted
    case .characterClass(let cc): return ".characterClass(\(cc))"
    case .any: return ".any"
    case .empty: return "".halfWidthCornerQuoted
    }
  }
}
