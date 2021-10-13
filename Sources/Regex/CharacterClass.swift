public struct CharacterClass: Hashable {
  /// The actual character class to match.
  var cc: Representation
  
  /// The level (character or Unicode scalar) at which to match.
  var matchLevel: MatchLevel
  
  public enum Representation {
    /// Any character
    case any
    /// Character.isDigit
    case digit
    /// Character.isHexDigit
    case hexDigit
    /// Character.isWhitespace
    case whitespace
    /// Character.isLetter or Character.isDigit or Character == "_"
    case word
  }
  
  public enum MatchLevel {
    /// Match at the extended grapheme cluster level.
    case character
    /// Match at the Unicode scalar level.
    case unicodeScalar
  }

  /// Returns the end of the match of this character class in `str`, if
  /// it matches.
  public func matches(in str: String, at i: String.Index) -> String.Index? {
    switch matchLevel {
    case .character:
      let c = str[i]
      let next = str.index(after: i)
      switch cc {
      case .any: return next
      case .digit: return c.isNumber ? next : nil
      case .hexDigit: return c.isHexDigit ? next : nil
      case .whitespace: return c.isWhitespace ? next : nil
      case .word: return c.isLetter || c.isNumber || c == "_"
        ? next : nil
      }
    case .unicodeScalar:
      let c = str.unicodeScalars[i]
      let next = str.unicodeScalars.index(after: i)
      switch cc {
      case .any: return next
      case .digit: return c.properties.numericType != nil ? next : nil
      case .hexDigit: return Character(c).isHexDigit ? next : nil
      case .whitespace: return c.properties.isWhitespace ? next : nil
      case .word: return c.properties.isAlphabetic || c == "_" ? next : nil
      }
    }
  }
}

extension CharacterClass {
  public static var any: CharacterClass {
    .init(cc: .any, matchLevel: .character)
  }
  
  public static var whitespace: CharacterClass {
    .init(cc: .whitespace, matchLevel: .character)
  }
  
  public static var digit: CharacterClass {
    .init(cc: .digit, matchLevel: .character)
  }
  
  public static var hexDigit: CharacterClass {
    .init(cc: .hexDigit, matchLevel: .character)
  }
  
  public static var word: CharacterClass {
    .init(cc: .word, matchLevel: .character)
  }
  
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
    switch cc {
    case .any: return "<any>"
    case .digit: return "<digit>"
    case .hexDigit: return "<hex digit>"
    case .whitespace: return "<whitespace>"
    case .word: return "<word>"
    }
  }
}
