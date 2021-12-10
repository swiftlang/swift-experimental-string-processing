import _MatchingEngine

/*

 Inspired by "Staged Parser Combinators for Efficient Data Processing" by Jonnalagedda et al.

 */

// Stages are represented as nested namespaces that bind generic
// types
public enum Combinators {
  public enum BindElement<Element: Comparable & Hashable> {
    public enum BindPosition<Position: Comparable & Hashable> {
      // TODO: it's not clear if error is bound earlier or
      // later than the collection...
      public enum BindError<Err: Error & Hashable> {
      }

      public enum BindInput<Input: Collection>
      where Input.Element == Element, Input.Index == Position {

      }
    }
  }
}

extension Combinators.BindElement.BindPosition.BindError {
  public struct ParseResult<T: Hashable>: Hashable {
    var next: Position
    var result: Result<T, Err>
  }

  public struct Parser<T: Hashable> {
    let apply: (Position) throws -> ParseResult<T>

    init(_ f: @escaping (Position) throws -> ParseResult<T>) {
      self.apply = f
    }
  }
}

// Helpers
extension
  Combinators.BindElement.BindPosition.BindError.ParseResult
{
  public typealias ParseResult = Combinators.BindElement<Element>.BindPosition<Position>.BindError<Err>.ParseResult

  public var value: T? {
    switch result {
    case .failure(_): return nil
    case .success(let v): return v
    }
  }

  public var isError: Bool { value == nil }

  // Paper does this, not sure if we want to distinguish
  // successful empty parses from error parses, and if
  // we want error recovery to involve skipping...
  public var isEmpty: Bool { isError }

  public func mapValue<U: Hashable>(_ f: (T) -> U) -> ParseResult<U> {
    ParseResult(next: next, result: result.map(f))
  }

  public func flatMap<U: Hashable>(
    _ f: (Position, T) throws -> ParseResult<U>
  ) rethrows -> ParseResult<U> {
    switch result {
    case .success(let v):
      return try f(next, v)
    case .failure(let e):
      return ParseResult(next: next, result: .failure(e))
    }
  }

  public var successSelf: Self? {
    guard !isError else { return nil }
    return self
  }

  public var errorSelf: Self? {
    guard isError else { return nil }
    return self
  }
}


// Combinators
extension Combinators.BindElement.BindPosition.BindError.Parser {
  public typealias Parser = Combinators.BindElement<Element>.BindPosition<Position>.BindError<Err>.Parser
  public typealias ParseResult = Combinators.BindElement<Element>.BindPosition<Position>.BindError<Err>.ParseResult

  // Backtracking alternation
  public func or(_ rhs: Self) -> Self {
    Self { pos in
      try self.apply(pos).successSelf ?? rhs.apply(pos)
    }
  }

  public func map<U: Hashable>(
    _ f: @escaping (T) -> U
  ) -> Parser<U> {
    Parser { pos in
      try self.apply(pos).mapValue(f)
    }
  }

  public func flatMap<U: Hashable>(
    _ f: @escaping (T) -> Parser<U>
  ) -> Parser<U> {
    return Parser { pos in
      try self.apply(pos).flatMap { (p, v) in
        try f(v).apply(p)
      }
    }
  }

  public func chain<U: Hashable, V: Hashable>(
    _ rhs: Parser<U>, combining f: @escaping (T, U) -> V
  ) -> Parser<V> {
    Parser { pos in
      try self.apply(pos).flatMap { p, t in
        try rhs.apply(p).mapValue { u in f(t, u) }
      }
    }
  }


  public func chain<U: Hashable>(
    _ rhs: Parser<U>
  ) -> Parser<Pair<T, U>> {
    self.chain(rhs) { Pair($0, $1) }
  }

  public func chainLeft<U: Hashable>(
    _ rhs: Parser<U>
  ) -> Parser<T> {
    self.chain(rhs) { r, _ in r }
  }
  public func chainRight<U: Hashable>(
    _ rhs: Parser<U>
  ) -> Parser<U> {
    self.chain(rhs) { _, r in r }
  }

  public var `repeat`: Parser<[T]> {
    // TODO: non-primitive construction
    Parser { pos in
      var pos = pos
      var result = Array<T>()
      while let intr = try self.apply(pos).successSelf {
        pos = intr.next
        result.append(intr.value!)
      }
      return ParseResult(next: pos, result: .success(result))
    }
  }

  public func `repeat`(exactly n: Int) -> Parser<[T]> {
    // TODO: non-primitive construction
    Parser { pos in
      var pos = pos
      var result = Array<T>()
      for _ in 0..<n {
        let intr = try self.apply(pos)
        guard !intr.isError else {
          return intr.mapValue { _ in fatalError() }
        }
        pos = intr.next
        result.append(intr.value!)
      }
      return ParseResult(next: pos, result: .success(result))
    }
  }
}

// Tuple isn't Hashable...
public struct Pair<T: Hashable, U: Hashable>: Hashable {
  var first: T
  var second: U

  init(_ t: T, _ u: U) {
    self.first = t
    self.second = u
  }
}


/*

 Extract HTTP response body

 def status = (
   ("HTTP/" ~ decimalNumber) ~> wholeNumber <~ (text ~ crlf)
 ) map (_.toInt)

 def headers = rep(header)

 def header = (headerName <~ ":") flatMap { key =>
   (valueParser(key) <~ crlf) map { value => (key, value) }
 }

 def valueParser(key: String) =
   if (key == "Content-Length") wholeNumber else text

 def body(i: Int) = repN(anyChar, i) <~ crlf

 def response = (status ~ headers <~ crlf) map {
   case st ~ hs => Response(st, hs)
 }

 def respWithPayload = response flatMap { r =>
   body(r.contentLength)
 }

 */
