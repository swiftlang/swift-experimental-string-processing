public struct CharacterClass: Hashable {
  /// The actual character class to match.
  var cc: Representation
  
  /// Whether this character class matches against an inverse,
  /// e.g \D, \S, [^abc].
  var isInverted: Bool = false

  public enum Representation: Hashable {
    /// Any single elements
    case any
    /// Any grapheme cluster, even in non-grapheme-cluster mode
    case anyGraphemeCluster
    /// Character.isDigit
    case digit
    /// Character.isHexDigit
    case hexDigit
    /// Character.isWhitespace
    case whitespace
    /// Character.isLetter or Character.isDigit or Character == "_"
    case word
    /// One of the custom character set.
    case custom([CharacterSetComponent])
  }

  public enum SetOperator: Hashable {
    case intersection
    case subtraction
    case symmetricDifference
  }

  /// A binary set operation that forms a character class component.
  public struct SetOperation: Hashable {
    var lhs: CharacterSetComponent
    var op: SetOperator
    var rhs: CharacterSetComponent

    public func matches(_ c: Character) -> Bool {
      switch op {
      case .intersection:
        return lhs.matches(c) && rhs.matches(c)
      case .subtraction:
        return lhs.matches(c) && !rhs.matches(c)
      case .symmetricDifference:
        return lhs.matches(c) != rhs.matches(c)
      }
    }
  }

  public enum CharacterSetComponent: Hashable {
    case character(Character)
    case range(ClosedRange<Character>)

    /// A nested character class.
    case characterClass(CharacterClass)

    /// A binary set operation of character class components.
    indirect case setOperation(SetOperation)

    public static func setOperation(
      lhs: CharacterSetComponent, op: SetOperator, rhs: CharacterSetComponent
    ) -> CharacterSetComponent {
      .setOperation(.init(lhs: lhs, op: op, rhs: rhs))
    }

    public func matches(_ character: Character) -> Bool {
      switch self {
      case .character(let c): return c == character
      case .range(let range): return range.contains(character)
      case .characterClass(let custom):
        let str = String(character)
        return custom.matches(in: str, at: str.startIndex) != nil
      case .setOperation(let op): return op.matches(character)
      }
    }
  }

  public enum MatchLevel {
    /// Match at the extended grapheme cluster level.
    case graphemeCluster
    /// Match at the Unicode scalar level.
    case unicodeScalar
    /// Match at the UTF-8 code unit level.
    case utf8CodeUnit
  }

  /// Returns the character class with the isInverted property set to a given
  /// value.
  public func withInversion(_ invertion: Bool) -> Self {
    var copy = self
    copy.isInverted = invertion
    return copy
  }

  /// Returns the inverse character class.
  public var inverted: Self {
    return withInversion(!isInverted)
  }
  
  /// Returns the end of the match of this character class in `str`, if
  /// it matches.
  public func matches(in str: String, at i: String.Index, options: REOptions) -> String.Index? {
    switch options {
    case let x where x.contains(.unicodeScalarSemantics):
      let c = str.unicodeScalars[i]
      var nextIndex = str.unicodeScalars.index(after: i)
      var matched: Bool
      switch cc {
      case .any: matched = true
      case .anyGraphemeCluster:
        matched = true
        nextIndex = str.index(after: i)
      case .digit: matched = c.properties.numericType != nil
      case .hexDigit: matched = Character(c).isHexDigit
      case .whitespace: matched = c.properties.isWhitespace
      case .word: matched = c.properties.isAlphabetic || c == "_"
      case .custom: fatalError("Not supported")
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? nextIndex : nil

    case let x where x.contains(.utf8Semantics):
      let byte = str.utf8[i]
      var nextIndex = str.unicodeScalars.index(after: i)
      var matched: Bool
      switch cc {
      case .any: matched = true
      case .anyGraphemeCluster:
        // TODO: Is this the right behavior? This yields the start of the next
        // character, even if `i` isn't character aligned, so the user may get
        // only a partial character / the resulting character may be a result
        // of rounding the starting index down to the previous character
        // boundary.
        matched = true
        nextIndex = str.index(after: i)
      case .digit:
        matched = (0x30...0x39).contains(byte)
      case .hexDigit:
        matched = (0x30...0x39).contains(byte)
          || (0x41...0x46).contains(byte)
          || (0x61...0x66).contains(byte)
      case .whitespace:
        matched = (0x09...0x0d).contains(byte) || 0x20 == byte
      case .word:
        matched = (0x41...0x5a).contains(byte) || (0x61...0x7a).contains(byte)
          || 0x5f == byte
      case .custom: fatalError("Not supported")
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? nextIndex : nil

    default:
      let c = str[i]
      var matched: Bool
      switch cc {
      case .any, .anyGraphemeCluster: matched = true
      case .digit: matched = c.isNumber
      case .hexDigit: matched = c.isHexDigit
      case .whitespace: matched = c.isWhitespace
      case .word: matched = c.isLetter || c.isNumber || c == "_"
      case .custom(let set):
        matched = set.any { $0.matches(c) }
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? str.index(after: i) : nil
    }
  }
}

extension CharacterClass {
  public static var any: CharacterClass {
    .init(cc: .any)
  }
  
  public static var whitespace: CharacterClass {
    .init(cc: .whitespace)
  }
  
  public static var digit: CharacterClass {
    .init(cc: .digit)
  }
  
  public static var hexDigit: CharacterClass {
    .init(cc: .hexDigit)
  }
  
  public static var word: CharacterClass {
    .init(cc: .word)
  }
  
  public static var anyGraphemeCluster: CharacterClass {
    .init(cc: .anyGraphemeCluster)
  }
  
  public static func custom(
    _ components: [CharacterSetComponent]
  ) -> CharacterClass {
    .init(cc: .custom(components))
  }
  
  init?(_ ch: Character) {
    switch ch {
    case "s": self = .whitespace
    case "d": self = .digit
    case "w": self = .word
    case "S", "D", "W":
      self = Self(Character(ch.lowercased()))!.inverted
    case "X": self = .anyGraphemeCluster
      
    default: return nil
    }
  }
}

extension CharacterClass.CharacterSetComponent: CustomStringConvertible {
  public var description: String {
    switch self {
    case .range(let range): return "<range \(range)>"
    case .character(let character): return "<character \(character)>"
    case .characterClass(let custom): return "\(custom)"
    case .setOperation(let op): return "<\(op.lhs) \(op.op) \(op.rhs)>"
    }
  }
}

extension CharacterClass.Representation: CustomStringConvertible {
  public var description: String {
    switch self {
    case .any: return "<any>"
    case .anyGraphemeCluster: return "<any char>"
    case .digit: return "<digit>"
    case .hexDigit: return "<hex digit>"
    case .whitespace: return "<whitespace>"
    case .word: return "<word>"
    case .custom(let set): return "<custom \(set)>"
    }
  }
}

extension CharacterClass: CustomStringConvertible {
  public var description: String {
    return "\(isInverted ? "not " : "")\(cc)"
  }
}
