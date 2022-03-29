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

import _RegexParser
@_spi(RegexBuilder) import _StringProcessing

public struct Anchor {
  internal enum Kind {
    case startOfSubject
    case endOfSubjectBeforeNewline
    case endOfSubject
    case firstMatchingPositionInSubject
    case textSegmentBoundary
    case startOfLine
    case endOfLine
    case wordBoundary
  }
  
  var kind: Kind
  var isInverted: Bool = false
}

extension Anchor: RegexComponent {
  var astAssertion: AST.Atom.AssertionKind {
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
      }
    }
  }
  
  public var regex: Regex<Substring> {
    Regex(node: .atom(.assertion(astAssertion)))
  }
}

// MARK: - Public API

extension Anchor {
  public static var startOfSubject: Anchor {
    Anchor(kind: .startOfSubject)
  }

  public static var endOfSubjectBeforeNewline: Anchor {
    Anchor(kind: .endOfSubjectBeforeNewline)
  }

  public static var endOfSubject: Anchor {
    Anchor(kind: .endOfSubject)
  }

  // TODO: Are we supporting this?
//  public static var resetStartOfMatch: Anchor {
//    Anchor(kind: resetStartOfMatch)
//  }

  public static var firstMatchingPositionInSubject: Anchor {
    Anchor(kind: .firstMatchingPositionInSubject)
  }

  public static var textSegmentBoundary: Anchor {
    Anchor(kind: .textSegmentBoundary)
  }
  
  public static var startOfLine: Anchor {
    Anchor(kind: .startOfLine)
  }

  public static var endOfLine: Anchor {
    Anchor(kind: .endOfLine)
  }

  public static var wordBoundary: Anchor {
    Anchor(kind: .wordBoundary)
  }
  
  public var inverted: Anchor {
    var result = self
    result.isInverted.toggle()
    return result
  }
}

public func lookahead<R: RegexComponent>(
  negative: Bool = false,
  @RegexComponentBuilder _ content: () -> R
) -> Regex<R.Output> {
  Regex(node: .nonCapturingGroup(negative ? .negativeLookahead : .lookahead, content().regex.root))
}
  
public func lookahead<R: RegexComponent>(
  _ component: R,
  negative: Bool = false
) -> Regex<R.Output> {
  Regex(node: .nonCapturingGroup(negative ? .negativeLookahead : .lookahead, component.regex.root))
}
