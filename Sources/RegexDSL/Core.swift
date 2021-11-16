import Regex
@_exported import struct Regex.CharacterClass

fileprivate typealias DefaultEngine = TortoiseVM

public struct RegexMatch<CapturedValue> {
  public let range: Range<String.Index>
  public let captures: CapturedValue
}

/// A compiled regular expression.
internal class RegexProgram {
  let ast: AST
  lazy private(set) var executable: RECode = {
    do {
      return try compile(ast)
    } catch {
      fatalError("Regex engine internal error: \(String(describing: error))")
    }
  }()

  init(ast: AST) {
    self.ast = ast
  }
}

/// A type that represents a regular expression.
public protocol RegexProtocol {
  associatedtype Capture
  var regex: Regex<Capture> { get }
}

public protocol EmptyProtocol {}
public struct Empty: EmptyProtocol {}
extension Array: EmptyProtocol where Element: EmptyProtocol {}
extension Optional: EmptyProtocol where Wrapped: EmptyProtocol {}

/// A regular expression.
public struct Regex<Capture>: RegexProtocol {
  let program: RegexProgram
  var ast: AST { program.ast }

  init(ast: AST) {
    self.program = RegexProgram(ast: ast)
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
    match(in: input, using: DefaultEngine.self)
  }

  // TODO: Support anything that conforms to `StringProtocol` rather than just `String`.
  internal func match(
    in input: String,
    using engine: VirtualMachine.Type
  ) -> RegexMatch<Capture>? {
    let vm = engine.init(regex.program.executable)
    guard let (range, captures) = vm.execute(input: input)?.destructure
    else {
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
}

extension String {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Capture>? {
    regex.match(in: self)
  }

  internal func match<R: RegexProtocol>(
    _ regex: R,
    using engine: VirtualMachine.Type
  ) -> RegexMatch<R.Capture>? {
    regex.match(in: self, using: engine)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Capture>? {
    match(content())
  }

  internal func match<R: RegexProtocol>(
    using engine: VirtualMachine.Type,
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Capture>? {
    match(content(), using: engine)
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
