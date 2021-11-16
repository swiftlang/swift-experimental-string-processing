
public struct SyntaxOptions: OptionSet {
  public var rawValue: UInt
  public init(rawValue: UInt) { self.rawValue = rawValue }

  private init(_ rawValue: UInt) {
    self.init(rawValue: rawValue)
  }

  public init() { self.init(0) }

  /// `'a \. b' == '/a\.b/'`
  public static var nonSemanticWhitespace: Self { Self(1 << 0) }

  /// `'a "." b' == '/a\Q.\Eb/'`
  ///
  /// NOTE: Currently, this means we have raw quotes.
  /// Better would be to have real Swift string delimiter parsing logic.
  public static var modernQuotes: Self { Self(1 << 1) }

  /// `'a /* comment */ b' == '/a(?#. comment )b/'`
  ///
  /// NOTE: traditional comments are not nested. Currently, we are neither.
  /// Traditional comments can't have `)`, not even escaped in them either, we
  /// can. Traditional comments can have `*/` in them, we can't without
  /// escaping. We don't currently do escaping.
  public static var modernComments: Self { Self(1 << 2) }

  /// ```
  ///   'a{n...m}' == '/a{n,m}/
  ///   'a{n..<m}' == '/a{n,m-1}/'
  ///   'a{n...}'  == '/a{n,}/'
  ///   'a{...m}'  == '/a{,m}/'
  ///   'a{..<m}'  == '/a{,m-1}/'
  /// ```
  public static var modernRanges: Self { Self(1 << 3) }

  /*
  /// `(name: .*)` == `(?<name>.*)`
  ///  `(_: .*)` == `(?:.*)`
  public static var modernCaptures

 /// `<digit>*` == `[[:digit:]]*` == `\d*`
 public static var modernConsumers

 */

  public static var traditional: Self { Self(0) }

  public static var modern: Self { Self(~0) }

  public var ignoreWhitespace: Bool {
    contains(.nonSemanticWhitespace)
  }
}


