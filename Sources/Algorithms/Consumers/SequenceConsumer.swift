struct SequenceConsumer<Consumed: Collection, Pattern: Collection>
  where Pattern.Element == Consumed.Element, Consumed.Element: Equatable
{
  let pattern: Pattern
}

extension SequenceConsumer: CollectionConsumer {
  func consume(_ consumed: Consumed, subrange: Range<Consumed.Index>) -> Consumed.Index? {
    var index = subrange.lowerBound
    var patternIndex = pattern.startIndex
    
    while true {
      if patternIndex == pattern.endIndex {
        return index
      }
      
      if index == subrange.upperBound || consumed[index] != pattern[patternIndex] {
        return nil
      }
      
      consumed.formIndex(after: &index)
      pattern.formIndex(after: &patternIndex)
    }
  }
}

extension SequenceConsumer: BackwardCollectionConsumer
  where Consumed: BidirectionalCollection, Pattern: BidirectionalCollection
{
  func consumeBack(_ consumed: Consumed, subrange: Range<Consumed.Index>) -> Consumed.Index? {
    var index = subrange.upperBound
    var patternIndex = pattern.endIndex
    
    while true {
      if patternIndex == pattern.startIndex {
        return index
      }
      
      if index == subrange.lowerBound {
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
