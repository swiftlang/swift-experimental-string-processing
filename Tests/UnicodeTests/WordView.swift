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

import XCTest
@testable import _StringProcessing

class UnicodeTests: XCTestCase {}

extension UnicodeTests {
  func parseWordTests() -> [[String]] {
    var result: [[String]] = []
    
    for line in testData.split(separator: "\n") {
      guard line.hasPrefix("÷") else {
        continue
      }
      
      let info = line.split(separator: "#")
      let components = info[0].split(separator: " ")
      
      var words: [String] = []
      var currentWord = ""
      
      for i in components.indices {
        guard i != 0 else {
          continue
        }
        
        // If we're an odd index, this is a scalar.
        if i & 0x1 == 1 {
          let scalar = Unicode.Scalar(UInt32(components[i], radix: 16)!)!
          
          currentWord.unicodeScalars.append(scalar)
        } else {
          // Otherwise, it is a grapheme breaking operator.
          
          // If this is a break, record the +1 count. Otherwise it is × which is
          // not a break.
          if components[i] == "÷" {
            words.append(currentWord)
            currentWord.removeAll()
          }
        }
      }
      
      result.append(words)
    }
    
    return result
  }
  
  func testWordView() {
    let tests = parseWordTests()
    
    for test in tests {
      var string = ""
      
      for word in test {
        string += word
      }
      
      XCTAssertEqual(test.count, string.words.count)
      
      for (testWord, ourWord) in zip(test, string.words) {
        XCTAssertEqual(testWord[...], ourWord)
      }
    }
  }
}
