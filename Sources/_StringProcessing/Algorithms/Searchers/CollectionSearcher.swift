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

struct DefaultSearcherState<Searched: Collection> {
  enum Position {
    case index(Searched.Index)
    case done
  }
  
  var position: Position
  let end: Searched.Index
}

protocol CollectionSearcher {
  associatedtype Searched: Collection
  associatedtype State
  
  func state(for searched: Searched, in range: Range<Searched.Index>) -> State
  func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>?
}

protocol StatelessCollectionSearcher: CollectionSearcher
  where State == DefaultSearcherState<Searched>
{
  func search(
    _ searched: Searched,
    in range: Range<Searched.Index>) -> Range<Searched.Index>?
}

extension StatelessCollectionSearcher {
  func state(
    for searched: Searched,
    in range: Range<Searched.Index>
  ) -> State {
    State(position: .index(range.lowerBound), end: range.upperBound)
  }
  
  func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    guard
      case .index(let index) = state.position,
      let range = search(searched, in: index..<state.end)
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
    
    return range
  }
}

