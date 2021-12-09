
// MARK: - Error and Value

extension Source {
  /// An error with source location info
  struct Error<E: Swift.Error>: Swift.Error {
    let error: E
    let sourceRange: SourceRange

    init(_ e: E, _ r: SourceRange) {
      self.error = e
      self.sourceRange = r
    }
  }

  /// A value with source location info
  struct Value<T> {
    var value: T
    var sourceRange: SourceRange

    init(_ v: T, _ r: SourceRange) {
      self.value = v
      self.sourceRange = r
    }
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
}

// MARK: - Simple expects

extension Source {
  /// Throws an expected character error if not matched
  mutating func expect(_ c: Character) throws {
    _ = try recordLoc { src in
      guard src.tryEat(c) else {
        throw ParseError.expected(String(c))
      }
    }
  }

  /// Throws an expected character error if not matched
  mutating func expect<C: Collection>(sequence c: C) throws
  where C.Element == Character
  {
    _ = try recordLoc { src in
      guard src.tryEat(sequence: c) else {
        throw ParseError.expected(String(c))
      }
    }
  }

  /// Throws an unexpected end of input error if not matched
  ///
  /// Note: much of the time, but not always, we can vend a more specific error.
  mutating func expectNonEmpty() throws {
    _ = try recordLoc { src in
      if src.isEmpty { throw ParseError.unexpectedEndOfInput }
    }
  }

  /// Throws an expected ASCII character error if not matched
  mutating func expectASCII() throws -> Value<Character> {
    try recordLoc { src in
      guard let c = src.peek() else {
        throw ParseError.unexpectedEndOfInput
      }
      guard c.isASCII else {
        throw ParseError.expectedASCII(c)
      }
      src.eat(asserting: c)
      return c
    }
  }
}

// MARK: - Parse errors

enum ParseError: Error, Hashable {
  // TODO: I wonder if it makes sense to store the string.
  // This can make equality weird.

  case numberOverflow(String)
  case expectedDigits(String, expecting: ClosedRange<Int>)
  case tooManyDigits(String)

  case expectedHexNumber(String)

  // Expected the given character or string
  case expected(String)

  // Expected something, anything really
  case unexpectedEndOfInput

  // Something happened, fall-back for now
  case misc(String)

  case expectedASCII(Character)

  case expectedCustomCharacterClassMembers
  case invalidCharacterClassRangeOperand

  case invalidPOSIXSetName(String)
  case emptyProperty
}


