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

@_silgen_name("_swift_stdlib_getNormData")
func _swift_stdlib_getNormData(_: UInt32) -> UInt16

@_silgen_name("_swift_stdlib_nfd_decompositions")
func _swift_stdlib_nfd_decompositions() -> UnsafePointer<UInt8>?

@_silgen_name("_swift_stdlib_getDecompositionEntry")
func _swift_stdlib_getDecompositionEntry(_: UInt32) -> UInt32

@_silgen_name("_swift_stdlib_getComposition")
func _swift_stdlib_getComposition(_: UInt32, _: UInt32) -> UInt32

extension Unicode {
  internal struct _NFD<S: StringProtocol> {
    let base: S
  }
}

extension Unicode._NFD {
  internal struct Iterator {
    var buffer = Unicode._NormDataBuffer()

    // This index always points at the next starter of a normalization segment.
    // Each iteration of 'next()' moves this index up to the next starter.
    var index: S.UnicodeScalarView.Index

    let unicodeScalars: S.UnicodeScalarView
  }
}

extension Unicode._NFD.Iterator: IteratorProtocol {
  internal mutating func decompose(
    _ scalar: Unicode.Scalar,
    with normData: Unicode._NormData
  ) {
    // ASCII always decomposes to itself.
    if _fastPath(scalar.value < 0xC0) {
      // ASCII always has normData of 0.
      // CCC = 0, NFC_QC = Yes, NFD_QC = Yes
      buffer.append((scalar, normData))
      return
    }

    // Handle Hangul decomposition algorithmically.
    // S.base = 0xAC00
    // S.count = 11172
    // S.base + S.count - 1 = 0xD7A3
    if (0xAC00 ... 0xD7A3).contains(scalar.value) {
      decomposeHangul(scalar)
      return
    }

    // Otherwise, we need to lookup the decomposition (if there is one).
    decomposeSlow(scalar, with: normData)
  }

  @inline(never)
  internal mutating func decomposeHangul(_ scalar: Unicode.Scalar) {
    // L = Hangul leading consonants
    let L: (base: UInt32, count: UInt32) = (base: 0x1100, count: 19)
    // V = Hangul vowels
    let V: (base: UInt32, count: UInt32) = (base: 0x1161, count: 21)
    // T = Hangul tail consonants
    let T: (base: UInt32, count: UInt32) = (base: 0x11A7, count: 28)
    // N = Number of precomposed Hangul syllables that start with the same
    //     leading consonant. (There is no base for N).
    let N: (base: UInt32, count: UInt32) = (base: 0x0, count: 588)
    // S = Hangul precomposed syllables
    let S: (base: UInt32, count: UInt32) = (base: 0xAC00, count: 11172)

    let sIdx = scalar.value &- S.base

    let lIdx = sIdx / N.count
    let l = Unicode.Scalar(_value: L.base &+ lIdx)
    // Hangul leading consonants, L, always have normData of 0.
    // CCC = 0, NFC_QC = Yes, NFD_QC = Yes
    buffer.append((scalar: l, normData: .init(rawValue: 0)))

    let vIdx = (sIdx % N.count) / T.count
    let v = Unicode.Scalar(_value: V.base &+ vIdx)
    // Hangul vowels, V, always have normData of 4.
    // CCC = 0, NFC_QC = Maybe, NFD_QC = Yes
    buffer.append((scalar: v, normData: .init(rawValue: 4)))

    let tIdx = sIdx % T.count
    if tIdx != 0 {
      let t = Unicode.Scalar(_value: T.base &+ tIdx)
      // Hangul tail consonants, T, always have normData of 4.
      // CCC = 0, NFC_QC = Maybe, NFD_QC = Yes
      buffer.append((scalar: t, normData: .init(rawValue: 4)))
    }
  }

  @inline(never)
  internal mutating func decomposeSlow(
    _ scalar: Unicode.Scalar,
    with normData: Unicode._NormData
  ) {
    // Look into the decomposition perfect hash table.
    let decompEntry = Unicode._DecompositionEntry(scalar)

    // If this is not our original scalar, then we have no decomposition for this
    // scalar, so just emit itself. This is required because perfect hashing
    // does not know the original set of keys that it used to create itself, so
    // we store the original scalar in our decomposition entry to ensure that
    // scalars that hash to the same index don't succeed.
    guard scalar == decompEntry.hashedScalar else {
      buffer.append((scalar, normData))
      return
    }

    var utf8 = decompEntry.utf8

    while utf8.count > 0 {
      let (scalar, len) = UnsafeAssumingValidUTF8.decode(
        utf8.byteBuffer,
        startingAt: 0
      )
      utf8 = UnsafeBufferPointer(rebasing: utf8[len...])

      // Fast path: Because this will be emitted into the completed NFD buffer,
      // we don't need to look at NFD_QC anymore which lets us do a larger
      // latiny check for NFC_QC and CCC (0xC0 vs. 0x300).
      let normData = Unicode._NormData(scalar, fastUpperbound: 0x300)

      buffer.append((scalar, normData))
    }
  }

  internal mutating func next() -> ScalarAndNormData? {
    // Empty out our buffer before attempting to decompose the next
    // normalization segment.
    if let nextBuffered = buffer.next() {
      return nextBuffered
    }

    while index < unicodeScalars.endIndex {
      let scalar = unicodeScalars[index]
      let normData = Unicode._NormData(scalar)

      // If we've reached a starter, stop.
      if normData.ccc == 0, !buffer.isEmpty {
        break
      }

      unicodeScalars.formIndex(after: &index)

      // If our scalar IS NFD quick check, then it's as simple as appending to
      // our buffer and moving on the next scalar. Otherwise, we need to
      // decompose this and append each decomposed scalar.
      if normData.isNFDQC {
        // Fast path: If our scalar is also ccc = 0, then this doesn't need to
        // be appended to the buffer at all.
        if normData.ccc == 0 {
          return (scalar, normData)
        }

        buffer.append((scalar, normData))
      } else {
        decompose(scalar, with: normData)
      }
    }

    // Sort the entire buffer based on the canonical combining class.
    buffer.sort()

    return buffer.next()
  }
}

extension Unicode._NFD: Sequence {
  internal func makeIterator() -> Iterator {
    Iterator(
      index: base.unicodeScalars.startIndex,
      unicodeScalars: base.unicodeScalars
    )
  }
}

extension StringProtocol {
  internal var _nfd: Unicode._NFD<Self> {
    Unicode._NFD(base: self)
  }
}

extension Unicode {
  internal struct _NFC<S: StringProtocol> {
    let base: S
  }
}

extension Unicode._NFC {
  internal struct Iterator {
    var buffer = Unicode._NormDataBuffer()

    // This is our starter that is currently being composed with other scalars
    // into new scalars. For example, "e\u{301}", here our first scalar is 'e',
    // which is a starter, thus we assign composee to this 'e' and move to the
    // next scalar. We attempt to compose our composee, 'e', with '\u{301}' and
    // find that there is a composition. Thus our new composee is now 'é' and
    // we continue to try and compose following scalars with this composee.
    var composee: Unicode.Scalar? = nil

    var iterator: Unicode._NFD<S>.Iterator
  }
}

extension Unicode._NFC.Iterator: IteratorProtocol {
  internal func compose(
    _ x: Unicode.Scalar,
    and y: Unicode.Scalar
  ) -> Unicode.Scalar? {
    // Fast path: ASCII and some latiny scalars never compose when they're on
    // the rhs.
    if _fastPath(y.value < 0x300) {
      return nil
    }

    if let hangul = composeHangul(x, and: y) {
      return hangul
    }

    // Otherwise, lookup the composition.
    let composition = _swift_stdlib_getComposition(x.value, y.value)

    guard composition != .max else {
      return nil
    }

    return Unicode.Scalar(_value: composition)
  }

  @inline(never)
  internal func composeHangul(
    _ x: Unicode.Scalar,
    and y: Unicode.Scalar
  ) -> Unicode.Scalar? {
    // L = Hangul leading consonants
    let L: (base: UInt32, count: UInt32) = (base: 0x1100, count: 19)
    // V = Hangul vowels
    let V: (base: UInt32, count: UInt32) = (base: 0x1161, count: 21)
    // T = Hangul tail consonants
    let T: (base: UInt32, count: UInt32) = (base: 0x11A7, count: 28)
    // N = Number of precomposed Hangul syllables that start with the same
    //     leading consonant. (There is no base for N).
    let N: (base: UInt32, count: UInt32) = (base: 0x0, count: 588)
    // S = Hangul precomposed syllables
    let S: (base: UInt32, count: UInt32) = (base: 0xAC00, count: 11172)

    switch (x.value, y.value) {
    // Check for Hangul (L, V) -> LV compositions.
    case (L.base ..< L.base &+ L.count, V.base ..< V.base &+ V.count):
      let lIdx = x.value &- L.base
      let vIdx = y.value &- V.base
      let lvIdx = lIdx &* N.count &+ vIdx &* T.count
      let s = S.base &+ lvIdx
      return Unicode.Scalar(_value: s)

    // Check for Hangul (LV, T) -> LVT compositions.
    case (S.base ..< S.base &+ S.count, T.base &+ 1 ..< T.base &+ T.count):
      if (x.value &- S.base) % T.count == 0 {
        return Unicode.Scalar(_value: x.value &+ y.value &- T.base)
      } else {
        fallthrough
      }

    default:
      return nil
    }
  }

  internal mutating func next() -> Unicode.Scalar? {
    // Empty out our buffer before attempting to compose anything with our new
    // composee.
    if let nextBuffered = buffer.next() {
      return nextBuffered.scalar
    }

    while let current = iterator.next() {
      guard let currentComposee = composee else {
        // If we don't have a composee at this point, we're most likely looking
        // at the start of a string. If our class is 0, then attempt to compose
        // the following scalars with this one. Otherwise, it's a one off scalar
        // that needs to be emitted.
        if current.normData.ccc == 0 {
          composee = current.scalar
          continue
        } else {
          return current.scalar
        }
      }

      // If we have any scalars in the buffer, it means those scalars couldn't
      // compose with our composee to form a new scalar. However, scalars
      // following them may still compose with our composee, so take the last
      // scalar in the buffer and get its normalization data so that we can
      // perform the check underneath this one about whether this current scalar
      // is "blocked". We get the last scalar because the scalars we receive are
      // already NFD, so the last scalar in the buffer will have the highest
      // CCC value in this normalization segment.
      guard let lastBufferedNormData = buffer.last?.normData else {
        // If we do not any have scalars in our buffer yet, then this step is
        // trivial. Attempt to compose our current scalar with whatever composee
        // we're currently building up.

        // If our right hand side scalar IS NFC_QC, then that means it can
        // never compose with any scalars previous to it. So, if our current
        // scalar is NFC_QC, then we have no composition.
        guard !current.normData.isNFCQC,
            let composed = compose(currentComposee, and: current.scalar) else {
          // We did not find a composition between the two. If our current class
          // is 0, then set that as the new composee and return whatever built
          // up scalar we have. Otherwise, add our current scalar to the buffer
          // for eventual removal!

          if current.normData.ccc == 0 {
            composee = current.scalar
            return currentComposee
          }

          buffer.append(current)
          continue
        }

        // We found a composition! Record it as our new composee and repeat the
        // process.
        composee = composed
        continue
      }

      // Check if our current scalar is not blocked from our current composee.
      // In this case blocked means there is some scalar whose class
      // (lastBufferedNormData.ccc) is either == 0 or >= current.normData.ccc.
      //
      // Example:
      //
      //     "z\u{0335}\u{0327}\u{0324}\u{0301}"
      //
      // In this example, there are several combining marks following a 'z', but
      // none of them actually compose with the composee 'z'. However, the last
      // scalar U+0301 does actually compose. So this check makes sure that the
      // last scalar doesn't have any scalar in between it and the composee that
      // would otherwise "block" it from composing.
      guard lastBufferedNormData.ccc < current.normData.ccc else {
        // We had a scalar block it. That means our current scalar is either a
        // starter or has a same class (preserve ordering).

        // Starters are the "start" of a new normalization segment. Set it as
        // the new composee and return our current composee. This will trigger
        // any other scalars in the buffer to be emitted before we handle
        // normalizing this new segment.
        if current.normData.ccc == 0 {
          composee = current.scalar
          return currentComposee
        }

        _internalInvariant(current.normData.ccc == lastBufferedNormData.ccc)
        buffer.append(current)
        continue
      }

      // There were no blockers! Attempt to compose the two! (Again, if our rhs
      // scalar IS NFC_QC, then it can never compose with anything previous to
      // it).
      guard !current.normData.isNFCQC,
            let composed = compose(currentComposee, and: current.scalar) else {
        // No composition found. Stick it at the end of the buffer with the rest
        // of non-composed scalars.

        buffer.append(current)
        continue
      }

      // They composed! Assign the composition as our new composee and iterate
      // to the next scalar.
      composee = composed
    }

    // If we have a leftover composee, make sure to return it.
    return composee._take()
  }
}

extension Unicode._NFC: Sequence {
  internal func makeIterator() -> Iterator {
    Iterator(iterator: base._nfd.makeIterator())
  }
}

extension StringProtocol {
  internal var _nfc: Unicode._NFC<Self> {
    Unicode._NFC(base: self)
  }
}

