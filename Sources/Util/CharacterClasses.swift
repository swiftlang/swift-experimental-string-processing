extension Character {
  internal var isSingleScalar: Bool {
    unicodeScalars.index(after: unicodeScalars.startIndex)
      == unicodeScalars.endIndex
  }
  
  internal var firstScalar: Unicode.Scalar {
    unicodeScalars.first.unsafelyUnwrapped
  }
}

// MARK: General_Category groups

extension Unicode.GeneralCategory {
  /// A Boolean value indicating whether this category is part of the
  /// "Letter" general category group.
  public var isLetter: Bool {
    switch self {
    case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter,
        .modifierLetter, .otherLetter:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Cased_Letter" general category group.
  public var isCasedLetter: Bool {
    switch self {
    case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Mark" general category group.
  public var isMark: Bool {
    switch self {
    case .nonspacingMark, .spacingMark, .enclosingMark:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Number" general category group.
  public var isNumber: Bool {
    switch self {
    case .decimalNumber, .letterNumber, .otherNumber:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Punctuation" general category group.
  public var isPunctuation: Bool {
    switch self {
    case .connectorPunctuation, .dashPunctuation,
        .openPunctuation, .closePunctuation,
        .initialPunctuation, .finalPunctuation, .otherPunctuation:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Symbol" general category group.
  public var isSymbol: Bool {
    switch self {
    case .mathSymbol, .currencySymbol, .modifierSymbol, .otherSymbol:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Separator" general category group.
  public var isSeparator: Bool {
    switch self {
    case .spaceSeparator, .lineSeparator, .paragraphSeparator:
      return true
    default:
      return false
    }
  }
  
  /// A Boolean value indicating whether this category is part of the
  /// "Other" general category group.
  public var isOther: Bool {
    switch self {
    case .control, .format, .surrogate, .privateUse, .unassigned:
      return true
    default:
      return false
    }
  }
}

// MARK: Decimal digits; \d

extension Character {
  /// A Boolean value indicating whether this character represents
  /// a decimal digit.
  ///
  /// Decimal digits are comprised of a single Unicode scalar that has a
  /// `numericType` property equal to `.decimal`. This includes the digits
  ///  from the ASCII range, from the _Halfwidth and Fullwidth Forms_ Unicode
  ///  block, as well as digits in some scripts, like `DEVANAGARI DIGIT NINE`
  ///  (U+096F).
  ///
  /// Decimal digits are a subset of whole numbers, see `isWholeNumber`.
  ///
  /// To get the character's value, use the `decimalDigitValue` property.
  public var isDecimalDigit: Bool {
    isSingleScalar && firstScalar.isDecimalDigit
  }

  /// The numeric value this character represents, if it is a decimal digit.
  ///
  /// Decimal digits are comprised of a single Unicode scalar that has a
  /// `numericType` property equal to `.decimal`. This includes the digits
  ///  from the ASCII range, from the _Halfwidth and Fullwidth Forms_ Unicode
  ///  block, as well as digits in some scripts, like `DEVANAGARI DIGIT NINE`
  ///  (U+096F).
  ///
  /// Decimal digits are a subset of whole numbers, see `wholeNumberValue`.
  ///
  ///     let chars: [Character] = ["1", "९", "A"]
  ///     for ch in chars {
  ///         print(ch, "-->", ch.decimalDigitValue)
  ///     }
  ///     // Prints:
  ///     // 1 --> Optional(1)
  ///     // ९ --> Optional(9)
  ///     // A --> nil
  public var decimalDigitValue: Int? {
    guard isDecimalDigit else { return nil }
    return wholeNumberValue
  }
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered
  /// a decimal digit.
  ///
  /// Any Unicode scalar that has a `numericType` property equal to `.decimal`
  /// is considered a decimal digit. This includes the digits from the ASCII
  /// range, from the _Halfwidth and Fullwidth Forms_  Unicode block, as well
  ///  as digits in some scripts, like `DEVANAGARI DIGIT NINE` (U+096F).
  public var isDecimalDigit: Bool {
    properties.numericType == .decimal
  }
}

// MARK: Word characters; \w

extension Character {
  /// A Boolean value indicating whether this character is considered
  /// a "word" character.
  ///
  /// See `Unicode.Scalar.isWordCharacter`.
  public var isWordCharacter: Bool {
    firstScalar.isWordCharacter
  }
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered
  /// a "word" character.
  ///
  /// Any Unicode scalar that has one of the Unicode properties
  /// `Alphabetic`, `Digit`, or `Join_Control`, or is in the
  /// general category `Mark` or `Connector_Punctuation`.
  public var isWordCharacter: Bool {
    properties.isAlphabetic || isDecimalDigit || properties.isJoinControl
      || properties.generalCategory.isMark
      || properties.generalCategory == .connectorPunctuation
  }
}

// MARK: Whitespace; \s

extension Character {
  /// A Boolean value indicating whether this character is considered
  /// horizontal whitespace.
  ///
  /// All characters with an initial Unicode scalar in the general
  /// category `Zs`/`Space_Separator`, or the control character
  /// `CHARACTER TABULATION` (U+0009), are considered horizontal
  /// whitespace.
  public var isHorizontalWhitespace: Bool {
    firstScalar.isHorizontalWhitespace
  }
  
  /// A Boolean value indicating whether this scalar is considered
  /// vertical whitespace.
  ///
  /// All characters with an initial Unicode scalar in the general
  /// category `Zl`/`Line_Separator`, or the following control
  /// characters, are considered vertical whitespace (see below)
  public var isVerticalWhitespace: Bool {
    firstScalar.isVerticalWhitespace
  }
}

extension Unicode.Scalar {
  /// A Boolean value indicating whether this scalar is considered
  /// whitespace.
  ///
  /// All Unicode scalars with the derived `White_Space` property are
  /// considered whitespace, including:
  ///
  /// - `CHARACTER TABULATION` (U+0009)
  /// - `LINE FEED (LF)` (U+000A)
  /// - `LINE TABULATION` (U+000B)
  /// - `FORM FEED (FF)` (U+000C)
  /// - `CARRIAGE RETURN (CR)` (U+000D)
  /// - `NEWLINE (NEL)` (U+0085)
  public var isWhitespace: Bool {
    properties.isWhitespace
  }
  
  /// A Boolean value indicating whether this scalar is considered
  /// horizontal whitespace.
  ///
  /// All Unicode scalars with the general category
  /// `Zs`/`Space_Separator`, along with the control character
  /// `CHARACTER TABULATION` (U+0009), are considered horizontal
  /// whitespace.
  public var isHorizontalWhitespace: Bool {
    self == .horizontalTab || properties.generalCategory == .spaceSeparator
  }

  /// A Boolean value indicating whether this scalar is considered
  /// vertical whitespace.
  ///
  /// All Unicode scalars with the general category
  /// `Zl`/`Line_Separator`, along with the following control
  /// characters, are considered vertical whitespace:
  ///
  /// - `LINE FEED (LF)` (U+000A)
  /// - `LINE TABULATION` (U+000B)
  /// - `FORM FEED (FF)` (U+000C)
  /// - `CARRIAGE RETURN (CR)` (U+000D)
  /// - `NEWLINE (NEL)` (U+0085)
  public var isVerticalWhitespace: Bool {
    (0x0A...0x0D).contains(value) || value == 0x85
      || properties.generalCategory == .lineSeparator
  }
}

// MARK: Control characters

extension Character {
  /// A horizontal tab character, `CHARACTER TABULATION` (U+0009).
  public static var horizontalTab: Character {
    .init(Unicode.Scalar.horizontalTab)
  }

  /// A carriage return character, `CARRIAGE RETURN (CR)` (U+000D).
  public static var carriageReturn: Character {
    .init(Unicode.Scalar.carriageReturn)
  }

  /// A line feed character, `LINE FEED (LF)` (U+000A).
  public static var lineFeed: Character { .init(Unicode.Scalar.lineFeed) }

  /// A form feed character, `FORM FEED (FF)` (U+000C).
  public static var formFeed: Character { .init(Unicode.Scalar.formFeed) }

  /// A NULL character, `NUL` (U+0000).
  public static var null: Character { .init(Unicode.Scalar.null) }

  /// An escape control character, `ESC` (U+001B).
  public static var escape: Character { .init(Unicode.Scalar.escape) }

  /// A bell character, `BEL` (U+0007).
  public static var bell: Character { .init(Unicode.Scalar.bell) }

  /// A backspace character, `BS` (U+0008).
  public static var backspace: Character { .init(Unicode.Scalar.backspace) }

  /// A combined carriage return and line feed as a single character denoting
  /// end-of-line.
  public static var carriageReturnLineFeed: Character { "\r\n" }

  /// Returns a control character with the given value, Control-`x`.
  ///
  /// This method returns a value only when you pass a letter in
  /// the ASCII range as `x`:
  ///
  ///     if let ch = Character.control("G") {
  ///         print("'ch' is a bell character", ch == Character.bell)
  ///     } else {
  ///         print("'ch' is not a control character")
  ///     }
  ///     // Prints "'ch' is a bell character: true"
  ///
  /// - Parameter x: An upper- or lowercase letter to derive
  ///   the control character from.
  /// - Returns: Control-`x` if `x` is in the pattern `[a-zA-Z]`;
  ///   otherwise, `nil`.
  public static func control(_ x: Unicode.Scalar) -> Character? {
    Unicode.Scalar.control(x).map(Character.init)
  }
  
  /// A Boolean value indicating whether this character represents
  /// a control character.
  ///
  /// Control characters are a single Unicode scalar with the
  /// general category `Cc`/`Control` or the CR-LF pair (`\r\n`).
  public var isControl: Bool {
    firstScalar.properties.generalCategory == .control
      || self == .carriageReturnLineFeed
  }
}

extension Unicode.Scalar {
  /// A horizontal tab character, `CHARACTER TABULATION` (U+0009).
  public static var horizontalTab: Unicode.Scalar { .init(0x09) }

  /// A carriage return character, `CARRIAGE RETURN (CR)` (U+000D).
  public static var carriageReturn: Unicode.Scalar { .init(0x0D) }

  /// A line feed character, `LINE FEED (LF)` (U+000A).
  public static var lineFeed: Unicode.Scalar { .init(0x0A) }

  /// A form feed character, `FORM FEED (FF)` (U+000C).
  public static var formFeed: Unicode.Scalar { .init(0x0C) }

  /// A NULL character, `NUL` (U+0000).
  public static var null: Unicode.Scalar { .init(0x00) }

  /// An escape control character, `ESC` (U+001B).
  public static var escape: Unicode.Scalar { .init(0x1B) }

  /// A bell character, `BEL` (U+0007).
  public static var bell: Unicode.Scalar { .init(0x07) }

  /// A backspace character, `BS` (U+0008).
  public static var backspace: Unicode.Scalar { .init(0x08) }

  /// Returns a control character with the given value, Control-`x`.
  ///
  /// This method returns a value only when you pass a letter in
  /// the ASCII range as `x`:
  ///
  ///     if let ch = Character.control("G") {
  ///         print("'ch' is a bell character", ch == Character.bell)
  ///     } else {
  ///         print("'ch' is not a control character")
  ///     }
  ///     // Prints "'ch' is a bell character: true"
  ///
  /// - Parameter x: An upper- or lowercase letter to derive
  ///   the control character from.
  /// - Returns: Control-`x` if `x` is in the pattern `[a-zA-Z]`;
  ///   otherwise, `nil`.
  public static func control(_ x: Unicode.Scalar) -> Unicode.Scalar? {
    guard ("a"..."z").contains(x) || ("A"..."Z").contains(x) else { return nil }
    return .init(x.value % 0x40)
  }
  
  /// A Boolean value indicating whether this scalar represents
  /// a control character.
  ///
  /// Control characters have the general category `Cc`/`Control`.
  public var isControl: Bool {
    properties.generalCategory == .control
  }
}

