//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//


import XCTest
import Dispatch
@testable import _StringProcessing
@testable import RegexBuilder

@available(SwiftStdlib 5.7, *)
class ReferenceConcurrencyTests: XCTestCase {
  static let threadCount = 8
}

#if canImport(Dispatch)

extension ReferenceConcurrencyTests {

  func testAtomicIntsAreUnique() {
    let perThread = 2_000
    let total = Self.threadCount * perThread
    let counter = AtomicCounter()
    
    nonisolated(unsafe)
    let ids = UnsafeMutablePointer<Int>.allocate(capacity: total)
    defer {
      ids.deallocate()
    }

    DispatchQueue.concurrentPerform(iterations: Self.threadCount) { thread in
      let base = thread * perThread
      for i in 0..<perThread {
        ids[base + i] = counter.next()
      }
    }

    let unique = Set(UnsafeBufferPointer(start: ids, count: total))
    XCTAssertEqual(
      unique.count, total,
      "\(total - unique.count) of \(total) ints were duplicates")
  }

  func testConcurrentReferenceIDsAreUnique() {
    let perThread = 2_000
    let total = Self.threadCount * perThread

    nonisolated(unsafe)
    let refs = UnsafeMutablePointer<Reference<Substring>>.allocate(capacity: total)
    defer {
      refs.deinitialize(count: total)
      refs.deallocate()
    }

    DispatchQueue.concurrentPerform(iterations: Self.threadCount) { thread in
      let base = thread * perThread
      for i in 0..<perThread {
        refs[base + i] = Reference()
      }
    }

    let unique = Set(UnsafeBufferPointer(start: refs, count: total).map { $0._raw })
    XCTAssertEqual(
      unique.count, total,
      "\(total - unique.count) of \(total) references were duplicates")
  }
}

#endif

extension ReferenceConcurrencyTests {
  func testConcurrentMatching() async {
    func parseOnce(_ input: String) -> String? {
      let group1 = Reference(Substring.self)
      let group2 = Reference(Substring.self)
      let group3 = Reference(Substring.self)
      let group4 = Reference(Substring.self)
      let group5 = Reference(Substring.self)
      let group6 = Reference(Substring.self)
      let group7 = Reference(Substring.self)
      let group8 = Reference(Substring.self)

      let regex = Regex {
        Capture(as: group1) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group2) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group3) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group4) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group5) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group6) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group7) { OneOrMore(.hexDigit) }
        ":"
        Capture(as: group8) { OneOrMore(.hexDigit) }
      }
      
      guard let m = try? regex.wholeMatch(in: input) else {
        return "wholeMatch returned nil"
      }
      
      if m[group1] != m.1 || m[group2] != m.2 || m[group3] != m.3 || m[group4] != m.4 ||
          m[group5] != m.5 || m[group6] != m.6 || m[group7] != m.7 || m[group8] != m.8
      {
        return """
          crossed captures:
            \(m[group1]):\(m[group2]):\(m[group3]):\(m[group4]):\
          \(m[group5]):\(m[group6]):\(m[group7]):\(m[group8])
          """
      }
      return nil
    }

    let iterations = 500_000
    let failures = await withTaskGroup(of: String?.self) { group in
      for _ in 0..<iterations {
        group.addTask {
          parseOnce("2601:246:4300:63a0:3043:575d:d702:4d4a")
        }
      }
      return await group.compact()
    }
    XCTAssert(failures.isEmpty)
    if !failures.isEmpty {
      for f in failures.prefix(10) { print(f) }
    }
  }
}

extension AsyncSequence {
  func compact<T>() async rethrows -> [T] where Element == T? {
    try await reduce(into: []) { result, el in if let el { result.append(el) } }
  }
}
