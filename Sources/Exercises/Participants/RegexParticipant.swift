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

import _StringProcessing
import RegexBuilder

/*

 TODO: We probably want to allow participants to register
 multiple variations or strategies.

 We have:

 1) DSL vs literal
 2) HareVM, TortoiseVM, transpile to PEG, transpile to
    MatchingEngine

*/


struct RegexDSLParticipant: Participant {
  static var name: String { "Regex DSL" }

    // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyData(forLine:)
  }
}

struct RegexLiteralParticipant: Participant {
  static var name: String { "Regex Literal" }

    // Produce a function that will parse a grapheme break entry from a line
  static func graphemeBreakProperty() throws -> (String) -> GraphemeBreakEntry? {
    graphemeBreakPropertyDataLiteral(forLine:)
  }
}

// MARK: - Regex literal

private func extractFromCaptures(
  _ match: (Substring, Substring, Substring?, Substring)
) -> GraphemeBreakEntry? {
  guard let lowerScalar = Unicode.Scalar(hex: match.1),
        let upperScalar = match.2.map(Unicode.Scalar.init(hex:)) ?? lowerScalar,
        let property = Unicode.GraphemeBreakProperty(match.3)
  else {
    return nil
  }
  return GraphemeBreakEntry(lowerScalar...upperScalar, property)
}

@inline(__always) // get rid of generic please
private func graphemeBreakPropertyData<RP: RegexComponent>(
  forLine line: String,
  using regex: RP
) -> GraphemeBreakEntry? where RP.Output == (Substring, Substring, Substring?, Substring) {
  line.match(regex).map(\.output).flatMap(extractFromCaptures)
}

private func graphemeBreakPropertyDataLiteral(
  forLine line: String
) -> GraphemeBreakEntry? {
  return graphemeBreakPropertyData(
    forLine: line,
    using: r(#"([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+(\w+).*"#,
             matching: (Substring, Substring, Substring?, Substring).self))
}

// MARK: - Builder DSL

private func graphemeBreakPropertyData(
  forLine line: String
) -> GraphemeBreakEntry? {
  line.match {
    TryCapture(OneOrMore(.hexDigit)) { Unicode.Scalar(hex: $0) }
    Optionally {
      ".."
      TryCapture(OneOrMore(.hexDigit)) { Unicode.Scalar(hex: $0) }
    }
    OneOrMore(.whitespace)
    ";"
    OneOrMore(.whitespace)
    TryCapture(OneOrMore(.word)) { Unicode.GraphemeBreakProperty($0) }
    ZeroOrMore(.any)
  }.map {
    let (_, lower, upper, property) = $0.output
    return GraphemeBreakEntry(lower...(upper ?? lower), property)
  }
}
