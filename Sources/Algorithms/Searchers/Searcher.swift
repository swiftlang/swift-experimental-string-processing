public protocol CollectionSearcher {
  associatedtype Searched: Collection
  associatedtype State = ()
  func initialState(_ searched: Searched) -> State
  func search(
    _ searched: Searched,
    subrange: Range<Searched.Index>,
    _ state: inout State
  ) -> Range<Searched.Index>?
}

extension CollectionSearcher {
  public func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    search(searched, subrange: searched.startIndex..<searched.endIndex, &state)
  }
}

public protocol StatelessCollectionSearcher: CollectionSearcher where State == () {
  func search(_ searched: Searched, subrange: Range<Searched.Index>) -> Range<Searched.Index>?
}

extension StatelessCollectionSearcher {
  public func search(
    _ searched: Searched,
    subrange: Range<Searched.Index>,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    search(searched, subrange: subrange)
  }
  
  public func search(_ searched: Searched) -> Range<Searched.Index>? {
    search(searched, subrange: searched.startIndex..<searched.endIndex)
  }
  
  public func initialState(_ searched: Searched) -> State {
    ()
  }
}

// MARK: Searching from the back

public protocol BackwardCollectionSearcher: CollectionSearcher where Searched: BidirectionalCollection {
  func searchBack(
    _ searched: Searched,
    subrange: Range<Searched.Index>,
    _ state: inout State
  ) -> Range<Searched.Index>?
}

extension BackwardCollectionSearcher {
  public func searchBack(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    searchBack(searched, subrange: searched.startIndex..<searched.endIndex, &state)
  }
}

public protocol StatelessBackwardCollectionSearcher: BackwardCollectionSearcher, StatelessCollectionSearcher {
  func searchBack(_ searched: Searched, subrange: Range<Searched.Index>) -> Range<Searched.Index>?
}

extension StatelessBackwardCollectionSearcher {
  public func searchBack(
    _ searched: Searched,
    subrange: Range<Searched.Index>,
    _ state: inout State
  ) -> Range<Searched.Index>? {
    searchBack(searched, subrange: subrange)
  }
  
  public func searchBack(_ searched: Searched) -> Range<Searched.Index>? {
    searchBack(searched, subrange: searched.startIndex..<searched.endIndex)
  }
}

public protocol BidirectionalCollectionSeacher: BackwardCollectionSearcher {}

public typealias StatelessBidirectionalCollectionSearcher
  = BidirectionalCollectionSeacher & StatelessBackwardCollectionSearcher
