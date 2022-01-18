//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// AST entities can be pretty-printed or dumped
///
/// Alternative: just use `description` for pretty-print
/// and `debugDescription` for dump
public protocol _ASTPrintable:
  CustomStringConvertible,
  CustomDebugStringConvertible
{
  // The "base" dump out for AST nodes, like `alternation`.
  // Children printing, parens, etc., handled automatically
  var _dumpBase: String { get }

}
extension _ASTPrintable {
  public var description: String { _print() }
  public var debugDescription: String { _dump() }

  var _children: [AST]? {
    if let children = (self as? _ASTParent)?.children {
      return children
    }
    if let children = (self as? AST)?.children {
      return children
    }
    return nil
  }

  func _print() -> String {
    // TODO: prettier printing
    _dump()
  }
  func _dump() -> String {
    guard let children = _children else {
      return _dumpBase
    }
    let sub = children.lazy.compactMap {
      // Exclude trivia for now, as we don't want it to appear when performing
      // comparisons of dumped output in tests.
      // TODO: We should eventually have some way of filtering out trivia for
      // tests, so that it can appear in regular dumps.
      if $0.isTrivia { return nil }
      return $0._dump()
    }.joined(separator: ",")
    return "\(_dumpBase)(\(sub))"
  }
}

extension AST: _ASTPrintable {
  public var _dumpBase: String {
    _associatedValue._dumpBase
  }
}

extension AST.Alternation {
  public var _dumpBase: String { "alternation" }
}

extension AST.Concatenation {
  public var _dumpBase: String { "" }
}

extension AST.Quote {
  public var _dumpBase: String { "quote \"\(literal)\"" }
}

extension AST.Trivia {
  public var _dumpBase: String {
    // TODO: comments, non-semantic whitespace, etc.
    ""
  }
}

extension AST.Empty {
  public var _dumpBase: String { "" }
}

extension AST.Conditional {
  public var _dumpBase: String {
    "if \(condition) then \(trueBranch) else \(falseBranch)"
  }
}

extension AST.Conditional.Condition: _ASTPrintable {
  public var _dumpBase: String { return "\(kind)" }
}
extension AST.Conditional.Condition.PCREVersionCheck.Kind: _ASTPrintable {
  public var _dumpBase: String {
    switch self {
    case .equal:              return "="
    case .greaterThanOrEqual: return ">="
    }
  }
}
extension AST.Conditional.Condition.PCREVersionNumber: _ASTPrintable {
  public var _dumpBase: String { "\(major).\(minor)" }
}
extension AST.Conditional.Condition.PCREVersionCheck: _ASTPrintable {
  public var _dumpBase: String { "VERSION\(kind.value)\(num)" }
}

extension AST.Atom {
  public var _dumpBase: String {
    if let lit = self.literalStringValue {
      return lit.halfWidthCornerQuoted
    }

    switch kind {
    case .escaped(let c): return "\\\(c.character)"

    case .namedCharacter(let charName):
      return "\\N{\(charName)}"

    case .property(let p): return "\(p._dumpBase)"

    case .keyboardControl, .keyboardMeta, .keyboardMetaControl:
      fatalError("TODO")

    case .any:         return "."
    case .startOfLine: return "^"
    case .endOfLine:   return "$"

    case .backreference(let r), .subpattern(let r):
      return "\(r._dumpBase)"

    case .char, .scalar:
      fatalError("Unreachable")
    }
  }
}

extension AST.Reference: _ASTPrintable {
  public var _dumpBase: String {
    "\(kind)"
  }
}

extension AST.Group.Kind: _ASTPrintable {
  public var _dumpBase: String {
    switch self {
    case .capture:               return "capture"
    case .namedCapture(let s):   return "capture<\(s.value)>"
    case .nonCapture:            return "nonCapture"
    case .nonCaptureReset:       return "nonCaptureReset"
    case .atomicNonCapturing:    return "atomicNonCapturing"
    case .lookahead:             return "lookahead"
    case .negativeLookahead:     return "negativeLookahead"
    case .nonAtomicLookahead:    return "nonAtomicLookahead"
    case .lookbehind:            return "lookbehind"
    case .negativeLookbehind:    return "negativeLookbehind"
    case .nonAtomicLookbehind:   return "nonAtomicLookbehind"
    case .scriptRun:             return "scriptRun"
    case .atomicScriptRun:       return "atomicScriptRun"
    case .changeMatchingOptions(let seq, let isIsolated):
      return "changeMatchingOptions<\(seq), \(isIsolated)>"
    }
  }
}

extension AST.Group: _ASTPrintable {
  public var _dumpBase: String {
    "group_\(kind.value._dumpBase)"
  }
}

extension AST.Quantification.Amount: _ASTPrintable {
  public var _printBase: String {
    _canonicalBase
  }
  public var _dumpBase: String {
    switch self {
    case .zeroOrMore:      return "zeroOrMore"
    case .oneOrMore:       return "oneOrMore"
    case .zeroOrOne:       return "zeroOrOne"
    case let .exactly(n):  return "exactly<\(n.value)>"
    case let .nOrMore(n):  return "nOrMore<\(n.value)>"
    case let .upToN(n):    return "uptoN<\(n.value)>"
    case let .range(lower, upper):
      return ".range<\(lower.value)...\(upper.value)>"
    }
  }
}
extension AST.Quantification.Kind: _ASTPrintable {
  public var _printBase: String { rawValue }
  public var _dumpBase: String {
    switch self {
    case .eager:      return "eager"
    case .reluctant:  return "reluctant"
    case .possessive: return "possessive"
    }
  }
}

extension AST.Quantification: _ASTPrintable {
  public var _printBase: String {
    """
    quant_\(amount.value._printBase)\(kind.value._printBase)
    """
  }

  public var _dumpBase: String {
    """
    quant_\(amount.value._dumpBase)_\(kind.value._dumpBase)
    """
  }
}

extension AST.CustomCharacterClass: _ASTNode {
  public var _dumpBase: String {
    "customCharacterClass(\(members))"
  }
}

extension AST.CustomCharacterClass.Member: _ASTPrintable {
  public var _dumpBase: String {
    switch self {
    case .custom(let cc): return "\(cc)"
    case .atom(let a): return "\(a)"
    case .range(let r): return "\(r)"
    case .quote(let q): return "\(q)"
    case .setOperation(let lhs, let op, let rhs):
      return "op \(lhs) \(op.value) \(rhs)"
    }
  }
}

extension AST.CustomCharacterClass.Range: _ASTPrintable {
  public var _dumpBase: String {
    "\(lhs)-\(rhs)"
  }
}
