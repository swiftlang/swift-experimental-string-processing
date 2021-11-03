struct PredicateSearcher<Searched: Collection> where Searched.SubSequence == Searched {
  let predicate: (Searched.Element) -> Bool
}

extension PredicateSearcher: StatelessCollectionSearcher {
  func search(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>? {
    guard let index = searched[index...].firstIndex(where: predicate) else { return nil }
    return index..<searched.index(after: index)
  }
}

//extension PredicateSearcher: BackwardCollectionSearcher, StatelessBackwardCollectionSearcher
//  where Searched: BidirectionalCollection
//{
//  func searchBack(_ searched: Searched, subrange: Range<Searched.Index>) -> Range<Searched.Index>? {
//    guard let index = searched[subrange].lastIndex(where: predicate) else { return nil }
//    return index..<searched.index(after: index)
//  }
//}
//
//extension PredicateSearcher: BidirectionalCollectionSeacher where Searched: BidirectionalCollection {}
