public struct DefaultSearcherState<Searched: Collection> {
  enum Position {
    case index(Searched.Index)
    case done
  }
  
  var position: Position
  let end: Searched.Index
}

public protocol CollectionSearcher {
  associatedtype Searched: Collection
  associatedtype State
  
  func state(for searched: Searched, in range: Range<Searched.Index>) -> State
  func search(
    _ searched: Searched,
    _ state: inout State
  ) -> Range<Searched.Index>?
}

public protocol StatelessCollectionSearcher: CollectionSearcher
  where State == DefaultSearcherState<Searched>
{
  func search(
    _ searched: Searched,
    in range: Range<Searched.Index>) -> Range<Searched.Index>?
}

extension StatelessCollectionSearcher {
  public func state(
    for searched: Searched,
    in range: Range<Searched.Index>
  ) -> State {
    State(position: .index(range.lowerBound), end: range.upperBound)
  }
  
  public func search(
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

// MARK: Searching from the back

public protocol BackwardCollectionSearcher {
  associatedtype BackwardSearched: BidirectionalCollection
  associatedtype BackwardState
  
  func backwardState(
    for searched: BackwardSearched,
    in range: Range<BackwardSearched.Index>) -> BackwardState
  func searchBack(
    _ searched: BackwardSearched,
    _ state: inout BackwardState
  ) -> Range<BackwardSearched.Index>?
}

public protocol StatelessBackwardCollectionSearcher: BackwardCollectionSearcher
  where BackwardState == DefaultSearcherState<BackwardSearched>
{
  func searchBack(
    _ searched: BackwardSearched,
    in range: Range<BackwardSearched.Index>
  ) -> Range<BackwardSearched.Index>?
}

extension StatelessBackwardCollectionSearcher {
  public func backwardState(
    for searched: BackwardSearched,
    in range: Range<BackwardSearched.Index>
  ) -> BackwardState {
    BackwardState(position: .index(range.upperBound), end: range.lowerBound)
  }
  
  public func searchBack(
    _ searched: BackwardSearched,
    _ state: inout BackwardState) -> Range<BackwardSearched.Index>? {
    guard
      case .index(let index) = state.position,
      let range = searchBack(searched, in: state.end..<index)
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
    
    return range
  }
}

public protocol BidirectionalCollectionSearcher: CollectionSearcher,
                                                 BackwardCollectionSearcher
  where Searched == BackwardSearched {}
