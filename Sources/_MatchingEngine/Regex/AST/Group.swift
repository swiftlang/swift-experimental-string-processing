public struct Group: ASTParentEntity {
  public let kind: Kind

  public let sourceRange: SourceRange

  public init(
    _ kind: Kind, _ r: SourceRange
  ) {
    self.kind = kind
    self.sourceRange = r
  }
}

// TODO: sourceRange doesn't participate in equality...

extension Group {
  public enum Kind: ASTValue {
    // (...)
    case capture

    // (?<name>...) (?'name'...) (?P<name>...)
    case namedCapture(String)

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
    // the same. They parse more like quotes, so are not listed
    // here.
  }
}

// MARK: - API

extension Group {
  public var isCapturing: Bool {
    switch kind {
    case .capture:         return true
    case .namedCapture(_): return true
    default: return false
    }
  }

  var name: String? {
    switch kind {
    case .namedCapture(let s): return s
    default: return nil
    }
  }
}


// MARK: - Printing

extension Group.Kind {
  // Note that this printing setup doesn't naturally support
  // nesting, but I think it's ok because all groups terminate
  // the same.
  //
  // Also, pretty-print uses our preferred syntax, and a different print
  // could use the originally provided syntax.
  public func _print() -> String {
    switch self {
    case .capture:            return "("
//    case .comment:            return "(?#."
    case .atomicNonCapturing: return "(?>"
    case .namedCapture:       return "(?<"
    case .nonCapture:         return "(?:"
    case .nonCaptureReset:    return "(?|"
    case .lookahead:          return "(?="
    case .negativeLookahead:  return "(?!"
    case .lookbehind:         return "(?<="
    case .negativeLookbehind: return "(?<!"
    }
  }

  public func _dump() -> String {
    _print()
  }
}
extension Group {
  public func _printNested(_ child: String) -> String {
    var res = kind._print()
    if let n = name {
      res += "\(n)>"
    }
    res += child
    res += ")"
    return res
  }

  public func _dumpNested(_ child: String) -> String {
    var res = kind._dump()
    if let n = name {
      res += "\(n)>" // syntax?
    }
    res += child
    res += ")"
    return res
  }
}
