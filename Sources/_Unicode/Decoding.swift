/*

 Provide very low-level interfaces for scalar decoding.

 These can be faster if we assume certain invariants are
 maintained. We assert, of course, because we're not monsters.

 Thus they are unsafe in the following senses:

 - They assume validly encoded contents, otherwise UB
 - They assume any pointers passed in will be live and valid
   during execution and not concurrently written to, otherwise UB
 - They assume any pointer passed in has sufficient bounds
   for decoding a scalar, otherwise UB.

 String maintains these invariants for its in-memory storage.

 */


// TODO: Design an "unsafe" and "assumingValid" API convention

enum UnsafeAssumingValidUTF8 {
  @inlinable @inline(__always)
  public func decode(_ x: UInt8) -> Unicode.Scalar {
    _internalInvariant(UTF8.isASCII(x))
    return Unicode.Scalar(_unchecked: UInt32(x))
  }

  @inlinable @inline(__always)
  public func decode(
    _ x: UInt8, _ y: UInt8
  ) -> Unicode.Scalar {
    _internalInvariant(scalarLength(x) == 2)
    _internalInvariant(UTF8.isContinuation(y))
    let x = UInt32(x)
    let value = ((x & 0b0001_1111) &<< 6) | continuationPayload(y)
    return Unicode.Scalar(_unchecked: value)
  }

  @inlinable @inline(__always)
  public func decode(
    _ x: UInt8, _ y: UInt8, _ z: UInt8
  ) -> Unicode.Scalar {
    _internalInvariant(scalarLength(x) == 3)
    _internalInvariant(UTF8.isContinuation(y) && UTF8.isContinuation(z))
    let x = UInt32(x)
    let value = ((x & 0b0000_1111) &<< 12)
    | (continuationPayload(y) &<< 6)
    | continuationPayload(z)
    return Unicode.Scalar(_unchecked: value)
  }

  @inlinable @inline(__always)
  public func decode(
    _ x: UInt8, _ y: UInt8, _ z: UInt8, _ w: UInt8
  ) -> Unicode.Scalar {
    _internalInvariant(scalarLength(x) == 4)
    _internalInvariant(
      UTF8.isContinuation(y) && UTF8.isContinuation(z)
      && UTF8.isContinuation(w))
    let x = UInt32(x)
    let value = ((x & 0b0000_1111) &<< 18)
    | (continuationPayload(y) &<< 12)
    | (continuationPayload(z) &<< 6)
    | continuationPayload(w)
    return Unicode.Scalar(_unchecked: value)
  }

  // Also, assuming we can load from those bounds...
  @inlinable
  public func decode(
    _ utf8: UnsafeByteBuffer, startingAt i: Int
  ) -> (Unicode.Scalar, scalarLength: Int) {
    let cu0 = utf8[_unchecked: i]
    let len = scalarLength(cu0)
    switch  len {
    case 1: return (decode(cu0), len)
    case 2: return (decode(cu0, utf8[_unchecked: i &+ 1]), len)
    case 3: return (decode(
      cu0, utf8[_unchecked: i &+ 1], utf8[_unchecked: i &+ 2]), len)
    case 4:
      return (decode(
        cu0,
        utf8[_unchecked: i &+ 1],
        utf8[_unchecked: i &+ 2],
        utf8[_unchecked: i &+ 3]),
              len)
    default:
      fatalError("unreachable")//Builtin.unreachable()
    }
  }

  @inlinable
  public func decode(
    _ utf8: UnsafeByteBuffer, endingAt i: Int
  ) -> (Unicode.Scalar, scalarLength: Int) {
    let len = scalarLength(utf8, endingAt: i)
    let (scalar, scalarLen) = decode(utf8, startingAt: i &- len)
    _internalInvariant(len == scalarLen)
    return (scalar, len)
  }

  @inlinable @inline(__always)
  public func scalarLength(_ x: UInt8) -> Int {
    _internalInvariant(!UTF8.isContinuation(x))
    if UTF8.isASCII(x) { return 1 }
    // TODO(String micro-performance): check codegen
    return (~x).leadingZeroBitCount
  }

  @inlinable @inline(__always)
  public func scalarLength(
    _ utf8: UnsafeByteBuffer, endingAt i: Int
  ) -> Int {
    var len = 1
    while UTF8.isContinuation(utf8[_unchecked: i &- len]) {
      len &+= 1
    }
    _internalInvariant(len == scalarLength(utf8[i &- len]))
    return len
  }

  @inlinable @inline(__always)
  public func continuationPayload(_ x: UInt8) -> UInt32 {
    return UInt32(x & 0x3F)
  }

  @inlinable
  public func scalarAlign(
    _ utf8: UnsafeByteBuffer, _ idx: Int
  ) -> Int {
    guard _fastPath(idx != utf8.count) else { return idx }

    var i = idx
    while _slowPath(UTF8.isContinuation(utf8[_unchecked: i])) {
      i &-= 1
      _internalInvariant(i >= 0,
                         "Malformed contents: starts with continuation byte")
    }
    return i
  }
}

// TODO: Validating versions that remove that aspect of
// unsafety. Stdlib has stuff on _StrinGuts that could be
// at least partially refactored.

// TODO: Consider UTF-16 support, but that's normally best
// handled as a transcoding concern.


