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

@Suite
struct DSLListTests {
  @available(macOS 9999, *)
  @Test(arguments: [
    (#/a/#, 2),             // literal, a
    (#/abcd+/#, 5),         // literal, concat, abc, quant, d
    (#/a(?:b+)c*/#, 8),     // literal, concat, a, noncap grp, quant, b, quant, c
  ])
  func convertedNodeCount(regex: Regex<Substring>, nodeCount: Int) {
    let dslList = regex.program.list
    #expect(dslList.nodes.count == nodeCount)
  }
  
  /// Every node's subtree must end where reading its children one after
  /// another ends, and the root's subtree must be the whole list.
  @available(macOS 26, *)
  @Test(arguments: [
    #"a"#, #"abc"#, #"a|b|c"#, #"a+b?c*"#, #"(a)(?:b|c+)(?<n>d)"#,
    #"(?:a*[ab])b"#, #"(?=a)(?!b)c"#, #"((a{2}){3}|b)+"#, #"(?i)a(?-i:b)"#,
    #"[a-c&&[b-d]]x"#, #""#,
  ])
  func indexAfterNodeCoversSubtrees(pattern: String) throws {
    let list = try Regex(pattern).program.list
    let count = list.nodes.count
    #expect(list.indexAfterNode(at: 0) == count)

    for i in 0..<count {
      let end = list.indexAfterNode(at: i)
      #expect(end > i && end <= count, "Bad subtree end at \(i) in '\(pattern)'")

      var next = i + 1
      for _ in 0..<list.nodes[i].directChildren {
        let childEnd = list.indexAfterNode(at: next)
        #expect(childEnd > next && childEnd <= end)
        next = childEnd
      }
      #expect(next == end, "Children of node \(i) don't fill its subtree in '\(pattern)'")
    }
  }
  
  @available(macOS 26, *)
  @Test func indexAfterNodeOutOfRange() async {
    let list = DSLList([.atom(.char("a"))])
    _ = list.indexAfterNode(at: 1)
    
    await #expect(processExitsWith: .failure) {
      let list = DSLList([.atom(.char("a"))])
      _ = list.indexAfterNode(at: 5)
    }
    await #expect(processExitsWith: .failure) {
      let list = DSLList([.atom(.char("a"))])
      _ = list.indexAfterNode(at: -1)
    }
  }

  /// `dropFirstSubtree()` must remove exactly what `indexAfterNode(at:)` says
  /// is the first node's subtree, wherever in the list it starts.
  @available(macOS 26, *)
  @Test(arguments: [
    #"a"#, #"a|b|c"#, #"a+b?c*"#, #"(a)(?:b|c+)(?<n>d)"#, #"((a{2}){3}|b)+"#, #""#,
  ])
  func dropFirstSubtreeMatchesIndexAfterNode(pattern: String) throws {
    let list = try Regex(pattern).program.list
    for i in 0..<list.nodes.count {
      var slice = list.nodes[i...]
      slice.dropFirstSubtree()
      #expect(slice.startIndex == list.indexAfterNode(at: i))
      #expect(slice.endIndex == list.nodes.count)
    }

    var empty = list.nodes[list.nodes.count...]
    empty.dropFirstSubtree()
    #expect(empty.isEmpty)
  }
}
