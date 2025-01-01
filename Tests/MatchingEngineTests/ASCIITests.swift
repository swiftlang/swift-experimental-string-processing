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

final class QuickASCIICharacterTests: XCTestCase {
  func testHappyPath() throws {
    // Given
    let sut = "foo"

    // When
    let result = sut._quickASCIICharacter(at: sut.startIndex, limitedBy: sut.endIndex)

    // Then
    let (char, nextIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[sut.startIndex])
    XCTAssertEqual(nextIdx, sut.index(after: sut.startIndex))
    XCTAssertFalse(isCRLF)
  }

  func testAtEnd() throws {
    // Given
    let sut = "foo"

    // When
    let result = sut._quickASCIICharacter(at: sut.endIndex, limitedBy: sut.endIndex)

    // Then
    XCTAssertNil(result)
  }

  func testNonASCIIChar() throws {
    // Given
    let sut = "é"

    // When
    let result = sut._quickASCIICharacter(at: sut.startIndex, limitedBy: sut.endIndex)

    // Then
    XCTAssertNil(result)
  }

  func testNextIsEnd() throws {
    // Given
    let sut = "foo"
    let index = sut.index(before: sut.endIndex)

    // When
    let result = sut._quickASCIICharacter(at: index, limitedBy: sut.endIndex)

    // Then
    let (char, nextIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[index])
    XCTAssertEqual(nextIdx, sut.endIndex)
    XCTAssertFalse(isCRLF)
  }

  // TODO: JH - Figure out how to test sub 300 starting bytes
  func testIsCRLF() throws {
    // Given
    let sut = "\r\n"

    // When
    let result = sut._quickASCIICharacter(at: sut.utf8.startIndex, limitedBy: sut.endIndex)

    // Then
    let (char, nextIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[sut.startIndex])
    XCTAssertEqual(nextIdx, sut.endIndex)
    XCTAssertTrue(isCRLF)
  }
}

final class QuickReverseASCIICharacterTests: XCTestCase {
  func testHappyPath() throws {
    // Given
    let sut = "foo"
    let index = sut.index(after: sut.startIndex)

    // When
    let result = sut._quickReverseASCIICharacter(at: index, limitedBy: sut.startIndex)

    // Then
    let (char, previousIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[index])
    XCTAssertEqual(previousIdx, sut.startIndex)
    XCTAssertFalse(isCRLF)
  }

  func testAtStart() throws {
    // Given
    let sut = "foo"

    // When
    let result = sut._quickReverseASCIICharacter(at: sut.startIndex, limitedBy: sut.startIndex)

    // Then
    XCTAssertNil(result)
  }

  func testNonASCIIChar() throws {
    // Given
    let sut = "é"

    // When
    let result = sut._quickReverseASCIICharacter(at: sut.startIndex, limitedBy: sut.startIndex)

    // Then
    XCTAssertNil(result)
  }

  func testPreviousIsStart() throws {
    // Given
    let sut = "foo"
    let index = sut.index(after: sut.startIndex)

    // When
    let result = sut._quickReverseASCIICharacter(at: index, limitedBy: sut.startIndex)

    // Then
    let (char, previousIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[index])
    XCTAssertEqual(previousIdx, sut.startIndex)
    XCTAssertFalse(isCRLF)
  }

  // TODO: JH - Figure out how to test sub 300 starting bytes
  func testIsCRLF() throws {
    // Given
    let sut = "foo\r\n"
    // Start at '\n'
    let index = sut.utf8.index(before: sut.endIndex)

    // When
    let result = sut._quickReverseASCIICharacter(at: index, limitedBy: sut.startIndex)

    // Then
    let (char, previousIndex, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[index])
    XCTAssertEqual(previousIndex, sut.index(sut.startIndex, offsetBy: 2))
    XCTAssertTrue(isCRLF)
  }
}

final class ASCIIQuickMatchTests: XCTestCase {
  func testAny() throws {
    try _test(matching: .any, against: "!")
    try _test(matching: .anyGrapheme, against: "!")
  }

  func testDigit() throws {
    try _test(matching: .digit, against: "1")
    try _test(matching: .digit, against: "a", shouldMatch: false)
  }

  func testHorizontalWhitespace() throws {
    try _test(matching: .horizontalWhitespace, against: " ")
    try _test(matching: .horizontalWhitespace, against: "\t")
    try _test(matching: .horizontalWhitespace, against: "\n", shouldMatch: false)
  }

  func testVerticalWhitespace() throws {
    try _test(matching: .verticalWhitespace, against: "\n")
    try _test(matching: .verticalWhitespace, against: "\t", shouldMatch: false)
    try _test(matching: .newlineSequence, against: "\n")
    try _test(matching: .newlineSequence, against: "\t", shouldMatch: false)
  }

  func testVerticalWhitespaceMatchesCRLF() throws {
    let crlf = "\r\n"

    // When using scalar semantics:
    // The next index should be the index of the "\n" character
    try _test(
      matching: .verticalWhitespace,
      against: crlf,
      expectedNext: crlf.utf8.firstIndex(of: ._lineFeed)
    )

    // When not using scalar semantics:
    // The next index should be the index after the whole \r\n sequence (the end index)
    try _test(
      matching: .verticalWhitespace,
      against: crlf,
      isScalarSemantics: false
    )
  }

  func testWhitespace() throws {
    try _test(matching: .whitespace, against: " ")
    try _test(matching: .whitespace, against: "\t")
    try _test(matching: .whitespace, against: "\n")
    try _test(matching: .whitespace, against: "a", shouldMatch: false)
  }

  func testWhitespaceCRLF() throws {
    // Given
    let crlf = "\r\n"

    // When using scalar semantics:
    // The next index should be the index of the "\n" character
    try _test(
      matching: .whitespace,
      against: crlf,
      expectedNext: crlf.utf8.firstIndex(of: ._lineFeed)
    )

    // When not using scalar semantics:
    // The next index should be the index after the whole \r\n sequence (the end index)
    try _test(
      matching: .whitespace,
      against: crlf,
      isScalarSemantics: false
    )
  }

  func testWord() throws {
    // Given
    try _test(matching: .word, against: "a")
    try _test(matching: .word, against: "1")
    try _test(matching: .word, against: "_")
    try _test(matching: .word, against: "-", shouldMatch: false)
  }

  private func _test(
    matching cc: _CharacterClassModel.Representation,
    against sut: String,
    isScalarSemantics: Bool = true,
    shouldMatch: Bool = true,
    expectedNext: String.Index? = nil
  ) throws {
    // When
    let result = sut._quickMatch(
      cc,
      at: sut.startIndex,
      limitedBy: sut.endIndex,
      isScalarSemantics: isScalarSemantics
    )

    // Then
    let (next, matched) = try XCTUnwrap(result)
    XCTAssertEqual(matched, shouldMatch)
    XCTAssertEqual(next, expectedNext ?? sut.endIndex)
  }
}

final class ASCIIQuickReverseMatchTests: XCTestCase {
  func testAny() throws {
    try _test(matching: .any, against: "1!")
    try _test(matching: .anyGrapheme, against: "1!")
  }

  func testDigit() throws {
    try _test(matching: .digit, against: "a1")
    try _test(matching: .digit, against: "1a", shouldMatch: false)
  }

  func testHorizontalWhitespace() throws {
    try _test(matching: .horizontalWhitespace, against: "a ")
    try _test(matching: .horizontalWhitespace, against: "a\t")
    try _test(matching: .horizontalWhitespace, against: "a\n", shouldMatch: false)
  }

  func testVerticalWhitespace() throws {
    try _test(matching: .verticalWhitespace, against: "a\n")
    try _test(matching: .verticalWhitespace, against: "a\t", shouldMatch: false)
  }

  func testVerticalWhitespaceMatchesCRLF() throws {
    let sut = "a\r\n"

    // When using scalar semantics:
    // The next index should be the index of the "\n" character
    try _test(
      matching: .verticalWhitespace,
      against: sut,
      at: sut.utf8.index(before: sut.utf8.endIndex),
      expectedPrevious: sut.utf8.firstIndex(of: ._carriageReturn)
    )

    // When not using scalar semantics:
    // The next index should be the index after the whole \r\n sequence (the end index)
    try _test(
      matching: .verticalWhitespace,
      against: sut,
      isScalarSemantics: false
    )
  }

  func testWhitespace() throws {
    try _test(matching: .whitespace, against: "a ")
    try _test(matching: .whitespace, against: "a\t")
    try _test(matching: .whitespace, against: "a\n")
    try _test(matching: .whitespace, against: " a", shouldMatch: false)
  }

  func testWhitespaceCRLF() throws {
    // Given
    let sut = "a\r\n"

    // When using scalar semantics:
    // The previous index should be the index of the "\r" character
    try _test(
      matching: .whitespace,
      against: sut,
      at: sut.utf8.index(before: sut.utf8.endIndex),
      expectedPrevious: sut.utf8.firstIndex(of: ._carriageReturn)
    )

    // When not using scalar semantics:
    // The previous index should be the index before the whole \r\n sequence
    // (the start index)
    try _test(
      matching: .whitespace,
      against: sut,
      isScalarSemantics: false
    )
  }

  func testWord() throws {
    // Given
    try _test(matching: .word, against: "!a")
    try _test(matching: .word, against: "!1")
    try _test(matching: .word, against: "!_")
    try _test(matching: .word, against: "a-", shouldMatch: false)
  }

  private func _test(
    matching cc: _CharacterClassModel.Representation,
    against sut: String,
    at index: String.Index? = nil,
    isScalarSemantics: Bool = true,
    shouldMatch: Bool = true,
    expectedPrevious: String.Index? = nil
  ) throws {
    // When
    let result = sut._quickReverseMatch(
      cc,
      at: index ?? sut.index(before: sut.endIndex),
      limitedBy: sut.startIndex,
      isScalarSemantics: isScalarSemantics
    )

    // Then
    let (previous, matched) = try XCTUnwrap(result)
    XCTAssertEqual(matched, shouldMatch)
    XCTAssertEqual(previous, expectedPrevious ?? sut.startIndex)
  }
}
