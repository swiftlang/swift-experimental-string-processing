@testable import Algorithms
import XCTest
import Util

// TODO: Protocol-powered testing
class AlgorithmTests: XCTestCase {

}

var enablePrinting = true
func output<T>(_ s: @autoclosure () -> T) {
  if enablePrinting {
    print(s())
  }
}

class RegexConsumerTests: XCTestCase {

  func testAdHoc() {

    let r = RegexConsumer(regex: "a|b+")

    XCTAssert("palindrome".contains(r))
    XCTAssert("botany".contains(r))
    XCTAssert("antiquing".contains(r))
    XCTAssertFalse("cdef".contains(r))

    let str = "a string with the letter b in it"
    let (first, last) = (str.firstRange(r), str.lastRange(r))
    let (expectFirst, expectLast) = (str.idx(0)..<str.idx(1), str.idx(25)..<str.idx(26))
    output(str.split(around: first!))
    output(str.split(around: last!))

    XCTAssertEqual(expectFirst, first)
    XCTAssertEqual(expectLast, last)

    XCTAssertEqual(
      [expectFirst, expectLast], Array(str.ranges(r)))

    XCTAssertTrue(str.starts(with: r))
    XCTAssertFalse(str.ends(with: r))
    
    XCTAssertEqual(str.dropFirst(), str.trimmingPrefix(r))
//    XCTAssertEqual("x", "axb".trimming(r))
    // Bug: XCTAssertEqual("x", "axbb".trimming(r))

  }
  
  func testSplit() {
    let s = "abcd"
    for range in s.ranges(of: "") {
      print(s.split(around: range))
    }
    print(Array<Substring>("abcd".split(separator: "")))
  }
  
  func testZ() {
    let s = "abcd"
    let searcher = ZSearcher<String>(pattern: [], by: ==)
    print(searcher.search(s, from: s.endIndex) as Any)
    print(s.split(searcher).map { $0 })
  }
  
  func test() {
    let regex = RegexConsumer(regex: "a*")
    let s = "aabbccaabbcc"
    for range in s.ranges(regex) {
      print(s.split(around: range))
    }
  }
  
  func testReplace() {
    let regex = RegexConsumer(regex: "a*")
    var string = "aabbccaabbcc"
    string.replace(regex, with: "X")
    print(string)
  }

}
