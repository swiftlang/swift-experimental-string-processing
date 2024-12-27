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
