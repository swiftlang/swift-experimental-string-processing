struct NaivePatternSearcher<Searched: Collection, Pattern: Collection>
  where Searched.Element: Equatable, Searched.SubSequence == Searched, Pattern.Element == Searched.Element
{
  let pattern: Pattern
}

extension NaivePatternSearcher: StatelessCollectionSearcher {
  func search(_ searched: Searched, from index: Searched.Index) -> Range<Searched.Index>? {
    var searchStart = index
    
    guard let patternFirst = pattern.first else {
      return searchStart..<searchStart
    }
    
    while let matchStart = searched[searchStart...]
            .firstIndex(of: patternFirst)
    {
      var index = matchStart
      var patternIndex = pattern.startIndex
      
      repeat {
        searched.formIndex(after: &index)
        pattern.formIndex(after: &patternIndex)
        
        if patternIndex == pattern.endIndex {
          return matchStart..<index
        } else if index == searched.endIndex {
          return nil
        }
      } while searched[index] == pattern[patternIndex]
      
      searchStart = searched.index(after: matchStart)
    }
    
    return nil
  }
}

//extension NaivePatternSearcher: BackwardCollectionSearcher, StatelessBackwardCollectionSearcher
//  where Searched: BidirectionalCollection, Pattern: BidirectionalCollection
//{
//  func searchBack(_ searched: Searched, subrange: Range<Searched.Index>) -> Range<Searched.Index>? {
//    var searchEnd = subrange.upperBound
//
//    guard let otherLastIndex = pattern.indices.last else {
//      return searchEnd..<searchEnd
//    }
//    
//    let patternLast = pattern[otherLastIndex]
//    
//    while let matchEnd = searched[subrange.lowerBound..<searchEnd]
//            .lastIndex(of: patternLast)
//    {
//      var index = matchEnd
//      var otherIndex = otherLastIndex
//      
//      repeat {
//        if otherIndex == pattern.startIndex {
//          return index..<searched.index(after: matchEnd)
//        } else if index == subrange.lowerBound {
//          return nil
//        }
//        
//        searched.formIndex(before: &index)
//        pattern.formIndex(before: &otherIndex)
//      } while searched[index] == pattern[otherIndex]
//      
//      searchEnd = matchEnd
//    }
//    
//    return nil
//  }
//}
