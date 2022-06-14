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

@_spi(_Unicode) import Swift

// TODO

extension Character {
  /// Whether this character and `c` are equal when case folded.
  func caseFoldedEquals(_ c: Character) -> Bool {
    guard #available(SwiftStdlib 5.7, *) else { fatalError() }
    let foldedSelf = unicodeScalars.lazy.map(\.properties._caseFolded).joined()
    let foldedOther = c.unicodeScalars.lazy.map(\.properties._caseFolded).joined()
    return foldedSelf.elementsEqual(foldedOther)
  }
}

extension UnicodeScalar {
  /// Whether this Unicode scalar and `s` are equal when case folded.
  func caseFoldedEquals(_ s: UnicodeScalar) -> Bool {
    guard #available(SwiftStdlib 5.7, *) else { fatalError() }
    return properties._caseFolded == s.properties._caseFolded
  }
}
