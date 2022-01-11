extension Source {
  /// The location in the input of a parsed entity, presented as a region over the input
  public struct Location: Hashable {
    public var range: Range<Source.Position>

    public var start: Source.Position { range.lowerBound }

    /// The open end
    public var end: Source.Position { range.upperBound }

    public init(_ r: Range<Source.Position>) {
      self.range = r
    }
    public init<R: RangeExpression>(
      _ r: R, in input: Source
    ) where R.Bound == Source.Position {
      self.init(r.relative(to: input.input))
    }

    /// NOTE: This is a temporary measure to unblock DSL efforts and
    /// incremental source location tracking. This shouldn't be called from
    /// within the parser's module...
    public static var fake: Self {
      .init("".startIndex ..< "".startIndex)
    }
    public var isFake: Bool { self == Self.fake }
    public var isReal: Bool { !isFake }
  }
}
public typealias SourceLocation = Source.Location

extension Source {
  var currentPosition: Position { bounds.lowerBound }
}

extension Source {
  /// An error with source location info
  public struct LocatedError<E: Error>: Error {
    public let error: E
    public let location: SourceLocation

    init(_ e: E, _ r: SourceLocation) {
      self.error = e
      self.location = r
    }
    public init(_ v: E, _ r: Range<Source.Position>) {
      self.error = v
      self.location = Location(r)
    }

  }

  /// Located value: a value wrapped with a source range
  ///
  /// Note: source location is part of value identity, so that the same
  /// e.g. `Character` appearing twice can be stored in a data structure
  /// distinctly. To ignore source locations, use `.value` directly.
  public struct Located<T: Hashable>: Hashable {
    public var value: T
    public var location: SourceLocation

    public init(_ v: T, _ r: SourceLocation) {
      self.value = v
      self.location = r
    }
    public init(_ v: T, _ r: Range<Source.Position>) {
      self.value = v
      self.location = Location(r)
    }

    /// NOTE: This is a temporary measure to unblock DSL efforts and
    /// incremental source location tracking. This shouldn't be called from
    /// within the parser's module...
    public init(faking v: T) {
      // TODO: any way to assert or guarantee this is called
      // externally?
      self.init(v, .fake)
    }

    public func map<U>(_ fn: (T) throws -> U) rethrows -> Located<U> {
      Located<U>(try fn(value), location)
    }
  }
}
extension AST {
  public typealias Located = Source.Located
}

