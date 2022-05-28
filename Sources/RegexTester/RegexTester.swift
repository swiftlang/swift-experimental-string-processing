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

import ArgumentParser
import _RegexParser
import _StringProcessing

@main
@available(macOS 9999, *)
struct RegexTester: ParsableCommand {
  typealias MatchFunctionType = (String) throws -> Regex<AnyRegexOutput>.Match?

  @Argument(help: "The regex pattern to test.")
  var pattern: String
  
  @Argument(help: "One or more input strings to test against <pattern>.")
  var inputs: [String]
  
  @Flag(
    name: [.customShort("p"), .customLong("partial")],
    help: "Allow partial matches.")
  var allowPartialMatch: Bool = false
  
  mutating func run() throws {
    print("Using pattern \(pattern.halfWidthCornerQuoted)")
    let regex = try Regex(pattern)
    
    for input in inputs {
      print("Input \(input.halfWidthCornerQuoted)")
      
      let matchFunc: MatchFunctionType = allowPartialMatch
        ? regex.firstMatch(in:)
        : regex.wholeMatch(in:)
      
      if let result = try matchFunc(input) {
        print("   matched: \(result.0.halfWidthCornerQuoted)")
      } else {
        print("   no match")
      }
    }
  }
}
