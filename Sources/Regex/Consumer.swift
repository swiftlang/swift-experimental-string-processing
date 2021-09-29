internal protocol Consumer {
  associatedtype Input
  associatedtype Output

  init(_ state: Input)

  mutating func eat() -> Output
  var isEmpty: Bool { get }
}

extension Substring: Consumer {
  typealias Input = String

  mutating func eat() -> Character {
    assert(!isEmpty)
    defer { self = self.dropFirst() }
    return self.first.unsafelyUnwrapped
  }
}

