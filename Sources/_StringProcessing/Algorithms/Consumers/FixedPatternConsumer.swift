struct FixedPatternConsumer<Consumed: Collection, Pattern: Collection>
  where Consumed.Element: Equatable, Pattern.Element == Consumed.Element
{
  let pattern: Pattern
}

extension FixedPatternConsumer: CollectionConsumer {
  func consuming(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index? {
    var index = range.lowerBound
    var patternIndex = pattern.startIndex
    
    while true {
      if patternIndex == pattern.endIndex {
        return index
      }
      
      if index == range.upperBound || consumed[index] != pattern[patternIndex] {
        return nil
      }
      
      consumed.formIndex(after: &index)
      pattern.formIndex(after: &patternIndex)
    }
  }
}

extension FixedPatternConsumer: BidirectionalCollectionConsumer
  where Consumed: BidirectionalCollection, Pattern: BidirectionalCollection
{
  func consumingBack(
    _ consumed: Consumed,
    in range: Range<Consumed.Index>
  ) -> Consumed.Index? {
    var index = range.upperBound
    var patternIndex = pattern.endIndex
    
    while true {
      if patternIndex == pattern.startIndex {
        return index
      }
      
      if index == range.lowerBound {
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
