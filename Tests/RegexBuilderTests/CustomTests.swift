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
@testable import RegexBuilder

// A nibbler processes a single character from a string
private protocol Nibbler: CustomConsumingRegexComponent {
  func nibble(_: Character) -> RegexOutput?
}

extension Nibbler {
  // Default implementation, just feed the character in
  func consuming(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: RegexOutput)? {
    guard index != bounds.upperBound, let res = nibble(input[index]) else {
      return nil
    }
    return (input.index(after: index), res)
  }
}


// A number nibbler
private struct Numbler: Nibbler {
  typealias RegexOutput = Int
  func nibble(_ c: Character) -> Int? {
    c.wholeNumberValue
  }
}

// An ASCII value nibbler
private struct Asciibbler: Nibbler {
  typealias RegexOutput = UInt8
  func nibble(_ c: Character) -> UInt8? {
    c.asciiValue
  }
}

private struct IntParser: CustomConsumingRegexComponent {
  struct ParseError: Error, Hashable {}
  typealias RegexOutput = Int
  func consuming(_ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: Int)? {
    guard index != bounds.upperBound else { return nil }

    let r = Regex {
      Capture(OneOrMore(.digit)) { Int($0) }
    }

    guard let match = input[index..<bounds.upperBound].prefixMatch(of: r),
            let output = match.1 else {
      throw ParseError()
    }

    return (match.range.upperBound, output)
  }
}

private struct CurrencyParser: CustomConsumingRegexComponent {
  enum Currency: String, Hashable {
    case usd = "USD"
    case ntd = "NTD"
    case dem = "DEM"
  }

  enum ParseError: Error, Hashable {
    case unrecognized
    case deprecated
  }

  typealias RegexOutput = Currency
  func consuming(_ input: String,
             startingAt index: String.Index,
             in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: Currency)? {

    guard index != bounds.upperBound else { return nil }

    let substr = input[index..<bounds.upperBound]
    guard !substr.isEmpty else { return nil }

    let currencies: [Currency] = [ .usd, .ntd ]
    let deprecated: [Currency] = [ .dem ]

    for currency in currencies {
      if substr.hasPrefix(currency.rawValue) {
        return (input.range(of: currency.rawValue)!.upperBound, currency)
      }
    }

    for dep in deprecated {
      if substr.hasPrefix(dep.rawValue) {
        throw ParseError.deprecated
      }
    }
    throw ParseError.unrecognized
  }
}

enum MatchCall {
  case match
  case firstMatch
}

func customTest<Match: Equatable>(
  _ regex: Regex<Match>,
  _ tests: (input: String, call: MatchCall, match: Match?)...
) {
  for (input, call, match) in tests {
    let result: Match?
    switch call {
    case .match:
      result = input.wholeMatch(of: regex)?.output
    case .firstMatch:
      result = input.firstMatch(of: regex)?.output
    }
    XCTAssertEqual(result, match)
  }
}

class CustomRegexComponentTests: XCTestCase {
  // TODO: Refactor below into more exhaustive, declarative
  // tests.
  func testCustomRegexComponents() throws {
    customTest(
      Regex {
        Numbler()
        Asciibbler()
      },
      ("4t", .match, "4t"),
      ("4", .match, nil),
      ("t", .match, nil),
      ("t x1y z", .firstMatch, "1y"),
      ("t4", .match, nil))

    customTest(
      Regex {
        OneOrMore { Numbler() }
      },
      ("ab123c", .firstMatch, "123"),
      ("abc", .firstMatch, nil),
      ("55z", .match, nil),
      ("55z", .firstMatch, "55"))

    customTest(
      Regex {
        Numbler()
      },
      ("ab123c", .firstMatch, 1),
      ("abc", .firstMatch, nil),
      ("55z", .match, nil),
      ("55z", .firstMatch, 5))

    // TODO: Convert below tests to better infra. Right now
    // it's hard because `Match` is constrained to be
    // `Equatable` which tuples cannot be.

    let regex3 = Regex {
      Capture {
        OneOrMore {
          Numbler()
        }
      }
    }

    let str = "ab123c"
    let res3 = try XCTUnwrap(str.firstMatch(of: regex3))

    let expectedSubstring = str.dropFirst(2).prefix(3)
    XCTAssertEqual(res3.range, expectedSubstring.startIndex..<expectedSubstring.endIndex)
    XCTAssertEqual(res3.output.0, expectedSubstring)
    XCTAssertEqual(res3.output.1, expectedSubstring)

    let regex4 = Regex {
      OneOrMore {
        Capture { Numbler() }
      }
    }

    guard let res4 = "ab123c".firstMatch(of: regex4) else {
      XCTFail()
      return
    }

    XCTAssertEqual(res4.output.0, "123")
    XCTAssertEqual(res4.output.1, 3)
  }

  func testRegexAbort() {

    enum Radix: Hashable {
      case dot
      case comma
    }
    struct Abort: Error, Hashable {}

    let hexRegex = Regex {
      Capture { OneOrMore(.hexDigit) }
      TryCapture { CharacterClass.any } transform: { c -> Radix? in
        switch c {
        case ".": return Radix.dot
        case ",": return Radix.comma
        case "❗️":
          // Malicious! Toxic levels of emphasis detected.
          throw Abort()
        default:
          // Not a radix
          return nil
        }
      }
      Capture { OneOrMore(.hexDigit) }
    }
    // hexRegex: Regex<(Substring, Substring, Radix?, Substring)>
    // TODO: Why is Radix optional?

    do {
      guard let m = try hexRegex.wholeMatch(in: "123aef.345") else {
        XCTFail()
        return
      }
      XCTAssertEqual(m.0, "123aef.345")
      XCTAssertEqual(m.1, "123aef")
      XCTAssertEqual(m.2, .dot)
      XCTAssertEqual(m.3, "345")
    } catch {
      XCTFail()
    }

    do {
      _ = try hexRegex.wholeMatch(in: "123aef❗️345")
      XCTFail()
    } catch let e as Abort {
      XCTAssertEqual(e, Abort())
    } catch {
      XCTFail()
    }

    struct Poison: Error, Hashable {}

    let addressRegex = Regex {
      "0x"
      Capture(Repeat(.hexDigit, count: 8)) { hex -> Int in
        let i = Int(hex, radix: 16)!
        if i == 0xdeadbeef {
          throw Poison()
        }
        return i
      }
    }

    do {
      guard let m = try addressRegex.wholeMatch(in: "0x1234567f") else {
        XCTFail()
        return
      }
      XCTAssertEqual(m.0, "0x1234567f")
      XCTAssertEqual(m.1, 0x1234567f)
    } catch {
      XCTFail()
    }

    do {
      _ = try addressRegex.wholeMatch(in: "0xdeadbeef")
      XCTFail()
    } catch let e as Poison {
      XCTAssertEqual(e, Poison())
    } catch {
      XCTFail()
    }


  }

  func testCustomRegexThrows() {

    func customTest<Match: Equatable, E: Error & Equatable>(
      _ regex: Regex<Match>,
      _ tests: (input: String, match: Match?, expectError: E?)...,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      for (input, match, expectError) in tests {
        do {
          let result = try regex.wholeMatch(in: input)?.output
          XCTAssertEqual(result, match)
        } catch let e as E {
          XCTAssertEqual(e, expectError)
        } catch {
          XCTFail()
        }
      }
    }

    func customTest<Match: Equatable, Error1: Error & Equatable, Error2: Error & Equatable>(
      _ regex: Regex<Match>,
      _ tests: (input: String, match: Match?, expectError1: Error1?, expectError2: Error2?)...,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      for (input, match, expectError1, expectError2) in tests {
        do {
          let result = try regex.wholeMatch(in: input)?.output
          XCTAssertEqual(result, match)
        } catch let e as Error1 {
          XCTAssertEqual(e, expectError1, input, file: file, line: line)
        } catch let e as Error2 {
          XCTAssertEqual(e, expectError2, input, file: file, line: line)
        } catch {
          XCTFail("caught error: \(error.localizedDescription)")
        }
      }
    }

    func customTest<Capture: Equatable, Error1: Error & Equatable, Error2: Error & Equatable>(
      _ regex: Regex<(Substring, Capture)>,
      _ tests: (input: String, match: (Substring, Capture)?, expectError1: Error1?, expectError2: Error2?)...,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      for (input, match, expectError1, expectError2) in tests {
        do {
          let result = try regex.wholeMatch(in: input)?.output
          XCTAssertEqual(result?.0, match?.0, file: file, line: line)
          XCTAssertEqual(result?.1, match?.1, file: file, line: line)
        } catch let e as Error1 {
          XCTAssertEqual(e, expectError1, input, file: file, line: line)
        } catch let e as Error2 {
          XCTAssertEqual(e, expectError2, input, file: file, line: line)
        } catch {
          XCTFail("caught error: \(error.localizedDescription)")
        }
      }
    }

    func customTest<Capture1: Equatable, Capture2: Equatable, Error1: Error & Equatable, Error2: Error & Equatable>(
      _ regex: Regex<(Substring, Capture1, Capture2)>,
      _ tests: (input: String, match: (Substring, Capture1, Capture2)?, expectError1: Error1?, expectError2: Error2?)...,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      for (input, match, expectError1, expectError2) in tests {
        do {
          let result = try regex.wholeMatch(in: input)?.output
          XCTAssertEqual(result?.0, match?.0, file: file, line: line)
          XCTAssertEqual(result?.1, match?.1, file: file, line: line)
          XCTAssertEqual(result?.2, match?.2, file: file, line: line)
        } catch let e as Error1 {
          XCTAssertEqual(e, expectError1, input,  file: file, line: line)
        } catch let e as Error2 {
          XCTAssertEqual(e, expectError2, input, file: file, line: line)
        } catch {
          XCTFail("caught error: \(error.localizedDescription)")
        }
      }
    }

    // No capture, one error
    customTest(
      Regex {
        IntParser()
      },
      ("zzz", nil, IntParser.ParseError()),
      ("x10x", nil, IntParser.ParseError()),
      ("30", 30, nil)
    )

    customTest(
      Regex {
        CurrencyParser()
      },
      ("USD", .usd, nil),
      ("NTD", .ntd, nil),
      ("NTD USD", nil, nil),
      ("DEM", nil, CurrencyParser.ParseError.deprecated),
      ("XXX", nil, CurrencyParser.ParseError.unrecognized)
    )

    // No capture, two errors
    customTest(
      Regex {
        IntParser()
        " "
        IntParser()
      },
      ("20304 100", "20304 100", nil, nil),
      ("20304.445 200", nil, IntParser.ParseError(), nil),
      ("20304 200.123", nil, nil, IntParser.ParseError()),
      ("20304.445 200.123", nil, IntParser.ParseError(), IntParser.ParseError())
    )

    customTest(
      Regex {
        CurrencyParser()
        IntParser()
      },
      ("USD100", "USD100", nil, nil),
      ("XXX100", nil, CurrencyParser.ParseError.unrecognized, nil),
      ("USD100.000", nil, nil, IntParser.ParseError()),
      ("XXX100.0000", nil, CurrencyParser.ParseError.unrecognized, IntParser.ParseError())
    )

    // One capture, two errors: One error is thrown from inside a capture,
    // while the other one is thrown from outside
    customTest(
      Regex {
        Capture { CurrencyParser() }
        IntParser()
      },
      ("USD100", ("USD100", .usd), nil, nil),
      ("NTD305.5", nil, nil, IntParser.ParseError()),
      ("DEM200", ("DEM200", .dem), CurrencyParser.ParseError.deprecated, nil),
      ("XXX", nil, CurrencyParser.ParseError.unrecognized, IntParser.ParseError())
    )

    customTest(
      Regex {
        CurrencyParser()
        Capture { IntParser() }
      },
      ("USD100", ("USD100", 100), nil, nil),
      ("NTD305.5", nil, nil, IntParser.ParseError()),
      ("DEM200", ("DEM200", 200), CurrencyParser.ParseError.deprecated, nil),
      ("XXX", nil, CurrencyParser.ParseError.unrecognized, IntParser.ParseError())
    )

    // One capture, two errors: Both errors are thrown from inside the capture
    customTest(
      Regex {
        Capture {
          CurrencyParser()
          IntParser()
        }
      },
      ("USD100", ("USD100", "USD100"), nil, nil),
      ("NTD305.5", nil, nil, IntParser.ParseError()),
      ("DEM200", ("DEM200", "DEM200"), CurrencyParser.ParseError.deprecated, nil),
      ("XXX", nil, CurrencyParser.ParseError.unrecognized, IntParser.ParseError())
    )

    // Two captures, two errors: Different erros are thrown from inside captures
    customTest(
      Regex {
        Capture(CurrencyParser())
        Capture(IntParser())
      },
      ("USD100", ("USD100", .usd, 100), nil, nil),
      ("NTD500", ("NTD500", .ntd, 500), nil, nil),
      ("XXX20", nil, CurrencyParser.ParseError.unrecognized, IntParser.ParseError()),
      ("DEM500", nil, CurrencyParser.ParseError.deprecated, nil),
      ("DEM500.345", nil, CurrencyParser.ParseError.deprecated, IntParser.ParseError()),
      ("NTD100.345", nil, nil, IntParser.ParseError())
    )

  }
}
