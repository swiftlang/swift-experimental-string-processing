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

    /// A "fake" location, sometimes useful for tooling purposes
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
  public struct Err<E: Error>: Error {
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
  public struct Loc<T: Hashable>: Hashable {
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
    public init(faking v: T) {
      self.init(v, .fake)
    }

    var start: Source.Position { location.start }
    var endLoc: Source.Position { location.end }
  }
}
extension AST {
  public typealias Loc = Source.Loc
}

extension Source {
  // MARK: - recordLoc

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  mutating func recordLoc<T>(
    _ f: (inout Self) throws -> T
  ) throws -> Loc<T> {
    let start = currentPosition
    do {
      let result = try f(&self)
      return Loc(result, Location(start..<currentPosition))
    } catch let e as Err<ParseError> {
      throw e
    } catch let e as ParseError {
      throw Err(e, Location(start..<currentPosition))
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  mutating func recordLoc<T>(
    _ f: (inout Self) throws -> T?
  ) throws -> Loc<T>? {
    let start = currentPosition
    do {
      guard let result = try f(&self) else { return nil }
      return Loc(result, start..<currentPosition)
    } catch let e as Source.Err<ParseError> {
      throw e
    } catch let e as ParseError {
      throw Err(e, start..<currentPosition)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  mutating func recordLoc(
    _ f: (inout Self) throws -> ()
  ) throws {
    let start = currentPosition
    do {
      try f(&self)
    } catch let e as Source.Err<ParseError> {
      throw e
    } catch let e as ParseError {
      throw Err(e, start..<currentPosition)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }
}
