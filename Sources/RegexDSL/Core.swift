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
  associatedtype MatchValue
  associatedtype CaptureValue
  var regex: Regex<CaptureValue> { get }
}

public protocol EmptyProtocol {}
public struct Empty: EmptyProtocol {}
extension Array: EmptyProtocol where Element: EmptyProtocol {}
extension Optional: EmptyProtocol where Wrapped: EmptyProtocol {}

/// A regular expression.
public struct Regex<CaptureValue>: RegexProtocol {
  public typealias MatchValue = CaptureValue
  let program: RegexProgram
  var ast: AST { program.ast }

  init(ast: AST) {
    self.program = RegexProgram(ast: ast)
  }

  public init<Content: RegexProtocol>(
    _ content: Content
  ) where Content.CaptureValue == CaptureValue {
    self = content.regex
  }

  public init<Content: RegexProtocol>(
    @RegexBuilder _ content: () -> Content
  ) where Content.CaptureValue == CaptureValue {
    self.init(content())
  }

  public var regex: Regex<CaptureValue> {
    self
  }
}

extension RegexProtocol {
  public func match(in input: String) -> RegexMatch<CaptureValue>? {
    match(in: input, using: DefaultEngine.self)
  }

  // TODO: Support anything that conforms to `StringProtocol` rather than just `String`.
  internal func match(
    in input: String,
    using engine: VirtualMachine.Type
  ) -> RegexMatch<CaptureValue>? {
    let vm = engine.init(regex.program.executable)
    guard let (range, captures) = vm.execute(input: input)?.destructure
    else {
      return nil
    }
    return RegexMatch(range: range, captures: captures.value as! CaptureValue)
  }
}

extension String {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.CaptureValue>? {
    regex.match(in: self)
  }

  internal func match<R: RegexProtocol>(
    _ regex: R,
    using engine: VirtualMachine.Type
  ) -> RegexMatch<R.CaptureValue>? {
    regex.match(in: self, using: engine)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.CaptureValue>? {
    match(content())
  }

  internal func match<R: RegexProtocol>(
    using engine: VirtualMachine.Type,
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.CaptureValue>? {
    match(content(), using: engine)
  }
}

public struct MockRegexLiteral<CaptureValue>: RegexProtocol {
  public typealias MatchValue = Substring
  public let regex: Regex<CaptureValue>

  public init(_ string: String, capturing: CaptureValue.Type = CaptureValue.self) throws {
    regex = Regex(ast: try parse(string))
  }
}
