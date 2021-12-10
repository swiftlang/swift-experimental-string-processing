/// A regex abstract syntax tree
public indirect enum AST:
  Hashable/*, _ASTPrintable ASTValue, ASTAction*/
{
  /// Located value: a value wrapped with a source range
  public typealias Loc = Source.Value

  /// ... | ... | ...
  case alternation(Alternation)

  /// ... ...
  case concatenation(Concatenation)

  /// (...)
  case group(Group)

  case quantification(Quantification)

  /// \Q...\E
  case quote(Quote)

  ///
  case trivia(Trivia) // TODO: track comments

  case atom(Atom)

  case customCharacterClass(CustomCharacterClass)

  case empty


  // FIXME: Move off the regex literal AST
  case groupTransform(
    Group, transform: CaptureTransform)
}

// TODO: This is currently unused, but it's likely we'll want
// to host things like global options, more source info, etc.
private struct ASTStorage {
  let ast: AST
  let sourceRange: SourceRange?
}

extension AST {
  // :-(
  var _associatedValue: _ASTNode? {
    switch self {
    case .empty: return nil
    case let .alternation(v):          return v
    case let .concatenation(v):        return v
    case let .group(v):                return v
    case let .quantification(v):       return v
    case let .quote(v):                return v
    case let .trivia(v):               return v
    case let .atom(v):                 return v
    case let .customCharacterClass(v): return v

    case let .groupTransform(g, _):
      return g // FIXME: get this out of here
    }
  }

  /// If this node is a parent node, access its children
  public var children: [AST]? {
    guard let av = _associatedValue else { return nil }
    return (av as? _ASTParent)?.children
  }

  /// Whether this node is "trivia" or non-semantic, like comments
  public var isTrivia: Bool {
    switch self {
    case .trivia: return true
    default: return false
    }
  }

  /// Whether this node has nested somewhere inside it a capture
  public var hasCapture: Bool {
    if case let .group(g) = self, g.kind.value.isCapturing {
      return true
    }

    return self.children?.any(\.hasCapture) ?? false
  }
}

// MARK: - AST types

extension AST {

  public struct Alternation: Hashable, _ASTNode {
    public let children: [AST]
    public let sourceRange: SourceRange

    public init(_ mems: [AST], _ sourceRange: SourceRange) {
      self.children = mems
      self.sourceRange = sourceRange
    }

    public var _dumpBase: String { "alternation" }
  }

  public struct Concatenation: Hashable, _ASTNode {
    public let children: [AST]
    public let sourceRange: SourceRange

    public init(_ mems: [AST], _ sourceRange: SourceRange) {
      self.children = mems
      self.sourceRange = sourceRange
    }

    public var _dumpBase: String { "" }
  }

  public struct Quote: Hashable, _ASTNode {
    public let literal: String
    public let sourceRange: SourceRange

    public init(_ s: String, _ sourceRange: SourceRange) {
      self.literal = s
      self.sourceRange = sourceRange
    }

    public var _dumpBase: String { "quote" }
  }

  public struct Trivia: Hashable, _ASTNode {
    // TODO: Contents of trivia, kinds, etc
    public let sourceRange: SourceRange

    public init(_ sourceRange: SourceRange) {
      self.sourceRange = sourceRange
    }

    public var _dumpBase: String {
      // TODO: comments, non-semantic whitespace, etc.
      ""
    }
  }
}

// FIXME: Get this out of here
public struct CaptureTransform: Equatable, Hashable, CustomStringConvertible {
  public let closure: (Substring) -> Any

  public init(_ closure: @escaping (Substring) -> Any) {
    self.closure = closure
  }

  public func callAsFunction(_ input: Substring) -> Any {
    closure(input)
  }

  public static func == (lhs: CaptureTransform, rhs: CaptureTransform) -> Bool {
    unsafeBitCast(lhs.closure, to: (Int, Int).self) ==
      unsafeBitCast(rhs.closure, to: (Int, Int).self)
  }

  public func hash(into hasher: inout Hasher) {
    let (fn, ctx) = unsafeBitCast(closure, to: (Int, Int).self)
    hasher.combine(fn)
    hasher.combine(ctx)
  }

  public var description: String {
    "<transform>"
  }
}

