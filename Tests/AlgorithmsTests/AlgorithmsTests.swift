@testable import _StringProcessing
import XCTest

// TODO: Protocol-powered testing
class AlgorithmTests: XCTestCase {

}

var enablePrinting = false
func output<T>(_ s: @autoclosure () -> T) {
  if enablePrinting {
    print(s())
  }
}

class RegexConsumerTests: XCTestCase {
  func testRanges() {
    func expectRanges<Capture>(
      _ string: String,
      _ regex: Regex<Capture>,
      _ expected: [Range<Int>],
      file: StaticString = #file, line: UInt = #line
    ) {
      let actualSeq = string[...].ranges(of: regex).map {
        string.offset(ofIndex: $0.lowerBound) ..< string.offset(ofIndex: $0.upperBound)
      }
      XCTAssertEqual(actualSeq, expected, file: file, line: line)

      // `IndexingIterator` tests the collection conformance
      let actualCol = string[...].ranges(of: regex)[...].map {
        string.offset(ofIndex: $0.lowerBound) ..< string.offset(ofIndex: $0.upperBound)
      }
      XCTAssertEqual(actualCol, expected, file: file, line: line)
    }

    expectRanges("", try! Regex(""), [0..<0])
    expectRanges("", try! Regex("x"), [])
    expectRanges("", try! Regex("x+"), [])
    expectRanges("", try! Regex("x*"), [0..<0])
    expectRanges("abc", try! Regex(""), [0..<0, 1..<1, 2..<2, 3..<3])
    expectRanges("abc", try! Regex("x"), [])
    expectRanges("abc", try! Regex("x+"), [])
    expectRanges("abc", try! Regex("x*"), [0..<0, 1..<1, 2..<2, 3..<3])
    expectRanges("abc", try! Regex("a"), [0..<1])
    expectRanges("abc", try! Regex("a*"), [0..<1, 1..<1, 2..<2, 3..<3])
    expectRanges("abc", try! Regex("a+"), [0..<1])
    expectRanges("abc", try! Regex("a|b"), [0..<1, 1..<2])
    expectRanges("abc", try! Regex("a|b+"), [0..<1, 1..<2])
    expectRanges("abc", try! Regex("a|b*"), [0..<1, 1..<2, 2..<2, 3..<3])
    expectRanges("abc", try! Regex("(a|b)+"), [0..<2])
    expectRanges("abc", try! Regex("(a|b)*"), [0..<2, 2..<2, 3..<3])
    expectRanges("abc", try! Regex("(b|c)+"), [1..<3])
    expectRanges("abc", try! Regex("(b|c)*"), [0..<0, 1..<3, 3..<3])
  }

  func testSplit() {
    func expectSplit<Capture>(
      _ string: String,
      _ regex: Regex<Capture>,
      _ expected: [Substring],
      file: StaticString = #file, line: UInt = #line
    ) {
      let actual = Array(string.split(by: regex))
      XCTAssertEqual(actual, expected, file: file, line: line)
    }

    expectSplit("", try! Regex(""), ["", ""])
    expectSplit("", try! Regex("x"), [""])
    expectSplit("a", try! Regex(""), ["", "a", ""])
    expectSplit("a", try! Regex("x"), ["a"])
    expectSplit("a", try! Regex("a"), ["", ""])
  }

  func testReplace() {
    XCTAssertEqual("".replacing(try! Regex(""), with: "X"), "X")
    XCTAssertEqual("".replacing(try! Regex("x"), with: "X"), "")
    XCTAssertEqual("".replacing(try! Regex("x*"), with: "X"), "X")
    XCTAssertEqual("a".replacing(try! Regex(""), with: "X"), "XaX")
    XCTAssertEqual("a".replacing(try! Regex("x"), with: "X"), "a")
    XCTAssertEqual("a".replacing(try! Regex("a"), with: "X"), "X")
    XCTAssertEqual("a".replacing(try! Regex("a+"), with: "X"), "X")
    XCTAssertEqual("a".replacing(try! Regex("a*"), with: "X"), "XX")
    XCTAssertEqual("aab".replacing(try! Regex("a"), with: "X"), "XXb")
    XCTAssertEqual("aab".replacing(try! Regex("a+"), with: "X"), "Xb")
    XCTAssertEqual("aab".replacing(try! Regex("a*"), with: "X"), "XXbX")
  }

  func testAdHoc() {
    let r = try! Regex("a|b+")

    XCTAssert("palindrome".contains(r))
    XCTAssert("botany".contains(r))
    XCTAssert("antiquing".contains(r))
    XCTAssertFalse("cdef".contains(r))

    let str = "a string with the letter b in it"
    let first = str.firstRange(of: r)
    let last = str.lastRange(of: r)
    let (expectFirst, expectLast) = (str.index(atOffset: 0)..<str.index(atOffset: 1), str.index(atOffset: 25)..<str.index(atOffset: 26))
    output(str.split(around: first!))
    output(str.split(around: last!))

    XCTAssertEqual(expectFirst, first)
    XCTAssertEqual(expectLast, last)

    XCTAssertEqual(
      [expectFirst, expectLast], Array(str.ranges(of: r)))

    XCTAssertTrue(str.starts(with: r))
    XCTAssertFalse(str.ends(with: r))

    XCTAssertEqual(str.dropFirst(), str.trimmingPrefix(r))
    XCTAssertEqual("x", "axb".trimming(r))
    XCTAssertEqual("x", "axbb".trimming(r))
  }
}
