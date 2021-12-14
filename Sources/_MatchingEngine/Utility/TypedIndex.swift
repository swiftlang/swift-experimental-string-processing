
/// Forwarding wrapper around Int-index collections that provide a
/// strongly (phantom) typed index.
@frozen
public struct TypedIndex<C: Collection, 👻>: RawRepresentable where C.Index == Int {
  @_alwaysEmitIntoClient
  public var rawValue: C

  @_alwaysEmitIntoClient
  public init(rawValue: C) { self.rawValue = rawValue }

  @_alwaysEmitIntoClient
  public init(_ rawValue: C) { self.init(rawValue: rawValue) }
}

extension TypedIndex: Collection {
  public typealias Index = TypedInt<👻>
  public typealias Element = C.Element

  @_alwaysEmitIntoClient
  public var startIndex: Index { Index(rawValue.startIndex) }

  @_alwaysEmitIntoClient
  public var endIndex: Index { Index(rawValue.endIndex )}

  @_alwaysEmitIntoClient
  public var count: Int { rawValue.count }

  @_alwaysEmitIntoClient
  public func index(after: Index) -> Index {
    Index(rawValue.index(after: after.rawValue))
  }

  @_alwaysEmitIntoClient
  public subscript(position: Index) -> Element {
    rawValue[position.rawValue]
  }

  @_alwaysEmitIntoClient
  public func distance(
    from start: Index, to end: Index
  ) -> Int {
    rawValue.distance(from: start.rawValue, to: end.rawValue)
  }

  @_alwaysEmitIntoClient
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    Index(rawValue.index(i.rawValue, offsetBy: distance))
  }

  @_alwaysEmitIntoClient
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    guard let idx = rawValue.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue) else {
      return nil
    }
    return Index(idx)
  }
}

extension TypedIndex: RandomAccessCollection where C: RandomAccessCollection {
}
extension TypedIndex: MutableCollection where C: MutableCollection {
  @_alwaysEmitIntoClient
  public subscript(position: Index) -> Element {
    _read {
      yield rawValue[position.rawValue]
    }
    _modify {
      yield &rawValue[position.rawValue]
    }
  }
}
extension TypedIndex: BidirectionalCollection where C: BidirectionalCollection {
  @_alwaysEmitIntoClient
  public func index(before: Index) -> Index {
    Index(rawValue.index(before: before.rawValue))
  }
}

// FIXME(apple/swift-experimental-string-processing#73): ParseableInterface test
// failure in the Swift repo.
#if false
extension TypedIndex: RangeReplaceableCollection where C: RangeReplaceableCollection {
  @_alwaysEmitIntoClient
  public init() { rawValue = C() }

  @_alwaysEmitIntoClient
  public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, C.Element == Element {
    let rawRange = subrange.lowerBound.rawValue ..< subrange.upperBound.rawValue
    rawValue.replaceSubrange(rawRange, with: newElements)
  }

  // TODO: append, and all the other customization hooks...
}
#endif

// Workaround for #73
extension TypedIndex where C: RangeReplaceableCollection {
  public mutating func append(_ newElement: Element) {
    rawValue.append(newElement)
  }
}

extension TypedIndex: ExpressibleByArrayLiteral where C: ExpressibleByArrayLiteral & RangeReplaceableCollection {
  @_alwaysEmitIntoClient
  public init(arrayLiteral elements: Element...) {
    // TODO: any way around the RRC copying init?
    self.init(C(elements))
  }
}

// MARK: - Strongly typed wrappers

public typealias InstructionList<Instruction: InstructionProtocol> = TypedIndex<[Instruction], _InstructionAddress>

