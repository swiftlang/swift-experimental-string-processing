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

// TODO: Probably refactor out of DSLTree
extension DSLTree.CustomCharacterClass {
  internal struct AsciiBitset {
    let isInverted: Bool

    // The matched values as a 128-bit mask, always stored un-inverted.
    fileprivate var a: UInt64 = 0
    fileprivate var b: UInt64 = 0

    init(isInverted: Bool) {
      self.isInverted = isInverted
    }

    init(_ val: UInt8, _ isInverted: Bool, _ isCaseInsensitive: Bool) {
      self.isInverted = isInverted
      add(val, isCaseInsensitive)
    }

    init(low: UInt8, high: UInt8, isInverted: Bool, isCaseInsensitive: Bool) {
      self.isInverted = isInverted
      for val in low...high {
        add(val, isCaseInsensitive)
      }
    }

    fileprivate init(
      a: UInt64,
      b: UInt64,
      isInverted: Bool
    ) {
      self.isInverted = isInverted
      self.a = a
      self.b = b
    }

    internal mutating func add(_ val: UInt8, _ isCaseInsensitive: Bool) {
      setBit(val)
      if isCaseInsensitive {
        switch val {
          case 64...90: setBit(val + 32)
          case 97...122: setBit(val - 32)
          default: break
        }
      }
    }

    internal mutating func setBit(_ val: UInt8) {
      if val < 64 {
        a = a | 1 << val
      } else {
        b = b | 1 << (val - 64)
      }
    }

    private func _matchesWithoutInversionCheck(_ val: UInt8) -> Bool {
      if val < 64 {
        return (a >> val) & 1 == 1
      } else {
        return (b >> (val - 64)) & 1 == 1
      }
    }

    internal func matches(_ byte: UInt8) -> Bool {
      guard byte < 128 else { return isInverted }
      return _matchesWithoutInversionCheck(byte) == !isInverted
    }

    internal func matches(_ char: Character) -> Bool {
      let matched: Bool
      if let val = char._singleScalarAsciiValue {
        matched = _matchesWithoutInversionCheck(val)
      } else {
        matched = false
      }

      if isInverted {
        return !matched
      }
      return matched
    }

    internal func matches(_ scalar: Unicode.Scalar) -> Bool {
      let matched: Bool
      if scalar.isASCII {
        let val = UInt8(ascii: scalar)
        matched = _matchesWithoutInversionCheck(val)
      } else {
        matched = false
      }

      if isInverted {
        return !matched
      }
      return matched
    }

    /// Joins another bitset from a Member of the same CustomCharacterClass
    internal func union(_ other: AsciiBitset) -> AsciiBitset {
      precondition(self.isInverted == other.isInverted)
      return AsciiBitset(
        a: self.a | other.a,
        b: self.b | other.b,
        isInverted: self.isInverted
      )
    }

    // MARK: Set operations
    //
    // These are all preconditioned on the bitsets being non-inverted,
    // since the operations are only valid on direct sets. An inverted ASCII
    // set matches every non-ASCII character, so e.g. intersecting doesn't
    // produce the actual intersection.

    /// Returns a bitset matching the values matched by both `self` and
    /// `other`.
    ///
    /// - Precondition: Neither bitset is inverted.
    internal func intersection(_ other: AsciiBitset) -> AsciiBitset {
      precondition(!self.isInverted && !other.isInverted)
      return AsciiBitset(
        a: self.a & other.a,
        b: self.b & other.b,
        isInverted: false
      )
    }

    /// Returns a bitset matching the values matched by `self` but not by
    /// `other`.
    ///
    /// - Precondition: Neither bitset is inverted.
    internal func subtracting(_ other: AsciiBitset) -> AsciiBitset {
      precondition(!self.isInverted && !other.isInverted)
      return AsciiBitset(
        a: self.a & ~other.a,
        b: self.b & ~other.b,
        isInverted: false
      )
    }

    /// Returns a bitset matching the values matched by exactly one of `self`
    /// and `other`.
    ///
    /// - Precondition: Neither bitset is inverted.
    internal func symmetricDifference(_ other: AsciiBitset) -> AsciiBitset {
      precondition(!self.isInverted && !other.isInverted)
      return AsciiBitset(
        a: self.a ^ other.a,
        b: self.b ^ other.b,
        isInverted: false
      )
    }

    /// Returns this bitset with its inversion set to `isInverted`, for
    /// applying the inversion of the class that encloses it.
    internal func settingInversion(_ isInverted: Bool) -> AsciiBitset {
      AsciiBitset(a: self.a, b: self.b, isInverted: isInverted)
    }
  }
}
