import _MatchingEngine

public struct RegexMatch<CapturedValue> {
  public let range: Range<String.Index>
  public let captures: CapturedValue
}

/// A type that represents a regular expression.
public protocol RegexProtocol {
  associatedtype Capture
  var regex: Regex<Capture> { get }
}

/// A regular expression.
@frozen
public struct Regex<Capture>: RegexProtocol {
  /// A program representation that caches any lowered representation for
  /// execution.
  @usableFromInline
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
    lazy private(set) var loweredProgram = Compiler(ast: ast).emit()

    init(ast: AST) {
      self.ast = ast
    }
  }

  @usableFromInline
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

  public init<Content: RegexProtocol>(
    _ content: Content
  ) where Content.Capture == Capture {
    self = content.regex
  }

  public init<Content: RegexProtocol>(
    @RegexBuilder _ content: () -> Content
  ) where Content.Capture == Capture {
    self.init(content())
  }

  public var regex: Regex<Capture> {
    self
  }
}

extension RegexProtocol {
  public func match(in input: String) -> RegexMatch<Capture>? {
    // TODO: Remove this branch when the matching engine supports captures.
    if regex.ast.hasCapture {
      let vm = HareVM(program: regex.program.legacyLoweredProgram)
      guard let (range, captures) = vm.execute(input: input)?.destructure else {
        return nil
      }
      let convertedCapture: Capture
      if Capture.self == DynamicCaptures.self {
        convertedCapture = DynamicCaptures(captures) as! Capture
      } else {
        convertedCapture = captures.value as! Capture
      }
      return RegexMatch(range: range, captures: convertedCapture)
    }
    let executor = Executor(program: regex.program.loweredProgram)
    guard let result = executor.execute(input: input) else {
      return nil
    }
    let convertedCapture: Capture
    if Capture.self == DynamicCaptures.self {
      convertedCapture = DynamicCaptures.tuple([]) as! Capture
    } else {
      convertedCapture = () as! Capture
    }
    return RegexMatch(range: result.range, captures: convertedCapture)
  }
}

extension String {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Capture>? {
    regex.match(in: self)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Capture>? {
    match(content())
  }
}

public struct MockRegexLiteral<Capture>: RegexProtocol {
  public typealias MatchValue = Substring
  public let regex: Regex<Capture>

  public init(
    _ string: String,
    _ syntax: SyntaxOptions = .traditional,
    capturing: Capture.Type = Capture.self
  ) throws {
    regex = Regex(ast: try parse(string, syntax))
  }
}

public func r<C>(
  _ s: String, capturing: C.Type = C.self
) -> MockRegexLiteral<C> {
  try! MockRegexLiteral(s, capturing: capturing)
}

fileprivate typealias DefaultEngine = TortoiseVM

public protocol EmptyProtocol {}
public struct Empty: EmptyProtocol {}
extension Array: EmptyProtocol where Element: EmptyProtocol {}
extension Optional: EmptyProtocol where Wrapped: EmptyProtocol {}

