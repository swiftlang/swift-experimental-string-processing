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

@testable import _RegexParser
@testable import _StringProcessing

import XCTest

extension RegexTests {

  private func testCompilationEquivalence(
    _ equivs: [String],
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    assert(!equivs.isEmpty)
    let progs = try equivs.map {
      try _compileRegex($0).engine.program
    }
    let ref = progs.first!
    for (prog, equiv) in zip(progs, equivs).dropFirst() {
      guard ref.instructions.elementsEqual(
        prog.instructions) else {
          XCTFail("""
          Reference:
          \(ref)
          Current:
          \(prog)
          Compiled from:
          \(equiv)
          """,
          file: file, line: line)
          continue
        }
    }
  }

  func testCompileQuantification() throws {

    // NOTE: While we might change how we compile
    // quantifications, they should be compiled equivalently
    // for different syntactic expressions.
    let equivalents: Array<[String]> = [
      ["a*", "a{0,}"],
      ["a+", "a{1,}"],
      ["a?", "a{0,1}", "a{,1}"],

      ["a*?", "a{0,}?"],
      ["a+?", "a{1,}?"],
      ["a??", "a{0,1}?", "a{,1}?"],

      ["a*+", "a{0,}+"],
      ["a++", "a{1,}+"],
      ["a?+", "a{0,1}+", "a{,1}+"],
    ]

    for row in equivalents {
      try testCompilationEquivalence(row)
    }
  }

  func testCompileGroups() throws {
    let equivalents: Array<[String]> = [
      ["(?= assert)",
       "(*pla: assert)",
       "(*positive_lookahead: assert)"],
      ["(?! assert)",
       "(*nla: assert)",
       "(*negative_lookahead: assert)"],
      
      ["a+?",
       "(?U)a+",
       "(?U:a+)"],
      ["a+",
       "(?U)(?-U)a+",
       "(?U)(?^s)a+"],
    ]

    for row in equivalents {
      try testCompilationEquivalence(row)
    }
  }
  
  func testCompileInitialOptions() throws {
    func expectInitialOptions<T>(
      _ regex: Regex<T>,
      _ optionSequence: AST.MatchingOptionSequence,
      file: StaticString = #file,
      line: UInt = #line
    ) throws {
      var options = MatchingOptions()
      options.apply(optionSequence)
      
      XCTAssertTrue(
        regex.program.loweredProgram.initialOptions._equal(to: options),
        file: file, line: line)
    }
    
    func expectInitialOptions(
      _ pattern: String,
      _ optionSequence: AST.MatchingOptionSequence,
      file: StaticString = #file,
      line: UInt = #line
    ) throws {
      let regex = try Regex(pattern)
      try expectInitialOptions(regex, optionSequence, file: file, line: line)
    }

    try expectInitialOptions(".", matchingOptions())
    try expectInitialOptions("(?i)(?-i).", matchingOptions())

    try expectInitialOptions("(?i).", matchingOptions(adding: [.caseInsensitive]))
    try expectInitialOptions("(?i).(?-i)", matchingOptions(adding: [.caseInsensitive]))

    try expectInitialOptions(
      "(?im)(?s).",
      matchingOptions(adding: [.caseInsensitive, .multiline, .singleLine]))
    try expectInitialOptions(".", matchingOptions())
    
    // FIXME: Figure out (?X) and (?u) semantics
    try XCTExpectFailure("Figure out (?X) and (?u) semantics") {
      try expectInitialOptions(
        "(?im)(?s).(?u)",
        matchingOptions(adding: [.caseInsensitive, .multiline, .singleLine]))
    }
    
    try expectInitialOptions(
      "(?i:.)",
      matchingOptions(adding: [.caseInsensitive]))
    try expectInitialOptions(
      "(?i:.)(?m:.)",
      matchingOptions(adding: [.caseInsensitive]))
    try expectInitialOptions(
      "((?i:.))",
      matchingOptions(adding: [.caseInsensitive]))
  }

  private func expectProgram(
    for regex: String,
    syntax: SyntaxOptions = .traditional,
    semanticLevel: RegexSemanticLevel? = nil,
    contains targets: Set<Instruction.OpCode> = [],
    doesNotContain invalid: Set<Instruction.OpCode> = [],
    file: StaticString = #file,
    line: UInt = #line
  ) {
    do {
      let prog = try _compileRegex(regex, syntax, semanticLevel)
      var found: Set<Instruction.OpCode> = []
      for inst in prog.engine.instructions {
        if targets.contains(inst.opcode) {
          found.insert(inst.opcode)
        }

        if invalid.contains(inst.opcode) {
          XCTFail(
            "Compiled regex '\(regex)' contains incorrect opcode \(inst.opcode)",
            file: file,
            line: line)
          return
        }
      }

      if !found.isSuperset(of: targets) {
        XCTFail(
          "Compiled regex '\(regex)' did not contain desired opcodes. Wanted: \(targets), found: \(found)",
          file: file,
          line: line)
      }
    } catch {
      XCTFail(
        "Failed to compile regex '\(regex)': \(error)",
        file: file,
        line: line)
    }
  }

  func testBitsetCompile() {
    expectProgram(
      for: "[abc]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .matchBitsetScalar])
    expectProgram(
      for: "[abc]",
      semanticLevel: .unicodeScalar,
      contains: [.matchBitsetScalar],
      doesNotContain: [.matchBitset, .consumeBy])
  }

  func testScalarOptimizeCompilation() {
    expectProgram(
      for: "abcd",
      contains: [.matchScalar, .matchScalarUnchecked],
      doesNotContain: [.matchSequence, .consumeBy])
    expectProgram(
      for: "a",
      contains: [.matchScalar],
      doesNotContain: [.matchSequence, .consumeBy, .matchScalarUnchecked])
    expectProgram(
      for: "aaa\u{301}",
      contains: [.matchSequence],
      doesNotContain: [.matchScalar, .consumeBy, .matchScalarUnchecked])

    expectProgram(
      for: "abcd",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.matchSequence, .consumeBy, .matchScalar])
    expectProgram(
      for: "a",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.matchSequence, .consumeBy, .matchScalar])
    expectProgram(
      for: "aaa\u{301}",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.matchSequence, .consumeBy, .matchScalar])
  }
}
