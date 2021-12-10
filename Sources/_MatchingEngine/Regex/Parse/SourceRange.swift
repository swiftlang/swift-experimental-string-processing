public typealias SourceRange = Range<Source.Loc>
public typealias SourceLoc = Source.Loc

extension Source {
  var currentLoc: Loc { bounds.lowerBound }
}

extension Source {
  /// An error with source location info
  public struct Error<E: Swift.Error>: Swift.Error {
    public let error: E
    public let sourceRange: SourceRange

    init(_ e: E, _ r: SourceRange) {
      self.error = e
      self.sourceRange = r
    }
  }

  /// A value with source location info
  ///
  /// Note: source location is part of value identity, so that the same
  /// e.g. `Character` appearing twice can be stored in a data structure
  /// distinctly. To ignore source locations, use `.value` directly.
  public struct Value<T: Hashable>: Hashable {
    public var value: T
    public var sourceRange: SourceRange

    public init(_ v: T, _ r: SourceRange) {
      self.value = v
      self.sourceRange = r
    }

    var startLoc: SourceLoc { sourceRange.lowerBound }
    var endLoc: SourceLoc { sourceRange.upperBound }
  }

  // MARK: - recordLoc

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  mutating func recordLoc<T>(
    _ f: (inout Self) throws -> T
  ) throws -> Value<T> {
    let startLoc = currentLoc
    do {
      let result = try f(&self)
      return Value(result, startLoc..<currentLoc)
    } catch let e as Source.Error<ParseError> {
      throw e
    } catch let e as ParseError {
      throw Error(e, startLoc..<currentLoc)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  mutating func recordLoc<T>(
    _ f: (inout Self) throws -> T?
  ) throws -> Value<T>? {
    let startLoc = currentLoc
    do {
      guard let result = try f(&self) else { return nil }
      return Value(result, startLoc..<currentLoc)
    } catch let e as Source.Error<ParseError> {
      throw e
    } catch let e as ParseError {
      throw Error(e, startLoc..<currentLoc)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }

  /// Record source loc before processing and return
  /// or throw the value/error with source locations.
  mutating func recordLoc(
    _ f: (inout Self) throws -> ()
  ) throws {
    let startLoc = currentLoc
    do {
      try f(&self)
    } catch let e as Source.Error<ParseError> {
      throw e
    } catch let e as ParseError {
      throw Error(e, startLoc..<currentLoc)
    } catch {
      fatalError("FIXME: Let's not keep the boxed existential...")
    }
  }
}

// FIXME: comparable-ness doesn't account for source location,
// likely weird corner cases. But it's needed for ranges...
extension Source.Value: Comparable where T: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.value < rhs.value
  }
}
