import XCTest
@testable import _MatchingEngine

class UtilTests: XCTestCase {
  func testTupleTypeConstruction() {
    XCTAssertTrue(TypeConstruction.tupleType(
      of: []) == Void.self)
    XCTAssertTrue(TypeConstruction.tupleType(
      of: [Int.self, Any.self]) == (Int, Any).self)
    XCTAssertTrue(
      TypeConstruction.tupleType(
        of: [[Int].self, [Int: Int].self, Void.self, Any.self])
      == ([Int], [Int: Int], Void, Any).self)
  }

  func testTypeErasedTupleConstruction() throws {
    let tuple0Erased = TypeConstruction.tuple(of: [1, 2, 3])
    let tuple0 = try XCTUnwrap(tuple0Erased as? (Int, Int, Int))
    XCTAssertEqual(tuple0.0, 1)
    XCTAssertEqual(tuple0.1, 2)
    XCTAssertEqual(tuple0.2, 3)

    let tuple1Erased = TypeConstruction.tuple(
      of: [[1, 2], [true, false], [3.0, 4.0]])
    XCTAssertTrue(type(of: tuple1Erased) == ([Int], [Bool], [Double]).self)
    let tuple1 = try XCTUnwrap(tuple1Erased as? ([Int], [Bool], [Double]))
    XCTAssertEqual(tuple1.0, [1, 2])
    XCTAssertEqual(tuple1.1, [true, false])
    XCTAssertEqual(tuple1.2, [3.0, 4.0])
  }
  
  func testSequenceMethods() {
    let seq = sequence(first: 0, next: { $0 < 10 ? $0 + 1 : nil })
    let empty = sequence(state: 0, next: { _ -> Int? in nil })
    assert(seq.elementsEqual(0...10))

    XCTAssertTrue(seq.all { $0 <= 10 })
    XCTAssertFalse(seq.all { $0 != 10 })
    XCTAssertTrue(empty.all { $0 < 10 })
    
    XCTAssertTrue(seq.none { $0 > 10 })
    XCTAssertFalse(seq.none { $0 == 10 })
    XCTAssertTrue(empty.none { $0 < 10 })
    
    XCTAssertTrue(seq.any { $0 == 5 })
    XCTAssertFalse(seq.any { $0 == 15 })
    XCTAssertFalse(empty.any { $0 == 5 })
    
    XCTAssertEqual(seq.elementCount(), 11)
    XCTAssertEqual(empty.elementCount(), 0)
    
    XCTAssertTrue(seq.hasElements())
    XCTAssertFalse(empty.hasElements())
  }
}
