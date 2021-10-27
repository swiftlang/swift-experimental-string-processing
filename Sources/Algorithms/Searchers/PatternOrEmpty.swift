/// Wraps a searcher that searches for a given pattern. If the pattern is empty, falls back on matching every empty index range exactly once.
public struct PatternOrEmpty<Searcher: CollectionSearcher> {
  let searcher: Searcher?
}

extension PatternOrEmpty: CollectionSearcher {
  public typealias Searched = Searcher.Searched
  
  public struct State {
    enum Representation {
      case state(Searcher.State)
      case empty(Searched.Index?)
    }
    
    let representation: Representation
  }
  
  public func state(for searched: Searcher.Searched) -> State {
    if let searcher = searcher {
      return State(representation: .state(searcher.state(for: searched)))
    } else {
      return State(representation: .empty(searched.startIndex))
    }
  }
  
  public func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    switch state.representation {
    case .state(var s):
      // TODO: Avoid a potential copy-on-write copy here
      let result = searcher!.search(searched, &s)
      state = State(representation: .state(s))
      return result
    case .empty(let index):
      guard let index = index else { return nil }
      let next = index == searched.endIndex
        ? nil
        : searched.index(after: index)
      state = State(representation: .empty(next))
      return index..<index
    }
  }
}
