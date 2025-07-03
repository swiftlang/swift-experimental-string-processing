//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import ArgumentParser
import _RegexParser

@main
@available(SwiftStdlib 5.8, *)
struct Regex2BNF: ParsableCommand {
  @Argument(help: "The regex pattern to convert to BNF.")
  var pattern: String

  @Flag(
    name: [.customShort("e"), .customLong("examples")],
    help: "Run several examples")
  var runExamples = false

  func convert(_ pattern: String) throws {
    print("/\(pattern)/\n")
    let bnf = try convertRegexToBNF(
        regex: pattern, namespace: "RE2BNF", version: 0)
    print(bnf)
  }

  mutating func run() throws {
    if runExamples {
      // TODO: Turn into test cases
//      print("[Examples")

//      print("Single-scalar character literals:")
      try convert("a")
      try convert("Z")
      try convert("あ")
      try convert("日")
      try convert("\u{301}")


//      print("Multi-scalar character literals")
      try convert("🧟‍♀️")
      try convert("e\u{301}")

//      print("Simple alternations")
      try convert("a|b")
      try convert("a|b|c|d")
      try convert("a|🧟‍♀️\u{301}日|z")

//      print("Simple quantifications")
      try convert("a*")
      try convert("a+")
      try convert("a?")
      try convert("a{2,10}")
      try convert("a{,10}")
      try convert("a{2,}")

//      print("Grouping")
      try convert("a(b|c)d")
      try convert("a(?:b|c)d")
      try convert("a(bcd|def(g|h)+)z")

//      print("Dot")
      try convert(".*")
      try convert("(a|b)*.{3}(a|b)")

//      print("Bultin character classes")
      try convert(#"\(\d{3}\)\d{3}-\d{4}"#)
      try convert(#"\s+keyword\s+"#)


//      print("[Done]")

      // Look at optimizer output, the quant child is very long
      try convert("a(123456789)+b")

      try convert("Hi the time right now is (AM|PM)")

      try convert("a(b|c)*d{2,4}e?")
    }
    try convert(pattern)



  }
}
