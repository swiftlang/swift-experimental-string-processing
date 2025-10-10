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

/// Convert regex syntax to BNF.
///
/// - Parameters:
///   - regex: The regex to convert.
///   - namespace: A namespace to use for generated symbols, to disambiguate when multiple regexes are used in a single grammar.
///   - version: The version of the BNF to generate. Currently, only supports version 0.
///
/// NOTE: This function should be treated as source-stable API.
///
public func convertRegexToBNF(
    regex: String, namespace: String, version: Int
) throws -> String {
  guard version == 0 else {
    fatalError("Unknown version \(version)")
  }

  // TODO: Should we pass in our language subset constraints here to
  // error at parse time rather than conversion time?
  let ast = try _RegexParser.parse(regex, .init())

  var converter = BNFConvert(namespace: namespace)
  let rhs = try converter.convert(ast.root)
  converter.root = converter.createProduction("ROOT", rhs)
  converter.optimize()
  let bnf = converter.createBNF()

  return bnf.render()
}

