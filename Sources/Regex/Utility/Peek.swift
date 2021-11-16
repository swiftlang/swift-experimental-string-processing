// MARK: - _Peekable

protocol _Peekable {
  associatedtype Output

  var isEmpty: Bool { get }
  mutating func peek() -> Output?
  mutating func advance()
}
extension _Peekable where Self: Collection, Output == Element {
  func peek() -> Output? { self.first }
}
extension _Peekable {
  @discardableResult
  mutating func eat() -> Output {
    assert(!isEmpty)
    defer { advance() }
    return peek().unsafelyUnwrapped
  }

  mutating func advance(_ i: Int) {
    for _ in 0..<i {
      advance()
    }
  }
}
extension _Peekable where Output: Equatable {
  mutating func tryEat(_ c: Output) -> Bool {
    guard peek() == c else { return false }
    advance()
    return true
  }
}
extension _Peekable
  where Self: Collection, Output == Element, Output: Equatable
{
  mutating func tryEat<C: Collection>(sequence c: C) -> Bool
    where C.Element == Element
  {
    guard starts(with: c) else { return false }
    advance(c.count)
    return true
  }
}

// MARK: - _CollectionWrapper

public protocol _CollectionWrapper: Collection
  where Index == _Wrapped.Index, Element == _Wrapped.Element
{
  associatedtype _Wrapped: Collection
  var _wrapped: _Wrapped { get } // but just for default impls
}
extension _CollectionWrapper {
  public func index(after i: Index) -> Index {
    _wrapped.index(after: i)
  }
  public subscript(_ i: Index) -> Element {
    _wrapped[i]
  }
  public var startIndex: Index { _wrapped.startIndex }
  public var endIndex: Index { _wrapped.endIndex }

  // TODO: all the customization points

}

// Below doesn't work, can't insert inheritor...
//
//extension _CollectionWrapper: BidirectionalCollection where _Wrapped: BidirectionalCollection {
//  func index(before i: Index) -> Index {
//    _wrapped.index(before: i)
//  }
//}

