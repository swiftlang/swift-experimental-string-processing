extension AST {
  public struct Group: Hashable {
    public let kind: Loc<Kind>
    public let child: AST

    public let sourceRange: SourceRange

    public init(
      _ kind: Loc<Kind>, _ child: AST, _ r: SourceRange
    ) {
      self.kind = kind
      self.child = child
      self.sourceRange = r
    }

    public enum Kind: Hashable {
      // (...)
      case capture

      // (?<name>...) (?'name'...) (?P<name>...)
      case namedCapture(Loc<String>)

      // (?:...)
      case nonCapture

      // (?|...)
      case nonCaptureReset

      // (?>...)
      case atomicNonCapturing // TODO: is Oniguruma capturing?

      // (?=...)
      case lookahead

      // (?!...)
      case negativeLookahead

      // (?<=...)
      case lookbehind

      // (?<!...)
      case negativeLookbehind

      // NOTE: Comments appear to be groups, but are not parsed
      // the same. They parse more like quotes, so are not
      // listed here.
    }
  }
}

extension AST.Group.Kind: _ASTPrintable {
  public var isCapturing: Bool {
    switch self {
    case .capture, .namedCapture: return true
    default: return false
    }
  }

  public var _dumpBase: String {
    switch self {
    case .capture:             return "capture"
    case .namedCapture(let s): return "capture<\(s)>"
    case .nonCapture:          return "nonCapture"
    case .nonCaptureReset:     return "nonCaptureReset"
    case .atomicNonCapturing:  return "atomicNonCapturing"
    case .lookahead:           return "lookahead"
    case .negativeLookahead:   return "negativeLookahead"
    case .lookbehind:          return "lookbehind"
    case .negativeLookbehind:  return "negativeLookbehind"
    }
  }
}

extension AST.Group: _ASTPrintable {
  public var _dumpBase: String {
    "group_\(kind.value._dumpBase)"
  }
}


