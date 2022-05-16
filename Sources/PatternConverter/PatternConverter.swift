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

// swift run PatternConverter <regex>

import ArgumentParser
import _RegexParser
@_spi(PatternConverter) import _StringProcessing

@main
struct PatternConverter: ParsableCommand {

  @Argument(help: "The regex to convert")
  var regex: String

  @Flag(help: "Whether to use the experimental syntax")
  var experimentalSyntax: Bool = false

  @Flag(help: "Whether to show rendered source ranges")
  var renderSourceRanges: Bool = false

  @Flag(help: "Whether to show canonical regex literal")
  var showCanonical: Bool = false

  @Flag(help: "Whether to skip result builder DSL")
  var skipDSL: Bool = false

  @Option(help: "Limit (from top-down) the conversion levels")
  var topDownConversionLimit: Int?

  @Option(help: "(TODO) Limit (from bottom-up) the conversion levels")
  var bottomUpConversionLimit: Int?

  func run() throws {
    print("""

    NOTE: This tool is experimental and its output is not
          necessarily compilable.

    """)
    let delim = experimentalSyntax ? "|" : "/"
    print("Converting '\(delim)\(regex)\(delim)'")

    let ast = try _RegexParser.parse(
      regex, .semantic,
      experimentalSyntax ? .experimental : .traditional)

    // Show rendered source ranges
    if renderSourceRanges {
      print()
      print(regex)
      print(ast._render(in: regex).joined(separator: "\n"))
      print()
    }

    if showCanonical {
      print("Canonical:")
      print()
      print(ast.renderAsCanonical())
      print()
    }

    print()
    if !skipDSL {
      let render = renderAsBuilderDSL(
        ast: ast,
        maxTopDownLevels: topDownConversionLimit,
        minBottomUpLevels: bottomUpConversionLimit
      )
      print(render)
    }

    return
  }
}
