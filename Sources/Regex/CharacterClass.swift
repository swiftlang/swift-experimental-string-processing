public struct CharacterClass: Hashable {
  /// The actual character class to match.
  var cc: Representation
  
  /// Whether this character class matches against an inverse,
  /// e.g \D, \S, [^abc].
  var isInverted: Bool = false

  public enum Representation: Hashable {
    /// Any single element, re the current matching semantics
    case any
    /// Any grapheme cluster, even when in a non-grapheme-cluster mode
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

    public func matches(in str: String, at i: String.Index, options: REOptions) -> String.Index? {
      print("SetOperation", str, str[i...], i, lhs, rhs)
      let lhsMatch = lhs.matches(in: str, at: i, options: options)
      switch (op, lhsMatch) {
      case (.intersection, nil), (.subtraction, nil):
        return nil
      case (.symmetricDifference, nil):
        return rhs.matches(in: str, at: i, options: options)
      case (.intersection, let lhsMatch?):
        guard let rhsMatch = rhs.matches(in: str, at: i, options: options)
          else { return nil }
        print(lhsMatch, rhsMatch)
        return min(lhsMatch, rhsMatch)
      case (.subtraction, let lhsMatch?), (.symmetricDifference, let lhsMatch?):
        return nil == rhs.matches(in: str, at: i, options: options)
          ? lhsMatch
          : nil
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

    public func matches(in str: String, at i: String.Index, options: REOptions) -> String.Index? {
      guard #available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *) else { fatalError() }
      switch options {
      case let x where x.contains(.unicodeScalarSemantics):
        switch self {
        case .character(let c):
          return str.unicodeScalars[i...].eat(c.unicodeScalars)
        case .range(let range):
          if !str[i].unicodeScalars.lexicographicallyPrecedes(range.lowerBound.unicodeScalars)
              && str[i].unicodeScalars.lexicographicallyPrecedes(range.upperBound.unicodeScalars) {
            // TODO: Should this be a Unicode scalar calculation? To what point?
            return str.index(after: i)
          } else {
            return nil
          }
        case .characterClass(let custom):
          return custom.matches(in: str, at: str.startIndex, options: options)
        case .setOperation(let op):
          return op.matches(in: str, at: i, options: options)
        }

      case let x where x.contains(.utf8Semantics):
        switch self {
        case .character(let c):
          return str.utf8[i...].eat(c.utf8)
        case .range(let range):
          if !str[i].utf8.lexicographicallyPrecedes(range.lowerBound.utf8)
              && str[i].utf8.lexicographicallyPrecedes(range.upperBound.utf8) {
            // TODO: Should this be a UTF-8 calculation? To what point?
            return str.index(after: i)
          } else {
            return nil
          }
        case .characterClass(let custom):
          return custom.matches(in: str, at: str.startIndex, options: options)
        case .setOperation(let op):
          return op.matches(in: str, at: i, options: options)
        }
        
      default:
        let nextIndex = str.index(after: i)
        switch self {
        case .character(let c):
          return str[i] == c ? nextIndex : nil
        case .range(let range):
          return range.contains(str[i]) ? nextIndex : nil
        case .characterClass(let custom):
          return custom.matches(in: str, at: i, options: options)
        case .setOperation(let op):
          return op.matches(in: str, at: i, options: options)
        }
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
      case .custom(let set):
        if let end = set.lazy.compactMap({ $0.matches(in: str, at: i, options: options) }).first {
          matched = true
          nextIndex = end
        } else {
          matched = false
        }
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
      case .custom(let set):
        if let end = set.lazy.compactMap({ $0.matches(in: str, at: i, options: options) }).first {
          matched = true
          nextIndex = end
        } else {
          matched = false
        }
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? nextIndex : nil

    default:
      let c = str[i]
      var nextIndex = str.index(after: i)
      var matched: Bool
      switch cc {
      case .any, .anyGraphemeCluster: matched = true
      case .digit: matched = c.isNumber
      case .hexDigit: matched = c.isHexDigit
      case .whitespace: matched = c.isWhitespace
      case .word: matched = c.isLetter || c.isNumber || c == "_"
      case .custom(let set):
        if let end = set.lazy.compactMap({ $0.matches(in: str, at: i, options: options) }).first {
          matched = true
          nextIndex = end
        } else {
          matched = false
        }
      }
      if isInverted {
        matched.toggle()
      }
      return matched ? nextIndex : nil
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
