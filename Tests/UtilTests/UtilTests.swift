import XCTest
@testable import Util

class UtilTests: XCTestCase {
  func testTupleTypeConstruction() {
    XCTAssertTrue(tupleType(of: []) == Void.self)
    XCTAssertTrue(tupleType(of: [Int.self, Any.self]) == (Int, Any).self)
    XCTAssertTrue(
      tupleType(of: [[Int].self, [Int: Int].self, Void.self, Any.self])
        == ([Int], [Int: Int], Void, Any).self)
  }

  func testTypeErasedTupleConstruction() throws {
    let tuple0Erased = tuple(of: [1, 2, 3])
    let tuple0 = try XCTUnwrap(tuple0Erased as? (Int, Int, Int))
    XCTAssertEqual(tuple0.0, 1)
    XCTAssertEqual(tuple0.1, 2)
    XCTAssertEqual(tuple0.2, 3)

    let tuple1Erased = tuple(of: [[1, 2], [true, false], [3.0, 4.0]])
    XCTAssertTrue(type(of: tuple1Erased) == ([Int], [Bool], [Double]).self)
    let tuple1 = try XCTUnwrap(tuple1Erased as? ([Int], [Bool], [Double]))
    XCTAssertEqual(tuple1.0, [1, 2])
    XCTAssertEqual(tuple1.1, [true, false])
    XCTAssertEqual(tuple1.2, [3.0, 4.0])
  }
  
  func testEatOther() {
    XCTAssertEqual(4, (1..<10).eat(1..<4))
    XCTAssertEqual(1, (1..<10).eat(0..<0))
    
    XCTAssertNil((1..<1).eat(1..<2))
    XCTAssertNil((1..<10).eat(2..<10))
    XCTAssertNil((1..<10).eat(1..<11))
  }
}
