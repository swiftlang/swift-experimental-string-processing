struct PredicateSearcher<Searched: Collection> {
  let predicate: (Searched.Element) -> Bool
}

extension PredicateSearcher: StatelessCollectionSearcher {
  func search(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    guard let index = searched[range].firstIndex(where: predicate) else {
      return nil
    }
    return index..<searched.index(after: index)
  }
}

extension PredicateSearcher: BackwardCollectionSearcher,
                             StatelessBackwardCollectionSearcher
  where Searched: BidirectionalCollection
{
  typealias BackwardSearched = Searched
  
  func searchBack(
    _ searched: BackwardSearched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    guard let index = searched[range].lastIndex(where: predicate) else {
      return nil
    }
    return index..<searched.index(after: index)
  }
}

extension PredicateSearcher: BidirectionalCollectionSearcher
  where Searched: BidirectionalCollection {}
