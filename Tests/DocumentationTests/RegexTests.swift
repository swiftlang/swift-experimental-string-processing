//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
//
//  Tests for the code samples in the Regex documentation.
//
//===----------------------------------------------------------------------===//

import XCTest
import _StringProcessing

class RegexTests: XCTestCase {}

extension RegexTests {
  func testRegex() throws {
    // 'keyAndValue' is created using a regex literal
    let keyAndValue = /(.+?): (.+)/
    // 'simpleDigits' is created from a pattern in a string
    let simpleDigits = try Regex("[0-9]+")
    
    let setting = "color: 161 103 230"
    if setting.contains(simpleDigits) {
      print("'\(setting)' contains some digits.")
    }
    // Prints "'color: 161 103 230' contains some digits."
        
    if let match = setting.firstMatch(of: keyAndValue) {
      print("Key: \(match.1)")
      print("Value: \(match.2)")
    }
    // Key: color
    // Value: 161 103 230
    
    XCTAssertTrue(setting.contains(simpleDigits))
    
    let match = try XCTUnwrap(setting.firstMatch(of: keyAndValue))
    XCTAssertEqual(match.1, "color")
    XCTAssertEqual(match.2, "161 103 230")
  }
  
  func testRegex_init() throws {
    let simpleDigits = try Regex("[0-9]+")
    
    // shouldn't throw
  }
  
  func testRegex_initStringAs() throws {
    let keyAndValue = try Regex("(.+): (.+)", as: (Substring, Substring, Substring).self)
    
    // shouldn't throw
  }
  
  func testRegex_initRegexAs() throws {
    let dynamicRegex = try Regex("(.+?): (.+)")
    if let stronglyTypedRegex = Regex(dynamicRegex, as: (Substring, Substring, Substring).self) {
      print("Converted properly")
    }
    // Prints "Converted properly"
    
    XCTAssertNotNil(Regex(dynamicRegex, as: (Substring, Substring, Substring).self))
  }
  
  func testRegex_initVerbatim() throws {
    let adjectiveDesignator = Regex<Substring>(verbatim: "(adj.)")
    
    print("awesome (adj.)".contains(adjectiveDesignator))
    // Prints "true"
    print("apple (n.)".contains(adjectiveDesignator))
    // Prints "false"
    
    XCTAssertTrue("awesome (adj.)".contains(adjectiveDesignator))
    XCTAssertFalse("apple (n.)".contains(adjectiveDesignator))
  }
  
  func testRegex_containsCapture() throws {
    let regex = try Regex("(?'key'.+?): (?'value'.+)")
    regex.contains(captureNamed: "key")       // true
    regex.contains(captureNamed: "VALUE")     // false
    regex.contains(captureNamed: "1")         // false
    
    XCTAssertTrue(regex.contains(captureNamed: "key"))
    XCTAssertFalse(regex.contains(captureNamed: "VALUE"))
    XCTAssertFalse(regex.contains(captureNamed: "1"))
  }
}

extension RegexTests {
  func testRegex_wholeMatchIn() throws {
    let digits = /[0-9]+/
    
    if let digitsMatch = try digits.wholeMatch(in: "2022") {
      print(digitsMatch.0)
    } else {
      print("No match.")
    }
    // Prints "2022"
    
    if let digitsMatch = try digits.wholeMatch(in: "The year is 2022.") {
      print(digitsMatch.0)
    } else {
      print("No match.")
    }
    // Prints "No match."
    
    XCTAssertEqual(try digits.wholeMatch(in: "2022")?.0, "2022")
    XCTAssertNil(try digits.wholeMatch(in: "The year is 2022."))
  }
  
  func testRegex_prefixMatchIn() throws {
    let titleCaseWord = /[A-Z][A-Za-z]+/
    
    if let wordMatch = try titleCaseWord.prefixMatch(in: "Searching in a Regex") {
      print(wordMatch.0)
    } else {
      print("No match.")
    }
    // Prints "Searching"
    
    if let wordMatch = try titleCaseWord.prefixMatch(in: "title case word at the End") {
      print(wordMatch.0)
    } else {
      print("No match.")
    }
    // Prints "No match."
    
    XCTAssertEqual(try titleCaseWord.prefixMatch(in: "Searching in a Regex")?.0, "Searching")
    XCTAssertNil(try titleCaseWord.prefixMatch(in: "title case word at the End"))
  }
  
  func testRegex_firstMatchIn() throws {
    let digits = /[0-9]+/
    
    if let digitsMatch = try digits.firstMatch(in: "The year is 2022; last year was 2021.") {
      print(digitsMatch.0)
    } else {
      print("No match.")
    }
    // Prints "2022"
   
    XCTAssertEqual(try digits.firstMatch(in: "The year is 2022; last year was 2021.")?.0, "2022")
  }
}
