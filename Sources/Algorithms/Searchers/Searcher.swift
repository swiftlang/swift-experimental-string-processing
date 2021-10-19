public protocol CollectionSearcher {
  associatedtype Searched: Collection
  associatedtype State = Searched.Index
  
  func state(startingAt index: Searched.Index, in searched: Searched) -> State
  func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>?
}

public protocol StatelessCollectionSearcher: CollectionSearcher
  where State == Searched.Index
{
  func search(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>?
}

extension StatelessCollectionSearcher {
  public func state(startingAt index: Searched.Index, in searched: Searched) -> State {
    index
  }
  
  public func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    let range = search(searched, from: state)
    state = range?.upperBound ?? searched.endIndex
    return range
  }
}

// MARK: Searching from the back

public protocol BackwardCollectionSearcher {
  associatedtype Searched: BidirectionalCollection
  associatedtype State = Searched.Index
  
  func backwardState(startingAt index: Searched.Index, in searched: Searched) -> State
  func searchBack(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>?
}

public protocol StatelessBackwardCollectionSearcher: BackwardCollectionSearcher
  where State == Searched.Index
{
  func searchBack(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>?
}

extension StatelessBackwardCollectionSearcher {
  public func backwardState(startingAt index: Searched.Index, in searched: Searched) -> State {
    index
  }
  
  public func searchBack(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    let range = searchBack(searched, from: state)
    state = range?.lowerBound ?? searched.startIndex
    return range
  }
}

// TODO: `BidirectionalCollectionSeacher`
