@available(macOS 9999, *)
extension RegexTests {
  func testConcurrentAccess2() async throws {
    let result = await withTaskGroup(of: Bool.self) { group in
      group.addTask { true }
      for await _ in group {}
      return true
    }
  }
}
