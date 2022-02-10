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

import _MatchingEngine

public struct Assertion {
  internal enum Kind {
    case startOfSubject
    case endOfSubjectBeforeNewline
    case endOfSubject
    case firstMatchingPositionInSubject
    case textSegmentBoundary
    case startOfLine
    case endOfLine
    case wordBoundary
    case lookahead(DSLTree.Node)
  }
  
  var kind: Kind
  var isInverted: Bool = false
}

extension Assertion: RegexProtocol {
  var astAssertion: AST.Atom.AssertionKind? {
    if !isInverted {
      switch kind {
      case .startOfSubject: return .startOfSubject
      case .endOfSubjectBeforeNewline: return .endOfSubjectBeforeNewline
      case .endOfSubject: return .endOfSubject
      case .firstMatchingPositionInSubject: return .firstMatchingPositionInSubject
      case .textSegmentBoundary: return .textSegment
      case .startOfLine: return .startOfLine
      case .endOfLine: return .endOfLine
      case .wordBoundary: return .wordBoundary
      default: return nil
      }
    } else {
      switch kind {
      case .startOfSubject: fatalError("Not yet supported")
      case .endOfSubjectBeforeNewline: fatalError("Not yet supported")
      case .endOfSubject: fatalError("Not yet supported")
      case .firstMatchingPositionInSubject: fatalError("Not yet supported")
      case .textSegmentBoundary: return .notTextSegment
      case .startOfLine: fatalError("Not yet supported")
      case .endOfLine: fatalError("Not yet supported")
      case .wordBoundary: return .notWordBoundary
      default: return nil
      }
    }
  }
  
  public var regex: Regex<Substring> {
    if let assertionKind = astAssertion {
      return Regex(node: .atom(.assertion(assertionKind)))
    }
    
    switch (kind, isInverted) {
    case let (.lookahead(node), false):
      return Regex(node: .group(.lookahead, node))
    case let (.lookahead(node), true):
      return Regex(node: .group(.negativeLookahead, node))

    default:
      fatalError("Unsupported assertion")
    }
  }
}

// MARK: - Public API

extension Assertion {
  public static var startOfSubject: Assertion {
    Assertion(kind: .startOfSubject)
  }

  public static var endOfSubjectBeforeNewline: Assertion {
    Assertion(kind: .endOfSubjectBeforeNewline)
  }

  public static var endOfSubject: Assertion {
    Assertion(kind: .endOfSubject)
  }

  // TODO: Are we supporting this?
//  public static var resetStartOfMatch: Assertion {
//    Assertion(kind: resetStartOfMatch)
//  }

  public static var firstMatchingPositionInSubject: Assertion {
    Assertion(kind: .firstMatchingPositionInSubject)
  }

  public static var textSegmentBoundary: Assertion {
    Assertion(kind: .textSegmentBoundary)
  }
  
  public static var startOfLine: Assertion {
    Assertion(kind: .startOfLine)
  }

  public static var endOfLine: Assertion {
    Assertion(kind: .endOfLine)
  }

  public static var wordBoundary: Assertion {
    Assertion(kind: .wordBoundary)
  }
  
  public var inverted: Assertion {
    var result = self
    result.isInverted.toggle()
    return result
  }
}

extension Assertion {
  public static func lookahead<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> Assertion {
    lookahead(content())
  }
  
  public static func lookahead<R: RegexProtocol>(_ component: R) -> Assertion {
    Assertion(kind: .lookahead(component.regex.root))
  }
}
