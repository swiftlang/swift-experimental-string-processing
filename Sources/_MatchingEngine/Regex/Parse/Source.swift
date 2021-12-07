/// The source given to a parser. This can be bytes in memory, a file on disk,
/// something streamed over a network connection, etc.
///
/// For now, we use String...
///
public struct Source {
  var input: Input
  var bounds: Range<Input.Index>
  var syntax: SyntaxOptions

  // TODO: source should hold outer collection and range, at least
  // for error reporting if nothing else

  init(_ str: Input, _ syntax: SyntaxOptions) {
    self.input = str
    self.bounds = str.startIndex ..< str.endIndex
    self.syntax = syntax
  }

  var currentLoc: Loc { bounds.lowerBound }
}

extension Source: _CollectionWrapper {
  public typealias _Wrapped = Input.SubSequence
  public typealias Element = Char
  public typealias Index = Loc
  public var _wrapped: _Wrapped {
    get { input[bounds] }
    set {
      let newBounds = newValue.startIndex ..< newValue.endIndex

      // Really doubly check our assumptions
      assert(newValue.base == input)
      assert(bounds.lowerBound <= newBounds.lowerBound)
      assert(bounds.upperBound >= newBounds.upperBound)

      bounds = newBounds
    }
  }
}

extension Source: _Peekable {
  public typealias Output = Char

  public mutating func advance() {
    assert(!isEmpty)
    _wrapped = _wrapped.dropFirst()
  }
}

// MARK: - Prototype uses String

// For prototyping, base everything on String. Might be buffer
// of bytes, etc., in the future
extension Source {
  public typealias Input = String
  public typealias Char  = Character
  public typealias Loc   = String.Index
}

public typealias SourceRange = Range<Source.Loc>
public typealias SourceLoc = Source.Loc

// Ugly...
extension Slice where Base == Source {
  var string: String {
    String(self)
  }
}

// MARK: - Syntax

extension Source {
  var modernRanges: Bool { syntax.contains(.modernRanges) }
  var modernCaptures: Bool { syntax.contains(.modernCaptures) }
  var modernQuotes: Bool { syntax.contains(.modernQuotes) }
  var nonSemanticWhitespace: Bool {
    syntax.contains(.nonSemanticWhitespace)
  }
}

