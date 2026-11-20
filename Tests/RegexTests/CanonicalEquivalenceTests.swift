//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Testing
@testable @_spi(RegexBenchmark) @_spi(RegexBuilder) import _StringProcessing
@testable import _RegexParser

@Suite struct CanonicalEquivalenceTests {
  /// The three ASCII characters that are canonically equivalent to a
  /// non-ASCII character.
  static let asciiEquivalentScalars:
    [(ascii: Unicode.Scalar, nonASCII: Unicode.Scalar)] = [
    (";", "\u{037E}"),  // GREEK QUESTION MARK
    ("K", "\u{212A}"),  // KELVIN SIGN
    ("`", "\u{1FEF}"),  // GREEK VARIA
  ]

  @available(SwiftStdlib 5.7, *)
  @Test func matchInGraphemeSemanticsOnly() throws {
    for (ascii, nonASCII) in Self.asciiEquivalentScalars {
      #expect("\(ascii)" == "\(nonASCII)")
      let subject = "xx\(nonASCII)yy"

      let patterns = [
        String(ascii),
        "\(ascii)+",
        "xx\(ascii)yy",
        "\(ascii)y",
        "abcdef\(ascii)ghijkl",
      ]
      for pattern in patterns {
        let input = pattern.hasPrefix("abcdef")
          ? "abcdef\(nonASCII)ghijkl"
          : subject
        let grapheme = try Regex(pattern).matchingSemantics(.graphemeCluster)
        #expect(
          try grapheme.firstMatch(in: input) != nil,
          """
          /\(pattern)/ should match \
          U+\(String(nonASCII.value, radix: 16, uppercase: true)) \
          under grapheme semantics
          """)

        let scalarMode = try Regex(pattern).matchingSemantics(.unicodeScalar)
        #expect(
          try scalarMode.firstMatch(in: input) == nil,
          """
          /\(pattern)/ should not match \
          U+\(String(nonASCII.value, radix: 16, uppercase: true)) \
          under scalar semantics
          """)
      }
    }
  }

  @available(SwiftStdlib 5.7, *)
  @Test func caseInsensitiveLiteralsMatchEquivalents() throws {
    for (ascii, nonASCII) in Self.asciiEquivalentScalars {
      for pattern in ["(?i)\(ascii)", "(?i)a\(ascii)b", "(?i)\\Qa\(ascii)b\\E"] {
        let subject = pattern.contains("a\(ascii)b")
          ? "a\(nonASCII)b"
          : String(nonASCII)

        let grapheme = try Regex(pattern).matchingSemantics(.graphemeCluster)
        #expect(
          try grapheme.firstMatch(in: subject) != nil,
          """
          /\(pattern)/ should match \
          U+\(String(nonASCII.value, radix: 16, uppercase: true)) \
          under grapheme semantics
          """)
      }
    }
  }

  @available(SwiftStdlib 5.7, *)
  @Test func combiningMarkPreventsMatch() throws {
    for (ascii, nonASCII) in Self.asciiEquivalentScalars {
      for spelling in [ascii, nonASCII] {
        let cluster = "\(spelling)\u{0301}"
        #expect(
          try Regex(String(ascii)).wholeMatch(in: cluster) == nil,
          "/\(ascii)/ should not whole-match \(cluster.unicodeScalars.count) scalars")
        #expect(
          try Regex(String(ascii)).firstMatch(in: "x\(cluster)y") == nil,
          "/\(ascii)/ should not match inside a combining sequence")
        #expect(
          try Regex("\(ascii)+").firstMatch(in: "x\(cluster)y") == nil)
      }
    }
  }

  /// Case-insensitive matching of a single ASCII scalar under scalar
  /// semantics must accept exactly the scalars whose lowercase mapping equals
  /// the pattern's -- not just the ASCII upper/lowercase pair. In particular,
  /// U+212A KELVIN SIGN lowercases to "k", so `(?i)k` has to match it.
  @available(SwiftStdlib 5.7, *)
  @Test func caseInsensitiveASCIIScalarMatchesAllCaseVariants() throws {
    // Everything that case-folds to each ASCII letter, found by brute force
    // rather than hard-coded, so the test states the rule instead of a list.
    var variants: [Unicode.Scalar: [Unicode.Scalar]] = [:]
    for scalar in allScalars {
      let lower = scalar.properties.lowercaseMapping
      guard lower.unicodeScalars.count == 1,
            let target = lower.unicodeScalars.first,
            target.isASCII, target.properties.isCased
      else { continue }
      variants[target, default: []].append(scalar)
    }
    #expect(variants.count == 26)
    #expect(variants["k"]?.contains("\u{212A}") == true)

    for (letter, scalars) in variants.sorted(by: { $0.key < $1.key }) {
      for pattern in [String(letter), String(letter).uppercased()] {
        for optimized in [true, false] {
          var regex = try Regex("(?i)\(pattern)").matchingSemantics(.unicodeScalar)
          if !optimized {
            precondition(regex._forceAction(.addOptions(.disableOptimizations)))
          }
          for scalar in scalars {
            let subject = String(scalar)
            #expect(
              try regex.wholeMatch(in: subject) != nil,
              """
              /(?i)\(pattern)/ should match U+\(String(scalar.value, radix: 16, uppercase: true)) \
              under scalar semantics (optimized: \(optimized))
              """)
          }
          // And nothing else near it: no other ASCII scalar, and a few
          // non-ASCII lookalikes that do not case-fold to this letter.
          for other in ["j", "l", "J", "L", "\u{17F}", "\u{130}", "\u{131}"]
          where !scalars.contains(other.unicodeScalars.first!) {
            #expect(try regex.wholeMatch(in: other) == nil)
          }
        }
      }
    }
  }

  @available(SwiftStdlib 5.7, *)
  @Test func optimizedAndUnoptimizedAgree() throws {
    for (ascii, scalar) in Self.asciiEquivalentScalars {
      let subject = "xx\(scalar)yy"
      for pattern in [String(ascii), "\(ascii)+", "xx\(ascii)yy"] {
        for level in [RegexSemanticLevel.graphemeCluster, .unicodeScalar] {
          var regex = try Regex(pattern).matchingSemantics(level)
          let optimized = try regex.firstMatch(in: subject)
          precondition(regex._forceAction(.addOptions(.disableOptimizations)))
          let unoptimized = try regex.firstMatch(in: subject)
          #expect(
            optimized.map { subject[$0.range] }
              == unoptimized.map { subject[$0.range] },
            """
            /\(pattern)/ diverges at \(level) for \
            U+\(String(scalar.value, radix: 16, uppercase: true))
            """)
        }
      }
    }
  }
}
