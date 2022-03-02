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

struct DelimiterLexError: Error, CustomStringConvertible {
  enum Kind: Hashable {
    case endOfString
    case invalidUTF8 // TODO: better range reporting
    case unknownDelimiter
    case unprintableASCII
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
    case .unprintableASCII: return "unprintable ASCII character found in source file"
    }
  }
}

fileprivate struct DelimiterLexer {
  let start: UnsafeRawPointer
  var cursor: UnsafeRawPointer
  let end: UnsafeRawPointer

  init(start: UnsafeRawPointer, end: UnsafeRawPointer) {
    precondition(start <= end)
    self.start = start
    self.cursor = start
    self.end = end
  }

  func ascii(_ s: Unicode.Scalar) -> UInt8 {
    assert(s.value <= 0x7F)
    return UInt8(asserting: s.value)
  }

  /// Return the byte at the current cursor, or `nil` if the end of the buffer
  /// has been reached.
  func load() -> UInt8? {
    guard cursor < end else { return nil }
    return cursor.load(as: UInt8.self)
  }

  /// Return the slice of `count` bytes from a specified cursor position, or
  /// `nil` if there are fewer than `count` bytes until the end of the buffer.
  func slice(
    at cursor: UnsafeRawPointer, _ count: Int
  ) -> UnsafeRawBufferPointer? {
    guard cursor + count <= end else { return nil }
    return UnsafeRawBufferPointer(start: cursor, count: count)
  }

  /// Return the slice of `count` bytes from the current cursor, or `nil` if
  /// there are fewer than `count` bytes until the end of the buffer.
  func slice(_ count: Int) -> UnsafeRawBufferPointer? {
    slice(at: cursor, count)
  }

  /// Advance the cursor `n` bytes.
  mutating func advanceCursor(_ n: Int = 1) {
    cursor += n
    precondition(cursor <= end, "Cannot advance past end")
  }

  /// Check to see if a UTF-8 sequence can be eaten from the current cursor.
  func canEat(_ utf8: String.UTF8View) -> Bool {
    guard let slice = slice(utf8.count) else { return false }
    return slice.elementsEqual(utf8)
  }

  /// Attempt to eat a UTF-8 byte sequence, returning `true` if successful.
  mutating func tryEat(_ utf8: String.UTF8View) -> Bool {
    guard canEat(utf8) else { return false }
    advanceCursor(utf8.count)
    return true
  }

  /// Attempt to eat a particular closing delimiter, returning the contents of
  /// the literal, and ending pointer, or `nil` if this is not a delimiter
  /// ending.
  mutating func tryEatEnding(
    _ delimiter: Delimiter, contentsStart: UnsafeRawPointer
  ) throws -> (contents: String, end: UnsafeRawPointer)? {
    let contentsEnd = cursor
    guard tryEat(delimiter.closing.utf8) else { return nil }

    // Form a string from the contents and make sure it's valid UTF-8.
    let count = contentsEnd - contentsStart
    let contents = UnsafeRawBufferPointer(
      start: contentsStart, count: count)
    let s = String(decoding: contents, as: UTF8.self)

    guard s.utf8.elementsEqual(contents) else {
      throw DelimiterLexError(.invalidUTF8, resumeAt: cursor)
    }
    return (contents: s, end: cursor)
  }

  /// Attempt to advance the lexer, throwing an error if the end of a line or
  /// the end of the buffer is reached.
  mutating func advance(escaped: Bool = false) throws {
    guard let next = load() else {
      throw DelimiterLexError(.endOfString, resumeAt: cursor)
    }
    switch UnicodeScalar(next) {
    case let next where !next.isASCII:
      // Just advance into a UTF-8 sequence. It shouldn't matter that we'll
      // iterate through each byte as we only match against ASCII, and we
      // validate it at the end. This case is separated out so we can just deal
      // with the ASCII cases below.
      advanceCursor()

    case "\n", "\r":
      throw DelimiterLexError(.endOfString, resumeAt: cursor)

    case "\0":
      // TODO: Warn to match the behavior of String literal lexer? Or should
      // we error as unprintable?
      advanceCursor()

    case "\\" where !escaped:
      // Advance again for an escape sequence.
      advanceCursor()
      try advance(escaped: true)

    case let next where !next.isPrintableASCII:
      // Diagnose unprintable ASCII.
      // TODO: Ideally we would recover and continue to lex until the ending
      // delimiter.
      throw DelimiterLexError(.unprintableASCII, resumeAt: cursor.successor())

    default:
      advanceCursor()
    }
  }

  /*consuming*/ mutating func lex(
  ) throws -> (contents: String, Delimiter, end: UnsafeRawPointer) {

    // Try to lex the opening delimiter.
    guard let delimiter = Delimiter.allCases.first(
      where: { tryEat($0.opening.utf8) }
    ) else {
      throw DelimiterLexError(.unknownDelimiter, resumeAt: cursor.successor())
    }

    let contentsStart = cursor
    while true {
      // Try to lex the closing delimiter.
      if let (contents, end) = try tryEatEnding(delimiter,
                                                contentsStart: contentsStart) {
        return (contents, delimiter, end)
      }
      // Try to advance the lexer.
      try advance()
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

/// Attempt to lex a regex literal between `start` and `end`, returning either
/// the contents and pointer from which to resume lexing, or an error.
func lexRegex(
  start: UnsafeRawPointer, end: UnsafeRawPointer
) throws -> (contents: String, Delimiter, end: UnsafeRawPointer) {
  var lexer = DelimiterLexer(start: start, end: end)
  return try lexer.lex()
}
