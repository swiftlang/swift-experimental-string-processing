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

