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


// TODO

extension Character {
  /// Whether this character is made up of exactly one Unicode scalar value.
  var hasExactlyOneScalar: Bool {
    unicodeScalars.index(after: unicodeScalars.startIndex) == unicodeScalars.endIndex
  }
}
