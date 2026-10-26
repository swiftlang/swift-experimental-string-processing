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
  @available(macOS 26, *)
  @Test(arguments: [#/a/#, #/a+/#, #/(?:a+)/#, #/(?:a)+/#, #/(?m)a+/#, #/ab?c/#, #/(?:a+)+$/#, #/(?:(?:a+b)+b)/#])
  func requiredFirstAtom(pattern: Regex<Substring>) throws {
    let list = pattern.program.list
    let atom = list.requiredFirstAtom(allowOptionsChanges: true)
    #expect(atom?.literalCharacterValue == "a", "Missing first character atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 26, *)
  @Test(arguments: [#/a?/#, #/(?:a|b)/#, #/[a]/#, #/a?bc/#])
  func noRequiredFirstAtom(pattern: Regex<Substring>) throws {
    let list = pattern.program.list
    let atom = list.requiredFirstAtom(allowOptionsChanges: true)
    #expect(atom == nil, "Unexpected required first atom in '\(pattern._literalPattern!)'")
  }
  
  @available(macOS 26, *)
  @Test(arguments: [#/a+b/#, #/a*b/#, #/\w+\s/#, #/(?:a+b|b+a)/#, #/\d+a/#, #/a+A/#, #/(?:x|a+b)/#])
  func autoPossessify(pattern: Regex<Substring>) throws {
    var list = pattern.program.list
    list.autoPossessify()
    for node in list.nodes {
      switch node {
      case .quantification(_, let kind):
        #expect(
          kind.isExplicit && kind.quantificationKind?.ast == .possessive,
          "Expected possessification in '\(pattern._literalPattern!)'")
      default: break
      }
    }
  }

  @available(macOS 26, *)
  @Test(arguments: [
    #/a?/#, #/a+a/#, #/a+(?:b|c)/#, #/(?:a+|b+)/#, #/[a]/#, #/a?a/#,
    #/(?i)a+A/#, #/(?i:a+A)/#,  // case insensitivity when checking exclusion
    #/(?:(?:ab)+b)/#,           // single atom quantifications only
    #/\w*(?:\s*)a/#,            // optional quantifier in between
  ])
  func noAutoPossessify(pattern: Regex<Substring>) throws {
    var list = pattern.program.list
    list.autoPossessify()
    for node in list.nodes {
      switch node {
      case .quantification(_, let kind):
        #expect(
          kind.quantificationKind?.ast != .possessive,
          "Unexpected possessification in '\(pattern._literalPattern!)'")
      default: break
      }
    }
  }

  @available(macOS 26, *)
  @Test(arguments: [
    #"(\w* {1})a"#, #"(\w* {2})a"#, #"(\w* {0} {1})a"#, #"(\w*)\s"#, #"((\w+)) b"#,
    #"(\w{1,} +)b"#, #"(?:\w* {1})a"#, #"\d{,1}\W"#,
  ])
  func autoPossessifyFirstQuantification(pattern: String) throws {
    // Valid possessification near skipped/zero-width nodes must still happen.
    var list = try Regex(pattern).program.list
    list.autoPossessify()
    let first = list.nodes.first {
      if case .quantification = $0 { return true } else { return false }
    }
    guard case .quantification(_, let kind)? = first else {
      Issue.record("No quantification in '\(pattern)'")
      return
    }
    #expect(kind.isExplicit && kind.quantificationKind?.ast == .possessive,
            "Expected possessification in '\(pattern)'")
  }

  @available(macOS 26, *)
  @Test(arguments: [#"(\w* {0})a"#, #"((\w* {0})){1}()a"#, #"(\w*)(?: {0})a"#])
  func noAutoPossessifyAcrossSkippedNode(pattern: String) throws {
    // The zero-width quantification doesn't hide the `a` that follows `\w*`.
    var list = try Regex(pattern).program.list
    list.autoPossessify()
    let first = list.nodes.first {
      if case .quantification = $0 { return true } else { return false }
    }
    guard case .quantification(_, let kind)? = first else {
      Issue.record("No quantification in '\(pattern)'")
      return
    }
    #expect(kind.quantificationKind?.ast != .possessive,
            "Unexpected possessification in '\(pattern)'")
  }

  @available(macOS 26, *)
  @Test func digitWordExclusionDependsOnOptions() throws {
    func firstIsPossessive(_ regex: Regex<AnyRegexOutput>) -> Bool {
      var list = regex.program.list
      list.autoPossessify()
      for case .quantification(_, let kind) in list.nodes {
        return kind.quantificationKind?.ast == .possessive
      }
      return false
    }
    // Digits are always word characters, so `\d?` can't give up input `\W` needs.
    #expect(firstIsPossessive(try Regex(#"\d?\W"#)))
    #expect(firstIsPossessive(try Regex(#"\d?\W"#).asciiOnlyDigits().asciiOnlyWordCharacters()))
    // Unless only `\w` is ASCII-only: then non-ASCII digits are `\W`.
    #expect(!firstIsPossessive(try Regex(#"\d?\W"#).asciiOnlyWordCharacters()))
  }
}
