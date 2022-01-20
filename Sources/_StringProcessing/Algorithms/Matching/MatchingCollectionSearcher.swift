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

public protocol MatchingCollectionSearcher: CollectionSearcher {
  associatedtype Match
  func matchingSearch(
    _ searched: Searched,
    _ state: inout State
  ) -> (Match, Range<Searched.Index>)?
}

extension MatchingCollectionSearcher {
  public func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, &state)?.1
  }
}

public protocol MatchingStatelessCollectionSearcher:
  MatchingCollectionSearcher, StatelessCollectionSearcher
{
  func matchingSearch(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> (Match, Range<Searched.Index>)?
}

extension MatchingStatelessCollectionSearcher {
  // for disambiguation
  public func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, &state)?.1
  }
  
  public func matchingSearch(
    _ searched: Searched,
    _ state: inout State
  ) -> (Match, Range<Searched.Index>)? {
    // TODO: deduplicate this logic with `StatelessCollectionSearcher`?
    
    guard
      case .index(let index) = state.position,
      let (value, range) = matchingSearch(searched, in: index..<state.end)
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
    
    return (value, range)
  }
  
  public func search(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    matchingSearch(searched, in: range)?.1
  }
}

// MARK: Searching from the back

public protocol BackwardMatchingCollectionSearcher: BackwardCollectionSearcher {
  associatedtype Match
  func matchingSearchBack(
    _ searched: BackwardSearched,
    _ state: inout BackwardState
  ) -> (Match, Range<BackwardSearched.Index>)?
}

public protocol BackwardMatchingStatelessCollectionSearcher:
  BackwardMatchingCollectionSearcher, BackwardStatelessCollectionSearcher
{
  func matchingSearchBack(
    _ searched: BackwardSearched,
    in range: Range<BackwardSearched.Index>
  ) -> (Match, Range<BackwardSearched.Index>)?
}

extension BackwardMatchingStatelessCollectionSearcher {
  public func matchingSearchBack(
    _ searched: BackwardSearched,
    _ state: inout BackwardState) -> (Match, Range<BackwardSearched.Index>)?
  {
    // TODO: deduplicate this logic with `StatelessBackwardCollectionSearcher`?
    
    guard
      case .index(let index) = state.position,
      let (value, range) = matchingSearchBack(searched, in: state.end..<index)
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
    
    return (value, range)
  }
}
