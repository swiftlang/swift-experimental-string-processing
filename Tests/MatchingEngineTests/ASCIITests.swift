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

final class QuickPreviousASCIICharacterTests: XCTestCase {
  func testHappyPath() throws {
    // Given
    let sut = "foo"
    let index = sut.index(after: sut.startIndex)

    // When
    let result = sut._quickASCIICharacter(before: index, limitedBy: sut.startIndex)

    // Then
    let (char, previousIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[sut.utf8.startIndex])
    XCTAssertEqual(previousIdx, sut.startIndex)
    XCTAssertFalse(isCRLF)
  }

  func testNonASCIIChar() throws {
    // Given
    let sut = "éi"

    // When
    let result = sut._quickASCIICharacter(before: sut.index(after: sut.startIndex), limitedBy: sut.startIndex)

    // Then
    XCTAssertNil(result)
  }

  func testPreviousIsStart() throws {
    // Given
    let sut = "foo"
    let index = sut.index(after: sut.startIndex)

    // When
    let result = sut._quickASCIICharacter(before: index, limitedBy: sut.startIndex)

    // Then
    let (char, previousIdx, isCRLF) = try XCTUnwrap(result)
    XCTAssertEqual(char, sut.utf8[sut.startIndex])
    XCTAssertEqual(previousIdx, sut.startIndex)
    XCTAssertFalse(isCRLF)
  }

  func testIsCRLF() throws {
    // Given
    let sut = "foo\r\nbar"
    // \n
    let startingIndex = sut.utf8.index(sut.utf8.startIndex, offsetBy: 5)

    // When
    let result = sut._quickASCIICharacter(
      before: startingIndex,
      limitedBy: sut.startIndex
    )

    // Then
    let (char, index, crlf) = try XCTUnwrap(result)
    // We should have reversed past the CRLF sequence
    let expectedIndex = sut.utf8.index(startingIndex, offsetBy: -2)
    XCTAssertEqual(index, expectedIndex)

    // We should have received only the LF
    let expectedCharPosition = sut.utf8.index(before: startingIndex)
    XCTAssertEqual(char, sut.utf8[expectedCharPosition])

    // And we should have detected the CRLF sequence
    XCTAssertTrue(crlf)
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

final class ASCIIQuickMatchPreviousTests: XCTestCase {
  func testAny() throws {
    try _test(matching: .any, against: "1!")
    try _test(matching: .anyGrapheme, against: "1!")
  }

  func testDigit() throws {
    try _test(matching: .digit, against: "1a")
    try _test(matching: .digit, against: "a1", shouldMatch: false)
  }

  func testHorizontalWhitespace() throws {
    try _test(matching: .horizontalWhitespace, against: " b")
    try _test(matching: .horizontalWhitespace, against: "\tb")
    try _test(matching: .horizontalWhitespace, against: "\nb", shouldMatch: false)
  }

  func testVerticalWhitespace() throws {
    try _test(matching: .verticalWhitespace, against: "\nb")
    try _test(matching: .verticalWhitespace, against: "\tb", shouldMatch: false)
  }

  func testVerticalWhitespaceMatchesCRLF() throws {
    let sut = "a\r\nb"

    // When using scalar semantics:
    // The next index should be the index of the "\n" character
    try _test(
      matching: .verticalWhitespace,
      against: sut,
      at: sut.utf8.index(before: sut.utf8.endIndex),
      expectedPrevious: sut.utf8.index(sut.utf8.startIndex, offsetBy: 2)
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
    try _test(matching: .whitespace, against: " a")
    try _test(matching: .whitespace, against: "\ta")
    try _test(matching: .whitespace, against: "\na")
    try _test(matching: .whitespace, against: " ab", shouldMatch: false)
  }

  // FIXME: JH
//  func testWhitespaceCRLF() throws {
//    // Given
//    let sut = "a\r\n"
//
//    // When using scalar semantics:
//    // The previous index should be the index of the "\r" character
//    try _test(
//      matching: .whitespace,
//      against: sut,
//      at: sut.utf8.index(before: sut.utf8.endIndex),
//      expectedPrevious: sut.utf8.firstIndex(of: ._carriageReturn)
//    )
//
//    // When not using scalar semantics:
//    // The previous index should be the index before the whole \r\n sequence
//    // (the start index)
//    try _test(
//      matching: .whitespace,
//      against: sut,
//      isScalarSemantics: false
//    )
//  }

  func testWord() throws {
    // Given
    try _test(matching: .word, against: "a!")
    try _test(matching: .word, against: "1!")
    try _test(matching: .word, against: "_!")
    try _test(matching: .word, against: "-!", shouldMatch: false)
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
    let indexOrDefault = index ?? sut.index(before: sut.endIndex)
    let result = sut._quickMatchPrevious(
      cc,
      at: indexOrDefault,
      limitedBy: sut.startIndex,
      isScalarSemantics: isScalarSemantics
    )

    // Then
    let (previous, matched) = try XCTUnwrap(result)
    XCTAssertEqual(matched, shouldMatch)
    XCTAssertEqual(
      previous,
      expectedPrevious ?? sut.index(before: indexOrDefault)
    )
  }
}
