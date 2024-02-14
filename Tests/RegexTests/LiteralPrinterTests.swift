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

import XCTest
@_spi(LiteralPattern)
import _StringProcessing
import RegexBuilder

@available(SwiftStdlib 5.9, *)
extension RegexTests {
  func testPrintableRegex() throws {
    let regexString = #"([a-fGH1-9[^\D]]+)?b*cd(e.+)\2\w\S+?"#
    let regex = try! Regex(regexString)
    let pattern = try XCTUnwrap(regex._literalPattern)
    // Note: This is true for this particular regex, but not all regexes
    XCTAssertEqual(regexString, pattern)
    
    let printableRegex = try XCTUnwrap(PrintableRegex(regex))
    XCTAssertEqual("\(printableRegex)", pattern)
  }
  
  func testPrintableDSLRegex() throws {
    let regex = Regex {
      OneOrMore("aaa", .reluctant)
      Regex {
        ChoiceOf {
          ZeroOrMore("bbb")
          OneOrMore("d")
          Repeat("e", 3...)
        }
      }.dotMatchesNewlines()
      Optionally("c")
    }.ignoresCase()
    let pattern = try XCTUnwrap(regex._literalPattern)
    XCTAssertEqual("(?i:(?:aaa)+?(?s:(?:bbb)*|d+|e{3,})c?)", pattern)

    let nonPrintableRegex = Regex {
      OneOrMore("a")
      Capture {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      Optionally("b")
    }
    XCTAssertNil(nonPrintableRegex._literalPattern)
  }
}

// MARK: - PrintableRegex

// Demonstration of a guaranteed Codable/Sendable regex type.
@available(macOS 9999, *)
struct PrintableRegex: RegexComponent, @unchecked Sendable {
  var pattern: String
  var regex: Regex<AnyRegexOutput>
  
  init?(_ re: some RegexComponent) {
    guard let pattern = re.regex._literalPattern
    else { return nil }
    self.pattern = pattern
    self.regex = Regex(re.regex)
  }
  
  func matches(in string: String) -> Bool {
    string.contains(regex)
  }
  
  func wholeMatches(in string: String) -> Bool {
    string.wholeMatch(of: regex) != nil
  }
}

@available(macOS 9999, *)
extension PrintableRegex: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.pattern = try container.decode(String.self)
    self.regex = try Regex(self.pattern)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(pattern)
  }
}

@available(macOS 9999, *)
extension PrintableRegex: CustomStringConvertible {
  var description: String {
    pattern
  }
}
