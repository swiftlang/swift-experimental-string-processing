extension RangeReplaceableCollection {
  public func replacing<Searcher: CollectionSearcher, Replacement: Collection>(
    _ searcher: Searcher,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Searcher.Searched == SubSequence, Replacement.Element == Element {
    precondition(maxReplacements >= 0)
    
    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])
    
    for range in self[subrange].ranges(of: searcher).prefix(maxReplacements) {
      result.append(contentsOf: self[index..<range.lowerBound])
      result.append(contentsOf: replacement)
      index = range.upperBound
    }
    
    result.append(contentsOf: self[index...])
    return result
  }
  
  public func replacing<Searcher: CollectionSearcher, Replacement: Collection>(
    _ searcher: Searcher,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Searcher.Searched == SubSequence, Replacement.Element == Element {
    replacing(
      searcher,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<Searcher: CollectionSearcher, Replacement: Collection>(
    _ searcher: Searcher,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Searcher.Searched == SubSequence, Replacement.Element == Element {
    self = replacing(
      searcher,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}

// MARK: Regex

extension RangeReplaceableCollection where SubSequence == Substring {
  public func replacing<Replacement: Collection>(
    _ regex: Regex,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      RegexConsumer(regex),
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements)
  }
  
  public func replacing<Replacement: Collection>(
    _ regex: Regex,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Replacement.Element == Element {
    replacing(
      regex,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
  
  public mutating func replace<Replacement: Collection>(
    _ regex: Regex,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Replacement.Element == Element {
    self = replacing(
      regex,
      with: replacement,
      maxReplacements: maxReplacements)
  }
}
