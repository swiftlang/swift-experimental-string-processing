import _MatchingEngine

@dynamicMemberLookup
public struct RegexMatch<Match> {
  public let range: Range<String.Index>
  public let match: Match

  public subscript<T>(dynamicMember keyPath: KeyPath<Match, T>) -> T {
    match[keyPath: keyPath]
  }
}

/// A type that represents a regular expression.
public protocol RegexProtocol {
  associatedtype Match: MatchProtocol
  var regex: Regex<Match> { get }
}

/// A regular expression.
public struct Regex<Match: MatchProtocol>: RegexProtocol {
  /// A program representation that caches any lowered representation for
  /// execution.
  internal class Program {
    /// The underlying AST.
    let ast: AST
    /// The legacy `RECode` for execution with a legacy VM.
    lazy private(set) var legacyLoweredProgram: RECode = {
      do {
        return try compile(ast)
      } catch {
        fatalError("Regex engine internal error: \(String(describing: error))")
      }
    }()
    /// The program for execution with the matching engine.
    lazy private(set) var loweredProgram = try! Compiler(ast: ast).emit()

    init(ast: AST) {
      self.ast = ast
    }
  }

  let program: Program
  var ast: AST { program.ast }

  init(ast: AST) {
    self.program = Program(ast: ast)
  }

  // Compiler interface. Do not change independently.
  @usableFromInline
  init(_regexString pattern: String) {
    self.init(ast: try! parse(pattern, .traditional))
  }

  // Compiler interface. Do not change independently.
  @usableFromInline
  init(_regexString pattern: String, version: Int) {
    assert(version == currentRegexLiteralFormatVersion)
    // The version argument is passed by the compiler using the value defined
    // in libswiftParseRegexLiteral.
    self.init(ast: try! parseWithDelimiters(pattern))
  }

  public init<Content: RegexProtocol>(
    _ content: Content
  ) where Content.Match == Match {
    self = content.regex
  }

  public init<Content: RegexProtocol>(
    @RegexBuilder _ content: () -> Content
  ) where Content.Match == Match {
    self.init(content())
  }

  public var regex: Regex<Match> {
    self
  }
}

extension RegexProtocol {
  // FIXME: This is mostly hacky because we go down two different paths based on
  // whether there are captures. This will be cleaned up once we deprecate the
  // legacy virtual machines.
  public func match(in input: String) -> RegexMatch<Match>? {
    // Casts a Swift tuple to the custom `Tuple<n>`, assuming their memory
    // layout is compatible.
    func bitCastToMatch<T>(_ x: T) -> Match {
      assert(
        MemoryLayout<T>.size == MemoryLayout<Match>.size,
        "Matched \(T.self), not the expected \(Match.self)"
      )
      return unsafeBitCast(x, to: Match.self)
    }
    let executor = Executor(program: regex.program.loweredProgram)
    guard let result = executor.execute(input: input) else {
      return nil
    }
    let convertedMatch: Match
    if Match.self == Tuple2<Substring, DynamicCaptures>.self {
      convertedMatch = Tuple2(
        input[result.range],
        DynamicCaptures(result.captures.mapRanges { input[$0] })
      ) as! Match
    } else {
      let typeErasedMatch = result.captures.matchValue(input: input)
      convertedMatch = _openExistential(typeErasedMatch, do: bitCastToMatch)
    }
    return RegexMatch(range: result.range, match: convertedMatch)
  }
}

extension String {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Match>? {
    regex.match(in: self)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Match>? {
    match(content())
  }
}

public struct MockRegexLiteral<Match: MatchProtocol>: RegexProtocol {
  public typealias MatchValue = Substring
  public let regex: Regex<Match>

  public init(
    _ string: String,
    _ syntax: SyntaxOptions = .traditional,
    matching: Match.Type = Match.self
  ) throws {
    regex = Regex(ast: try parse(string, syntax))
  }
}

public func r<Match>(
  _ s: String, matching matchType: Match.Type = Match.self
) -> MockRegexLiteral<Match> {
  try! MockRegexLiteral(s, matching: matchType)
}

fileprivate typealias DefaultEngine = TortoiseVM

public protocol EmptyCaptureProtocol {}
public struct EmptyCapture: EmptyCaptureProtocol {}
extension Array: EmptyCaptureProtocol where Element: EmptyCaptureProtocol {}
extension Optional: EmptyCaptureProtocol where Wrapped: EmptyCaptureProtocol {}

public protocol MatchProtocol {
  associatedtype Capture
}
extension Substring: MatchProtocol {
  public typealias Capture = EmptyCapture
}

