public struct Group: ASTParentEntity {
  public let name: String?
  public let kind: Kind

  public let sourceRange: SourceRange?

  init(
    _ kind: Kind, name: String? = nil, _ r: SourceRange?
  ) {
    self.name = name
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
    case namedCapture

    // (?:...)
    case nonCapture

    // (?|...)
    case nonCaptureReset

    // (?>...)
    case atomicNonCapturing // TODO: is Oniguruma capturing?

    // (?#....)
    case comment

    // (?=...) (?!...)
    case lookahead(inverted: Bool)

    // (?<=...) (?<!...)
    case lookbehind(inverted: Bool)
  }
}

// MARK: - Convenience constructors

extension Group {
  public static func capture(_ sr: SourceRange? = nil) -> Group {
    Group(.capture, sr)
  }
  public static func nonCapture(_ sr: SourceRange? = nil) -> Group {
    Group(.nonCapture, sr)
  }
}

// MARK: - API

extension Group {
  public var isCapturing: Bool {
    return kind == .capture || kind == .namedCapture
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
    case .comment:            return "(?#."
    case .atomicNonCapturing: return "(?>"
    case .namedCapture:       return "(?<"
    case .nonCapture:         return "(?:"
    case .nonCaptureReset:    return "(?|"
    case .lookahead(let invert):  return invert ? "(?!" : "(?="
    case .lookbehind(let invert): return invert ? "(?<!" :"(?<="
    }
  }

  public func _dump() -> String {
    fatalError()
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

// MARK: - AST constructors

extension AST {
  public static func capture(
    _ a: AST, _ sr: SourceRange? = nil
  ) -> AST {
    .group(.capture(sr), a)
  }
  public static func nonCapture(
    _ a: AST, _ sr: SourceRange? = nil
  ) -> AST {
    .group(.nonCapture(sr), a)
  }
}
