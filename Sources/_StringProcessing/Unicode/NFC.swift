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

@_spi(_Unicode)
import Swift

extension UInt8 {
  /// Whether this is the starting byte of a sub-300 (i.e. pre-combining scalar) scalars
  var _isSub300StartingByte: Bool { self < 0xCC }
}

extension UnicodeScalar {
  /// Checks whether the scalar is in NFC form.
  var isNFC: Bool { Character(self).singleNFCScalar == self }
}

extension Character {
  /// If the given character consists of a single NFC scalar, returns it. If
  /// there are multiple NFC scalars, returns `nil`.
  var singleNFCScalar: UnicodeScalar? {
    // SwiftStdlib is always >= 5.7 for a shipped StringProcessing.
    guard #available(SwiftStdlib 5.7, *) else { return nil }
    var nfcIter = String(self)._nfc.makeIterator()
    guard let scalar = nfcIter.next(), nfcIter.next() == nil else { return nil }
    return scalar
  }

  /// If the given character contains a single scalar, returns it. If none or
  /// multiple scalars are present, returns `nil`.
  var singleScalar: UnicodeScalar? {
    hasExactlyOneScalar ? unicodeScalars.first! : nil
  }
}

extension String {
  /// If the given string consists of a single NFC scalar, returns it. If none
  /// or multiple NFC scalars are present, returns `nil`.
  var singleNFCScalar: UnicodeScalar? {
    guard !isEmpty && index(after: startIndex) == endIndex else { return nil }
    return first!.singleNFCScalar
  }

  /// If the given string contains a single scalar, returns it. If none or
  /// multiple scalars are present, returns `nil`.
  var singleScalar: UnicodeScalar? {
    let scalars = unicodeScalars
    guard !scalars.isEmpty &&
          scalars.index(after: scalars.startIndex) == scalars.endIndex
    else { return nil }
    return scalars.first!
  }
}
