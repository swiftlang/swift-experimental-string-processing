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

@testable import _MatchingEngine

import XCTest
@testable import _StringProcessing

extension RECode.Instruction: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = Character
  public init(extendedGraphemeClusterLiteral value: Character) {
    self = .character(value)
  }
}

extension RECode: Equatable {
  public static func ==(lhs: RECode, rhs: RECode) -> Bool {
    return lhs.instructions == rhs.instructions
    && lhs.labels == rhs.labels && lhs.options == rhs.options
  }
}

struct ExpectedPass {
  let input: String
  let range: Range<String.Index>
  let expected: String
  let expectedCaptures: [[String]]

  init(
    _ input: String,
    offsets: Offsets? = nil,
    expected: String,
    expectedCaptures: [[String]] = []
  ) {
    self.input = input
    self.range = input.flatmapOffsets(offsets)
    self.expected = expected
    self.expectedCaptures = expectedCaptures
  }
}


private struct TestCase {
  let regex: String
  let pass: [ExpectedPass]
  let fail: [String]
  let range: Range<String.Index>
  let mode: _StringProcessing.MatchMode
  let expected: (String?, [[String]])

  init(regex: String, input: String) {
    fatalError()
  }
}

struct TestExpectation<Capture> {
  let content: String?
  let captures: Capture
  // A function that determines
  let capturesEqual: (Capture, Capture) -> Bool

  init(
    _ content: String? = nil,
    captures: Capture,
    capturesEqual: @escaping (Capture, Capture) -> Bool
  ) {
    self.content = content
    self.captures = captures
    self.capturesEqual = capturesEqual
  }

  init(_ content: String? = nil) where Capture == Void {
    self.content = content
    self.captures = ()
    self.capturesEqual = { _, _ in true }
  }

  func isExpectedCapture(_ actualCaptures: Capture) -> Bool {
    capturesEqual(actualCaptures, captures)
  }

  func isExpectedContentIfSpecified(_ actualContent: Substring) -> Bool {
    return content.map { $0 == actualContent } ?? true
  }
}

private func performTest<Capture>(
  regex: String,
  input: String,
  offsets: Offsets? = nil,
  mode: _StringProcessing.MatchMode = .wholeString,
  expectedCaptureType: Capture.Type,
  expecting expectation: TestExpectation<Capture>?
) {
  let range = input.flatmapOffsets(offsets)
  let ast = try! parse(regex, .traditional)
  func report(name: String,
              matchedRange: Range<String.Index>?,
              actualCaptures: Any?,
              expectedCaptures: Capture?
  ) -> String {
    return """
      \(name) failed
      Regex:    \(regex)
      Input:    \(input)
      Matched range: \(String(describing: matchedRange))
      Matched content: \(matchedRange.map { "\"\(input[$0])\"" } ?? "none")
      Expected captures: \(expectedCaptures.map { "\"\($0)\": \(type(of: $0))" } ?? "none")
      Saw: \(actualCaptures.map { "\"\($0)\": \(type(of: $0))" } ?? "none")
      """
  }
  func run<VM: VirtualMachine>(_ vm: VM, name: String) {
    let actualResult = vm.execute(input: input, in: range, mode: mode)
    switch (actualResult, expectation) {
    case let (result?, expectation?) where Capture.self != Void.self:
      guard expectation.isExpectedContentIfSpecified(input[result.range]),
            let actualCapture = result.captures.value as? Capture,
            expectation.isExpectedCapture(actualCapture) else {
        XCTFail(report(
          name: name,
          matchedRange: result.range,
          actualCaptures: result.captures.value,
          expectedCaptures: expectation.captures))
        break
      }
    case (_?, nil), (nil, _?):
      XCTFail(report(
        name: name,
        matchedRange: actualResult?.range,
        actualCaptures: actualResult?.captures.value,
        expectedCaptures: expectation?.captures))
    default:
      break
    }
  }
  let legacyProgram = try! compile(ast)
  run(TortoiseVM(program: legacyProgram), name: "Lonesome George")
  run(HareVM(program: legacyProgram), name: "Harvey")
  // TODO: Support captures in the matching engine.
  guard !ast.hasCapture else {
    return
  }
  let program = try! Compiler(ast: ast).emit()
  run(Executor(program: program), name: "Matching Engine")
}

extension RegexTests {
  func testLegacyCompile() {
    func performTest(_ input: String, _ expecting: RECode, line: UInt = #line) {
      let recode = try! compile(input)
      guard recode == expecting else {
        XCTFail("""

                  Expected: \(expecting)
                  Found:    \(recode)
                  """, line: line)
        return
      }
    }

    func recode(
      _ list: RECode.Instruction..., labels: [Int] = [], splits: [Int] = []
    ) -> RECode {
      return RECode(instructions: list + [.accept],
                    labels: labels.map { InstructionAddress($0) },
                    splits: splits.map { InstructionAddress($0) },
                    options: .none)
    }
    func label(_ id: Int) -> RECode.Instruction {
      return .label(LabelId(id))
    }
    func split(disfavoring id: Int) -> RECode.Instruction {
      return .split(disfavoring: LabelId(id))
    }
    func goto(label id: Int) -> RECode.Instruction {
      return .goto(label: LabelId(id))
    }

    performTest(
      "abc", recode("a", "b", "c"))
    performTest(
      "abc\\+d*",
      recode("a", "b", "c", "+", label(0),
             split(disfavoring: 1), "d", goto(label: 0), label(1),
             labels: [4, 8]))
    performTest(
      "a(b)c",
      recode(
        .beginGroup,
        "a", .beginCapture, "b", .endCapture(), "c",
        .endGroup))
    performTest(
      "a(?:b)c",
      recode(
        "a", .beginGroup, "b", .endGroup, "c"))
    performTest(
      "abc(?:de)+fghi*k|j",
      recode(split(disfavoring: 1),
             "a", "b", "c",
             label(2),
             .beginGroup,
             "d", "e",
             .endGroup,
             split(disfavoring: 3), goto(label: 2),
             label(3),
             "f", "g", "h",
             label(4),
             split(disfavoring: 5), "i", goto(label: 4),
             label(5), "k",
             goto(label: 0),
             label(1), "j",
             label(0),
             labels: [24, 22, 4, 11, 15, 19]))
    performTest(
      "a(?:b|c)?d",
      recode(
        "a",
        split(disfavoring: 0),
        .beginGroup,
        split(disfavoring: 2), "b",
        goto(label: 1),
        label(2), "c",
        label(1),
        .endGroup,
        label(0),
        "d",
        labels: [10, 8, 6],
        splits: [3, 5]))
    performTest(
      "a(b|c)?d",
      recode(.beginGroup,
             "a",
             .beginGroup,
             split(disfavoring: 0),
             .beginCapture,
             split(disfavoring: 3), "b", goto(label: 2),
             label(3), "c",
             label(2),
             .endCapture(),
             .captureSome,
             goto(label: 1),
             label(0),
             .captureNil(childType: Substring.self),
             label(1),
             .endGroup,
             "d",
             .endGroup,
             labels: [14, 16, 10, 8],
             splits: [3, 5]))
    performTest(
      "a(b|c)*",
      recode(.beginGroup,
             "a",
             .beginGroup,
             .label(0),
             .split(disfavoring: 1),
             .beginCapture,
             .split(disfavoring: 3),
             "b",
             .goto(label: 2),
             .label(3),
             "c",
             .label(2),
             .endCapture(),
             .goto(label: 0),
             .label(1),
             .captureArray(childType: Substring.self),
             .endGroup,
             .endGroup,
             labels: [3, 14, 11, 9],
             splits: [4, 6]))
    performTest(
      "(a*)*",
      recode(.beginGroup,
             label(0), split(disfavoring: 1), .beginCapture,
             label(2), split(disfavoring: 3), "a", goto(label: 2),
             label(3), .endCapture(), goto(label: 0),
             label(1),
             .captureArray(childType: Substring.self),
             .endGroup,
             labels: [1, 11, 4, 8], splits: [2, 5]))
    performTest(
      "(?:.*)*",
      recode(
        label(0), split(disfavoring: 1),
        .beginGroup,
        label(2), split(disfavoring: 3), .any, goto(label: 2),
        label(3),
        .endGroup,
        goto(label: 0),
        label(1),
        labels: [0, 10, 3, 7], splits: [1, 4]))
    performTest(
      "a.*?b+?c??",
      recode("a",
             label(0), split(disfavoring: 1), goto(label: 2),
             label(1), .any, goto(label: 0),
             label(2),
             label(3), "b", split(disfavoring: 3),
             split(disfavoring: 4), goto(label: 5),
             label(4), "c",
             label(5),
             labels: [1, 4, 7, 8, 13, 15], splits: [2, 10, 11]))
  }

  func testLegacyVMs() {
    let tests: Array<(String, pass: [String], fail: [String])> = [
      ("a|b", ["a", "b"], ["ab", "c"]),
      ("a.b", ["abb", "aab", "acb"], ["ab", "c", "abc"]),
      ("a|b?c", ["a", "c", "bc"], ["ab", "ac"]),
      ("abc*", ["abc", "ab", "abcc", "abccccc"], ["a", "c", "abca"]),
      ("abc*?", ["abc", "ab", "abcc", "abccccc"], ["a", "c", "abca"]),
      ("ab*?bb", ["abb", "abbbbb"], ["ab", "acb", "abc"]),
      ("ab+?bb", ["abbb", "abbbbb"], ["abb", "acb", "abc"]),
      ("abc+def", ["abcdef", "abccccccdef"], ["abc", "abdef"]),
      ("ab(cdef)*", ["ab", "abcdef", "abcdefcdefcdef"],
       ["abc", "cdef", "abcde", "abcdeff"]),
      ("ab(c|def)+", ["abc", "abdef", "abcdef", "abdefdefcdefc"],
       ["ab", "c", "abca"]),
      ("a(.*?)(c+).*?(e+)", ["abbbbccccddddeeee"], ["aacccceeeeeef"]),
      ("a(.+?)(c+).+?(e+)", ["abbbbccccddddeeee"], ["ace"]),
      ("a(?:b|c|d)e", ["abe", "ace", "ade"], ["afe", "aae"]),

      ("a\\sb", ["a b"], ["ab", "a  b"]),
      ("a\\s+b", ["a b", "a    b"], ["ab", "a    c"]),
      ("a\\dbc", ["a1bc"], ["ab2", "a1b", "a11b2", "a1b22"]),
      ("a\\db\\dc", ["a1b3c"], ["ab2", "a1b", "a11b2", "a1b22"]),
      ("a\\d\\db\\dc", ["a12b3c"], ["ab2", "a1b", "a11b2", "a1b22"]),

      ("Caf\\u{65}\\u0301", ["Cafe\u{301}"], ["Café", "Cafe"]),
      ("Caf\\x65\\u0301", ["Cafe\u{301}"], ["Café", "Cafe"]),

      ("[^abc]", ["x", "0", "*", " "], ["a", "b", "c"]),
      ("\\D\\s\\W", ["a *", "* -"], ["0 *", "000", "a a", "a 8", "aaa", "***"]),

      ("[^\\d]", ["x", "*", "_", " "], ["0", "9"]),
      ("[^[\\D]]", ["0", "9"], ["x", "*", "_", " "]),
      ("[[ab][bc]]", ["a", "b", "c"], ["d", "*", " "]),
      ("[[ab]c[de]]", ["a", "b", "c", "d", "e"], ["f", "*", " "]),

      ("[\\w--\\d]+", ["w", "_wf"], ["0", "*", "_0", "0a"]),
      ("[\\w&&\\d]+", ["0", "093"], ["a0", "*", "_"]),
      ("[\\w~~[\\d\\s]]+", ["a", "_", " a ", " a _  c"], ["a0", " 0 ", "90", "*"]),
      ("[[\\w\\d\\s]--\\s--[a-zA-Z]]+", ["0", "38", "8_90"], [" 38", "a", "a8", " ", "A", " T"]),
      ("[[ab]~~[bc]]", ["a", "c"], ["b", "d"]),

      // Pathological (at least for HareVM and for now Tortoise too)
      //            ("(a*)*", ["a"], ["b"])
    ]

    // Matching tests
    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(
          regex: regex, input: pass, expectedCaptureType: Void.self, expecting: .init(pass))
      }
      for fail in fails {
        performTest(
          regex: regex, input: fail, expectedCaptureType: Void.self, expecting: nil)
      }
    }

    // Singly nested capture tests
    performTest(
      regex: "a(b)c", input: "abc",
      expectedCaptureType: Substring.self, expecting: .init(captures: "b", capturesEqual: ==))
    performTest(
      regex: "a(.)c", input: "axc",
      expectedCaptureType: Substring.self, expecting: .init(captures: "x", capturesEqual: ==))
    performTest(
      regex: "a(b)c(d)ef", input: "abcdef",
      expectedCaptureType: (Substring, Substring).self,
      expecting: .init(captures: ("b", "d"), capturesEqual: ==))
    performTest(
      regex: "a(b*)c(d+)ef", input: "acddddef",
      expectedCaptureType: (Substring, Substring).self,
      expecting: .init(captures: ("", "dddd"), capturesEqual: ==))
    performTest(
      regex: "a(b*)c(d+)ef", input: "abbcdef",
      expectedCaptureType: (Substring, Substring).self,
      expecting: .init(captures: ("bb", "d"), capturesEqual: ==))

    // Eager vs reluctant quantifiers
    performTest(
      regex: "a(.*)(c+).*(e+)", input: "abbbbccccddddeeee",
      expectedCaptureType: (Substring, Substring, Substring).self,
      expecting: .init(captures: ("bbbbccc", "c", "e"), capturesEqual: ==))
    performTest(
      regex: "a(.+)(c+).+(e+)", input: "abbbbccccddddeeee",
      expectedCaptureType: (Substring, Substring, Substring).self,
      expecting: .init(captures: ("bbbbccc", "c", "e"), capturesEqual: ==))
    performTest(
      regex: "a(.?)(c+).?(e+)", input: "acccceeee",
      expectedCaptureType: (Substring, Substring, Substring).self,
      expecting: .init(captures: ("c", "ccc", "eee"), capturesEqual: ==))
    performTest(
      regex: "a(.*?)(c+).*?(e+)", input: "abbbbccccddddeeee",
      expectedCaptureType: (Substring, Substring, Substring).self,
      expecting: .init(captures: ("bbbb", "cccc", "eeee"), capturesEqual: ==))
    performTest(
      regex: "a(.+?)(c+).+?(e+)", input: "abbbbccccddddeeee",
      expectedCaptureType: (Substring, Substring, Substring).self,
      expecting: .init(captures: ("bbbb", "cccc", "eeee"), capturesEqual: ==))
    performTest(
      regex: "a(.??)(c+).??(e+)", input: "acccceeee",
      expectedCaptureType: (Substring, Substring, Substring).self,
      expecting: .init(captures: ("", "cccc", "eeee"), capturesEqual: ==))
//    performTest(
//      regex: "(?a*)*", input: "aaaa",
//      expectedCaptureType: Substring.self,
//      expecting: .init(captures: "aaaa", capturesEqual: ==))
  }

  func testLegacyPartialMatches() {
    let tests: Array<(String, pass: [(String, matched: String)], fail: [String])> = [
      ("a+",
       pass: [("aaa", matched: "aaa"),
              ("ab", matched: "a"),
              ("aab", matched: "aa"),
              ("a", matched: "a"),
             ],
       fail: ["b", ""]),
      ("a|b",
       pass: [
        ("a", matched: "a"),
        ("ab", matched: "a"),
        ("ba", matched: "b"),
        ("bc", matched: "b"),
       ],
       fail: ["c", "d", ""]
      ),
    ]

    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(
          regex: regex, input: pass.0, mode: .partialFromFront,
          expectedCaptureType: Void.self,
          expecting: .init(pass.matched))
      }
      for fail in fails {
        performTest(
          regex: regex, input: fail, mode: .partialFromFront,
          expectedCaptureType: Void.self,
          expecting: nil)
      }
    }
  }

  func testLegacySubrangeMatches() {
    // whole subrange
    let tests: Array<
      (String,
       pass: [(String, offsets: (lower: Int, upper: Int), matched: String)],
       fail: [(String, offsets: (lower: Int, upper: Int))])
    > = [
      ("a",
       pass: [
        ("a", offsets: (0, 0), matched: "a"),
        ("ab", offsets: (0, -1), matched: "a"),
        ("ba", offsets: (1, 0), matched: "a"),
       ],
       fail: [
        ("a", offsets: (1, 0)),
        ("a", offsets: (0, -1)),
        ("ab", offsets: (1, 0)),
        ("ba", offsets: (0, -1)),
        ("ab", offsets: (0, 0)),
       ])
    ]

    for (regex, passes, fails) in tests {
      for pass in passes {
        performTest(
          regex: regex,
          input: pass.0,
          offsets: pass.offsets,
          mode: .wholeString,
          expectedCaptureType: Void.self,
          expecting: .init(pass.matched))
      }
      for fail in fails {
        performTest(
          regex: regex,
          input: fail.0,
          offsets: fail.offsets,
          mode: .wholeString,
          expectedCaptureType: Void.self,
          expecting: nil)
      }
    }

    // partial subrange from front
  }
}
