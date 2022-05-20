//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension AST {
  public struct Conditional: Hashable, Sendable, _ASTNode {
    public var location: SourceLocation
    public var condition: Condition

    public var trueBranch: AST.Node
    public var pipe: SourceLocation?
    public var falseBranch: AST.Node

    public init(
      _ condition: Condition, trueBranch: AST.Node, pipe: SourceLocation?,
      falseBranch: AST.Node, _ location: SourceLocation
    ) {
      self.location = location
      self.condition = condition
      self.trueBranch = trueBranch
      self.pipe = pipe
      self.falseBranch = falseBranch
    }
  }
}

extension AST.Conditional {
  public struct Condition: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
      /// Check to see if a certain group was matched.
      case groupMatched(AST.Reference)

      // Check for recursion.
      case recursionCheck
      case groupRecursionCheck(AST.Reference)

      /// Define a new group that can be referenced elsewhere.
      case defineGroup

      /// A PCRE version check.
      case pcreVersionCheck(PCREVersionCheck)

      /// A group condition, which checks to see if an arbitrary bit of regex
      /// matches. Note that the semantics of this differs by engine, .NET only
      /// treats it as a lookahead, whereas Oniguruma can evaluate separately
      /// from the body of the conditional.
      case group(AST.Group)
    }

    public var kind: Kind
    public var location: SourceLocation

    public init(_ kind: Kind, _ location: SourceLocation) {
      self.kind = kind
      self.location = location
    }
  }
}

extension AST.Conditional.Condition {
  public struct PCREVersionNumber: Hashable, Sendable {
    public var major: Int
    public var minor: Int
    public var location: SourceLocation

    public init(major: Int, minor: Int, _ location: SourceLocation) {
      self.major = major
      self.minor = minor
      self.location = location
    }
  }
  public struct PCREVersionCheck: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
      case equal, greaterThanOrEqual
    }
    public var kind: AST.Located<Kind>
    public var num: PCREVersionNumber

    public init(_ kind: AST.Located<Kind>, _ num: PCREVersionNumber) {
      self.kind = kind
      self.num = num
    }
  }
}
