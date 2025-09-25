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

@Suite
struct OptimizationTests {
  @available(macOS 9999, *)
  @Test(arguments: [#/a/#, #/a+/#, #/(?:a+)/#, #/(?:a)+/#, #/(?m)a+/#, #/ab?c/#, #/(?:a+)+$/#])
  func requiredFirstAtom(pattern: Regex<Substring>) throws {
    let atom = pattern.root.requiredFirstAtom()
    #expect(atom?.literalCharacterValue == "a", "Missing first character atom in '\(pattern._literalPattern!)'")
    
    let list = DSLList(tree: pattern.program.tree)
    var nodes = list.nodes[...]
    let atom2 = _StringProcessing.requiredFirstAtom(&nodes)
    #expect(atom2?.literalCharacterValue == "a", "Missing first character atom in '\(pattern._literalPattern!)'")
    
    let atom3 = list.requiredFirstAtom()
    #expect(atom3?.literalCharacterValue == "a", "Missing first character atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 9999, *)
  @Test(arguments: [#/a?/#, #/(?:a|b)/#, #/[a]/#, #/a?bc/#])
  func noRequiredFirstAtom(pattern: Regex<Substring>) throws {
    let atom = pattern.root.requiredFirstAtom()
    #expect(atom == nil, "Unexpected required first atom in '\(pattern._literalPattern!)'")
    
    let list = DSLList(tree: pattern.program.tree)
    var nodes = list.nodes[...]
    let atom2 = _StringProcessing.requiredFirstAtom(&nodes)
    #expect(atom2 == nil, "Unexpected required first atom in '\(pattern._literalPattern!)'")
    
    let atom3 = list.requiredFirstAtom()
    #expect(atom3 == nil, "Unexpected required first atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 9999, *)
  @Test(arguments: [#/a/#, #/a+/#, #/(?:a+)/#, #/(?:a)+/#, #/(?m)a+/#, #/cb?a/#])
  func requiredLastAtom(pattern: Regex<Substring>) throws {
    let atom = pattern.root.requiredLastAtom()
    #expect(atom?.literalCharacterValue == "a", "Missing last character atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 9999, *)
  @Test(arguments: [#/a?/#, #/a*/#, #/(?:a|b)/#, #/[a]/#, #/abc?/#])
  func noRequiredLastAtom(pattern: Regex<Substring>) throws {
    let atom = pattern.root.requiredLastAtom()
    #expect(atom == nil, "Unexpected required last atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 9999, *)
  @Test(arguments: [#/(?:a+b|b+a)/#]) //[#/a+b/#, #/a*b/#, #/\d+a/#, #/\w+\s/#, #/(?:a+b|b+a)/#])
  func autoPossessify(pattern: Regex<Substring>) throws {
    var list = DSLList(tree: pattern.program.tree)
    var index = 0
    _ = list.autoPossessifyNextQuantification(&index)
    print(pattern._literalPattern!)
    dump(list)
  }

  @available(macOS 9999, *)
  @Test(arguments: [#/a?/#, #/(?:a|b)/#, #/(?:a+|b+)/#, #/[a]/#, #/a?a/#])
  func noAutoPossessify(pattern: Regex<Substring>) throws {
    var list = DSLList(tree: pattern.program.tree)
    list.autoPossessify()
  }
}
