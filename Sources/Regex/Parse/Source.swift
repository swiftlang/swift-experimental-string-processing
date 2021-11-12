/// The source to a lexer. This can be bytes in memory, a file on disk,
/// something streamed over a network connection, etc.
///
/// Currently, we model this as just a Substring (i.e. String + position)
struct Source {
  var state: Substring
  init(_ str: String) { state = str[...] }

  func peek() -> Character? { state.first }
  mutating func eat() -> Character { state.eat() }

  mutating func tryEat(_ c: Character) -> Bool {
    guard peek() == c else { return false }
    _ = state.eat()
    return true
  }

  var isEmpty: Bool { state.isEmpty }

  typealias Location = String.Index
  var currentLoc: Location { state.startIndex }
}

// TODO: more source-location constructs

fileprivate protocol Consumer {
  associatedtype Input
  associatedtype Output

  init(_ state: Input)

  mutating func eat() -> Output
  var isEmpty: Bool { get }
}


extension Substring {
  typealias Input = String
  fileprivate mutating func eat() -> Character {
    assert(!isEmpty)
    defer { self = self.dropFirst() }
    return self.first.unsafelyUnwrapped
  }
}

