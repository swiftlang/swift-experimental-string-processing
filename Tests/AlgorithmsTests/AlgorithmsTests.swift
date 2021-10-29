import Algorithms
import XCTest
import Util

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

  func testAdHoc() {

    let r = RegexConsumer(regex: "a|b+")

// TODO: Why isn't there `contains`?
//    XCTAssert("palindrome".contains(r))
//    XCTAssert("botany".contains(r))
//    XCTAssert("antiquing".contains(r))
//    XCTAssertFalse("cdef".contains(r))

    let str = "a string with the letter b in it"
    let (first, last) = (str.firstRange(r), str.lastRange(r))
    let (expectFirst, expectLast) = (str.idx(0)..<str.idx(1), str.idx(25)..<str.idx(26))
    output(str.split(around: first!))
    output(str.split(around: last!))

    XCTAssertEqual(expectFirst, first)
    XCTAssertEqual(expectLast, last)

    // FIXME: Doesn't terminate, haven't explored where bug is
//    XCTAssertEqual(
//      [expectFirst, expectLast], Array(str.ranges(r)))

    XCTAssertTrue(str.starts(with: r))
    XCTAssertFalse(str.ends(with: r))
    
    XCTAssertEqual(str.dropFirst(), str.trimming(r))
    XCTAssertEqual("x", "axb".trimming(r))
    // Bug: XCTAssertEqual("x", "axbb".trimming(r))

  }

}


