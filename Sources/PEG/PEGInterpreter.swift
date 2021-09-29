import XCTest
extension PEG {
  struct Grammar {
    var environment: Dictionary<String, Pattern>
    var start: Pattern
  }

  struct Interpreter<C: Collection> where C.Element == Element {
    var grammar: Grammar

    func consume(_ c: C, from: C.Index) -> C.Index? {
      fatalError()
    }

    func consume(_ c: C) -> C.Index? {
      consume(c, from: c.startIndex)
    }

    func find(_ c: C) -> Range<C.Index>? {
      // TODO: more efficient to have native support
      var idx = c.startIndex
      while idx != c.endIndex {
        if let endIdx = consume(c, from: idx) {
          return idx ..< endIdx
        }
        c.formIndex(after: &idx)
      }
      return nil
    }
  }
}

extension PEG.Program {
  func consume<C: Collection>(
    _ c: C
  ) -> C.Index? where C.Element == Element {
    _consume(c, from: c.startIndex, environment[start]!, environment)
  }
}

func _consume<C: Collection>(
  _ c: C,
  from idx: C.Index,
  _ pattern: PEG<C.Element>.Pattern,
  _ environment: PEG<C.Element>.Environment
) -> C.Index? {
  var captures = Array<Range<C.Index>>()
  return _consume(c, from: idx, pattern, environment, &captures)
}

func _consume<C: Collection>(
  _ c: C,
  from idx: C.Index,
  _ pattern: PEG<C.Element>.Pattern,
  _ environment: PEG<C.Element>.Environment,
  _ captures: inout Array<Range<C.Index>>
) -> C.Index? {
  typealias Pattern = PEG<C.Element>.Pattern

  var idx = idx

  func consume(_ p: Pattern, from idx: C.Index) -> C.Index? {
    _consume(c, from: idx, p, environment, &captures)
  }

  func consumeIf(_ p: (C.Element) -> Bool) -> C.Index? {
    guard idx < c.endIndex, p(c[idx]) else { return nil }
    return c.index(after: idx)
  }

  func consumePrefix<Prefix: Sequence>(
    _ p: Prefix
  ) -> C.Index? where Prefix.Element == C.Element {
    var idx = idx
    for e in p {
      guard idx < c.endIndex, e == c[idx] else { return nil }
      c.formIndex(after: &idx)
    }
    return idx
  }

  func consumeMany(_ p: Pattern, atLeast: Int) -> C.Index? {
    var counter = 0
    var idx = idx
    while let nextIdx = consume(p, from: idx) {
      counter += 1
      idx = nextIdx
    }
    guard counter >= atLeast else { return nil }
    return idx
  }

  func peek(_ p: Pattern) -> Bool {
    nil != consume(p, from: idx)
  }

  switch pattern {
  // Terminals
  case .success: return idx
  case .failure: return nil

  case .end: return idx == c.endIndex ? idx : nil

  // Consume a single unit of input
  case .any: return consumeIf { _ in true }
  case .element(let e): return consumeIf { e == $0 }
  case .charactetSet(let p): return consumeIf(p)

  // Consume many inputs
  case .literal(let lit): return consumePrefix(lit)

  case .repeat(let e, atLeast: let atLeast):
    return consumeMany(e, atLeast: atLeast)

  case .repeatRange(_, atLeast: _, atMost: _):
    fatalError()

  // Assertions (does not consume)
  case .and(let p):
    return peek(p) ? idx : nil
  case .not(let p):
    return peek(p) ? nil : idx

  // Combinations of patterns
  case .orderedChoice(let p1, let p2):
    return consume(p1, from: idx) ?? consume(p2, from: idx)

  case .concat(let ps):
    for p in ps {
      guard let resume = consume(p, from: idx) else {
        return nil
      }
      idx = resume
    }
    return idx

  case .difference(let p1, let p2):
    guard !peek(p2) else { return nil }
    return consume(p1, from: idx)

  case .variable(let name):
    return consume(environment[name]!, from: idx)

  case .capture(let p):
    // TODO: Are captured pre-order or post-order?
    guard let endIdx = consume(p, from: idx) else { return nil }
    captures.append(idx ..< endIdx)
    return endIdx
  }
}


// Match some subsequence within the collection
func _find<C: Collection>(
  _ c: C,
  from idx: C.Index,
  _ pattern: PEG<C.Element>.Pattern,
  _ environment: PEG<C.Element>.Environment,
  _ captures: inout Array<Range<C.Index>>
) -> Range<C.Index>? {
  // TODO: more efficient to have native support
  var idx = c.startIndex
  while idx != c.endIndex {
    if let endIdx = _consume(c, from: idx, pattern, environment, &captures) {
      return idx ..< endIdx
    }
    c.formIndex(after: &idx)
  }
  return nil
}

// Convenience: gather up the result of repeated consumption
func _gather<C: Collection>(
  _ c: C,
  _ pattern: PEG<C.Element>.Pattern,
  _ environment: PEG<C.Element>.Environment
) -> [C.SubSequence] {
  var idx = c.startIndex
  var result = Array<C.SubSequence>()
  while let end = _consume(c, from: idx, pattern, environment) {
    result.append(c[idx ..< end])
    idx = end
  }
  return result
}
