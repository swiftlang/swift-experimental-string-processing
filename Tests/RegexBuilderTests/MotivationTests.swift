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
import _StringProcessing
import RegexBuilder

// FIXME: macOS CI seems to be busted and Linux doesn't have FormatStyle
// So, we disable this larger test for now.
#if false

private struct Transaction: Hashable {
  enum Kind: Hashable {
    case credit
    case debit

    init?(_ s: Substring) {
      switch s.lowercased() {
      case "credit": self = .credit
      case "debit": self = .debit
      default: return nil
      }
    }
  }

  var kind: Kind
  var date: Date
  var account: String
  var amount: Decimal
}
extension Transaction: CustomStringConvertible {
  var description: String {
    """
      kind: \(kind)
      date: \(date)
      account: \(account)
      amount: \(amount)
    """
  }
}

private struct Statement {
  var entries: [Transaction]
  init<S: Sequence>(_ entries: S) where S.Element == Transaction {
    self.entries = Array(entries)
  }
}

// In contrast to unit tests, or small functional tests, these
// test full workloads or perform real(ish) tasks.
//
// TODO: Consider adapting into Exercises or benchmark target...

private let statement = """
CREDIT    03/02/2022    Payroll                   $200.23
CREDIT    03/03/2022    Sanctioned Individual A   $2,000,000.00
DEBIT     03/03/2022    Totally Legit Shell Corp  $2,000,000.00
DEBIT     03/05/2022    Beanie Babies Are Back    $57.33
"""

private func processEntry(_ s: String) -> Transaction? {
  var slice = s[...]
  guard let kindEndIdx = slice.firstIndex(of: " "),
        let kind = Transaction.Kind(slice[..<kindEndIdx])
  else {
    return nil
  }

  slice = slice[kindEndIdx...].drop(while: \.isWhitespace)
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  guard let dateEndIdx = slice.firstIndex(of: " "),
        let date = formatter.date(from: String(slice[..<dateEndIdx]))
  else {
    return nil
  }
  slice = slice[dateEndIdx...].drop(while: \.isWhitespace)

  // Account can have spaces, look for 2-or-more for end-of-field
  // ...
  // You know what, let's just bail and call it a day
  _ = (kind, date)
  return nil
}

let pattern = #"(\w+)\s\s+(\S+)\s\s+((?:(?!\s\s).)+)\s\s+(.*)"#

@available(macOS 12.0, *)
private func processWithNSRegularExpression(_ line: String) -> Transaction? {
  let nsRegEx = try! NSRegularExpression(pattern: pattern)

  let range = NSRange(line.startIndex..<line.endIndex, in: line)
  guard let result = nsRegEx.firstMatch(in: line, range: range) else {
    return nil
  }

  guard let kindRange = Range(result.range(at: 1), in: line),
        let kind = Transaction.Kind(line[kindRange])
  else {
    return nil
  }

  let dateStrat = Date.FormatStyle(date: .numeric).parseStrategy
  guard let dateRange = Range(result.range(at: 2), in: line),
        let date = try? Date(String(line[dateRange]), strategy: dateStrat)
  else {
    return nil
  }

  guard let accountRange = Range(result.range(at: 3), in: line) else {
    return nil
  }
  let account = String(line[accountRange])

  guard let amountRange = Range(result.range(at: 4), in: line),
        let amount = try? Decimal(
          String(line[amountRange]), format: .currency(code: "USD"))
  else {
    return nil
  }

  return Transaction(
    kind: kind, date: date, account: account, amount: amount)
}

private func processWithRuntimeDynamicRegex(
  _ line: String
) -> Transaction? {
  // FIXME: Shouldn't this init throw?
  let regex = try! Regex(pattern)
  let dateStrat = Date.FormatStyle(date: .numeric).parseStrategy
  
  guard let result = line.wholeMatch(of: regex)?.output,
        let kind = Transaction.Kind(result[1].substring!),
        let date = try? Date(String(result[2].substring!), strategy: dateStrat),
        let account = result[3].substring.map(String.init),
        let amount = try? Decimal(
          String(result[4].substring!), format: .currency(code: "USD")) else {
    return nil
  }

  return Transaction(
    kind: kind, date: date, account: account, amount: amount)
}

@available(macOS 12.0, *)
private func processWithRuntimeStaticRegex(_ line: String) -> Transaction? {
  let regex: Regex<(Substring, Substring, Substring, Substring, Substring)>
  = try! Regex(pattern)

  return process(line, using: regex)
}

@available(macOS 12.0, *)
private func processWithDSL(_ line: String) -> Transaction? {
  let fieldSeparator = Regex {
    CharacterClass.whitespace
    OneOrMore(.whitespace)
  }

  let regex = Regex {
    Capture(OneOrMore(.word))
    fieldSeparator

    Capture(OneOrMore(.whitespace.inverted))
    fieldSeparator

    Capture {
      OneOrMore {
        Lookahead(
          // FIXME: `fieldSeparator` differs, why?
          Regex {
            CharacterClass.whitespace
            CharacterClass.whitespace
          }, negative: true)
        CharacterClass.any
      }
    }
    fieldSeparator

    Capture { OneOrMore(.any) }
  }

  return process(line, using: regex)
}

@available(macOS 12.0, *)
private func process(
  _ line: String,
  using regex: Regex<(Substring, Substring, Substring, Substring, Substring)>
) -> Transaction? {
  guard let output = try? regex.wholeMatch(in: line),
        let kind = Transaction.Kind(output.1)
  else {
    return nil
  }

  let dateStrat = Date.FormatStyle(date: .numeric).parseStrategy
  guard let date = try? Date(String(output.2), strategy: dateStrat) else {
    return nil
  }

  let account = String(output.3)

  guard let amount = try? Decimal(
    String(output.4), format: .currency(code: "USD")
  ) else {
    return nil
  }

  return Transaction(
    kind: kind, date: date, account: account, amount: amount)
}

extension RegexDSLTests {

  // TODO: FormatStyle not available on Linux...
  @available(macOS 12.0, *)
  func testBankStatement() {
    // TODO: Stop printing and start testing...

    for line in statement.split(separator: "\n") {
      let line = String(line)
      _ = processEntry(line)

      // NSRegularExpression
      let referenceOutput = processWithNSRegularExpression(line)!

      XCTAssertEqual(
        referenceOutput, processWithNSRegularExpression(line))

      XCTAssertEqual(
        referenceOutput, processWithRuntimeDynamicRegex(line))

      // Static run-time regex
      XCTAssertEqual(
        referenceOutput, processWithRuntimeStaticRegex(line))

      // DSL
      let dslOut = processWithDSL(line)!
      guard referenceOutput == dslOut else {
        if referenceOutput.account != dslOut.account {
          // FIXME: Bug in lookahead here?
          continue
        }

        XCTFail()
        continue
      }
    }
  }
}

#endif

extension RegexDSLTests {
  func testProposalExample() {
    let statement = """
      CREDIT    04062020    PayPal transfer    $4.99
      CREDIT    04032020    Payroll            $69.73
      DEBIT     04022020    ACH transfer       $38.25
      DEBIT     03242020    IRS tax payment    $52249.98
      """
    let expectation: [(TransactionKind, Date, Substring, Double)] = [
      (.credit, Date(mmddyyyy: "04062020")!, "PayPal transfer",  4.99),
      (.credit, Date(mmddyyyy: "04032020")!, "Payroll",          69.73),
      (.debit,  Date(mmddyyyy: "04022020")!, "ACH transfer",     38.25),
      (.debit,  Date(mmddyyyy: "03242020")!, "IRS tax payment",  52249.98),
    ]
    
    enum TransactionKind: String {
      case credit = "CREDIT"
      case debit = "DEBIT"
    }
    
    struct Date: Hashable {
      var month: Int
      var day: Int
      var year: Int
      
      init?(mmddyyyy: String) {
        guard let (_, m, d, y) = mmddyyyy.wholeMatch(of: Regex {
          Capture(Repeat(.digit, count: 2), transform: { Int($0)! })
          Capture(Repeat(.digit, count: 2), transform: { Int($0)! })
          Capture(Repeat(.digit, count: 4), transform: { Int($0)! })
        })?.output else {
          return nil
        }
        
        self.month = m
        self.day = d
        self.year = y
      }
    }
    
    let statementRegex = Regex {
      // First, lets capture the transaction kind by wrapping our ChoiceOf in a
      // TryCapture because we want
      TryCapture {
        ChoiceOf {
          "CREDIT"
          "DEBIT"
        }
      } transform: {
        TransactionKind(rawValue: String($0))
      }
      
      OneOrMore(.whitespace)
      
      // Next, lets represent our date as 3 separate repeat quantifiers. The first
      // two will require 2 digit characters, and the last will require 4. Then
      // we'll take the entire substring and try to parse a date out.
      TryCapture {
        Repeat(.digit, count: 2)
        Repeat(.digit, count: 2)
        Repeat(.digit, count: 4)
      } transform: {
        Date(mmddyyyy: String($0))
      }
      
      OneOrMore(.whitespace)
      
      // Next, grab the description which can be any combination of word characters,
      // digits, etc.
      Capture {
        OneOrMore(.any, .reluctant)
      }
      
      OneOrMore(.whitespace)
      
      "$"
      
      // Finally, we'll grab one or more digits which will represent the whole
      // dollars, match the decimal point, and finally get 2 digits which will be
      // our cents.
      TryCapture {
        OneOrMore(.digit)
        "."
        Repeat(.digit, count: 2)
      } transform: {
        Double($0)
      }
    }
    
    for (i, match) in statement.matches(of: statementRegex).enumerated() {
      let (_, kind, date, description, amount) = match.output
      XCTAssert((kind, date, description, amount) == expectation[i])
    }
  }
}
