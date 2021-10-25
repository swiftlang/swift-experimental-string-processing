// MARK: - Element Consumer

/// An alternate formation of consumers: Don't bind collection type as we're just
/// consuming elements by classification or literal sequencing.
protocol ElementConsumer {
  associatedtype Element
  func consume<C: Collection>(
    _ c: C, in: Range<C.Index>
  ) -> C.Index? where C.Element == Element
}

protocol CharacterConsumer: ElementConsumer
where Element == Character { }

protocol ScalarConsumer: ElementConsumer
where Element == Unicode.Scalar { }

protocol UTF8Consumer: ElementConsumer
where Element == UInt8 { }

protocol UTF16Consumer: ElementConsumer
where Element == UInt16 { }

// struct ...LiteralSequence: ...Consumer { ... }

// MARK: - Element Classes

protocol ElementClass: ElementConsumer {
  func contains(_ e: Element) -> Bool
}
extension ElementClass {
  func consume<C: Collection>(
    _ c: C, in range: Range<C.Index>
  ) -> C.Index? where C.Element == Element {
    // FIXME: empty ranges, etc...
    let lower = range.lowerBound
    return contains(c[lower]) ? c.index(after: lower) : nil
  }
}

protocol ScalarClass: ElementClass, ScalarConsumer {}
protocol CharacterClass: ElementClass, CharacterConsumer {}

// MARK: Granularity adapters

/// Any higher-granularity consumer can be a lower-granularity
/// consumer by just consuming at its higher-granularity
struct _CharacterToScalar <
  Characters: CharacterConsumer
>: ScalarConsumer {
  var characters: Characters

  func consume<C: Collection>(
    _ c: C, in range: Range<C.Index>
  ) -> C.Index? where C.Element == Unicode.Scalar {
    let str = String(c)
    let r = c.convertByOffset(range, in: str)
    guard let idx = characters.consume(str, in: r) else {
      return nil
    }

    return str.convertByOffset(idx, in: c)
  }
}
// ...

/// Any lower-granularity consumer can be a higher
/// granularity consumer by checking if the result falls on a
/// boundary.
struct _ScalarToCharacter <
  Scalars: ScalarConsumer
>: CharacterConsumer {
  var scalars: Scalars

  func _consume(
    _ str: String, in range: Range<String.Index>
  ) -> String.Index? {
    guard let idx = scalars.consume(str.unicodeScalars, in: range),
          str.isOnGraphemeClusterBoundary(idx)
    else {
      return nil
    }
    return idx
  }

  func consume<C: Collection>(
    _ c: C, in range: Range<C.Index>
  ) -> C.Index? where C.Element == Character {
    let str = String(c)
    let r = c.convertByOffset(range, in: str)

    guard let idx = _consume(str, in: r) else {
      return nil
    }
    return str.convertByOffset(idx, in: c)
  }
}

/// Any lower-granularity class can be a higher-granularity
/// class if we choose a semantic-extension style
struct _FirstScalarCharacters<
  Scalars: ScalarClass
>: CharacterClass {
  var scalars: Scalars
  func contains(_ c: Character) -> Bool {
    scalars.contains(c.unicodeScalars.first!)
  }
}
struct _SingleScalarCharacters<
  Scalars: ScalarClass
>: CharacterClass {
  var scalars: Scalars
  func contains(_ c: Character) -> Bool {
    let scs = c.unicodeScalars
    return scs.count == 1 && scalars.contains(scs.first!)
  }
  // NOTE: This would be equivalent to _ScalarToCharacter
  // for any scalar consumer that consumes only one scalar
  // at a time.
}
struct _AllScalarCharacters<
  Scalars: ScalarClass
>: CharacterClass {
  var scalars: Scalars
  func contains(_ c: Character) -> Bool {
    c.unicodeScalars.allSatisfy(scalars.contains)
  }
}


