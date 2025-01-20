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

final class StringMatchingTests: XCTestCase {
  // MARK: characterAndEnd tests
  func testCharacterAndEnd_HappyPath() throws {
    // Given
    let sut = "foo"

    // When
    let result = sut.characterAndEnd(at: sut.startIndex, limitedBy: sut.endIndex)

    // Then
    let (char, nextIndex) = try XCTUnwrap(result)
    XCTAssertEqual(char, "f")
    XCTAssertEqual(nextIndex, sut.index(after: sut.startIndex))
  }

  func testCharacterAndEnd_SubcharacterMatch() throws {
    // Given a string with 2 subcharacter positions in its utf8 view
    // \u{62}\u{300}\u{316}\u{65}\u{73}\u{74}
    let sut = "b̖̀est"

    let pos = sut.startIndex
    let end = sut.utf8.index(after: sut.utf8.startIndex)

    // When
    let result = sut.characterAndEnd(at: pos, limitedBy: end)

    // Then
    let (char, nextIndex) = try XCTUnwrap(result)
    XCTAssertEqual(char, "b")
    XCTAssertEqual(nextIndex, end)
  }

  func testCharacterAndEnd_SubcharacterMatchEmptyRounded() throws {
    // Given a string with 3 sub-character positions in its utf8 view
    // \u{62}\u{300}\u{316}\u{335}\u{65}\u{73}\u{74}
    let sut = "b̵̖̀est"

    // And a range that doesn't touch a grapheme cluster boundary
    // 1[utf8] (aka \u{300})
    let pos = sut.utf8.index(after: sut.startIndex)
    // 2[utf8] (aka \u{316})
    let end = sut.utf8.index(sut.startIndex, offsetBy: 2)

    // When we try to get a character from a sub-character range
    // of unicode scalars
    let result = sut.characterAndEnd(at: pos, limitedBy: end)

    // Then `characterAndEnd` should return nil rather than an empty string
    XCTAssertNil(result)
  }

  func testCharacterAndEnd_atEnd() {
    // Given
    let sut = "foo"

    // When
    let result = sut.characterAndEnd(at: sut.endIndex, limitedBy: sut.endIndex)

    // Then
    XCTAssertNil(result)
  }

  // MARK: characterAndStart tests
  func testCharacterAndStart_HappyPath() throws {
    // Given
    let sut = "foo"
    let pos = sut.index(before: sut.endIndex)

    // When
    let result = sut.characterAndStart(at: pos, limitedBy: sut.startIndex)

    // Then
    let (char, previousIndex) = try XCTUnwrap(result)
    XCTAssertEqual(char, "o")
    XCTAssertEqual(previousIndex, sut.index(before: pos))
  }

  // FIXME: JH - Two diacritical marks are considered a character.
  // TODO: JH - Learn more about Substring rounding(?)
//  func testCharacterAndStart_SubcharacterMatch() throws {
//    // Given a string with 2 subcharacter positions in its utf8 view
//    // \u{61}\u{62}\u{300}\u{316}\u{63}\u{64}
//    let sut = "ab̖̀cd"
//
//    // 3[utf8] (aka \u{316})
//    let pos = sut.utf8.index(sut.startIndex, offsetBy: 3)
//    let start = sut.startIndex//utf8.index(before: pos)
//
//    // When
//    let result = sut.characterAndStart(at: pos, limitedBy: start)
//
//    // Then
//    XCTAssertNil(result)
//    let (char, nextIndex) = try XCTUnwrap(result)
//    XCTAssertEqual(char, "t")
//    XCTAssertEqual(nextIndex, end)
//  }
//
//  func testCharacterAndStart_SubcharacterMatchEmptyRounded() throws {
//    // Given a string with 3 sub-character positions in its utf8 view
//    // \u{61}\u{62}\u{335}\u{300}\u{316}\u{63}\u{64}
//    let sut = "ab̵̖̀cd"
//
//    // And a range that doesn't touch a grapheme cluster boundary
//    // 4[utf8] (aka \u{335})
//    let pos = sut.utf8.index(sut.startIndex, offsetBy: 4)
//    // 3[utf8] (aka \u{300})
//    let start = sut.utf8.index(sut.startIndex, offsetBy: 3)
//
//    // When we try to get a character from a sub-character range
//    // of unicode scalars
//    let result = sut.characterAndStart(at: pos, limitedBy: start)
//
//    // Then `characterAndStart` should return nil rather than an empty string
//    XCTAssertNil(result)
//  }

  func testCharacterAndStart_atStart() {
    // Given
    let sut = "foo"

    // When
    let result = sut.characterAndStart(at: sut.startIndex, limitedBy: sut.startIndex)

    // Then
    XCTAssertNil(result)
  }

  // MARK: matchAnyNonNewline tests
  func testMatchAnyNonNewline() throws {
    // Given
    // A string without any newline characters
    let sut = "bar"
    // and any index other than `endIndex`
    let pos = sut.index(before: sut.endIndex)

    // When we run the match:
    let result = sut.matchAnyNonNewline(
      at: pos,
      limitedBy: sut.endIndex,
      isScalarSemantics: true
    )

    // Then the next index should be `sut.endIndex`
    let nextIndex = try XCTUnwrap(result)
    XCTAssertEqual(nextIndex, sut.endIndex)
  }

  func testMatchAnyNonNewline_Newline() throws {
    // Given
    // A string that has a newline character
    let sut = "ba\nr"
    // and the index of that newline character
    let pos = try XCTUnwrap(sut.firstIndex(of: "\n"))

    // When we run the reverse match:
    let result = sut.matchAnyNonNewline(
      at: pos,
      limitedBy: sut.endIndex,
      isScalarSemantics: true
    )

    // Then we should get nil because the character at `pos` is a newline
    XCTAssertNil(result)
  }

  func testMatchAnyNonNewline_atEnd() throws {
    // Given
    // A string without any newline characters
    let sut = "bar"

    // When we try to reverse match starting at `startIndex`:
    let result = sut.matchAnyNonNewline(
      at: sut.endIndex,
      limitedBy: sut.endIndex,
      isScalarSemantics: true
    )

    // Then we should get nil because there isn't an index before `startIndex`
    XCTAssertNil(result)
  }

  func testReverseMatchAnyNonNewline() throws {
    // Given
    // A string without any newline characters
    let sut = "bar"
    // and an index other than `startIndex` or `endIndex`
    let pos = sut.index(before: sut.endIndex)

    // When we run the reverse match:
    let result = sut.reverseMatchAnyNonNewline(
      at: pos,
      limitedBy: sut.startIndex,
      isScalarSemantics: true
    )

    // Then we should get a previous index
    let previousIndex = try XCTUnwrap(result)
    // The character at the previous index should be "a"
    XCTAssertEqual(sut[previousIndex], "a")
  }

  func testReverseMatchAnyNonNewline_Newline() throws {
    // Given
    // A string that has a newline character,
    let sut = "ba\nr"
    // and the index of that newline character
    let pos = try XCTUnwrap(sut.firstIndex(of: "\n"))

    // When we run the reverse match:
    let result = sut.reverseMatchAnyNonNewline(
      at: pos,
      limitedBy: sut.startIndex,
      isScalarSemantics: true
    )

    // Then we should get nil because the character at `pos` is a newline
    XCTAssertNil(result)
  }

  func testReverseMatchAnyNonNewline_atStart() throws {
    // Given
    // A string without any newline characters
    let sut = "bar"

    // When we try to reverse match starting at `startIndex`:
    let result = sut.reverseMatchAnyNonNewline(
      at: sut.startIndex,
      limitedBy: sut.startIndex,
      isScalarSemantics: true
    )

    // Then we should get nil because there isn't an index before `startIndex`
    XCTAssertNil(result)
  }

  func testMatchBuiltinCCAtEnd() {
    // Given
    let sut = ""

    // When
    let next = sut.matchBuiltinCC(
      .any,
      at: sut.endIndex,
      limitedBy: sut.endIndex,
      isInverted: false,
      isStrictASCII: false,
      isScalarSemantics: true
    )

    // Then
    XCTAssertNil(next)
  }
}

// MARK: matchScalar tests
extension StringMatchingTests {
  func testMatchScalar() {
    // Given
    let sut = "bar"

    // When
    let next = sut.matchScalar(
      "b",
      at: sut.startIndex,
      limitedBy: sut.endIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertEqual(next, sut.index(after: sut.startIndex))
  }

  func testMatchScalarNoMatch() {
    // Given
    let sut = "bar"

    // When
    let next = sut.matchScalar(
      "a",
      at: sut.startIndex,
      limitedBy: sut.endIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertNil(next)
  }

  func testMatchScalarCaseInsensitive() {
    // Given
    let sut = "BAR"

    // When
    let next = sut.matchScalar(
      "b",
      at: sut.startIndex,
      limitedBy: sut.endIndex,
      boundaryCheck: false,
      isCaseInsensitive: true
    )

    // Then
    XCTAssertEqual(next, sut.index(after: sut.startIndex))
  }

  func testMatchScalarCaseInsensitiveNoMatch() {
    // Given
    let sut = "BAR"

    // When
    let next = sut.matchScalar(
      "a",
      at: sut.startIndex,
      limitedBy: sut.endIndex,
      boundaryCheck: false,
      isCaseInsensitive: true
    )

    // Then
    XCTAssertNil(next)
  }

  func testMatchScalarAtEnd() {
    // Given
    let sut = ""

    // When
    let next = sut.matchScalar(
      "a",
      at: sut.endIndex,
      limitedBy: sut.endIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertNil(next)
  }

  func testMatchScalarBoundaryCheck() {
    // Given
    // \u{62}\u{300}\u{316}\u{65}\u{73}\u{74}
    let sut = "b̖̀est"

    // When
    let next = sut.matchScalar(
      "\u{300}",
      at: sut.unicodeScalars.index(after: sut.unicodeScalars.startIndex),
      limitedBy: sut.endIndex,
      boundaryCheck: true,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertNil(next)
  }

  func testMatchScalarNoBoundaryCheck() {
    // Given
    // \u{62}\u{300}\u{316}\u{65}\u{73}\u{74}
    let sut = "b̖̀est"
    let atPos = sut.unicodeScalars.index(after: sut.unicodeScalars.startIndex)

    // When
    let next = sut.matchScalar(
      "\u{300}",
      at: atPos,
      limitedBy: sut.endIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertEqual(next, sut.unicodeScalars.index(after: atPos))
  }
}

// MARK: reverseMatchScalar tests
extension StringMatchingTests {
  func testReverseMatchScalar() {
    // Given
    let sut = "bar"

    // When
    let previous = sut.reverseMatchScalar(
      "a",
      at: sut.index(after: sut.startIndex),
      limitedBy: sut.startIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertEqual(previous, sut.startIndex)
  }

  func testReverseMatchScalarNoMatch() {
    // Given
    let sut = "bar"

    // When
    let previous = sut.reverseMatchScalar(
      "b",
      at: sut.index(after: sut.startIndex),
      limitedBy: sut.startIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertNil(previous)
  }

  func testReverseMatchScalarCaseInsensitive() {
    // Given
    let sut = "BAR"

    // When
    let previous = sut.reverseMatchScalar(
      "a",
      at: sut.index(after: sut.startIndex),
      limitedBy: sut.startIndex,
      boundaryCheck: false,
      isCaseInsensitive: true
    )

    // Then
    XCTAssertEqual(previous, sut.startIndex)
  }

  func testReverseMatchScalarCaseInsensitiveNoMatch() {
    // Given
    let sut = "BAR"

    // When
    let previous = sut.reverseMatchScalar(
      "b",
      at: sut.index(after: sut.startIndex),
      limitedBy: sut.startIndex,
      boundaryCheck: false,
      isCaseInsensitive: true
    )

    // Then
    XCTAssertNil(previous)
  }

  func testReverseMatchScalarAtStart() {
    // Given
    let sut = "a"

    // When
    let previous = sut.reverseMatchScalar(
      "a",
      at: sut.startIndex,
      limitedBy: sut.startIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertNil(previous)
  }

  func testReverseMatchScalarBoundaryCheck() {
    // Given
    // \u{61}\u{62}\u{300}\u{316}\u{63}\u{64}
    let sut = "ab̖̀cd"

    // When
    let previous = sut.reverseMatchScalar(
      "\u{316}",
      at: sut.unicodeScalars.index(sut.unicodeScalars.startIndex, offsetBy: 3),
      limitedBy: sut.startIndex,
      boundaryCheck: true,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertNil(previous)
  }

  func testReverseMatchScalarNoBoundaryCheck() {
    // Given
    // \u{61}\u{62}\u{300}\u{316}\u{63}\u{64}
    let sut = "ab̖̀cd"
    let atPos = sut.unicodeScalars.index(sut.unicodeScalars.startIndex, offsetBy: 3)

    // When
    let previous = sut.reverseMatchScalar(
      "\u{316}",
      at: atPos,
      limitedBy: sut.startIndex,
      boundaryCheck: false,
      isCaseInsensitive: false
    )

    // Then
    XCTAssertEqual(previous, sut.unicodeScalars.index(before: atPos))
  }
}
