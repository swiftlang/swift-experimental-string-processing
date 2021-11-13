/// The source given to a parser. This can be bytes in memory, a file on disk,
/// something streamed over a network connection, etc.
struct Source {
  var input: Input
  init<C: Collection>(_ str: C) where C.SubSequence == Input {
    input = str[...]
  }

  var currentLoc: Loc { input.startIndex }
}

extension Source: _CollectionWrapper {
  typealias _Wrapped = Input
  typealias Element = Char
  typealias Index = Loc
  var _wrapped: _Wrapped { input }
}

extension Source: _Peekable {
  typealias Output = Char

  mutating func advance() {
    input = input.dropFirst()
  }
}

// MARK: - Prototype uses String

// For prototyping, base everything on String. Might be buffer
// of bytes, etc., in the future
extension Source {
  typealias Input = Substring
  typealias Char  = Character
  typealias Loc   = String.Index
}

// MARK: - _Peekable

protocol _Peekable: Collection {
  associatedtype Input
  associatedtype Output

  init<C: Collection>(_ str: C) where C.SubSequence == Input

  var isEmpty: Bool { get }
  mutating func peek() -> Output?
  mutating func advance()
}
extension _Peekable where Output == Element {
  func peek() -> Output? { self.first }
}
extension _Peekable {
  mutating func eat() -> Output {
    assert(!isEmpty)
    defer { advance() }
    return peek().unsafelyUnwrapped
  }
}
extension _Peekable where Output: Equatable {
  mutating func tryEat(_ c: Output) -> Bool {
    guard peek() == c else { return false }
    advance()
    return true
  }
}

// MARK: - _CollectionWrapper

protocol _CollectionWrapper: Collection
  where Index == _Wrapped.Index, Element == _Wrapped.Element
{
  associatedtype _Wrapped: Collection
  var _wrapped: _Wrapped { get } // but just for default impls
}
extension _CollectionWrapper {
  func index(after i: Index) -> Index {
    _wrapped.index(after: i)
  }
  subscript(_ i: Index) -> Element {
    _wrapped[i]
  }
  var startIndex: Index { _wrapped.startIndex }
  var endIndex: Index { _wrapped.endIndex }

  // TODO: all the customization points

}

// Below doesn't work, can't insert inheritor...
//
//extension _CollectionWrapper: BidirectionalCollection where _Wrapped: BidirectionalCollection {
//  func index(before i: Index) -> Index {
//    _wrapped.index(before: i)
//  }
//}

