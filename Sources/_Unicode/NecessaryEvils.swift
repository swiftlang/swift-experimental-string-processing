/*

 Pull in shims and other things so our code is closer to the
 stdlib's and vice versa. Long term, we'll want to address
 each of these

*/

func _internalInvariant(
  _ b: @autoclosure () -> Bool, _ s: String = ""
) {
  assert(b(), s)
}

extension UnsafeBufferPointer {
  subscript(_unchecked idx: Int) -> Element {
    // TODO: faster version
    self[idx]
  }
}

extension Unicode.Scalar {
  init(_unchecked v: UInt32) {
    self.init(v)!
  }
}

// TODO: This actually might be good module API fodder
extension UTF16 {
  //@inlinable @inline(__always)
  internal static func _decodeSurrogates(
    _ lead: CodeUnit,
    _ trail: CodeUnit
  ) -> Unicode.Scalar {
    _internalInvariant(isLeadSurrogate(lead))
    _internalInvariant(isTrailSurrogate(trail))
    return Unicode.Scalar(
      _unchecked: 0x10000 +
      (UInt32(lead & 0x03ff) &<< 10 | UInt32(trail & 0x03ff)))
  }
}
