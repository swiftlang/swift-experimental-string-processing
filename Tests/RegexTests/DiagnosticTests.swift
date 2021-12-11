@testable import _MatchingEngine
import _StringProcessing

import XCTest

extension RegexTests {

  func testUnit() {
    XCTAssert(_fakeRange.isFake)
    XCTAssert(group(.capture, "a").sourceRange.isFake)
  }

}
