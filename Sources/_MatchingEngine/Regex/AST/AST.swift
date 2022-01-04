/// A regex abstract syntax tree
public indirect enum AST:
  Hashable/*, _ASTPrintable ASTValue, ASTAction*/
{
  /// ... | ... | ...
  case alternation(Alternation)

  /// ... ...
  case concatenation(Concatenation)

  /// (...)
  case group(Group)

  case quantification(Quantification)

  /// \Q...\E
  case quote(Quote)

  /// Comments, non-semantic whitespace, etc
  case trivia(Trivia)

  case atom(Atom)

  case customCharacterClass(CustomCharacterClass)

  case empty(Empty)

  // FIXME: Move off the regex literal AST
  case groupTransform(
    Group, transform: CaptureTransform<String>)
}

// TODO: Do we want something that holds the AST and stored global options?

extension AST {
  // :-(
  //
  // Existential-based programming is highly prone to silent
  // errors, but it does enable us to avoid having to switch
  // over `self` _everywhere_ we want to do anything.
  var _associatedValue: _ASTNode {
    switch self {
    case let .alternation(v):          return v
    case let .concatenation(v):        return v
    case let .group(v):                return v
    case let .quantification(v):       return v
    case let .quote(v):                return v
    case let .trivia(v):               return v
    case let .atom(v):                 return v
    case let .customCharacterClass(v): return v
    case let .empty(v):                return v

    case let .groupTransform(g, _):
      return g // FIXME: get this out of here
    }
  }

  /// If this node is a parent node, access its children
  public var children: [AST]? {
    return (_associatedValue as? _ASTParent)?.children
  }

  public var location: SourceLocation {
    _associatedValue.location
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
    switch self {
    case .group(let g) where g.kind.value.isCapturing:
      return true
    // FIXME: Move off of regex AST.
    case .groupTransform:
      return true
    default:
      break
    }
    return self.children?.any(\.hasCapture) ?? false
  }
}

// MARK: - AST types

extension AST {

  public struct Alternation: Hashable, _ASTNode {
    public let children: [AST]
    public let location: SourceLocation

    public init(_ mems: [AST], _ location: SourceLocation) {
      self.children = mems
      self.location = location
    }

    public var _dumpBase: String { "alternation" }
  }

  public struct Concatenation: Hashable, _ASTNode {
    public let children: [AST]
    public let location: SourceLocation

    public init(_ mems: [AST], _ location: SourceLocation) {
      self.children = mems
      self.location = location
    }

    public var _dumpBase: String { "" }
  }

  public struct Quote: Hashable, _ASTNode {
    public let literal: String
    public let location: SourceLocation

    public init(_ s: String, _ location: SourceLocation) {
      self.literal = s
      self.location = location
    }

    public var _dumpBase: String { "quote" }
  }

  public struct Trivia: Hashable, _ASTNode {
    public let contents: String
    public let location: SourceLocation

    public init(_ s: String, _ location: SourceLocation) {
      self.contents = s
      self.location = location
    }

    init(_ v: Located<String>) {
      self.contents = v.value
      self.location = v.location
    }

    public var _dumpBase: String {
      // TODO: comments, non-semantic whitespace, etc.
      ""
    }
  }

  public struct Empty: Hashable, _ASTNode {
    public let location: SourceLocation

    public init(_ location: SourceLocation) {
      self.location = location
    }

    public var _dumpBase: String { "" }
  }
}
