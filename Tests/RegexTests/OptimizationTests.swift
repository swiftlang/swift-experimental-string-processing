//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Testing
@testable @_spi(RegexBuilder) import _StringProcessing
@testable import _RegexParser

@Suite struct OptimizationTests {
  @available(macOS 9999, *)
  @Test(arguments: [#/a/#, #/a+/#, #/(?:a+)/#, #/(?:a)+/#, #/(?m)a+/#, #/ab?c/#, #/(?:a+)+$/#, #/(?:(?:a+b)+b)/#])
  func requiredFirstAtom(pattern: Regex<Substring>) throws {
    let list = DSLList(tree: pattern.program.tree)
    let atom = list.requiredFirstAtom()
    #expect(atom?.literalCharacterValue == "a", "Missing first character atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 9999, *)
  @Test(arguments: [#/a?/#, #/(?:a|b)/#, #/[a]/#, #/a?bc/#])
  func noRequiredFirstAtom(pattern: Regex<Substring>) throws {
    let list = DSLList(tree: pattern.program.tree)
    let atom = list.requiredFirstAtom()
    #expect(atom == nil, "Unexpected required first atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 9999, *)
  @Test(arguments: [#/a+b/#, #/a*b/#, #/\w+\s/#, #/(?:a+b|b+a)/#]) // , #/\d+a/#
  func autoPossessify(pattern: Regex<Substring>) throws {
    var list = DSLList(tree: pattern.program.tree)
    list.autoPossessify()
    for node in list.nodes {
      switch node {
      case .quantification(_, let kind, _):
        #expect(
          kind.isExplicit && kind.quantificationKind?.ast == .possessive,
          "Expected possessification in '\(pattern._literalPattern!)'")
      default: break
      }
    }
  }

  @available(macOS 9999, *)
  @Test(arguments: [#/a?/#, #/a+a/#, #/(?:a|b)/#, #/(?:a+|b+)/#, #/[a]/#, #/a?a/#])
  func noAutoPossessify(pattern: Regex<Substring>) throws {
    var list = DSLList(tree: pattern.program.tree)
    list.autoPossessify()
    for node in list.nodes {
      switch node {
      case .quantification(_, let kind, _):
        #expect(
          kind.quantificationKind?.ast != .possessive,
          "Unexpected possessification in '\(pattern._literalPattern!)'")
      default: break
      }
    }
  }
}
