struct NaivePatternSearcher<Searched: Collection, Pattern: Collection>
  where Searched.Element: Equatable, Pattern.Element == Searched.Element
{
  let pattern: Pattern
}

extension NaivePatternSearcher: StatelessCollectionSearcher {
  func search(
    _ searched: Searched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    var searchStart = range.lowerBound
    
    guard let patternFirst = pattern.first else {
      return searchStart..<searchStart
    }
    
    while let matchStart = searched[searchStart..<range.upperBound]
            .firstIndex(of: patternFirst)
    {
      var index = matchStart
      var patternIndex = pattern.startIndex
      
      repeat {
        searched.formIndex(after: &index)
        pattern.formIndex(after: &patternIndex)
        
        if patternIndex == pattern.endIndex {
          return matchStart..<index
        } else if index == range.upperBound {
          return nil
        }
      } while searched[index] == pattern[patternIndex]
      
      searchStart = searched.index(after: matchStart)
    }
    
    return nil
  }
}

extension NaivePatternSearcher: BackwardCollectionSearcher,
                                StatelessBackwardCollectionSearcher
  where Searched: BidirectionalCollection, Pattern: BidirectionalCollection
{
  typealias BackwardSearched = Searched
  
  func searchBack(
    _ searched: BackwardSearched,
    in range: Range<Searched.Index>
  ) -> Range<Searched.Index>? {
    var searchEnd = range.upperBound

    guard let otherLastIndex = pattern.indices.last else {
      return searchEnd..<searchEnd
    }
    
    let patternLast = pattern[otherLastIndex]
    
    while let matchEnd = searched[range.lowerBound..<searchEnd]
            .lastIndex(of: patternLast)
    {
      var index = matchEnd
      var otherIndex = otherLastIndex
      
      repeat {
        if otherIndex == pattern.startIndex {
          return index..<searched.index(after: matchEnd)
        } else if index == range.lowerBound {
          return nil
        }
        
        searched.formIndex(before: &index)
        pattern.formIndex(before: &otherIndex)
      } while searched[index] == pattern[otherIndex]
      
      searchEnd = matchEnd
    }
    
    return nil
  }
}
