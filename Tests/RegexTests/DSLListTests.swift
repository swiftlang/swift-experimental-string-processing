//
//  DSLListTests.swift
//  swift-experimental-string-processing
//
//  Created by Nate Cook on 9/25/25.
//

import Testing
@testable import _StringProcessing

@Suite
struct DSLListTests {
  @Test(arguments: [(#/abc/#, 4), (#/a(?:b+)c*/#, 7)])
  func simple(regex: Regex<Substring>, nodeCount: Int) {
    let dslList = DSLList(root: regex.root)
    #expect(dslList.nodes.count == nodeCount)
    for (i, node) in dslList.nodes.enumerated() {
      print(i, node)
    }
  }
}
