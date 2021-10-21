extension RangeReplaceableCollection {
  public func replacing<Searcher: CollectionSearcher, Replacement: Collection>(
    _ searcher: Searcher,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Searcher.Searched == SubSequence, Replacement.Element == Element {
    // TODO: `Searcher.Searched == Self`?
    
    precondition(maxReplacements >= 0)
    
    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])
    
    for range in self[subrange].ranges(searcher).prefix(maxReplacements) {
      result.append(contentsOf: self[index..<range.lowerBound])
      result.append(contentsOf: replacement)
      index = range.upperBound
    }
    
    result.append(contentsOf: self[index...])
    return result
  }
  
  @inlinable
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
}

extension RangeReplaceableCollection {
  @inlinable
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
