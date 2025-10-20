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
@testable import _StringProcessing

@Suite
struct DSLListTests {
  @available(macOS 9999, *)
  @Test(arguments: [
    (#/a/#, 2),             // literal, a
    (#/abcd+/#, 5),         // literal, concat, abc, quant, d
    (#/a(?:b+)c*/#, 8),     // literal, concat, a, noncap grp, quant, b, quant, c
  ])
  func convertedNodeCount(regex: Regex<Substring>, nodeCount: Int) {
    let dslList = regex.program.tree
    #expect(dslList.nodes.count == nodeCount)
  }
  
  @Test(arguments: [#/a|b/#, #/a+b?c/#, #/abc/#, #/a(?:b+)c*/#, #/;[\r\n]/#, #/(?=(?:[1-9]|(?:a|b)))/#])
  func compilationComparison(regex: Regex<Substring>) throws {
    let listCompiler = Compiler(list: regex.program.tree)
    let listProgram = try listCompiler.emitViaList()

//    #expect(treeProgram.instructions == listProgram.instructions)
  }
}
