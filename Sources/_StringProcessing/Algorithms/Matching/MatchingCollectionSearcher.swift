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

protocol MatchingCollectionSearcher: CollectionSearcher {
  associatedtype Match
  func matchingSearch(
    _ searched: Searched,
    _ state: inout State
  ) -> (range: Range<Searched.Index>, match: Match)?
}

extension MatchingCollectionSearcher {
  func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, &state)?.range
  }
}

protocol MatchingStatelessCollectionSearcher:
  MatchingCollectionSearcher, StatelessCollectionSearcher
{
  func matchingSearch(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> (range: Range<Searched.Index>, match: Match)?
}

extension MatchingStatelessCollectionSearcher {
  // for disambiguation between the `MatchingCollectionSearcher` and
  // `StatelessCollectionSearcher` overloads
  func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, &state)?.range
  }
  
  func matchingSearch(
    _ searched: Searched,
    _ state: inout State
  ) -> (range: Range<Searched.Index>, match: Match)? {
    // TODO: deduplicate this logic with `StatelessCollectionSearcher`?
    
    guard
      case .index(let index) = state.position,
      let (range, value) = matchingSearch(searched, in: index..<state.end)
    else { return nil }
    
    if range.isEmpty {
      if range.upperBound == searched.endIndex {
        state.position = .done
      } else {
        state.position = .index(searched.index(after: range.upperBound))
      }
    } else {
      state.position = .index(range.upperBound)
    }
    
    return (range, value)
  }
  
  func search(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, in: range)?.range
  }
}

// MARK: Searching from the back

protocol BackwardMatchingCollectionSearcher: BackwardCollectionSearcher {
  associatedtype Match
  func matchingSearchBack(
    _ searched: BackwardSearched,
    _ state: inout BackwardState
  ) -> (range: Range<BackwardSearched.Index>, match: Match)?
}

protocol BackwardMatchingStatelessCollectionSearcher:
  BackwardMatchingCollectionSearcher, BackwardStatelessCollectionSearcher
{
  func matchingSearchBack(
    _ searched: BackwardSearched,
    in range: Range<BackwardSearched.Index>
  ) -> (range: Range<BackwardSearched.Index>, match: Match)?
}

extension BackwardMatchingStatelessCollectionSearcher {
  func searchBack(
    _ searched: BackwardSearched,
    in range: Range<BackwardSearched.Index>
  ) -> Range<BackwardSearched.Index>? {
    matchingSearchBack(searched, in: range)?.range
  }
  
  func matchingSearchBack(
    _ searched: BackwardSearched,
    _ state: inout BackwardState) -> (range: Range<BackwardSearched.Index>, match: Match)?
  {
    // TODO: deduplicate this logic with `StatelessBackwardCollectionSearcher`?
    
    guard
      case .index(let index) = state.position,
      let (range, value) = matchingSearchBack(searched, in: state.end..<index)
    else { return nil }
    
    
    if range.isEmpty {
      if range.lowerBound == searched.startIndex {
        state.position = .done
      } else {
        state.position = .index(searched.index(before: range.lowerBound))
      }
    } else {
      state.position = .index(range.lowerBound)
    }
    
    return (range, value)
  }
}
