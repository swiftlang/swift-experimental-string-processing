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

/// An implementation of the Boyer-Moore-Horspool algorithm, for string-specific
/// searching.
struct SubstringSearcher: Sequence, IteratorProtocol {
  struct State {
    let badCharacterOffsets: [Character: Int]
    let patternCount: Int
    var endOfNextPotentialMatch: String.Index?
    
    /// The minimum pattern length for using bad character offsets 
    /// (aka Boyer-Moore) instead of just a simple naive search.
    static let patternCountMinimum = 4
    
    init(text: Substring? = nil, pattern: Substring) {
      let useBadCharacterOffsets =
        pattern.prefix(Self.patternCountMinimum).count == Self.patternCountMinimum
      
      if useBadCharacterOffsets {
        var offsets: [Character: Int] = [:]
        var count = 0
        for (offset, ch) in pattern.enumerated() {
          offsets[ch] = offset
          count += 1
        }
        
        self.badCharacterOffsets = offsets
        self.patternCount = count
      } else {
        self.badCharacterOffsets = [:]
        self.patternCount = pattern.count
      }
      
      if let text {
        self.endOfNextPotentialMatch = text.index(
          text.startIndex, offsetBy: patternCount, limitedBy: text.endIndex)
      }
    }
    
    var shouldUseNaiveSearch: Bool {
      badCharacterOffsets.isEmpty
    }
  }
  
  let text: Searched
  let pattern: Substring
  var state: State
  
  init(text: Searched, pattern: Substring) {
    self.text = text
    self.pattern = pattern
    self.state = .init(text: text[...], pattern: pattern)
  }

  /// Finds and returns the range of the next matching substring, along
  /// with the end index of the next possible match, using a naive approach.
  func nextRangeNaive(in text: Searched, searchFromEnd end: String.Index)
    -> (result: Range<String.Index>?, nextEnd: String.Index?)
  {
    precondition(state.patternCount > 0)
    let patternLastIndex = pattern.index(before: pattern.endIndex)
    var textLastIndex = text.index(before: end)
    
  FindLastCharacterMatch:
    while let potentialMatchEnd = text[textLastIndex...].firstIndex(of: pattern[patternLastIndex]) {
      var textCursor = potentialMatchEnd
      var patternCursor = patternLastIndex
      
      precondition(textCursor >= text.startIndex)
      while patternCursor > pattern.startIndex {
        pattern.formIndex(before: &patternCursor)
        text.formIndex(before: &textCursor)
        
        guard pattern[patternCursor] == text[textCursor] else {
          textLastIndex = text.index(after: potentialMatchEnd)
          continue FindLastCharacterMatch
        }
      }
      
      // It's a match!
      let currentEnd = text.index(after: potentialMatchEnd)
      return (
        textCursor..<currentEnd, 
        text.index(currentEnd, offsetBy: state.patternCount, limitedBy: text.endIndex))
    }
    
    return (nil, nil)
  }

  /// Finds and returns the range of the next matching substring, along
  /// with the end index of the next possible match.
  func nextRange(in text: Searched, searchFromEnd end: String.Index)
    -> (result: Range<String.Index>?, nextEnd: String.Index?)
  {  
    // Empty pattern matches at every position.
    if state.patternCount == 0 {
      return (
        end..<end,
        end == text.endIndex ? nil : text.index(after: end))
    }

    // We fall back to the naive search if `pattern` is small.
    if state.shouldUseNaiveSearch {
      return nextRangeNaive(in: text, searchFromEnd: end)
    }
    
    var currentEnd = end
    while true {
      // Search backwards from `currentEnd` to the start of the pattern
      var textCursor = text.index(before: currentEnd)
      var patternOffset = state.patternCount - 1
      var patternCursor = pattern.index(before: pattern.endIndex)

      while patternCursor >= pattern.startIndex
              && pattern[patternCursor] == text[textCursor]
      {
        patternOffset -= 1
        
        // Success!
        if patternCursor == pattern.startIndex {
          // Calculate the offset for the next search.
          return (
            textCursor..<currentEnd,
            text.index(currentEnd, offsetBy: state.patternCount, limitedBy: text.endIndex))
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
        patternOffset - (state.badCharacterOffsets[text[textCursor]] ?? 0))
      if let nextEnd = text.index(
        currentEnd, offsetBy: shiftOffset, limitedBy: text.endIndex) {
        currentEnd = nextEnd
      } else {
        return (nil, nil)
      }
    }
  }
  
  mutating func next() -> Range<String.Index>? {
    guard let end = state.endOfNextPotentialMatch else { return nil }
    let (result, nextEnd) = nextRange(in: text, searchFromEnd: end)
    state.endOfNextPotentialMatch = nextEnd
    return result
  }
}

extension SubstringSearcher: CollectionSearcher {
  typealias Searched = Substring
  
  func state(for text: Searched, in range: Range<String.Index>) -> State {
    State(text: text[range], pattern: pattern)
  }
  
  func search(_ text: Searched, _ state: inout State) -> Range<String.Index>? {
    guard let end = state.endOfNextPotentialMatch else { return nil }
    let (result, nextEnd) = nextRange(in: text, searchFromEnd: end)
    state.endOfNextPotentialMatch = nextEnd
    return result
  }
}
