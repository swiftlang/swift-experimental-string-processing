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

struct Delimiter: Hashable {
  let kind: Kind
  let poundCount: Int

  init(_ kind: Kind, poundCount: Int) {
    precondition(kind.allowsExtendedPoundSyntax || poundCount == 0)
    self.kind = kind
    self.poundCount = poundCount
  }

  var opening: String {
    String(repeating: "#", count: poundCount) + kind.opening
  }
  var closing: String {
    kind.closing + String(repeating: "#", count: poundCount)
  }

  /// Whether or not multi-line mode is permitted.
  var allowsMultiline: Bool {
    switch kind {
    case .forwardSlash:
      return poundCount > 0
    case .experimental, .reSingleQuote, .rxSingleQuote:
      return false
    }
  }

  /// The delimiters which are currently enabled.
  static var enabledDelimiters: [Kind] { [.forwardSlash] }

  /// All known delimiters.
  static var allDelimiters: [Kind] { Kind.allCases }
}

extension Delimiter {
  enum Kind: Hashable, CaseIterable {
    case forwardSlash
    case experimental
    case reSingleQuote
    case rxSingleQuote

    var openingAndClosing: (opening: String, closing: String) {
      switch self {
      case .forwardSlash: return ("/", "/")
      case .experimental: return ("#|", "|#")
      case .reSingleQuote: return ("re'", "'")
      case .rxSingleQuote: return ("rx'", "'")
      }
    }
    var opening: String { openingAndClosing.opening }
    var closing: String { openingAndClosing.closing }

    /// Whether or not extended pound syntax e.g `##/.../##` is allowed with
    /// this delimiter.
    var allowsExtendedPoundSyntax: Bool {
      switch self {
      case .forwardSlash:
        return true
      case .experimental, .reSingleQuote, .rxSingleQuote:
        return false
      }
    }
  }
}

struct DelimiterLexError: Error, CustomStringConvertible {
  enum Kind: Hashable {
    case unterminated
    case invalidUTF8 // TODO: better range reporting
    case unknownDelimiter
    case unprintableASCII
    case multilineClosingNotOnNewline
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
    case .unterminated: return "unterminated regex literal"
    case .invalidUTF8: return "invalid UTF-8 found in source file"
    case .unknownDelimiter: return "unknown regex literal delimiter"
    case .unprintableASCII: return "unprintable ASCII character found in source file"
    case .multilineClosingNotOnNewline: return "closing delimiter must appear on new line"
    }
  }
}

fileprivate struct DelimiterLexer {
  let start: UnsafeRawPointer
  var cursor: UnsafeRawPointer
  let end: UnsafeRawPointer

  var firstNewline: UnsafeRawPointer?
  var isMultiline: Bool { firstNewline != nil }

  let delimiters: [Delimiter.Kind]

  init(start: UnsafeRawPointer, end: UnsafeRawPointer,
       delimiters: [Delimiter.Kind]) {
    precondition(start <= end)
    self.start = start
    self.cursor = start
    self.end = end
    self.delimiters = delimiters
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

  /// Return the slice of `count` bytes preceding the current cursor, or `nil`
  /// if there are fewer than `count` bytes before the cursor.
  func sliceBehind(_ count: Int) -> UnsafeRawBufferPointer? {
    let priorCursor = cursor - count
    guard priorCursor >= start else { return nil }
    return slice(at: priorCursor, count)
  }

  /// Advance the cursor `n` bytes.
  mutating func advanceCursor(_ n: Int = 1) {
    cursor += n
    precondition(cursor <= end, "Cannot advance past end")
  }

  /// Check to see if a byte sequence can be eaten from the current cursor.
  func canEat<C : Collection>(_ bytes: C) -> Bool where C.Element == UInt8 {
    guard let slice = slice(bytes.count) else { return false }
    return slice.elementsEqual(bytes)
  }

  /// Attempt to eat a byte sequence, returning `true` if successful.
  mutating func tryEat<C : Collection>(
    _ bytes: C
  ) -> Bool where C.Element == UInt8 {
    guard canEat(bytes) else { return false }
    advanceCursor(bytes.count)
    return true
  }

  /// Attempt to eat an ascii scalar, returning `true` if successful.
  mutating func tryEat(ascii s: Unicode.Scalar) -> Bool {
    guard load() == ascii(s) else { return false }
    advanceCursor()
    return true
  }

  /// Attempt to skip over a closing delimiter character that is unlikely to be
  /// the actual closing delimiter.
  mutating func trySkipDelimiter(_ delimiter: Delimiter) {
    // Only the closing `'` for re'...'/rx'...' can potentially be skipped over.
    switch delimiter.kind {
    case .forwardSlash, .experimental:
      return
    case .reSingleQuote, .rxSingleQuote:
      break
    }
    guard load() == ascii("'") else { return }

    /// Need to look for a prefix of `(?`, `(?(`, `\k`, `\g`, `(?C`, as those
    /// are the cases that could use single quotes. Note that none of these
    /// would be valid regex endings anyway.
    let calloutPrefix = "(?C"
    let prefix = ["(?", "(?(", #"\k"#, #"\g"#, calloutPrefix].first { prior in
      guard let priorSlice = sliceBehind(prior.utf8.count),
            priorSlice.elementsEqual(prior.utf8)
      else { return false }

      // Make sure the slice isn't preceded by a '\', as that invalidates this
      // analysis.
      if let prior = sliceBehind(priorSlice.count + 1) {
        return prior[0] != ascii("\\")
      }
      return true
    }
    guard let prefix = prefix else { return }
    let isCallout = prefix == calloutPrefix

    func isPossiblyGroupReference(_ c: UInt8) -> Bool {
      // If this is an ASCII character, make sure it's for a group name. Leave
      // other UTF-8 encoded scalars alone, this should at least catch cases
      // where we run into a symbol such as `{`, `.`, `;` that would indicate
      // we've likely advanced out of the bounds of the regex.
      let scalar = UnicodeScalar(c)
      guard scalar.isASCII else { return true }
      switch scalar {
      // Include '-' and '+' which may be used in recursion levels and relative
      // references.
      case "A"..."Z", "a"..."z", "0"..."9", "_", "-", "+":
        return true
      default:
        return false
      }
    }

    // Make a note of the current lexing position, as we may need to revert
    // back to it.
    let originalCursor = cursor
    advanceCursor()

    // Try skip over what would be the contents of a group identifier/reference.
    while let next = load() {
      // Found the ending, we're done. Return so we can continue to lex to the
      // real delimiter.
      if next == ascii("'") {
        advanceCursor()
        return
      }

      // If this isn't a callout, make sure we have something that could be a
      // group reference. We limit the character set here to improve diagnostic
      // behavior in the case where the literal is actually unterminated. We
      // ideally don't want to go wandering off into Swift source code. We can't
      // do the same for callouts, as they take arbitrary strings.
      guard isCallout || isPossiblyGroupReference(next) else { break }
      do {
        try advance()
      } catch {
        break
      }
    }
    // We bailed out, either because we ran into something that didn't look like
    // an identifier, or we reached the end of the line. Revert back to the
    // original guess of delimiter.
    cursor = originalCursor
  }

  /// Attempt to eat a particular closing delimiter, returning the contents of
  /// the literal, and ending pointer, or `nil` if this is not a delimiter
  /// ending.
  mutating func tryEatEnding(
    _ delimiter: Delimiter, contentsStart: UnsafeRawPointer
  ) throws -> (contents: String, end: UnsafeRawPointer)? {
    let contentsEnd = cursor
    guard tryEat(delimiter.closing.utf8) else { return nil }

    let count = contentsEnd - contentsStart
    let contents = UnsafeRawBufferPointer(
      start: contentsStart, count: count)

    // In multi-line mode, we must be on a new line. So scan backwards and make
    // sure we only have whitespace until the newline.
    if isMultiline {
      let idx = contents.lastIndex(
        where: { $0 == ascii("\n") || $0 == ascii("\r") })! + 1
      guard contents[idx...].all({ $0 == ascii(" ") || $0 == ascii("\t") })
      else {
        throw DelimiterLexError(.multilineClosingNotOnNewline, resumeAt: cursor)
      }
    }

    // Form a string from the contents and make sure it's valid UTF-8.
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
      // We've hit the end of the buffer. In multi-line mode, we don't want to
      // skip over what is likely otherwise valid Swift code, so resume from the
      // first newline.
      throw DelimiterLexError(.unterminated, resumeAt: firstNewline ?? cursor)
    }
    switch UnicodeScalar(next) {
    case let next where !next.isASCII:
      // Just advance into a UTF-8 sequence. It shouldn't matter that we'll
      // iterate through each byte as we only match against ASCII, and we
      // validate it at the end. This case is separated out so we can just deal
      // with the ASCII cases below.
      advanceCursor()

    case "\n", "\r":
      guard isMultiline else {
        throw DelimiterLexError(.unterminated, resumeAt: cursor)
      }
      advanceCursor()

    case "\0":
      // TODO: Warn to match the behavior of String literal lexer? Or should
      // we error as unprintable?
      advanceCursor()

    case "\\" where !escaped:
      // Advance again for an escape sequence.
      advanceCursor()
      try advance(escaped: true)

    case let next
      where !next.isPrintableASCII && !(isMultiline && next == "\t"):
      // Diagnose unprintable ASCII.
      // Note that tabs are allowed in multi-line literals.
      // TODO: This matches the string literal behavior, but should we allow
      // tabs for single-line regex literals too?
      // TODO: Ideally we would recover and continue to lex until the ending
      // delimiter.
      throw DelimiterLexError(.unprintableASCII, resumeAt: cursor.successor())

    default:
      advanceCursor()
    }
  }

  mutating func tryLexOpeningDelimiter(poundCount: Int) -> Delimiter? {
    for kind in delimiters {
      // If the delimiter allows extended pound syntax, or there are no pounds,
      // we just need to lex it.
      let opening = kind.opening.utf8
      if kind.allowsExtendedPoundSyntax || poundCount == 0 {
        guard tryEat(opening) else { continue }
        return Delimiter(kind, poundCount: poundCount)
      }

      // The delimiter doesn't allow extended pound syntax, so the pounds must be
      // part of the delimiter.
      guard
        poundCount < opening.count,
        opening.prefix(poundCount)
          .elementsEqual(repeatElement(ascii("#"), count: poundCount)),
        tryEat(opening.dropFirst(poundCount))
      else { continue }

      return Delimiter(kind, poundCount: 0)
    }
    return nil
  }

  /*consuming*/ mutating func lex(
  ) throws -> (contents: String, Delimiter, end: UnsafeRawPointer) {
    // We can consume any number of pound signs.
    var poundCount = 0
    while tryEat(ascii: "#") {
      poundCount += 1
    }

    // Try to lex the opening delimiter.
    guard let delimiter = tryLexOpeningDelimiter(poundCount: poundCount) else {
      throw DelimiterLexError(.unknownDelimiter, resumeAt: cursor.successor())
    }
    let contentsStart = cursor

    // If the delimiter allows multi-line, try skipping over any whitespace to a
    // newline character. If we can do that, we enter multi-line mode.
    if delimiter.allowsMultiline {
      while let next = load() {
        switch next {
        case ascii(" "), ascii("\t"):
          advanceCursor()
          continue
        case ascii("\n"), ascii("\r"):
          firstNewline = cursor
        default:
          break
        }
        break
      }
    }
    while true {
      // Check to see if we're at a character that looks like a delimiter, but
      // likely isn't. In such a case, we can attempt to skip over it.
      trySkipDelimiter(delimiter)

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
  func stripDelimiter(_ kind: Delimiter.Kind) -> (String, Delimiter)? {
    var slice = str.utf8[...]

    // Try strip any number of opening '#'s.
    var poundCount = 0
    if kind.allowsExtendedPoundSyntax {
      poundCount = slice.prefix(while: {
        $0 == UInt8(("#" as UnicodeScalar).value)
      }).count
      slice = slice.dropFirst(poundCount)
    }

    // The opening delimiter must match.
    guard var slice = slice.tryDropPrefix(kind.opening.utf8)
    else { return nil }

    // The closing delimiter may optionally match, as it may not be present in
    // invalid code.
    let delim = Delimiter(kind, poundCount: poundCount)
    if let newSlice = slice.tryDropSuffix(delim.closing.utf8) {
      slice = newSlice
    }
    let result = String(decoding: slice, as: UTF8.self)
    precondition(result.utf8.elementsEqual(slice))
    return (result, delim)
  }
  for kind in Delimiter.allDelimiters {
    if let (contents, d) = stripDelimiter(kind) {
      return (contents, d)
    }
  }
  fatalError("No valid delimiters")
}

/// Attempt to lex a regex literal between `start` and `end`, returning either
/// the contents and pointer from which to resume lexing, or an error.
func lexRegex(
  start: UnsafeRawPointer, end: UnsafeRawPointer,
  delimiters: [Delimiter.Kind] = Delimiter.enabledDelimiters
) throws -> (contents: String, Delimiter, end: UnsafeRawPointer) {
  var lexer = DelimiterLexer(start: start, end: end, delimiters: delimiters)
  return try lexer.lex()
}
