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

@dynamicMemberLookup
public struct RegexMatch<Match> {
  public let range: Range<String.Index>
  public let match: Match

  public subscript<T>(dynamicMember keyPath: KeyPath<Match, T>) -> T {
    match[keyPath: keyPath]
  }
}

/// A type that represents a regular expression.
public protocol RegexProtocol {
  associatedtype Match
  var regex: Regex<Match> { get }
}

/// A regular expression.
public struct Regex<Match>: RegexProtocol {
  /// A program representation that caches any lowered representation for
  /// execution.
  internal class Program {
    /// The underlying IR.
    ///
    /// FIXME: If Regex is the unit of composition, then it should be a Node instead,
    /// and we should have a separate type that handled both global options and,
    /// likely, compilation/caching.
    let tree: DSLTree

    /// The legacy `RECode` for execution with a legacy VM.
    lazy private(set) var legacyLoweredProgram: RECode = {
      do {
        return try compile(tree)
      } catch {
        fatalError("Regex engine internal error: \(String(describing: error))")
      }
    }()
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

  public init<Content: RegexProtocol>(
    _ content: Content
  ) where Content.Match == Match {
    self = content.regex
  }

  public init<Content: RegexProtocol>(
    @RegexBuilder _ content: () -> Content
  ) where Content.Match == Match {
    self.init(content())
  }

  public var regex: Regex<Match> {
    self
  }
}

extension RegexProtocol {
  public func match(in input: String) -> RegexMatch<Match>? {
    _match(
      input, in: input.startIndex..<input.endIndex)
  }
  public func match(in input: Substring) -> RegexMatch<Match>? {
    _match(
      input.base, in: input.startIndex..<input.endIndex)
  }

  // FIXME: This is mostly hacky because we go down two different paths based on
  // whether there are captures. This will be cleaned up once we deprecate the
  // legacy virtual machines.
  func _match(
    _ input: String,
    in inputRange: Range<String.Index>,
    mode: MatchMode = .wholeString
  ) -> RegexMatch<Match>? {
    // TODO: Remove this branch when the matching engine supports captures.
    if regex.hasCapture {
      let vm = HareVM(program: regex.program.legacyLoweredProgram)
      guard let (range, captures) = vm.execute(
        input: input, in: inputRange, mode: mode
      )?.destructure else {
        return nil
      }
      let convertedMatch: Match
      if Match.self == (Substring, DynamicCaptures).self {
        convertedMatch = (input[range], DynamicCaptures(captures)) as! Match
      } else {
        let typeErasedMatch = captures.matchValue(
          withWholeMatch: input[range]
        )
        convertedMatch = typeErasedMatch as! Match
      }
      return RegexMatch(range: range, match: convertedMatch)
    }

    let executor = Executor(program: regex.program.loweredProgram)
    guard let result = executor.execute(
      input: input, in: inputRange, mode: mode
    ) else {
      return nil
    }
    let convertedMatch: Match
    if Match.self == (Substring, DynamicCaptures).self {
      convertedMatch = (input[result.range], DynamicCaptures.empty) as! Match
    } else {
      assert(Match.self == Substring.self)
      convertedMatch = input[result.range] as! Match
    }
    return RegexMatch(range: result.range, match: convertedMatch)
  }
}

extension String {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Match>? {
    regex.match(in: self)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Match>? {
    match(content())
  }
}
extension Substring {
  public func match<R: RegexProtocol>(_ regex: R) -> RegexMatch<R.Match>? {
    regex.match(in: self)
  }

  public func match<R: RegexProtocol>(
    @RegexBuilder _ content: () -> R
  ) -> RegexMatch<R.Match>? {
    match(content())
  }
}
public struct MockRegexLiteral<Match>: RegexProtocol {
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

fileprivate typealias DefaultEngine = TortoiseVM
