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
//  Tests for the code samples in the RegexBuilder documentation.
//
//===----------------------------------------------------------------------===//

import XCTest
import _StringProcessing
import RegexBuilder

class RegexBuilderTests: XCTestCase {}

extension RegexBuilderTests {
  func testCharacterClass_inverted() throws {
    let validCharacters = CharacterClass("a"..."z", .anyOf("-_"))
    let invalidCharacters = validCharacters.inverted
    
    let username = "user123"
    if username.contains(invalidCharacters) {
      print("Invalid username: '\(username)'")
    }
    // Prints "Invalid username: 'user123'"
    
    XCTAssertTrue(username.contains(invalidCharacters))
  }
  
  func testCharacterClass_anyOf() {
    let regex1 = /[abcd]+/
    let regex2 = OneOrMore(.anyOf("abcd"))
    
    // syntax/compilation test
  }
  
  func testChoiceOf() throws {
    let regex = Regex {
      ChoiceOf {
        "CREDIT"
        "DEBIT"
      }
    }
    let match = try regex.prefixMatch(in: "DEBIT    04032020    Payroll $69.73")
    print(match?.0 as Any)
    // Prints "DEBIT"
    
    XCTAssertEqual(match?.0, "DEBIT")
  }
  
  func testReference() throws {
    let kindRef = Reference(Substring.self)
    let kindRegex = ChoiceOf {
      "CREDIT"
      "DEBIT"
    }
    
    let transactionRegex = Regex {
      Anchor.startOfLine
      Capture(kindRegex, as: kindRef)
      OneOrMore(.anyNonNewline)
      kindRef
      Anchor.endOfLine
    }
    
    let validTransaction = "CREDIT     109912311421    Payroll   $69.73  CREDIT"
    let invalidTransaction = "DEBIT     00522142123    Expense   $5.17  CREDIT"
    
    print(validTransaction.contains(transactionRegex))
    // Prints "true"
    print(invalidTransaction.contains(transactionRegex))
    // Prints "false"
    
    if let match = validTransaction.firstMatch(of: transactionRegex) {
      print(match[kindRef])
    }
    // Prints "CREDIT"
    
    struct Transaction: Equatable {
      var id: UInt64
    }
    let transactionRef = Reference(Transaction.self)
    
    let transactionIDRegex = Regex {
      Capture(kindRegex, as: kindRef)
      OneOrMore(.whitespace)
      TryCapture(as: transactionRef) {
        OneOrMore(.digit)
      } transform: { str in
        UInt64(str).map(Transaction.init(id:))
      }
      OneOrMore(.anyNonNewline)
      kindRef
      Anchor.endOfLine
    }
    
    if let match = validTransaction.firstMatch(of: transactionIDRegex) {
      print(match[transactionRef])
    }
    // Prints "Transaction(id: 109912311421)"
    
    XCTAssertTrue(validTransaction.contains(transactionRegex))
    XCTAssertFalse(invalidTransaction.contains(transactionRegex))
    
    XCTAssertEqual(validTransaction.firstMatch(of: transactionRegex)?[kindRef], "CREDIT")
    
    XCTAssertEqual(
      validTransaction.firstMatch(of: transactionIDRegex)?[transactionRef],
      Transaction(id: 109912311421))
  }
  
  func testCapture() throws {
    let transactions = """
     CREDIT     109912311421    Payroll   $69.73
     CREDIT     105912031123    Travel   $121.54
     DEBIT      107733291022    Refund    $8.42
     """
    
    let regex = Regex {
      "$"
      Capture {
        OneOrMore(.digit)
        "."
        Repeat(.digit, count: 2)
      }
      Anchor.endOfLine
    }
    
    // The type of each match's output is `(Substring, Substring)`.
    for match in transactions.matches(of: regex) {
      print("Transaction amount: \(match.1)")
    }
    // Prints "Transaction amount: 69.73"
    // Prints "Transaction amount: 121.54"
    // Prints "Transaction amount: 8.42"
    
    let doubleValueRegex = Regex {
      "$"
      Capture {
        OneOrMore(.digit)
        "."
        Repeat(.digit, count: 2)
      } transform: { Double($0)! }
      Anchor.endOfLine
    }
    
    // The type of each match's output is `(Substring, Double)`.
    for match in transactions.matches(of: doubleValueRegex) {
      if match.1 >= 100.0 {
        print("Large amount: \(match.1)")
      }
    }
    // Prints "Large amount: 121.54"
    
    let matchCaptures = transactions.matches(of: regex).map(\.1)
    XCTAssertEqual(matchCaptures, ["69.73", "121.54", "8.42"])
    
    let doubleValues = transactions.matches(of: doubleValueRegex).map(\.1)
    XCTAssertEqual(doubleValues, [69.73, 121.54, 8.42])
  }
  
  func testTryCapture() throws {
    let transactions = """
    CREDIT     109912311421    Payroll   $69.73
    CREDIT     105912031123    Travel   $121.54
    DEBIT      107733291022    Refund    $8.42
    """
    let transactionLimit = 100.0
    
    let regex = Regex {
      "$"
      TryCapture {
        OneOrMore(.digit)
        "."
        Repeat(.digit, count: 2)
      } transform: { str -> Double? in
        let value = Double(str)!
        if value > transactionLimit {
          return value
        }
        return nil
      }
      Anchor.endOfLine
    }
    
    // The type of each match's output is `(Substring, Double)`.
    for match in transactions.matches(of: regex) {
      print("Transaction amount: \(match.1)")
    }
    // Prints "Transaction amount: 121.54"
    
    let matches = transactions.matches(of: regex)
    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(matches[0].1, 121.54)
  }
}
