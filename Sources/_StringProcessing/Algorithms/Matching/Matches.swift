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

// MARK: Regex algorithms

@available(SwiftStdlib 5.7, *)
struct RegexMatchesSequence<Output> {
  let input: String
  let subjectBounds: Range<String.Index>
  let searchBounds: Range<String.Index>
  let regex: Regex<Output>

  init(
    input: String,
    subjectBounds: Range<String.Index>,
    searchBounds: Range<String.Index>,
    regex: Regex<Output>
  ) {
    self.input = input
    self.subjectBounds = subjectBounds
    self.searchBounds = searchBounds
    self.regex = regex
  }
}

@available(SwiftStdlib 5.7, *)
extension RegexMatchesSequence: Sequence {
  /// Returns the index to start searching for the next match after `match`.
  fileprivate func searchIndex(after match: Regex<Output>.Match) -> String.Index? {
    if !match.range.isEmpty {
      return match.range.upperBound
    }
    
    // If the last match was an empty match, advance by one position and
    // run again, unless at the end of `input`.
    guard match.range.lowerBound < subjectBounds.upperBound else {
      return nil
    }
    
    switch regex.initialOptions.semanticLevel {
    case .graphemeCluster:
      return input.index(after: match.range.upperBound)
    case .unicodeScalar:
      return input.unicodeScalars.index(after: match.range.upperBound)
    }
  }

  struct Iterator: IteratorProtocol {
    let base: RegexMatchesSequence

    // Set to nil when iteration is finished (because some regex can empty-match
    // at the end of the subject).
    var currentPosition: String.Index?

    init(_ matches: RegexMatchesSequence) {
      self.base = matches
      self.currentPosition = base.subjectBounds.lowerBound
    }
    
    mutating func next() -> Regex<Output>.Match? {
      // `currentPosition` is `nil` when iteration has completed
      guard let position = currentPosition, position <= base.searchBounds.upperBound else {
        return nil
      }

      // Otherwise, find the next match (if any) and compute `nextStart`
      let match = try? Executor<Output>.firstMatch(
        base.regex.program.loweredProgram,
        base.input,
        subjectBounds: base.subjectBounds, 
        searchBounds: position..<base.searchBounds.upperBound)
      currentPosition = match.flatMap(base.searchIndex(after:))
      return match
    }
  }
  
  func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension BidirectionalCollection where SubSequence == Substring {
  @available(SwiftStdlib 5.7, *)
  @_disfavoredOverload
  func _matches<R: RegexComponent>(
    of regex: R
  ) -> RegexMatchesSequence<R.RegexOutput> {
    RegexMatchesSequence(
      input: self[...].base,
      subjectBounds: startIndex..<endIndex,
      searchBounds: startIndex..<endIndex,
      regex: regex.regex)
  }

  // FIXME: Return `some Collection<Regex<R.Output>.Match> for SE-0346
  /// Returns a collection containing all matches of the specified regex.
  /// - Parameter regex: The regex to search for.
  /// - Returns: A collection of matches of `regex`.
  @available(SwiftStdlib 5.7, *)
  public func matches<Output>(
    of r: some RegexComponent<Output>
  ) -> [Regex<Output>.Match] {
    // FIXME: Array init calls count, which double-executes the regex :-(
    // FIXME: just return some Collection<Regex<Output>.Match>
    var result = Array<Regex<Output>.Match>()

    

    for match in _matches(of: r) {
      result.append(match)
    }
    return result
  }
}
