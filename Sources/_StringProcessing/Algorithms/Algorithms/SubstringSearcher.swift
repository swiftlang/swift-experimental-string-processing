//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// An implementation of the Boyer-Moore algorithm, for string-specific
/// searching.
@usableFromInline
struct SubstringSearcher: Sequence, IteratorProtocol {
  @usableFromInline
  let text: Substring
  @usableFromInline
  let pattern: Substring
  @usableFromInline
  let badCharacterOffsets: [Character: Int]
  @usableFromInline
  let patternCount: Int
  @usableFromInline
  var endOfSearch: String.Index?
  
  @usableFromInline
  init(text: Substring, pattern: Substring) {
    self.text = text
    self.pattern = pattern
    self.patternCount = pattern.count
    self.endOfSearch = text.index(
      text.startIndex, offsetBy: patternCount, limitedBy: text.endIndex)
    self.badCharacterOffsets = Dictionary(
      zip(pattern, 0...), uniquingKeysWith: { _, last in last })
  }

  @inlinable
  mutating func next() -> Range<String.Index>? {
    while let end = endOfSearch {
      // Empty pattern matches at every position.
      if patternCount == 0 {
        endOfSearch = end == text.endIndex ? nil : text.index(after: end)
        return end..<end
      }
      
      var patternOffset = patternCount - 1
      var patternCursor = pattern.index(before: pattern.endIndex)
      var textCursor = text.index(before: end)
      
      // Search backwards from `end` to the start of the pattern
      while patternCursor >= pattern.startIndex
              && pattern[patternCursor] == text[textCursor]
      {
        patternOffset -= 1
        
        // Success!
        if patternCursor == pattern.startIndex {
          // Calculate the offset for the next search.
          endOfSearch = text.index(end, offsetBy: patternCount, limitedBy: text.endIndex)
          return textCursor..<end
        }
        
        precondition(textCursor > text.startIndex)
        text.formIndex(before: &textCursor)
        pattern.formIndex(before: &patternCursor)
      }
      
      // Match failed - calculate the end index of the next possible
      // candidate, based on the `badCharacterOffsets` table and the
      // current position in the pattern.
      let shiftOffset = Swift.max(
        1,
        patternOffset - (badCharacterOffsets[text[textCursor]] ?? 0))
      endOfSearch = text.index(
        end, offsetBy: shiftOffset, limitedBy: text.endIndex)
    }
    return nil
  }
}

