public enum CharacterClass {
  // Any character
  case any
  // Character.isDigit
  case digit
  // Character.isHexDigit
  case hexDigit
  // Character.isWhitespace
  case whitespace
  // Character.isLetter or Character.isDigit or Character == "_"
  case word

  public func matches(_ c: Character) -> Bool {
    switch self {
    case .any: return true
    case .digit: return c.isNumber
    case .hexDigit: return c.isHexDigit
    case .whitespace: return c.isWhitespace
    case .word: return c.isLetter || c.isNumber || c == "_"
    }
  }
}

extension CharacterClass {
  init?(_ ch: Character) {
    switch ch {
    case "s": self = .whitespace
    case "d": self = .digit
    case "w": self = .word
      
    default: return nil
    }
  }
}

extension CharacterClass: CustomStringConvertible {
  public var description: String {
    switch self {
    case .any: return "<any>"
    case .digit: return "<digit>"
    case .hexDigit: return "<hex digit>"
    case .whitespace: return "<whitespace>"
    case .word: return "<word>"
    }
  }
}
