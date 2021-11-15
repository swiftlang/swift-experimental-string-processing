
public struct SyntaxOptions: OptionSet {
  public var rawValue: UInt
  public init(rawValue: UInt) { self.rawValue = rawValue }

  private init(_ rawValue: UInt) {
    self.init(rawValue: rawValue)
  }

  public init() { self.init(0) }

  /// `a \. b` == `a\.b`
  public static var nonSemanticWhitespace: Self { Self(1 << 0) }

  /// `a "." b` == `a\Q.\Eb`
  public static var swiftyQuotes:          Self { Self(1 << 1) }

  /// `a /* comment */ b` == `a(?#. comment )b`
  public static var swiftyComments:        Self { Self(1 << 2) }

/*
  /// `a{3..<10}` == `a{3,9}`
  public static var swiftyRanges:        Self { Self(1 << 3) }

  /// `[[:digit:]]*` == `\d*` == `<digit>*`
 public static var consumers:            Self { Self(1 << 4) }

 */

  public static var traditional: Self { Self() }

  public static var modern: Self {
    [.nonSemanticWhitespace, .swiftyQuotes, .swiftyComments]
  }

  public var ignoreWhitespace: Bool {
    contains(.nonSemanticWhitespace)
  }
}


