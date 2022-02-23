import _MatchingEngine

extension CaptureStructure {
  var optionalCount: Int {
    switch self {
    case .atom: return 0
    case .optional(let o):
      return 1 + o.optionalCount
    case .tuple:
      // FIXME: Separate CaptureStructure and a component
      fatalError("Recursive nesting")
    @unknown default:
      fatalError("Unknown default")
    }
  }

  // FIXME: Do it all in one pass, no need for all these
  // intermediary arrays
  func structuralize(
    _ list: CaptureList,
    _ input: String
  ) throws -> [StructuredCapture] {

    func mapCap(
      _ cap: CaptureStructure,
      _ storedCap: Processor<String>._StoredCapture
    ) -> StructuredCapture {
      // TODO: CaptureList perhaps should store a
      // metatype or relevant info...
      let optCount = cap.optionalCount

      if cap.atomType.base == Substring.self {
        // FIXME: What if a typed capture is Substring?
        assert(!storedCap.hasValues)

        if let r = storedCap.latest {
          return StructuredCapture(
            optionalCount: optCount,
            storedCapture: StoredCapture(range: r))
        }

        return StructuredCapture(
          optionalCount: optCount,
          storedCapture: nil)
      }

      guard (storedCap.isEmpty || storedCap.hasValues) else {
        print(storedCap)
        fatalError()
      }
      // TODO: assert types are the same, under all the
      // optionals

      if let v = storedCap.latestValue {
        return StructuredCapture(
          optionalCount: optCount,
          storedCapture: StoredCapture(range: storedCap.latest, value: v))
      }
      return StructuredCapture(
        optionalCount: optCount,
        storedCapture: nil)
    }

    switch self {
    case let .tuple(caps):
      assert(list.caps.count == caps.count)
      var result = Array<StructuredCapture>()
      for (cap, storedCap) in zip(caps, list.caps) {
        result.append(mapCap(cap, storedCap))
      }
      return result

    default:
      assert(list.caps.count == 1)
      return [mapCap(self, list.caps.first!)]
    }
  }
}
