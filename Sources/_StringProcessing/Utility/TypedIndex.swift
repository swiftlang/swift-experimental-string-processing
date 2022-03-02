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


/// Forwarding wrapper around Int-index collections that provide a
/// strongly (phantom) typed index.
struct TypedIndex<C: Collection, 👻>: RawRepresentable where C.Index == Int {
  var rawValue: C

  init(rawValue: C) { self.rawValue = rawValue }

  init(_ rawValue: C) { self.init(rawValue: rawValue) }
}

extension TypedIndex: Collection {
  typealias Index = TypedInt<👻>
  typealias Element = C.Element

  var startIndex: Index { Index(rawValue.startIndex) }

  var endIndex: Index { Index(rawValue.endIndex )}

  var count: Int { rawValue.count }

  func index(after: Index) -> Index {
    Index(rawValue.index(after: after.rawValue))
  }

  subscript(position: Index) -> Element {
    rawValue[position.rawValue]
  }

  func distance(
    from start: Index, to end: Index
  ) -> Int {
    rawValue.distance(from: start.rawValue, to: end.rawValue)
  }

  func index(_ i: Index, offsetBy distance: Int) -> Index {
    Index(rawValue.index(i.rawValue, offsetBy: distance))
  }

  func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    guard let idx = rawValue.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue) else {
      return nil
    }
    return Index(idx)
  }
}

extension TypedIndex: RandomAccessCollection where C: RandomAccessCollection {
}
extension TypedIndex: MutableCollection where C: MutableCollection {
  subscript(position: Index) -> Element {
    _read {
      yield rawValue[position.rawValue]
    }
    _modify {
      yield &rawValue[position.rawValue]
    }
  }
}
extension TypedIndex: BidirectionalCollection where C: BidirectionalCollection {
  func index(before: Index) -> Index {
    Index(rawValue.index(before: before.rawValue))
  }
}

// FIXME(apple/swift-experimental-string-processing#73): ParseableInterface test
// failure in the Swift repo.
#if false
extension TypedIndex: RangeReplaceableCollection where C: RangeReplaceableCollection {
  init() { rawValue = C() }

  mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, C.Element == Element {
    let rawRange = subrange.lowerBound.rawValue ..< subrange.upperBound.rawValue
    rawValue.replaceSubrange(rawRange, with: newElements)
  }

  // TODO: append, and all the other customization hooks...
}
#endif

// Workaround for #73
extension TypedIndex where C: RangeReplaceableCollection {
  mutating func append(_ newElement: Element) {
    rawValue.append(newElement)
  }
}

extension TypedIndex: ExpressibleByArrayLiteral where C: ExpressibleByArrayLiteral & RangeReplaceableCollection {
  init(arrayLiteral elements: Element...) {
    // TODO: any way around the RRC copying init?
    self.init(C(elements))
  }
}

// MARK: - Strongly typed wrappers

typealias InstructionList<Instruction: InstructionProtocol> = TypedIndex<[Instruction], _InstructionAddress>

