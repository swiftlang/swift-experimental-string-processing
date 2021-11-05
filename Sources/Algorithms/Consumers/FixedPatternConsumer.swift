struct FixedPatternConsumer<Consumed: Collection, Pattern: Collection>
  where Consumed.Element: Equatable,
    Consumed.SubSequence == Consumed,
    Pattern.Element == Consumed.Element
{
  let pattern: Pattern
}

extension FixedPatternConsumer: CollectionConsumer {
  func consuming(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index? {
    var index = index
    var patternIndex = pattern.startIndex
    
    while true {
      if patternIndex == pattern.endIndex {
        return index
      }
      
      if index == consumed.endIndex || consumed[index] != pattern[patternIndex] {
        return nil
      }
      
      consumed.formIndex(after: &index)
      pattern.formIndex(after: &patternIndex)
    }
  }
}

extension FixedPatternConsumer: BackwardCollectionConsumer
  where Consumed: BidirectionalCollection, Pattern: BidirectionalCollection
{
  func consumingBack(_ consumed: Consumed, from index: Consumed.Index) -> Consumed.Index? {
    var index = index
    var patternIndex = pattern.endIndex
    
    while true {
      if patternIndex == pattern.startIndex {
        return index
      }
      
      if index == consumed.startIndex {
        return nil
      }
      
      consumed.formIndex(before: &index)
      pattern.formIndex(before: &patternIndex)
      
      if consumed[index] != pattern[patternIndex] {
        return nil
      }
    }
  }
}
