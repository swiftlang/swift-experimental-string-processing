import XCTest

class ConcurrencyTest: XCTestCase {
  func testConcurrentAccess3() async throws {
    let result = await withTaskGroup(of: Bool.self) { group in
      group.addTask { true }
      for await _ in group {}
      return true
    }
  }
}
