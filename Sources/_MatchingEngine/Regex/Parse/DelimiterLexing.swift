//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// TODO: mock up multi-line soon

enum Delimiter: Hashable, CaseIterable {
  case traditional
  case experimental
  case reSingleQuote

  var openingAndClosing: (opening: String, closing: String) {
    switch self {
    case .traditional: return ("#/", "/#")
    case .experimental: return ("#|", "|#")
    case .reSingleQuote: return ("re'", "'")
    }
  }
  var opening: String { openingAndClosing.opening }
  var closing: String { openingAndClosing.closing }

  /// The default set of syntax options that the delimiter indicates.
  var defaultSyntaxOptions: SyntaxOptions {
    switch self {
    case .traditional, .reSingleQuote:
      return .traditional
    case .experimental:
      return .experimental
    }
  }
}

struct LexError: Error, CustomStringConvertible {
  enum Kind: Hashable {
    case endOfString
    case invalidUTF8 // TODO: better range reporting
    case unknownDelimiter
  }

  var kind: Kind

  /// The pointer at which to resume lexing.
  var resumePtr: UnsafeRawPointer

  init(_ kind: Kind, resumeAt resumePtr: UnsafeRawPointer) {
    self.kind = kind
    self.resumePtr = resumePtr
  }

  var description: String {
    switch kind {
    case .endOfString: return "unterminated regex literal"
    case .invalidUTF8: return "invalid UTF-8 found in source file"
    case .unknownDelimiter: return "unknown regex literal delimiter"
    }
  }
}

/// Attempt to lex a regex literal between `start` and `end`, returning either
/// the contents and pointer from which to resume lexing, or an error.
func lexRegex(
  start: UnsafeRawPointer, end: UnsafeRawPointer
) throws -> (contents: String, Delimiter, end: UnsafeRawPointer) {
  precondition(start <= end)
  var current = start

  func ascii(_ s: Unicode.Scalar) -> UInt8 {
    assert(s.value <= 0x7F)
    return UInt8(asserting: s.value)
  }
  func load(offset: Int) -> UInt8? {
    guard current + offset < end else { return nil }
    return current.load(fromByteOffset: offset, as: UInt8.self)
  }
  func load() -> UInt8? { load(offset: 0) }
  func advance(_ n: Int = 1) {
    precondition(current + n <= end, "Cannot advance past end")
    current = current.advanced(by: n)
  }

  func tryEat(_ utf8: String.UTF8View) -> Bool {
    for (i, idx) in utf8.indices.enumerated() {
      guard load(offset: i) == utf8[idx] else { return false }
    }
    advance(utf8.count)
    return true
  }

  // Try to lex the opening delimiter.
  guard let delimiter = Delimiter.allCases.first(
    where: { tryEat($0.opening.utf8) }
  ) else {
    throw LexError(.unknownDelimiter, resumeAt: current.successor())
  }

  let contentsStart = current
  while true {
    switch load() {
    case nil, ascii("\n"), ascii("\r"):
      throw LexError(.endOfString, resumeAt: current)

    case ascii("\\"):
      // Skip next byte.
      advance(2)

    default:
      // Try to lex the closing delimiter.
      let contentsEnd = current
      guard tryEat(delimiter.closing.utf8) else {
        advance()
        continue
      }

      // Form a string from the contents and make sure it's valid UTF-8.
      let count = contentsEnd - contentsStart
      let contents = UnsafeRawBufferPointer(
        start: contentsStart, count: count)
      let s = String(decoding: contents, as: UTF8.self)

      guard s.utf8.elementsEqual(contents) else {
        throw LexError(.invalidUTF8, resumeAt: current)
      }
      return (contents: s, delimiter, end: current)
    }
  }
}

/// Drop a set of regex delimiters from the input string, returning the contents
/// and the delimiter used. The input string must have valid delimiters.
func droppingRegexDelimiters(_ str: String) -> (String, Delimiter) {
  let utf8 = str.utf8
  func stripDelimiter(_ delim: Delimiter) -> String? {
    let prefix = delim.opening.utf8
    let suffix = delim.closing.utf8
    guard utf8.prefix(prefix.count).elementsEqual(prefix),
          utf8.suffix(suffix.count).elementsEqual(suffix) else { return nil }

    return String(utf8.dropFirst(prefix.count).dropLast(suffix.count))
  }
  for d in Delimiter.allCases {
    if let contents = stripDelimiter(d) {
      return (contents, d)
    }
  }
  fatalError("No valid delimiters")
}
