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

import ArgumentParser
import _RegexParser
import _StringProcessing
import Foundation

@available(SwiftStdlib 5.8, *)
let litPattern = #/a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1/#
@available(SwiftStdlib 5.8, *)
let strPattern = try! Regex("a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1")

@available(SwiftStdlib 5.8, *)
struct CompileOnceTest: ParsableCommand {
  static let litPattern = #/a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1/#
  static let strPattern = try! Regex("a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1")
  
  var N: Int { 10_000 }
  var testString = "zzzzzzzzza"

  func globalLitPattern() -> TimeInterval {
    let start = Date.now
    for _ in 0..<N {
      guard testString.contains(RegexTester.litPattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }
  
  func globalStrPattern() -> TimeInterval {
    let start = Date.now
    for _ in 0..<N {
      guard testString.contains(RegexTester.strPattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }

  func staticLitPattern() -> TimeInterval {
    let start = Date.now
    for _ in 0..<N {
      guard testString.contains(Self.litPattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }
  
  func staticStrPattern() -> TimeInterval {
    let start = Date.now
    for _ in 0..<N {
      guard testString.contains(Self.strPattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }

  func outerLitPattern() -> TimeInterval {
    let start = Date.now
    let pattern = #/a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1/#
    for _ in 0..<N {
      guard testString.contains(pattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }
  
  func outerStrPattern() -> TimeInterval {
    let start = Date.now
    let pattern = try! Regex("a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1")
    for _ in 0..<N {
      guard testString.contains(pattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }

  func innerLitPattern() -> TimeInterval {
    let start = Date.now
    for _ in 0..<N {
      let pattern = #/a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1/#
      guard testString.contains(pattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }
  
  func innerStrPattern() -> TimeInterval {
    let start = Date.now
    for _ in 0..<N {
      let pattern = try! Regex("a+bcd(?:g*)ab+?c?de(?:(?:(?i:f)))hij|zzz++a|3|2|1")
      guard testString.contains(pattern) else { return 0 }
    }
    return Date.now.timeIntervalSince(start)
  }

  func run() throws {
    let globalLit = globalLitPattern()
    let globalStr = globalStrPattern()
    let staticLit = staticLitPattern()
    let staticStr = staticStrPattern()
    let outerLit = outerLitPattern()
    let outerStr = outerStrPattern()
    let innerLit = innerLitPattern()
    let innerStr = innerStrPattern()
    
    print("""
      Global literal: \(globalLit)
              string: \(globalStr)
      Static literal: \(staticLit)
              string: \(staticStr)
       Outer literal: \(outerLit)
              string: \(outerStr)
       Inner literal: \(innerLit)
              string: \(innerStr)
      """)
  }
}
