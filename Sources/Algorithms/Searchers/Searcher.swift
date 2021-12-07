import _MatchingEngine

public struct DefaultState<Searched: Collection> {
  enum _State {
    case index(Searched.Index)
    case done
  }
  
  let state: _State
}

public protocol CollectionSearcher {
  associatedtype Searched: Collection where Searched.SubSequence == Searched
  
  // NOTE: Removing the default value causes a lot of associated type inference breakage
  associatedtype State = DefaultState<Searched>
  
  func state(startingAt index: Searched.Index, in searched: Searched) -> State
  func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>?
}

public protocol StatelessCollectionSearcher: CollectionSearcher
  where State == DefaultState<Searched>
{
  func search(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>?
}

extension StatelessCollectionSearcher {
  public func state(startingAt index: Searched.Index, in searched: Searched) -> State {
    DefaultState(state: .index(index))
  }
  
  public func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    guard
      case .index(let index) = state.state,
      let range = search(searched, from: index)
    else { return nil }
    
    
    if range.isEmpty {
      if range.upperBound == searched.endIndex {
        state = State(state: .done)
      } else {
        state = State(state: .index(searched.index(after: range.upperBound)))
      }
    } else {
      state = State(state: .index(range.upperBound))
    }
    
    return range
  }
}

// MARK: Searching from the back

// TODO: Inherit from `CollectionSearcher`? `State` might not match
public protocol BackwardCollectionSearcher {
  associatedtype Searched: BidirectionalCollection
  associatedtype State = Searched.Index
  
  func backwardState(startingAt index: Searched.Index, in searched: Searched) -> State
  func searchBack(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>?
}

public protocol StatelessBackwardCollectionSearcher: BackwardCollectionSearcher
  where State == DefaultState<Searched>
{
  func searchBack(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>?
}

extension StatelessBackwardCollectionSearcher {
  public func backwardState(startingAt index: Searched.Index, in searched: Searched) -> State {
    DefaultState(state: .index(index))
  }
  
  public func searchBack(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    guard
      case .index(let index) = state.state,
      let range = searchBack(searched, from: index)
    else { return nil }
    
    
    if range.isEmpty {
      if range.lowerBound == searched.startIndex {
        state = State(state: .done)
      } else {
        state = State(state: .index(searched.index(before: range.lowerBound)))
      }
    } else {
      state = State(state: .index(range.lowerBound))
    }
    
    return range
  }
}

// TODO: `BidirectionalCollectionSeacher`
