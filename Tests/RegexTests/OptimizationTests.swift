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
    #/(?:a*[ab])b/#,            // a component that rules out a required atom
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

  /// The number of quantifications in `pattern` that auto-possessification
  /// converts to possessive, and the total number of quantifications.
  @available(macOS 26, *)
  func possessificationCounts(
    in pattern: String
  ) throws -> (possessive: Int, total: Int) {
    var list = try Regex(pattern).program.list
    list.autoPossessify()
    var possessive = 0
    var total = 0
    for node in list.nodes {
      guard case .quantification(_, let kind) = node else { continue }
      total += 1
      if kind.isExplicit && kind.quantificationKind?.ast == .possessive {
        possessive += 1
      }
    }
    return (possessive, total)
  }

  /// Auto-possessification walks a flat list of nodes, so a case that stops
  /// looking at a node's children has to leave the cursor past the whole
  /// subtree anyway. Losing track of it possessifies the wrong quantification,
  /// which drops matches, or stops the traversal short, which silently gives
  /// up the optimization.
  @available(macOS 26, *)
  @Test func partialAutoPossessify() throws {
    // pattern, expected possessive count, expected quantification count
    let expectations: [(String, Int, Int)] = [
      // Every quantification of a concatenation participates, not just the
      // first one.
      (#"a+b\d+c"#, 2, 2),
      (#"x*a+b"#, 2, 2),
      (#"\w+\s\d+a"#, 2, 2),
      // `\s?` is excluded by the following `b`, but `b{1,3}` isn't
      // possessifiable, because `\s?` is allowed to match nothing.
      (#"(b{1,3}\s?)b"#, 1, 2),
      // Same, one level down: only `\+*` is excluded by what follows it.
      (#"(?i)(?:a*\+*)A{2}"#, 1, 3),
      // Nothing is known about what has to match after `[ab]`, so `a*` can't
      // be possessified at any level.
      (#"(?:a*[ab])b"#, 0, 1),
      (#"(?:(?:a*[ab])x?)b"#, 1, 2),
    ]
    for (pattern, possessive, total) in expectations {
      let counts = try possessificationCounts(in: pattern)
      #expect(
        counts == (possessive, total),
        "Unexpected possessification in '\(pattern)'")
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
  @Test(arguments: [#"(\w* {0})a"#, #"((\w* {0})){1}()a"#, #"(\w*)(?: {0})a"#,
    // `\s*` can be possessified, but an optional quantifier hides what follows `\w*`
    #"\w*(?:\s*)a"#,
  ])
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
