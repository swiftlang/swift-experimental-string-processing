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


/// A type that represents a regular expression.
public protocol RegexComponent {
  associatedtype Match
  var regex: Regex<Match> { get }
}

/// A regular expression.
public struct Regex<Match>: RegexComponent {
  /// A program representation that caches any lowered representation for
  /// execution.
  internal class Program {
    /// The underlying IR.
    ///
    /// FIXME: If Regex is the unit of composition, then it should be a Node instead,
    /// and we should have a separate type that handled both global options and,
    /// likely, compilation/caching.
    let tree: DSLTree

    /// The program for execution with the matching engine.
    lazy private(set) var loweredProgram = try! Compiler(tree: tree).emit()

    init(ast: AST) {
      self.tree = ast.dslTree
    }
    init(tree: DSLTree) {
      self.tree = tree
    }
  }

  let program: Program
//  var ast: AST { program.ast }

  var root: DSLTree.Node {
    program.tree.root
  }

  var hasCapture: Bool {
    program.tree.hasCapture
  }

  init(ast: AST) {
    self.program = Program(ast: ast)
  }
  init(ast: AST.Node) {
    self.program = Program(ast: .init(ast, globalOptions: nil))
  }

  init(node: DSLTree.Node) {
    self.program = Program(tree: .init(node, options: nil))
  }

  // Compiler interface. Do not change independently.
  @usableFromInline
  init(_regexString pattern: String) {
    self.init(ast: try! parse(pattern, .traditional))
  }

  // Compiler interface. Do not change independently.
  @usableFromInline
  init(_regexString pattern: String, version: Int) {
    assert(version == currentRegexLiteralFormatVersion)
    // The version argument is passed by the compiler using the value defined
    // in libswiftParseRegexLiteral.
    self.init(ast: try! parseWithDelimiters(pattern))
  }

  public init<Content: RegexComponent>(
    _ content: Content
  ) where Content.Match == Match {
    self = content.regex
  }

  public init<Content: RegexComponent>(
    @RegexComponentBuilder _ content: () -> Content
  ) where Content.Match == Match {
    self.init(content())
  }

  public var regex: Regex<Match> {
    self
  }
}


public struct MockRegexLiteral<Match>: RegexComponent {
  public typealias MatchValue = Substring
  public let regex: Regex<Match>

  public init(
    _ string: String,
    _ syntax: SyntaxOptions = .traditional,
    matching: Match.Type = Match.self
  ) throws {
    regex = Regex(ast: try parse(string, syntax))
  }
}

public func r<Match>(
  _ s: String, matching matchType: Match.Type = Match.self
) -> MockRegexLiteral<Match> {
  try! MockRegexLiteral(s, matching: matchType)
}
