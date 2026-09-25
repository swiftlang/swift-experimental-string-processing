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
import TestSupport

import XCTest

enum DecodedInstr {
  case invalid
  case moveImmediate
  case moveCurrentPosition
  case restorePosition
  case branch
  case condBranchZeroElseDecrement
  case condBranchSamePosition
  case save
  case saveAddress
  case splitSaving
  case clear
  case clearThrough
  case accept
  case fail
  case advance
  case match
  case matchCaseInsensitive
  case matchScalar
  case matchScalarCaseInsensitiveUnchecked
  case matchScalarCaseInsensitive
  case matchScalarUnchecked
  case matchBitsetScalar
  case matchAnyNonNewline
  case matchBitset
  case matchBuiltin
  case matchUTF8
  case consumeBy
  case assertBy
  case matchBy
  case backreference
  case beginCapture
  case endCapture
  case transformCapture
  case captureValue
  case quantify
}

extension DecodedInstr {
  /// Decode the given instruction by looking at the opcode and payload, expanding out certain instructions
  /// like matchScalar and match into their variants
  ///
  /// Must stay in sync with Processor.cycle
  static func decode(_ instruction: Instruction) -> DecodedInstr {
    let (opcode, payload) = instruction.destructure
    switch opcode {
    case .invalid:
      fatalError("Invalid program")
    case .moveImmediate:
      return .moveImmediate
    case .moveCurrentPosition:
      return .moveCurrentPosition
    case .restorePosition:
      return .restorePosition
    case .branch:
      return .branch
    case .condBranchZeroElseDecrement:
      return .condBranchZeroElseDecrement
    case .condBranchSamePosition:
      return .condBranchSamePosition
    case .save:
      return .save
    case .saveAddress:
      return .saveAddress
    case .splitSaving:
      return .splitSaving
    case .clear:
      return .clear
    case .clearThrough:
      return .clearThrough
    case .accept:
      return .accept
    case .fail:
      return .fail
    case .advance:
      return .advance
    case .match:
      let (isCaseInsensitive, _) = payload.elementPayload
      if isCaseInsensitive {
        return .matchCaseInsensitive
      } else {
        return .match
      }
    case .matchScalar:
      let (_, caseInsensitive, boundaryCheck) = payload.scalarPayload
      if caseInsensitive {
        if boundaryCheck {
          return .matchScalarCaseInsensitive
        } else {
          return .matchScalarCaseInsensitiveUnchecked
        }
      } else {
        if boundaryCheck {
          return .matchScalar
        } else {
          return .matchScalarUnchecked
        }
      }
    case .matchBitset:
      let (isScalar, _) = payload.bitsetPayload
      if isScalar {
        return .matchBitsetScalar
      } else {
        return .matchBitset
      }
    case .consumeBy:
      return .consumeBy
    case .matchAnyNonNewline:
      return .matchAnyNonNewline
    case .assertBy:
      return .assertBy
    case .matchBy:
      return .matchBy
    case .quantify:
      return .quantify
    case .backreference:
      return .backreference
    case .beginCapture:
      return .beginCapture
    case .endCapture:
      return .endCapture
    case .transformCapture:
      return .transformCapture
    case .captureValue:
      return .captureValue
    case .matchBuiltin:
      return .matchBuiltin
    case .matchUTF8:
      return .matchUTF8
    }
  }
}

extension RegexTests {

  private func testCompilationEquivalence(
    _ equivs: [String],
    file: StaticString = #filePath,
    line: UInt = #line
  ) throws {
    assert(!equivs.isEmpty)
    let progs = try equivs.map {
      try _compileRegex($0)
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

  private func testCompileError(
    _ regex: String, _ error: RegexCompilationError,
    file: StaticString = #filePath, line: UInt = #line
  ) {
    do {
      _ = try _compileRegex(regex)
      XCTFail("Expected compile error", file: file, line: line)
    } catch let err as RegexCompilationError {
      XCTAssertEqual(err, error, file: file, line: line)
    } catch {
      XCTFail("Unknown compile error", file: file, line: line)
    }
  }

  func testInvalidScalarCoalescing() throws {
    guard ensureNewStdlib() else { return }

    // Non-single-scalar bounds.
    testCompileError(
      #"[a\u{302}-✅]"#, .invalidCharacterClassRangeOperand("a\u{302}"))
    testCompileError(
      #"[e\u{301}-\u{302}]"#, .invalidCharacterClassRangeOperand("e\u{301}"))
    testCompileError(
      #"[\u{73}\u{323}\u{307}-\u{1E00}]"#,
      .invalidCharacterClassRangeOperand("\u{73}\u{323}\u{307}"))
    testCompileError(
      #"[a\u{315}\u{301}-\u{302}]"#,
      .invalidCharacterClassRangeOperand("a\u{315}\u{301}")
    )
    testCompileError(
      #"[a-z1e\u{301}-\u{302}\u{E1}3-59]"#,
      .invalidCharacterClassRangeOperand("e\u{301}")
    )
    testCompileError(
      #"[[e\u{301}-\u{302}]&&e\u{303}]"#,
      .invalidCharacterClassRangeOperand("e\u{301}")
    )
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
      file: StaticString = #filePath,
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
      file: StaticString = #filePath,
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

  func expectProgram(
    for regex: String,
    syntax: SyntaxOptions = .traditional,
    semanticLevel: RegexSemanticLevel? = nil,
    contains targets: Set<DecodedInstr> = [],
    doesNotContain invalid: Set<DecodedInstr> = [],
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    do {
      let prog = try _compileRegex(regex, syntax, semanticLevel)
      var found: Set<DecodedInstr> = []
      for inst in prog.instructions {
        let decoded = DecodedInstr.decode(inst)
        found.insert(decoded)

        if invalid.contains(decoded) {
          XCTFail(
            "Compiled regex '\(regex)' contains incorrect opcode \(decoded)",
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
    expectProgram(
      for: #"[\Qab\Ec]"#,
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .matchBitsetScalar])
    expectProgram(
      for: #"[\Qab\Ec]"#,
      semanticLevel: .unicodeScalar,
      contains: [.matchBitsetScalar],
      doesNotContain: [.matchBitset, .consumeBy])
    expectProgram(
      for: "[a-c]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .matchBitsetScalar])
    expectProgram(
      for: "[a-c0123]",
      contains: [.matchBitset],
      doesNotContain: [.matchBitsetScalar, .consumeBy])
    expectProgram(
      for: #"\w"#,
      contains: [.matchBuiltin],
      doesNotContain: [.consumeBy, .matchBitset, .matchBitsetScalar])
    expectProgram(
      for: #"[\w]"#,
      contains: [.matchBuiltin],
      doesNotContain: [.consumeBy, .matchBitset, .matchBitsetScalar])
    expectProgram(
      for: #"\w"#,
      semanticLevel: .unicodeScalar,
      contains: [.matchBuiltin],
      doesNotContain: [.consumeBy, .matchBitset, .matchBitsetScalar])
    expectProgram(
      for: #"[\w]"#,
      semanticLevel: .unicodeScalar,
      contains: [.matchBuiltin],
      doesNotContain: [.consumeBy, .matchBitset, .matchBitsetScalar])
    expectProgram(
      for: #"\p{Greek}"#,
      contains: [.consumeBy],
      doesNotContain: [.matchBuiltin, .matchBitset, .matchBitsetScalar])

    // MARK: Nested classes

    // A nested class folds into its parent's bitset.
    expectProgram(
      for: "[[abc]]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .matchBitsetScalar])
    expectProgram(
      for: "[[abc]d]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .matchBitsetScalar])
    // An inverted class, nested or not, folds its inversion into the bitset
    // rather than wrapping the match in save/clear/fail.
    expectProgram(
      for: "[^abc]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .save, .clear, .fail, .advance])
    expectProgram(
      for: "[^[abc]]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .save, .clear, .fail, .advance])
    expectProgram(
      for: "[[^abc]]",
      contains: [.matchBitset],
      doesNotContain: [.consumeBy, .save, .clear, .fail, .advance])

    // MARK: Set operations
    //
    // ASCII-only, non-inverted classes can fold into a single bitset
    // after algebraic operations. Otherwise, fall back to evaluating
    // both sides in sequence, which shows up as the
    // `.moveCurrentPosition`/`.restorePosition` pair.

    for op in ["&&", "--", "~~"] {
      // Folds: both operands are plain ASCII classes.
      expectProgram(
        for: "[a-z\(op)[aeiou]]",
        contains: [.matchBitset],
        doesNotContain: [
          .consumeBy, .matchBitsetScalar,
          .moveCurrentPosition, .restorePosition, .condBranchSamePosition])
      // Folds: inverting the whole class only flips the bitset's own flag.
      expectProgram(
        for: "[^a-z\(op)[aeiou]]",
        contains: [.matchBitset],
        doesNotContain: [
          .consumeBy, .matchBitsetScalar, .moveCurrentPosition,
          .restorePosition, .save, .clear, .fail, .advance])
      // Folds: operands may themselves be nested classes or quoted literals.
      expectProgram(
        for: "[[a-f]\(op)[c-z]]",
        contains: [.matchBitset],
        doesNotContain: [.consumeBy, .moveCurrentPosition, .restorePosition])
      expectProgram(
        for: #"[\Qab\E"# + op + "[ab]]",
        contains: [.matchBitset],
        doesNotContain: [.consumeBy, .moveCurrentPosition, .restorePosition])
      // Folds: chained operators, which associate to the left.
      expectProgram(
        for: "[a-z\(op)[b-y]\(op)[c-x]]",
        contains: [.matchBitset],
        doesNotContain: [.consumeBy, .moveCurrentPosition, .restorePosition])
      // Folds: a set operation unioned with sibling members.
      expectProgram(
        for: "[0-9[a-z\(op)[aeiou]]]",
        contains: [.matchBitset],
        doesNotContain: [.consumeBy, .moveCurrentPosition, .restorePosition])
      expectProgram(
        for: "[0-9\(op)[5-9]a-c]",
        contains: [.matchBitset],
        doesNotContain: [.consumeBy, .moveCurrentPosition, .restorePosition])
      // Folds: case-insensitive matching is baked into the bitset.
      expectProgram(
        for: "(?i)[a-z\(op)[aeiou]]",
        contains: [.matchBitset],
        doesNotContain: [
          .consumeBy, .matchCaseInsensitive, .matchScalarCaseInsensitive,
          .moveCurrentPosition, .restorePosition])
      // Folds, in scalar semantics, to the scalar bitset instruction.
      expectProgram(
        for: "[a-z\(op)[aeiou]]",
        semanticLevel: .unicodeScalar,
        contains: [.matchBitsetScalar],
        doesNotContain: [
          .consumeBy, .matchBitset,
          .moveCurrentPosition, .restorePosition])

      // Doesn't fold: an inverted operand. An inverted bitset also matches
      // every non-ASCII scalar, so it can't be combined bit-wise.
      expectProgram(
        for: "[a-z\(op)[^aeiou]]",
        contains: [.moveCurrentPosition, .restorePosition])
      expectProgram(
        for: "[[^a-z]\(op)[aeiou]]",
        contains: [.moveCurrentPosition, .restorePosition])
      // Doesn't fold: an inverted class nested inside an operand.
      expectProgram(
        for: "[a-z\(op)[[^b]]]",
        contains: [.moveCurrentPosition, .restorePosition])
      expectProgram(
        for: "[a-z\(op)[b[^c]]]",
        contains: [.moveCurrentPosition, .restorePosition])
      // Doesn't fold: an operand that isn't ASCII-only.
      expectProgram(
        for: "[a-z\(op)[aeiou\u{f6}]]",
        contains: [.moveCurrentPosition, .restorePosition])
      // Doesn't fold: an operand holding a built-in character class, which
      // isn't representable as an ASCII bitset.
      expectProgram(
        for: #"[a-z"# + op + #"[\w]]"#,
        contains: [.moveCurrentPosition, .restorePosition])
      expectProgram(
        for: #"[\d"# + op + "[0-5]]",
        contains: [.moveCurrentPosition, .restorePosition])
      // Doesn't fold: trivia members. Conservative rather than required --
      // the same is true of a non-set-operation class under (?xx).
      expectProgram(
        for: "(?xx)[ a \(op) ab ]",
        contains: [.moveCurrentPosition, .restorePosition])

      // MARK: Quantified set operations
      //
      // A foldable set operation can use the fused quantify instruction;
      // one that can't fold has to run the general quantification loop.
      expectProgram(
        for: "[a-z\(op)[aeiou]]+",
        contains: [.quantify],
        doesNotContain: [.matchBitset, .moveCurrentPosition, .restorePosition])
      expectProgram(
        for: "[a-z\(op)[aeiou]]{2,4}",
        contains: [.quantify],
        doesNotContain: [.matchBitset, .moveCurrentPosition, .restorePosition])
      expectProgram(
        for: "[^a-z\(op)[aeiou]]+",
        contains: [.quantify],
        doesNotContain: [.matchBitset, .moveCurrentPosition, .restorePosition])
      expectProgram(
        for: "[a-z\(op)[^aeiou]]+",
        contains: [.moveCurrentPosition, .restorePosition],
        doesNotContain: [.quantify])
    }

    // Must have new stdlib for character class ranges.
    guard ensureNewStdlib() else { return }
    
    expectProgram(
      for: "[a-á]",
      contains: [.consumeBy],
      doesNotContain: [.matchBitset, .matchBitsetScalar])
    expectProgram(
      for: "[a-fá-ém-zk]",
      contains: [.matchBitset, .consumeBy],
      doesNotContain: [.matchBitsetScalar])
  }

  func testScalarOptimizeCompilation() {
    // all ascii quoted literal -> elide boundary checks
    expectProgram(
      for: "abcd",
      contains: [.matchScalar, .matchScalarUnchecked],
      doesNotContain: [.match, .consumeBy])
    // ascii character -> matchScalar with boundary check
    expectProgram(
      for: "a",
      contains: [.matchScalar],
      doesNotContain: [.match, .consumeBy, .matchScalarUnchecked])
    // quoted literal is not all ascii -> match scalar when possible, always do boundary checks
    expectProgram(
      for: "aaa\u{301}",
      contains: [.match, .matchScalar],
      doesNotContain: [.consumeBy, .matchScalarUnchecked])
    // scalar mode -> always emit match scalar without boundary checks
    expectProgram(
      for: "abcd",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.match, .consumeBy, .matchScalar])
    expectProgram(
      for: "a",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.match, .consumeBy, .matchScalar])
    expectProgram(
      for: "a\u{301}",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.match, .consumeBy, .matchScalar])
    expectProgram(
      for: "abcdefg",
      semanticLevel: .unicodeScalar,
      contains: [.matchUTF8],
      doesNotContain: [.match, .consumeBy, .matchScalar])
    expectProgram(
      for: "abcdefg",
      semanticLevel: .graphemeCluster,
      contains: [.matchUTF8],
      doesNotContain: [.match, .consumeBy, .matchScalar])
    expectProgram(
      for: "aaa\u{301}",
      semanticLevel: .unicodeScalar,
      contains: [.matchUTF8],
      doesNotContain: [.match, .consumeBy, .matchScalar])
    expectProgram(
      for: "aaa\u{301}",
      semanticLevel: .graphemeCluster,
      contains: [.match],
      doesNotContain: [.matchUTF8, .consumeBy])
  }
  
  func testCaseInsensitivityCompilation() {
    // quoted literal is all ascii -> match scalar case insensitive and skip
    // boundary checks
    expectProgram(
      for: "(?i)abcd",
      contains: [.matchScalarCaseInsensitiveUnchecked, .matchScalarCaseInsensitive],
      doesNotContain: [.match, .matchCaseInsensitive, .matchScalar, .matchScalarUnchecked])
    // quoted literal is all non-cased ascii -> emit match scalar instructions
    expectProgram(
      for: "(?i)&&&&",
      contains: [.matchScalar, .matchScalarUnchecked],
      doesNotContain: [.match, .matchCaseInsensitive,
        .matchScalarCaseInsensitive, .matchScalarCaseInsensitiveUnchecked])
    // quoted literal is not all ascii -> match scalar case insensitive when
    // possible, match character case insensitive when needed, always perform
    // boundary check
    expectProgram(
      for: "(?i)abcd\u{301}",
      contains: [.matchCaseInsensitive, .matchScalarCaseInsensitive],
      doesNotContain: [.matchScalarCaseInsensitiveUnchecked, .match, .matchScalar])
    // same as before but contains ascii non cased characters -> emit matchScalar for them
    expectProgram(
      for: "(?i)abcd\u{301};.'!",
      contains: [.matchCaseInsensitive, .matchScalarCaseInsensitive, .matchScalar],
      doesNotContain: [.matchScalarCaseInsensitiveUnchecked, .match])
    // contains non-ascii non-cased characters -> emit match
    expectProgram(
      for: "(?i)abcd\u{301};.'!💖",
      contains: [.matchCaseInsensitive, .matchScalarCaseInsensitive, .matchScalar, .match],
      doesNotContain: [.matchScalarCaseInsensitiveUnchecked])
    
    // scalar mode -> emit unchecked scalar match only, emit case insensitive
    // only if the scalar is cased
    expectProgram(
      for: "(?i);.'!💖",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarUnchecked],
      doesNotContain: [.matchScalarCaseInsensitiveUnchecked])
    expectProgram(
      for: "(?i)abcdé",
      semanticLevel: .unicodeScalar,
      contains: [.matchScalarCaseInsensitiveUnchecked],
      doesNotContain: [.matchScalarUnchecked])
  }

  func testQuantificationForwardProgressCompile() {
    // Unbounded quantification + non forward progressing inner nodes
    // Expect to emit the position checking instructions
    expectProgram(for: #"(?:(?=a)){1,}"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\b)*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:(?#comment))+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:|)+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|)+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?i-i:))+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?#comment))+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?#comment)(?i-i:))+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?i))+"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:A*(?:b|c*))*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:[^/]*(?:/|$))*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:(?=a)\d*)*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:(?!a)\d*)*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:(?!\d)[0-9]*)*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])

    // Bounded quantification, don't emit position checking
    expectProgram(for: #"(?:(?=a)){1,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\b)?"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:(?#comment)){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:|){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?i-i:)){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?#comment)){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?#comment)(?i-i:)){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(?:\w|(?i)){,4}"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
  
    // Inner node is a quantification that does not guarantee forward progress
    expectProgram(for: #"(a*)*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(a?)*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(a{,5})*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"((\b){,4})*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"((\b){1,4})*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"((|){1,4})*"#, contains: [.moveCurrentPosition, .condBranchSamePosition])
    // Inner node is a quantification that guarantees forward progress
    expectProgram(for: #"(a+)*"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
    expectProgram(for: #"(a{1,})*"#, doesNotContain: [.moveCurrentPosition, .condBranchSamePosition])
  }
  
  func testCanOnlyMatchAtStart() throws {
    func expectCanOnlyMatchAtStart(
      _ regexStr: String,
      _ expectTrue: Bool,
      file: StaticString = #filePath,
      line: UInt = #line
    ) throws {
      let regex = try Regex(regexStr)
      XCTAssertEqual(
        regex.program.loweredProgram.canOnlyMatchAtStart, expectTrue,
        file: file, line: line)
    }
    
    try expectCanOnlyMatchAtStart("^foo", true)        // anchor
    try expectCanOnlyMatchAtStart("\\Afoo", true)      // more specific anchor
    try expectCanOnlyMatchAtStart("foo", false)        // no anchor

    try expectCanOnlyMatchAtStart("(?i)^foo", true)    // unrelated option
    try expectCanOnlyMatchAtStart("(?m)^foo", false)   // anchors match newlines
    try expectCanOnlyMatchAtStart("(?i:^foo)", true)   // unrelated option
    try expectCanOnlyMatchAtStart("(?m:^foo)", false)  // anchors match newlines

    try expectCanOnlyMatchAtStart("(^foo|bar)", false) // one side of alternation
    try expectCanOnlyMatchAtStart("(foo|^bar)", false) // other side of alternation
    try expectCanOnlyMatchAtStart("(^foo|^bar)", true) // both sides of alternation

    // Test quantifiers that include the anchor
    try expectCanOnlyMatchAtStart("(^foo)?bar", false)
    try expectCanOnlyMatchAtStart("(^foo)*bar", false)
    try expectCanOnlyMatchAtStart("(^foo)+bar", true)
    try expectCanOnlyMatchAtStart("(?:^foo)+bar", true)

    // Test quantifiers before the anchor
    try expectCanOnlyMatchAtStart("(foo)?^bar", true)  // The initial group must match ""
    try expectCanOnlyMatchAtStart("(?:foo)?^bar", true)
    try expectCanOnlyMatchAtStart("(foo)+^bar", false) // This can't actually match anywhere
    
    // Test lookahead assertions with anchor
    try expectCanOnlyMatchAtStart("(?=^)foo", true)
    try expectCanOnlyMatchAtStart("(?!^)foo", false)
  }
}
