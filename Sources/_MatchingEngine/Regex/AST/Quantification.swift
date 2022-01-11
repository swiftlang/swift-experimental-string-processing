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

extension AST {
  public struct Quantification: Hashable {
    public let amount: Located<Amount>
    public let kind: Located<Kind>

    public let child: AST
    public let location: SourceLocation

    public init(
      _ amount: Located<Amount>,
      _ kind: Located<Kind>,
      _ child: AST,
      _ r: SourceLocation
    ) {
      self.amount = amount
      self.kind = kind
      self.child = child
      self.location = r
    }

    public enum Amount: Hashable {
      case zeroOrMore              // *
      case oneOrMore               // +
      case zeroOrOne               // ?
      case exactly(Located<Int>)         // {n}
      case nOrMore(Located<Int>)         // {n,}
      case upToN(Located<Int>)           // {,n}
      case range(Located<Int>, Located<Int>) // {n,m}
    }

    public enum Kind: String, Hashable {
      case eager      = ""
      case reluctant  = "?"
      case possessive = "+"
    }
  }
}

/// MARK: - Semantic API

extension AST.Quantification.Amount {
  /// Get the bounds
  public var bounds: (atLeast: Int, atMost: Int?) {
    switch self {
    case .zeroOrMore: return (0, nil)
    case .oneOrMore:  return (1, nil)
    case .zeroOrOne:  return (0, 1)

    case let .exactly(n):  return (n.value, n.value)
    case let .nOrMore(n):  return (n.value, nil)
    case let .upToN(n):    return (0, n.value)
    case let .range(n, m): return (n.value, m.value)
    }
  }
}
